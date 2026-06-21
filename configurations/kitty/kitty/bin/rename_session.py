#!/usr/bin/env python3
"""Rename the active kitty session (WezTerm workspace rename equivalent)."""

from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

SESSION_SUFFIXES = (".kitty-session", ".kitty_session", ".session")


def session_dir() -> Path:
    data_home = os.environ.get("XDG_DATA_HOME")
    base = Path(data_home) if data_home else Path.home() / ".local" / "share"
    return base / "kitty" / "sessions"


def run(cmd: list[str], *, input_text: str | None = None, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        cmd,
        input=input_text,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        check=check,
    )


def close_launcher() -> None:
    window_id = os.environ.get("KITTY_WINDOW_ID")
    if window_id:
        run(["kitty", "@", "close-window", "--match", f"id:{window_id}"], check=False)


def ask_line(message: str) -> str | None:
    try:
        result = run(
            ["kitten", "ask", "--type=line", "--message", message, "--name", "kitty-rename-session"],
            check=False,
        )
    except FileNotFoundError:
        print("rename_session: kitten ask is required", file=sys.stderr)
        return None
    if result.returncode != 0:
        return None
    value = result.stdout.strip()
    return value or None


def current_session_file() -> Path | None:
    try:
        result = run(["kitty", "@", "ls", "--self", "--output-format=json"])
        data = json.loads(result.stdout)
    except (FileNotFoundError, subprocess.CalledProcessError, json.JSONDecodeError):
        return None

    candidates: list[str] = []

    def collect(obj: object) -> None:
        if isinstance(obj, dict):
            for key in ("session_name", "active_session_name", "session"):
                value = obj.get(key)
                if isinstance(value, str) and value.strip():
                    candidates.append(value.strip())
            for value in obj.values():
                collect(value)
        elif isinstance(obj, list):
            for item in obj:
                collect(item)

    collect(data)
    for candidate in candidates:
        path = Path(candidate).expanduser()
        if path.is_file():
            return path.resolve()
        for suffix in SESSION_SUFFIXES:
            resolved = session_dir() / f"{Path(candidate).stem}{suffix}"
            if resolved.is_file():
                return resolved.resolve()
    return None


def rename_tab_title(title: str) -> None:
    run(["kitty", "@", "set-tab-title", title], check=False)


def main() -> int:
    session_file = current_session_file()
    current_name = session_file.stem if session_file else "current tab"

    new_name = ask_line(f"Enter new workspace/session name (current: {current_name})")
    if not new_name:
        close_launcher()
        return 0

    new_name = new_name.strip()
    if not new_name:
        close_launcher()
        return 1

    if session_file is None:
        rename_tab_title(new_name)
        close_launcher()
        return 0

    target = session_dir() / f"{new_name}.kitty-session"
    session_dir().mkdir(parents=True, exist_ok=True)
    if target.exists() and target.resolve() != session_file.resolve():
        print(f"rename_session: session already exists: {target}", file=sys.stderr)
        close_launcher()
        return 1

    session_file.rename(target)
    rename_tab_title(new_name)
    close_launcher()
    return 0


if __name__ == "__main__":
    sys.exit(main())
