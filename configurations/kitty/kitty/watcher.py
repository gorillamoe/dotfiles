"""Kitty window watchers."""

from __future__ import annotations

from pathlib import Path

DEFAULT_TITLE = "default"
GENERIC_TITLES = frozenset(("", "Terminal", "kitty", "Kitty"))
SESSION_SUFFIXES = (".kitty-session", ".kitty_session", ".session")

_save_timer_id: int | None = None
_periodic_timer_id: int | None = None
AUTOSAVE_INTERVAL_S = 10.0
LAYOUT_SAVE_DELAY_S = 1.5


def on_title_change(_, window, data) -> None:
    if window.override_title is not None:
        return
    if not data.get("from_child"):
        return
    if data.get("title") in GENERIC_TITLES:
        window.set_title(DEFAULT_TITLE)


def _session_dir() -> Path:
    import os

    data_home = os.environ.get("XDG_DATA_HOME")
    base = Path(data_home) if data_home else Path.home() / ".local" / "share"
    return base / "kitty" / "sessions"


def _session_path(session_name: str) -> str | None:
    import os

    from kitty.session import seen_session_paths

    path = seen_session_paths.get(session_name)
    if path and not os.path.isfile(path):
        del seen_session_paths[session_name]
        path = None
    if path:
        return path

    directory = _session_dir()
    for suffix in SESSION_SUFFIXES:
        candidate = directory / f"{session_name}{suffix}"
        if candidate.is_file():
            path = str(candidate)
            seen_session_paths[session_name] = path
            return path
    return None


def _session_names_for_window(boss, window) -> set[str]:
    names: set[str] = set()
    if window.created_in_session_name:
        names.add(window.created_in_session_name)
    tab = window.tabref()
    if tab is not None and tab.created_in_session_name:
        names.add(tab.created_in_session_name)
    if boss.active_session:
        names.add(boss.active_session)
    return names


def _save_session(boss, session_name: str) -> None:
    from kitty.session import parse_save_as_options_spec_args, save_as_session_part2

    path = _session_path(session_name)
    if not path:
        return
    opts, _ = parse_save_as_options_spec_args(["--save-only", f"--match=session:{session_name}"])
    save_as_session_part2(boss, opts, path)


def save_loaded_sessions(boss) -> None:
    seen: set[str] = set()
    for name in boss.all_loaded_session_names:
        if name in seen:
            continue
        seen.add(name)
        _save_session(boss, name)


def _cancel_debounced_save() -> None:
    global _save_timer_id
    if _save_timer_id is None:
        return
    from kitty.fast_data_types import remove_timer

    remove_timer(_save_timer_id)
    _save_timer_id = None


def schedule_session_save(boss) -> None:
    global _save_timer_id
    from kitty.fast_data_types import add_timer, remove_timer

    if _save_timer_id is not None:
        remove_timer(_save_timer_id)

    def save() -> None:
        global _save_timer_id
        _save_timer_id = None
        save_loaded_sessions(boss)

    _save_timer_id = add_timer(save, LAYOUT_SAVE_DELAY_S, False)


def on_load(boss, data) -> None:
    global _periodic_timer_id
    from kitty.fast_data_types import add_timer

    def autosave() -> None:
        if boss.all_loaded_session_names:
            save_loaded_sessions(boss)

    _periodic_timer_id = add_timer(autosave, AUTOSAVE_INTERVAL_S, True)


def on_close(boss, window, data) -> None:
    names = _session_names_for_window(boss, window)
    if not names:
        return

    for name in names:
        siblings = [
            other
            for other in boss.all_windows
            if other is not window and other.created_in_session_name == name
        ]
        if siblings:
            _cancel_debounced_save()
            _save_session(boss, name)


def on_resize(boss, window, data) -> None:
    old = data.get("old_geometry")
    if old is not None and old.xnum == 0 and old.ynum == 0:
        return
    if _session_names_for_window(boss, window):
        schedule_session_save(boss)


def on_quit(boss, window, data) -> None:
    _cancel_debounced_save()
    save_loaded_sessions(boss)


def on_tab_bar_dirty(boss, window, data) -> None:
    if boss.active_session:
        schedule_session_save(boss)
