"""Kitty kitten: update in-memory session names after a session file rename."""

import os
from contextlib import suppress

from kittens.tui.handler import result_handler


def main():
    return None


def rename_session_in_memory(boss, old_name: str, session_path: str) -> bool:
    from kitty.session import (
        append_to_session_history,
        goto_session_history,
        seen_session_paths,
        session_arg_to_name,
    )

    path = os.path.abspath(os.path.expanduser(session_path))
    new_name = session_arg_to_name(path)
    if not old_name or not new_name or old_name == new_name:
        return False

    changed = False
    for window in boss.all_windows:
        if window.created_in_session_name == old_name:
            window.created_in_session_name = new_name
            changed = True

    for tab in boss.all_tabs:
        if tab.created_in_session_name == old_name:
            tab.created_in_session_name = new_name
            changed = True

    for tab_manager in boss.all_tab_managers:
        if tab_manager.created_in_session_name == old_name:
            tab_manager.created_in_session_name = new_name
            changed = True

    seen_session_paths.pop(old_name, None)
    seen_session_paths[new_name] = path

    if old_name in goto_session_history:
        with suppress(ValueError):
            goto_session_history.remove(old_name)
        append_to_session_history(new_name)

    boss.refresh_active_tab_bar()
    return changed


@result_handler(no_ui=True)
def handle_result(args, _, __, boss):
    if len(args) < 3:
        return False
    return rename_session_in_memory(boss, args[1], args[2])
