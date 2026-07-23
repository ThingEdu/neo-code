"""
Entry point for Chơi-mode script runs: injects `arm`, then runs the student's
file untouched.

Why not just prepend an import to the script? Because a preamble shifts every
line in it, and then a traceback points at line 7 for a mistake the kid can see
on line 5. That bug is why `prepare_script` no longer prepends anything. Running
the file through runpy keeps it byte-identical, so line numbers match the editor.

Usage (from execution/runner.py):
    python -X utf8 -u -m neo_code.execution.play_bootstrap <script.py>
"""

from __future__ import annotations

import runpy
import sys
import traceback


def _report(script: str, exc: BaseException) -> None:
    """Print a traceback trimmed to the kid's own code.

    Going through runpy buries the one useful frame under runpy internals, this
    module, and student_api's validation helpers. None of that is the kid's
    program, and a six-year-old reading fifteen frames to find "line 4" is worse
    off than before. Keep only frames from their file, so the output matches
    what the other modes print for the same mistake.
    """
    if isinstance(exc, SyntaxError) and exc.filename == script:
        # A SyntaxError never ran, so it has no frames worth showing.
        sys.stderr.write(f'  File "{script}", line {exc.lineno}\n')
        if exc.text:
            sys.stderr.write(f"    {exc.text.strip()}\n")
        sys.stderr.write(f"{type(exc).__name__}: {exc.msg}\n")
        return

    frames = [f for f in traceback.extract_tb(exc.__traceback__) if f.filename == script]
    sys.stderr.write("Traceback (most recent call last):\n")
    sys.stderr.write("".join(traceback.format_list(frames)))
    sys.stderr.write("".join(traceback.format_exception_only(type(exc), exc)))


def main() -> int:
    if len(sys.argv) < 2:
        sys.stderr.write("play_bootstrap: no script given\n")
        return 2

    script = sys.argv[1]
    # The student's own argv, as if they had been run directly.
    sys.argv = sys.argv[1:]

    # Imported after argv is fixed up, and inside main() so an import failure
    # is reported by the same handler as everything else.
    from neo_code.features.arm.student_api import StudentArmAPI

    try:
        runpy.run_path(script, init_globals={"arm": StudentArmAPI()}, run_name="__main__")
    except SystemExit as exc:  # the kid called exit(); honour it quietly
        return int(exc.code or 0)
    except KeyboardInterrupt:
        return 130
    except BaseException as exc:  # noqa: BLE001 — this is the top-level handler
        _report(script, exc)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
