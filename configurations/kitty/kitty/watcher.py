"""Kitty window watchers."""

from __future__ import annotations

from pathlib import Path

DEFAULT_TITLE = "default"
GENERIC_TITLES = frozenset(("", "Terminal", "kitty", "Kitty"))
SESSION_SUFFIXES = (".kitty-session", ".kitty_session", ".session")
WORKSPACE_SWITCHER = Path.home() / ".config/kitty/bin/workspace_switcher.py"

_save_timer_id: int | None = None
_quitting: bool = False
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


def _session_names_for_window(_, window) -> set[str]:
    names: set[str] = set()
    if window.created_in_session_name:
        names.add(window.created_in_session_name)
    tab = window.tabref()
    if tab is not None and tab.created_in_session_name:
        names.add(tab.created_in_session_name)
    return names


def _windows_in_session(boss, session_name: str, *, exclude=None) -> list:
    return [
        other
        for other in boss.all_windows
        if other is not exclude and other.created_in_session_name == session_name
    ]


def _delete_session_files(session_name: str) -> None:
    from kitty.session import seen_session_paths

    seen_session_paths.pop(session_name, None)
    for suffix in SESSION_SUFFIXES:
        path = _session_dir() / f"{session_name}{suffix}"
        if path.is_file():
            path.unlink(missing_ok=True)


def _open_workspace_switcher(boss, *, exclude=None) -> None:
    script = str(WORKSPACE_SWITCHER)
    if not WORKSPACE_SWITCHER.is_file():
        return
    other_windows = [w for w in boss.all_windows if w is not exclude]
    if other_windows:
        boss.launch("--type=overlay", "--allow-remote-control", "python3", script)
    else:
        boss.launch("--type=os_window", "--allow-remote-control", "python3", script)


def _save_session(boss, session_name: str) -> None:
    from kitty.session import parse_save_as_options_spec_args, save_as_session_part2

    path = _session_path(session_name)
    if not path:
        return
    opts, _ = parse_save_as_options_spec_args(
        ["--save-only", f"--match=session:{session_name}"]
    )
    session_lines = list(boss.serialize_state_as_session(path, opts))
    if not any(line.strip() for line in session_lines):
        return
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


def _kitty_is_quitting(boss) -> bool:
    return _quitting or boss.shutting_down


def on_close(boss, window, data) -> None:
    if _kitty_is_quitting(boss):
        # on_quit already saved every session while windows were still alive;
        # saving again here would serialize closing windows and wipe session files.
        return

    session_name = window.created_in_session_name
    if not session_name:
        return

    siblings = _windows_in_session(boss, session_name, exclude=window)
    if siblings:
        _cancel_debounced_save()
        _save_session(boss, session_name)
        return

    if not _session_path(session_name):
        return

    _cancel_debounced_save()
    _delete_session_files(session_name)
    _open_workspace_switcher(boss, exclude=window)


def on_resize(boss, window, data) -> None:
    old = data.get("old_geometry")
    if old is not None and old.xnum == 0 and old.ynum == 0:
        return
    if _session_names_for_window(boss, window):
        schedule_session_save(boss)


def on_quit(boss, _, data) -> None:
    global _quitting
    _cancel_debounced_save()
    if data.get("confirmed"):
        _quitting = True
        save_loaded_sessions(boss)
    else:
        _quitting = False


def on_tab_bar_dirty(boss, window, data) -> None:
    if boss.active_session:
        schedule_session_save(boss)
