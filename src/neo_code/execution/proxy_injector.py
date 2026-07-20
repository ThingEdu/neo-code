"""
proxy_injector — writes student code to a runnable temp file.

Pure Python, no Qt dependency. (Historically this prepended a sys.path shim for
a `turtle` proxy that no longer exists; that preamble offset every traceback
line number by 2 and has been removed — student line numbers now match.)
"""

import tempfile
from pathlib import Path


def prepare_script(code: str) -> Path:
    """Write student code to a temp .py file and return its path."""
    tmp = tempfile.NamedTemporaryFile(
        mode="w", suffix=".py", delete=False, encoding="utf-8"
    )
    tmp.write(code)
    tmp.flush()
    tmp.close()
    return Path(tmp.name)
