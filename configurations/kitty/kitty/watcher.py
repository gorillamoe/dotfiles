"""Kitty window watchers."""

from __future__ import annotations

DEFAULT_TITLE = "default"
GENERIC_TITLES = frozenset(("", "Terminal", "kitty", "Kitty"))


def on_title_change(_, window, data) -> None:
    if window.override_title is not None:
        return
    if not data.get("from_child"):
        return
    if data.get("title") in GENERIC_TITLES:
        window.set_title(DEFAULT_TITLE)
