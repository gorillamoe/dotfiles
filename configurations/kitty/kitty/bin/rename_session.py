#!/usr/bin/env python3
"""Rename the active kitty session (WezTerm workspace rename equivalent)."""

from __future__ import annotations

import base64
import json
import os
import re
import subprocess
import sys
from pathlib import Path, PurePath

SESSION_SUFFIXES = (".kitty-session", ".kitty_session", ".session")
KITTEN_ASK_RESULT_RE = re.compile(r"\x1bP@kitty-kitten-result\|([^\x1b]+)\x1b\\")


def session_dir() -> Path:
    data_home = os.environ.get("XDG_DATA_HOME")
    base = Path(data_home) if data_home else Path.home() / ".local" / "share"
    return base / "kitty" / "sessions"


def run(
    cmd: list[str], *, input_text: str | None = None, check: bool = True
) -> subprocess.CompletedProcess[str]:
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


def format_session_name(name: str) -> str:
    base = PurePath(name).name
    for suffix in SESSION_SUFFIXES:
        if base.endswith(suffix):
            return base[: -len(suffix)]
    return PurePath(base).stem if "." in base else base


def parse_kitten_ask_output(stdout: str) -> str | None:
    """Decode kitten ask output; subprocess mode returns a DCS payload, not plain text."""
    text = stdout.strip()
    if not text:
        return None
    match = KITTEN_ASK_RESULT_RE.search(text)
    if not match:
        return text
    try:
        data = json.loads(base64.b85decode(match.group(1)))
    except (ValueError, json.JSONDecodeError):
        return None
    response = data.get("response")
    if not isinstance(response, str):
        return None
    value = response.strip()
    return value or None


def ask_line(message: str) -> str | None:
    try:
        result = run(
            [
                "kitten",
                "ask",
                "--type=line",
                "--message",
                message,
                "--name",
                "kitty-rename-session",
            ],
            check=False,
        )
    except FileNotFoundError:
        print("rename_session: kitten ask is required", file=sys.stderr)
        return None
    if result.returncode != 0:
        return None
    return parse_kitten_ask_output(result.stdout)


def active_session_internal_name() -> str | None:
    try:
        result = run(["kitty", "@", "ls", "--self", "--output-format=json"])
        data = json.loads(result.stdout)
    except (FileNotFoundError, subprocess.CalledProcessError, json.JSONDecodeError):
        return None

    def collect(obj: object) -> str | None:
        if isinstance(obj, dict):
            value = obj.get("created_in_session_name")
            if isinstance(value, str) and value.strip():
                return value.strip()
            for child in obj.values():
                if found := collect(child):
                    return found
        elif isinstance(obj, list):
            for item in obj:
                if found := collect(item):
                    return found
        return None

    return collect(data)


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
        stem = format_session_name(candidate)
        path = Path(candidate).expanduser()
        if path.is_file():
            return path.resolve()
        for suffix in SESSION_SUFFIXES:
            resolved = session_dir() / f"{stem}{suffix}"
            if resolved.is_file():
                return resolved.resolve()
    return None


def rename_tab_title(title: str, *, old_session_name: str | None = None) -> None:
    cmd = ["kitty", "@", "set-tab-title", title]
    if old_session_name:
        cmd[2:2] = ["--match", f"session:{old_session_name}"]
    run(cmd, check=False)


def update_session_file_tab_name(session_file: Path, new_name: str) -> None:
    try:
        lines = session_file.read_text().splitlines()
    except OSError:
        return
    changed = False
    for index, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith("new_tab "):
            lines[index] = f"new_tab {new_name}"
            changed = True
            break
    if changed:
        session_file.write_text("\n".join(lines) + "\n")


def update_session_mru(old_name: str, new_name: str) -> None:
    path = session_dir() / "session-mru.json"
    if not path.is_file():
        return
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return
    if not isinstance(data, list):
        return
    names = [item for item in data if isinstance(item, str) and item.strip()]
    if old_name not in names:
        return
    names = [new_name if name == old_name else name for name in names]
    deduped: list[str] = []
    seen: set[str] = set()
    for name in names:
        if name in seen:
            continue
        seen.add(name)
        deduped.append(name)
    path.write_text(json.dumps(deduped, indent=2) + "\n", encoding="utf-8")


def commit_session_rename(old_session_name: str, session_path: Path) -> None:
    run(
        [
            "kitty",
            "@",
            "kitten",
            "rename_session_internals.py",
            old_session_name,
            str(session_path.resolve()),
            "--match",
            f"session:{old_session_name}",
        ],
        check=False,
    )


def main() -> int:
    session_file = current_session_file()
    current_name = (
        format_session_name(session_file.name) if session_file else "current tab"
    )

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

    if format_session_name(new_name) == current_name:
        close_launcher()
        return 0

    target = session_dir() / f"{new_name}.kitty-session"
    session_dir().mkdir(parents=True, exist_ok=True)
    if target.exists() and target.resolve() != session_file.resolve():
        print(f"rename_session: session already exists: {target}", file=sys.stderr)
        close_launcher()
        return 1

    old_session_name = active_session_internal_name() or current_name
    session_file.rename(target)
    update_session_file_tab_name(target, new_name)
    rename_tab_title(new_name, old_session_name=old_session_name)
    commit_session_rename(old_session_name, target)
    update_session_mru(current_name, new_name)
    close_launcher()
    return 0


if __name__ == "__main__":
    sys.exit(main())
