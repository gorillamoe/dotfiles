#!/usr/bin/env python3
"""Kitty workspace/session switcher with zoxide (WezTerm workspace-switcher equivalent)."""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
from pathlib import Path, PurePath

SESSION_SUFFIXES = (".kitty-session", ".kitty_session", ".session")
ANSI_ESCAPE_RE = re.compile(r"\x1b\[[0-9;]*m")
DELETE_KEYS = frozenset({"ctrl-x"})


def session_dir() -> Path:
    data_home = os.environ.get("XDG_DATA_HOME")
    base = Path(data_home) if data_home else Path.home() / ".local" / "share"
    return base / "kitty" / "sessions"


def template_path() -> Path:
    return Path(__file__).resolve().parent.parent / "session-template.kitty-session"


def strip_ansi(text: str) -> str:
    return ANSI_ESCAPE_RE.sub("", text)


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


def zoxide_paths() -> list[str]:
    try:
        result = run(["zoxide", "query", "-l"])
    except (FileNotFoundError, subprocess.CalledProcessError):
        return []
    return [line for line in result.stdout.splitlines() if line.strip()]


def list_session_files() -> list[Path]:
    directory = session_dir()
    if not directory.exists():
        return []
    files: list[Path] = []
    for suffix in SESSION_SUFFIXES:
        files.extend(directory.glob(f"*{suffix}"))
    return sorted({path.resolve() for path in files}, key=lambda path: session_stem(path).lower())


def active_session_names() -> set[str]:
    names: set[str] = set()
    try:
        result = run(["kitty", "@", "ls", "--output-format=json"])
        data = json.loads(result.stdout)
    except (FileNotFoundError, subprocess.CalledProcessError, json.JSONDecodeError):
        return names

    def collect(obj: object) -> None:
        if isinstance(obj, dict):
            for key in ("session_name", "active_session_name", "session"):
                value = obj.get(key)
                if isinstance(value, str) and value.strip():
                    names.add(format_session_name(value.strip()))
            for value in obj.values():
                collect(value)
        elif isinstance(obj, list):
            for item in obj:
                collect(item)

    collect(data)
    return names


def ensure_session_file(name: str, cwd: str) -> Path:
    directory = session_dir()
    directory.mkdir(parents=True, exist_ok=True)
    session_file = directory / f"{name}.kitty-session"
    if session_file.exists():
        return session_file

    template = template_path().read_text(encoding="utf-8")
    session_file.write_text(
        template.replace("@@session@@", name).replace("@@session-path@@", cwd),
        encoding="utf-8",
    )
    return session_file


def format_session_name(name: str) -> str:
    base = PurePath(name).name
    for suffix in SESSION_SUFFIXES:
        if base.endswith(suffix):
            return base[: -len(suffix)]
    return PurePath(base).stem if "." in base else base


def session_stem(path: Path) -> str:
    return format_session_name(path.name)


def session_files_for_stem(stem: str) -> list[Path]:
    directory = session_dir()
    files: list[Path] = []
    for suffix in SESSION_SUFFIXES:
        path = directory / f"{stem}{suffix}"
        if path.is_file():
            files.append(path)
    return files


def build_entries() -> list[tuple[str, Path | None, str | None]]:
    session_files = list_session_files()
    active_names = active_session_names()
    zoxide = zoxide_paths()
    known_names = {session_stem(path) for path in session_files}

    entries: list[tuple[str, Path | None, str | None]] = []
    for path in session_files:
        stem = session_stem(path)
        marker = "▶ " if stem in active_names else "  "
        entries.append((f"\x1b[32m[session]\x1b[0m {marker}{stem}", path, None))

    for path in zoxide:
        name = Path(path).name
        if name in known_names:
            continue
        entries.append((f"\x1b[34m[zoxide]\x1b[0m  {path}", None, path))

    return entries


def fzf_pick(
    lines: str,
    *,
    header: str,
    expect: str | None = None,
) -> tuple[str, str] | None:
    cmd = [
        "fzf",
        "--reverse",
        "--no-sort",
        "--ansi",
        "--delimiter=\t",
        "--with-nth=2..",
        "--accept-nth=1",
        "--prompt",
        "workspace > ",
        "--header",
        header,
        "--header-first",
    ]
    if expect:
        cmd.extend(["--expect", expect])

    try:
        result = run(cmd, input_text=lines, check=False)
    except FileNotFoundError:
        print("workspace_switcher: fzf is required", file=sys.stderr)
        return None

    if result.returncode != 0 or not result.stdout.strip():
        return None

    output_lines = result.stdout.strip().split("\n")
    if expect and output_lines[0] in DELETE_KEYS:
        return "delete", output_lines[1] if len(output_lines) > 1 else ""

    if expect and output_lines[0] in {"enter"}:
        return "goto", output_lines[1] if len(output_lines) > 1 else output_lines[0]

    return "goto", output_lines[0]


