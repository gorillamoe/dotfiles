#!/usr/bin/env python3
"""Persist kitty session files (splits, tabs, layout) via remote control."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

SESSION_SUFFIXES = (".kitty-session", ".kitty_session", ".session")


def session_dir() -> Path:
    import os

    data_home = os.environ.get("XDG_DATA_HOME")
    base = Path(data_home) if data_home else Path.home() / ".local" / "share"
    return base / "kitty" / "sessions"


def session_path_for_name(name: str) -> Path | None:
    directory = session_dir()
    for suffix in SESSION_SUFFIXES:
        path = directory / f"{name}{suffix}"
        if path.is_file():
            return path
    return None


def save_session(name: str, *, path: Path | str | None = None) -> bool:
    session_path = Path(path) if path else session_path_for_name(name)
    if session_path is None or not session_path.is_file():
        return False

    result = subprocess.run(
        [
            "kitty",
            "@",
            "action",
            "save_as_session",
            "--save-only",
            f"--match=session:{name}",
            str(session_path),
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        check=False,
    )
    if result.returncode != 0 and result.stderr.strip():
        print(f"session_persist: failed to save {name}: {result.stderr.strip()}", file=sys.stderr)
    return result.returncode == 0


def save_all_loaded_sessions() -> None:
    try:
        result = subprocess.run(
            ["kitty", "@", "ls", "--output-format=json"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=False,
        )
        if result.returncode != 0:
            return
        names: set[str] = set()

        def collect(obj: object) -> None:
            if isinstance(obj, dict):
                value = obj.get("created_in_session_name")
                if isinstance(value, str) and value.strip():
                    names.add(Path(value).name if "/" in value else value.strip())
                for item in obj.values():
                    collect(item)
            elif isinstance(obj, list):
                for item in obj:
                    collect(item)

        collect(json.loads(result.stdout))
        for name in names:
            save_session(name)
    except (json.JSONDecodeError, FileNotFoundError):
        return


def save_active_session() -> bool:
    result = subprocess.run(
        [
            "kitty",
            "@",
            "action",
            "save_as_session",
            "--save-only",
            "--match=session:.",
            ".",
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        check=False,
    )
    return result.returncode == 0


if __name__ == "__main__":
    if len(sys.argv) < 2:
        raise SystemExit(save_active_session())
    raise SystemExit(0 if save_session(sys.argv[1]) else 1)
