#!/usr/bin/env python3

from __future__ import annotations

import sys
from pathlib import Path
import subprocess


def _has_flag(argv: list[str], *names: str) -> bool:
    return any(a in names or any(a.startswith(n + "=") for n in names) for a in argv)


def _resolve_scene(arg: str) -> Path:
    p = Path(arg)

    # Allow passing just the example name ("foo") or file ("foo.toml").
    if p.suffix == "":
        p = p.with_suffix(".toml")

    # If caller passed only a bare filename, assume it lives under examples/.
    if not p.is_absolute() and len(p.parts) == 1:
        p = Path("examples") / p

    return p


def main(argv: list[str]) -> int:
    if not argv or argv[0] in {"-h", "--help"}:
        print(
            "Usage: scripts/run-example.py <scene> [render args...]\n"
            "\n"
            "<scene> can be:\n"
            "  - an example name (e.g. 'bump-demo')\n"
            "  - a filename (e.g. 'bump-demo.toml')\n"
            "  - a path (e.g. 'examples/bump-demo.toml')\n"
            "\n"
            "Anything after <scene> is passed through to `moon run src/render -- ...`.\n"
            "Defaults are applied if not provided: --samples 4 --divide 1\n"
            "If -o/--output is not provided, output defaults to '<scene-stem>.png'.\n",
            file=sys.stderr,
        )
        return 2

    scene_arg, passthrough = argv[0], argv[1:]

    # Avoid conflicting scene flags; this script always supplies -s.
    if _has_flag(passthrough, "-s", "--scene"):
        print("error: do not pass -s/--scene; provide <scene> as the first arg", file=sys.stderr)
        return 2

    scene_path = _resolve_scene(scene_arg)

    # Default output is based on the scene filename.
    if not _has_flag(passthrough, "-o", "--output"):
        passthrough = ["-o", f"{scene_path.stem}.png", *passthrough]

    # Common defaults used by run-all.sh (overrideable).
    if not _has_flag(passthrough, "--samples"):
        passthrough = [*passthrough, "--samples", "4"]
    if not _has_flag(passthrough, "--divide"):
        passthrough = [*passthrough, "--divide", "1"]

    cmd = [
        "moon",
        "run",
        "src/render",
        "--",
        "-s",
        scene_path.as_posix(),
        *passthrough,
    ]

    return subprocess.call(cmd)


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