def entry_from_index(
    entries: list[tuple[str, Path | None, str | None]],
    index_text: str,
) -> tuple[Path | None, str | None] | None:
    try:
        index = int(index_text.strip())
        _, session_file, zoxide_path = entries[index]
    except (ValueError, IndexError):
        return None
    return session_file, zoxide_path


def pick_entry(
    entries: list[tuple[str, Path | None, str | None]],
) -> tuple[str, Path | None, str | None] | None:
    if not entries:
        return None

    lines = "\n".join(f"{index}\t{label}" for index, (label, _, _) in enumerate(entries))
    picked = fzf_pick(
        lines,
        header="enter: switch  |  ctrl-x : delete session",
        expect="ctrl-x,ctrl-d,delete",
    )
    if picked is None:
        return None

    action, index_text = picked
    if not index_text.strip():
        return "error", None, None

    resolved = entry_from_index(entries, index_text)
    if resolved is None:
        return "error", None, None

    session_file, zoxide_path = resolved
    return action, session_file, zoxide_path


def confirm_delete(stem: str) -> bool:
    message = (
        f"Delete kitty session '{stem}'?\n"
        "This removes the session file and closes its windows.\n"
        "The path will remain in zoxide."
    )
    picked = fzf_pick(
        "no\tNo\nyes\tYes",
        header=message,
        expect=None,
    )
    if picked is None:
        return False
    _, choice = picked
    return choice.strip().lower() == "yes"


def notify(message: str) -> None:
    run(
        [
            "fzf",
            "--reverse",
            "--no-sort",
            "--header",
            message,
            "--header-first",
            "--prompt",
            "OK > ",
        ],
        input_text="ok\tPress Enter to continue",
        check=False,
    )


def session_window_ids(stem: str) -> list[int]:
    try:
        result = run(
            ["kitty", "@", "ls", "--match", f"session:{stem}", "--output-format=json"],
            check=False,
        )
        if result.returncode != 0 or not result.stdout.strip():
            return []
        data = json.loads(result.stdout)
    except (json.JSONDecodeError, subprocess.CalledProcessError):
        return []

    ids: list[int] = []

    def collect(obj: object) -> None:
        if isinstance(obj, dict):
            if "created_in_session_name" in obj and isinstance(obj.get("id"), int):
                ids.append(obj["id"])
            for value in obj.values():
                collect(value)
        elif isinstance(obj, list):
            for item in obj:
                collect(item)

    collect(data)
    return ids


def close_session_windows(stem: str) -> None:
    launcher_id = os.environ.get("KITTY_WINDOW_ID")
    for window_id in session_window_ids(stem):
        if launcher_id and str(window_id) == launcher_id:
            continue
        run(["kitty", "@", "close-window", "--match", f"id:{window_id}"], check=False)


def remove_session_files(stem: str) -> bool:
    removed = False
    for path in session_files_for_stem(stem):
        try:
            path.unlink()
            removed = True
        except OSError as exc:
            print(f"workspace_switcher: failed to delete {path}: {exc}", file=sys.stderr)
    return removed


def delete_session(session_file: Path) -> bool:
    stem = session_stem(session_file)
    if not confirm_delete(stem):
        return False

    if not remove_session_files(stem):
        notify(f"Could not delete session file for '{stem}'.")
        return False

    close_session_windows(stem)
    return True


def goto_session(session_file: Path) -> int:
    result = run(["kitty", "@", "action", "goto_session", str(session_file)], check=False)
    run(["kitty", "@", "set-tab-title", session_stem(session_file)], check=False)
    return result.returncode


def main() -> int:
    while True:
        entries = build_entries()
        if not entries:
            print("workspace_switcher: no sessions or zoxide paths found", file=sys.stderr)
            return 1

        picked = pick_entry(entries)
        if picked is None:
            close_launcher()
            return 0

        action, session_file, zoxide_path = picked

        if action == "error":
            notify("Select an entry first, then press ctrl-x to delete.")
            continue

        if action == "delete":
            if session_file is None:
                notify("Only saved kitty sessions can be deleted (not zoxide paths).")
                continue
            delete_session(session_file)
            continue

        if session_file is None and zoxide_path is not None:
            name = Path(zoxide_path).name
            session_file = ensure_session_file(name, zoxide_path)
            run(["zoxide", "add", zoxide_path], check=False)

        assert session_file is not None
        code = goto_session(session_file)
        close_launcher()
        return code


if __name__ == "__main__":
    sys.exit(main())
