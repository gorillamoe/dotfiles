"""Custom kitty tab bar: single workspace label before tabs."""

from __future__ import annotations

from pathlib import PurePath

from kitty.fast_data_types import Screen, get_boss
from kitty.session import most_recent_session
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    TabBarData,
    as_rgb,
    draw_tab_with_powerline,
    powerline_symbols,
)
from kitty.utils import color_as_int

SESSION_SUFFIXES = (".kitty-session", ".kitty_session", ".session")


def format_session_name(name: str) -> str:
    if not name:
        return ""
    base = PurePath(name).name
    for suffix in SESSION_SUFFIXES:
        if base.endswith(suffix):
            return base[: -len(suffix)]
    return PurePath(base).stem if "." in base else base


def workspace_name(tab: TabBarData) -> str:
    boss = get_boss()

    candidates = (
        boss.active_session,
        tab.active_session_name,
        tab.session_name,
        most_recent_session(),
    )
    active_tab = boss.active_tab
    if active_tab is not None:
        candidates = (*candidates, active_tab.created_in_session_name)

    for name in candidates:
        label = format_session_name(name)
        if label:
            return f" {label}"
    return ""


def draw_session_badge(
    draw_data: DrawData,
    screen: Screen,
    label: str,
    next_tab_bg: int,
) -> None:
    separator_symbol, _ = powerline_symbols.get(draw_data.powerline_style, ("", ""))

    badge_bg = as_rgb(color_as_int(draw_data.active_bg))
    badge_fg = as_rgb(color_as_int(draw_data.active_fg))

    screen.cursor.bg = badge_bg
    screen.cursor.fg = badge_fg
    screen.cursor.bold = True
    screen.draw(f" {label} ")
    screen.cursor.bold = False

    screen.draw(" ")
    screen.cursor.fg = badge_bg
    screen.cursor.bg = as_rgb(next_tab_bg)
    screen.draw(separator_symbol)


def draw_data_for_tab(draw_data: DrawData, tab: TabBarData) -> DrawData:
    if not tab.is_active:
        return draw_data
    return draw_data._replace(
        active_fg=draw_data.active_bg,
        active_bg=draw_data.active_fg,
    )


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_tab_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    if screen.cursor.x == 0:
        label = workspace_name(tab)
        if label:
            draw_session_badge(draw_data, screen, label, draw_data_for_tab(draw_data, tab).tab_bg(tab))

    return draw_tab_with_powerline(
        draw_data_for_tab(draw_data, tab),
        screen,
        tab,
        before,
        max_tab_length,
        index,
        is_last,
        extra_data,
    )
