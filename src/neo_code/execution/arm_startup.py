"""
PYTHONSTARTUP file for Chơi-mode REPL sessions.

`python -i` cannot also take `-m`, so the script path's play_bootstrap trick
doesn't work for the REPL. PYTHONSTARTUP is the hook built for exactly this:
the interpreter executes this file before the first prompt, so `arm` is simply
there when the kid starts typing.

Set by ui/controllers/repl_controller.py; never imported directly.
"""

from neo_code.features.arm.student_api import StudentArmAPI as _StudentArmAPI

arm = _StudentArmAPI()

del _StudentArmAPI
