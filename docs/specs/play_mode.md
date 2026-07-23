---
title: Chơi (Play) mode — open-arm
status: implemented
last_updated: 2026-07-23
---

> **Implemented.** Two things changed while building it, both recorded in place
> below: the backend layer came out much thinner than a port of neo-robot's
> classes (§2), and `play_bootstrap` grew traceback trimming it did not plan for
> (§4). Verified on Debian bookworm / Qt 6.4.2 — see §9.

# Chơi (Play) mode — open-arm sandbox

Third mode alongside Sáng tạo and Học. Students drive a 3-joint robotic arm
(ThingBot, over `thingbot-telemetrix`) by writing Python in the editor.

**Free exploration, not a lesson.** There is no goal, no hints, no expected
output and no pass/fail. The panel's job is to tell the kid *what the arm can
do* — a live API reference — and then get out of the way. Nothing gates
anything; whatever they type, they can run.

Ported concepts come from `/data/projects/neo-robot` (Textual TUI, same arm,
same student API). The hardware/mock/API layers are lifted almost verbatim; the
execution model is *not* — neo-robot `exec()`s student code in-process, NEO Code
runs it in a `QProcess`, which forces the proxy design in §4.

## 1. Layout

Structurally mirrors Học, with the Expected pane swapped for arm telemetry:

```
┌──────────────────────────────────────────────────────────────┐
│ ToolBar   ← │ new open save │ ▶ ■ │              ⚙          │
├──────────────┬───────────────────────────┬───────────────────┤
│ ArmPanel     │ EditorPanel               │ ArmStatusPane     │
│              │                           │  xoay    90° ▓▓░░ │
│ 🤖 Đã kết nối│  arm.turn_left(30)        │  nâng    90° ▓▓░░ │
│              │  arm.grab()               │  kẹp    đang mở   │
│ Điều khiển…  │                           ├───────────────────┤
│              │                           │ ResultConsole     │
│ 🧩 API       │                           │  (stdout/stderr)  │
│  turn_left() │                           │                   │
│  grab()  …   │                           │                   │
└──────────────┴───────────────────────────┴───────────────────┘
   SplitView, same handles/margins as LearnView
```

- **ArmPanel** (left) — connection chip, a two-line instruction, then the API
  reference. Same card frame, header bar and collapse behaviour as
  `LessonSidebar`.
- **EditorPanel** (centre) — its own instance, like Học's, so Play code never
  bleeds into Sáng tạo or a lesson attempt.
- **Right column** — vertical `SplitView`, exactly `LessonConsole`'s mechanic:
  top = **ArmStatusPane** (joint angles / gripper), bottom = the result console.

### 1.1 REPL layout

Play supports the REPL, and unlike Sáng tạo the side panel **stays visible** —
the API reference is exactly what a kid needs while typing one-liners:

```
├──────────────┬───────────────────────────┬───────────────────┤
│ ArmPanel     │ ReplPanel                 │ ArmStatusPane     │
│              │  >>> arm.turn_left(30)    │  xoay    60° ▓░░░ │
│ 🧩 API       │  >>> arm.grab()           │  nâng    90° ▓▓░░ │
│  turn_left() │  >>>                      │  kẹp    đang kẹp  │
└──────────────┴───────────────────────────┴───────────────────┘
```

`ArmStatusPane` stays too — typing a command and watching the gauge move *is*
the feedback loop here, which is why it earns the space the result console gives
up (the REPL prints its own output). So Play's REPL swap is narrower than
`CreateView`'s full-area takeover: only the centre and right columns change.

`ToolBar` already hides the REPL toggle only for `learnMode`, so Play gets the
button for free. But `MainWindow.replActive` is global — carrying an active REPL
across a mode switch would leave a live namespace bound to a mode that no longer
exists. **Rule: changing mode always stops the REPL.** Simple, and §4.1 needs it
anyway.

### 1.2 Extract `ResultConsole.qml` first

`LessonConsole.qml`'s bottom pane (lines 86–157) and `TerminalPanel.qml` are
already near-duplicates; Play would make it three. Extract
`components/common/ResultConsole.qml` — header bar + `ConsoleView` + `signalBus`
wiring + the none/running/success/fail border state — and have `LessonConsole`
and the new `PlayConsole` compose it. This is a prerequisite refactor, not part
of the feature, and it should land on its own so its diff stays readable.

Result: `PlayConsole.qml` ≈ 20 lines — `SplitView { ArmStatusPane; ResultConsole }`.

### 1.3 `ApiReference.qml`

`CodeBlockPalette` is a `Flow` of bare pill chips — no room for a description,
so it is the wrong component here. `ApiReference` is a list of rows instead:

```
Nhấn để chèn
┌─────────────────────────────────────┐
│ arm.turn_left(30)                   │  ← mono, syntax-colored
│ Xoay cánh tay sang trái 30 độ       │  ← Vietnamese, secondary
├─────────────────────────────────────┤
│ arm.grab()                          │
│ Kẹp vật lại                         │
└─────────────────────────────────────┘
```

It keeps `CodeBlockPalette`'s tap-to-insert mechanic and `kindColor` idea
(tapping inserts at the cursor; free typing still works around it), grouped
under headings — *Xoay*, *Nâng hạ*, *Kẹp*, *Thời gian*.

## 2. Files

```
features/arm/
  backends.py       MockBackend + TelemetrixBackend — one method: set_servo()
  session.py        ArmSession — owns the one connection, applies commands
  protocol.py       encode/decode of the stdout command line (§4)
  student_api.py    the `arm` object injected into student code
features/play/
  loader.py         reads resources/play/*.json (mirrors features/lessons/loader.py)
resources/play/
  open-arm.json     title, instruction, api[]  — no goal/hints/expected
execution/
  play_bootstrap.py entry module for arm-enabled runs (§4)
ui/controllers/play_controller.py
ui/qml/views/PlayView.qml
ui/qml/components/play/ArmPanel.qml
ui/qml/components/play/ApiReference.qml
ui/qml/components/play/ArmStatusPane.qml
ui/qml/components/play/PlayConsole.qml
execution/
  arm_startup.py    PYTHONSTARTUP file for arm-enabled REPL sessions (§4.1)
ui/qml/components/common/ResultConsole.qml   (§1.2, extracted)
```

Nothing from `components/curriculums/` is reused — `ChallengeCard` and
`HintPanel` carry the goal/hint framing this mode deliberately drops, and
`CodeBlockPalette` is superseded by `ApiReference` (§1.3).

**Keep the manifest honest.** `open-arm.json` describes methods that live in
`student_api.py`; if they drift, kids get docs for calls that raise
`AttributeError`. `features/play/loader.py` filters every entry against
`hasattr(StudentArmAPI, …)` — one loop, and the drift cannot reach a kid.

**Backends came out thinner than planned.** The spec called for porting
neo-robot's `Arm`/`Hand`/`RobotArm`. Once the protocol carried *absolute* angles
(§4), those classes had nothing left to do: they existed to hold joint state and
range-check relative moves, and both now live in `student_api`, where a bad move
raises where the kid can read it. What remains is `set_servo(n, angle)` and
`shutdown()`. Porting the hierarchy would have meant validating twice, in two
processes, with two copies of the Vietnamese error strings.

## 3. Connection lifecycle

`Telemetrix()` is **not safe to construct on the GUI thread**: `_find_arduino`
sleeps `arduino_wait` (4 s) then polls up to 50 × 0.2 s, opens every candidate
serial port, and `print()`s progress. Worst case ~14 s of frozen UI plus stray
stdout.

- `ArmSession` lives on a `QThread`; `PlayController` talks to it only through
  queued signals. Nothing arm-related ever blocks the event loop.
- Construction is wrapped in `contextlib.redirect_stdout` so telemetrix's
  progress prints don't leak into the app's own stdout.
- Connect **lazily** on first entry to Play mode, not at app start.
- States surfaced to QML as `PlayController.status`:
  `disconnected → connecting → connected | mock | error`.
  ArmPanel shows a chip: *Đang kết nối…* / *Đã kết nối* / *Chế độ mô phỏng*.
- On failure, or when `settings.get("arm_mock")` is set, fall back to
  `MockRobotArm` — Play mode always opens. This is what makes the feature
  buildable and screenshot-verifiable without a board.
- `shutdown()` on leaving Play mode and on `aboutToQuit`. The serial port
  register (`telemetrix_port_register.py`) means a leaked connection blocks the
  next one.

**Open question — servo numbering.** `neo_robot.hardware.robot_arm.RobotArm`
defaults to pins 9/10/11, but `neo_robot.config.settings.HardwareConfig` says
1/2/3, and `thingbot_handler.control_servo(servo_number, angle)` takes a servo
*number*, not a pin. Three answers in the source; confirm the real one against
the board before Phase 3. Store it in `settings.json` (`arm_servos: {yaw, pitch,
hand}`) rather than hardcoding.

## 4. Why the main process owns the port

Student code runs in a `QProcess`, so the obvious design is to let the
subprocess open the serial port directly (that is what neo-robot does). Two
reasons not to:

- **Connection cost.** §3's ~14 s discovery would run on *every* Run. A kid
  pressing ▶ waits a quarter-minute before the arm twitches. Connecting once on
  entering the mode makes Run instant.
- **The status pane persists between runs.** If the arm dies with the
  subprocess, the joint readout has nothing to show the moment a script ends.

So the main process holds the connection, and the subprocess proxies commands
out through stdout — reviving the pattern `output_parser` was originally built
for (the removed turtle feature).

```
QProcess (student code)
  arm.turn_left(30)
    └─ print('\x1e@@ARM {…}') ─► output_parser ─► event_bus.arm_command
                                                        │
                                                        ▼
                                   PlayController ──► ArmSession ──► board
```

**Wire format.** One line per command, prefixed with `\x1e@@ARM ` followed by
compact JSON. The `\x1e` (record separator) makes a collision with a student's
own `print` output effectively impossible. `output_parser.parse_line` checks the
prefix: match → `event_bus.arm_command.emit(payload)` and the line is *not*
forwarded to stdout; otherwise unchanged behaviour.

**Keeping student line numbers exact.** `prepare_script` must not prepend a
preamble — that was removed precisely because it offset every traceback by 2.
Instead the runner launches arm-mode scripts as:

```
python -X utf8 -u -m neo_code.execution.play_bootstrap <tmp script>
```

`play_bootstrap` injects `arm` into a `__main__` namespace and calls
`runpy.run_path(script, run_name="__main__")`. The student file stays
byte-identical, so line numbers in tracebacks match what they see in the editor.

**It also has to trim the traceback** — this was not in the original plan and
turned up on first test. Going through runpy buries the one useful frame under
runpy internals, play_bootstrap itself, and `student_api`'s validation helpers:
a one-line mistake printed fifteen frames, strictly worse than Sáng tạo prints
for the same error. `_report()` keeps only frames whose filename is the student's
script, so the output matches the other modes:

```
Traceback (most recent call last):
  File "…", line 4, in <module>
    arm.set_yaw(999)
ValueError: Góc phải nằm trong khoảng 0 đến 180
```

**Runner mode.** `event_bus.execution_requested` becomes `pyqtSignal(str, str)`
— `(code, mode)` with mode ∈ `"plain" | "arm"`. `ExecutionController.run(code,
mode="plain")`; `PlayView` passes `"arm"`. One signal, explicit at the call site.
This touches `CreateView`/`LearnView`'s Run path only through `MainWindow`.

**State mirroring.** `arm.turn_left(30)` returns immediately in the subprocess,
so the range checks (`Chỉ có thể xoay trái N độ`) need current angles locally.
`student_api` keeps its own mirror, seeded from env vars
(`NEO_ARM_YAW` / `NEO_ARM_PITCH` / `NEO_ARM_GRIP`) at launch. Sound here because
the running script is the only writer — nothing else moves the arm.

`arm.delay(s)` is a plain `time.sleep` in the subprocess; `-u` means commands
are already flushed before it blocks. The existing 30 s execution cap applies
unchanged.

### 4.1 The REPL takes the same channel

`ReplController` runs `python -X utf8 -u -i` in its own `QProcess`, so it needs
`arm` injected too — and `-i` can't take the `-m` trick above. Use the hook
built for exactly this: set **`PYTHONSTARTUP`** to `execution/arm_startup.py`
when launching an arm-mode REPL. `python -i` executes it before the first
prompt, so `arm` is simply there when the kid starts typing.

Three consequences:

- **Mode must reach the controller.** `event_bus.repl_mode_changed` becomes
  `pyqtSignal(bool, str)` — `(active, mode)`, mirroring `execution_requested`.
  Env vars are fixed at launch, so switching mode requires a restart — which
  §1.1's "changing mode stops the REPL" rule already guarantees.
- **`ReplController` must route arm lines.** It currently emits whatever chunk
  arrives from stdout; a `\x1e@@ARM …` line would be printed to the kid as
  garbage. It needs the same prefix check as `output_parser` — and, because it
  reads *chunks rather than lines*, a line buffer first (`runner.py` already has
  one worth copying; `ReplController` has none).
- **Two live namespaces.** A REPL session and a Run can both be alive at once,
  and both would mirror angles independently (§4's env-var seed). Simplest fix
  that keeps the mirror honest: **disable Run while the Play REPL is active** —
  the toolbar already knows `replActive`.

Both `-m neo_code.execution.play_bootstrap` and `PYTHONSTARTUP` require
`neo_code` to be importable by `sys.executable`. That holds for `pip install -e`
and the .deb, but not necessarily for a bare source checkout, so both launch
paths should also set `PYTHONPATH` to `neo_code`'s parent directory rather than
assuming.

## 5. Student API

Straight port of `neo_robot.engine.apis.StudentArmAPI`, with Vietnamese
docstrings. Every call becomes one proxy line.

| Call | Effect |
|------|--------|
| `arm.turn_left(deg)` / `arm.turn_right(deg)` | yaw, relative |
| `arm.set_yaw(deg)` | yaw, absolute 0–180 |
| `arm.lift_up(deg)` / `arm.lower_down(deg)` | pitch, relative |
| `arm.set_pitch(deg)` | pitch, absolute 0–180 |
| `arm.grab()` / `arm.release()` | gripper |
| `arm.delay(seconds)` | pause |

Unlike neo-robot there is **no builtins whitelist** — the subprocess already
provides the isolation `SAFE_BUILTINS` was standing in for, and stripping
builtins would make Play strictly less capable than Sáng tạo for no gain. Kids
exploring should be able to use `input()`, imports, everything.

## 6. Touched existing files

| File | Change |
|------|--------|
| `views/HomeView.qml` | "Chơi" card → `available: true`, `targetMode: "play"` |
| `MainWindow.qml` | `mode` gains `"play"`; hosts `PlayView`. The `learnActive ? … : …` ternaries in Save/Run become a `currentEditorText()` function — a third mode makes the nested form unreadable |
| `components/common/ToolBar.qml` | `playMode` prop; REPL toggle needs no change (it hides only for `learnMode`), but Run is disabled while a Play REPL is live (§4.1) |
| `components/common/ReplPanel.qml` | unchanged — `PlayView` just hosts it in the centre column instead of full-area |
| `execution/output_parser.py` | `\x1e@@ARM` prefix routing |
| `execution/runner.py` | accept `mode`; launch via `-m …play_bootstrap` when `"arm"` |
| `ui/controllers/repl_controller.py` | accept `mode`; `PYTHONSTARTUP` for arm sessions; add line buffering + arm-line routing (§4.1) |
| `core/event_bus.py` | `execution_requested(str, str)`, `repl_mode_changed(bool, str)`; new `arm_command(str)`, `arm_state_changed(...)` |
| `ui/bridge.py` | re-emit `armStateChanged` for QML |
| `theme/design.py` | MDI codepoints: `robot_industrial`, `rotate_left`, `rotate_right`, `arrow_up_bold`, `arrow_down_bold`, `hand_back_left`, `usb_port`, `connection` |
| `app.py` | construct + `setContextProperty("playController", …)` |
| `core/settings.py` | `arm_servos`, `arm_port`, `arm_mock` |

## 7. Packaging

**Resolved in 0.7.1.** `thingbot-telemetrix` 2.2 (AGPL-3.0-or-later) is bundled
into the Python package at `src/neo_code/_vendor/`, so the wheel — and the .deb
built from it — already carry it. One artifact, nothing extra to install.

A dependency would not have worked. apt resolves only apt packages, and bookworm
marks the system Python externally-managed, so a .deb has no way to pull from
PyPI at install time. Both alternatives were built and rejected: a second
`python3-thingbot-telemetrix` .deb (shipped briefly in 0.7.1) put a second
artifact in front of anyone installing by hand, and pip with
`--break-system-packages` writes into a Python Debian says not to write into,
where apt cannot track it.

Bundling in the *Python* build rather than in `build_deb.sh` is what keeps this
cheap: setuptools picks the directory up on its own, so a plain `pip install .`
and the .deb end up with identical code, and there is no packaging-only branch
to keep working.

It keeps its own top-level name under `_vendor/` instead of becoming
`neo_code._vendor.thingbot_telemetrix`, because the library imports itself
absolutely (`from thingbot_telemetrix.transport import ...`) and a rename breaks
it. `backends._telemetrix_class()` tries the plain import first — a real
installation always wins — and only then puts `_vendor/` on `sys.path`.

The licence mismatch is handled by keeping the code unmodified and recording it
in `debian/copyright`: NEO Code stays MIT, the bundled tree stays
AGPL-3.0-or-later. `src/neo_code/_vendor/README.md` records provenance, and
`make vendor` replaces the copy wholesale rather than patching it.

`debian/control` also carries `python3-serial` (pyserial), which is *not*
bundled — it is a real Debian package. The import stays lazy + guarded: with the
library now always present, a boardless machine fails in port discovery (~4 s)
rather than at import, and must still degrade to mock mode instead of breaking
app start.

## 8. Phasing

Each phase is independently reviewable and, from Phase 2 on, verifiable headless
in the bookworm container — mock mode needs no hardware.

1. **Shell** — extract `ResultConsole.qml`; add the mode to Home/MainWindow/
   ToolBar; `PlayView` with a static `ArmPanel` + editor + `PlayConsole` with a
   dummy status pane, plus the REPL swap (§1.1) and the stop-on-mode-change
   rule. No Python backend. Screenshot both layouts.
2. **Arm core, end to end on mock** — `features/arm/` (`mock.py`, `session.py`,
   `protocol.py`, `student_api.py`), `ArmSession` on its thread,
   `PlayController`, `play_bootstrap`, runner mode, `output_parser` routing,
   `ArmStatusPane` bound to live state. Running code moves the mock arm and the
   readout follows. This is the phase that proves the design.
3. **REPL arm sessions** — `arm_startup.py`, `repl_mode_changed(bool, str)`,
   `ReplController` line buffering + arm-line routing, Run disabled while the
   Play REPL is live. Deliberately after Phase 2: it reuses that protocol, and
   `ReplController`'s chunk-vs-line handling is the fiddliest part of the
   feature.
4. **Real hardware** — `hardware.py` Telemetrix backend, connect/fallback/status
   chip, servo-number resolution, packaging deps.
5. **Content** — `resources/play/open-arm.json` + `features/play/loader.py` +
   `ApiReference` wired to it; update `AGENTS.md` and `debian/control`.

## 9. Verification

All of it ran headless on `debian:bookworm` with **Qt 6.4.2** and the exact Qt6
packages `debian/control` depends on, in simulation mode (no board attached):

- All four layouts render — Chơi (script), Chơi (REPL), Học, Sáng tạo.
- Script path: `arm.turn_left(30)` / `grab()` / `set_pitch(120)` moves the
  session to `(60, 120, True)`; the console shows only the kid's own `print`
  output, with no protocol lines leaking through — including the
  `print(..., end="")` case where a command arrives glued to their text.
- Pose seeding: the next program reads `arm.yaw == 60`, i.e. where the arm
  actually is, not the home pose.
- REPL path: `arm.set_yaw(15)` reaches the session, and `arm.is_grabbed` reports
  `True` from the previous script — the PYTHONSTARTUP mirror seeds correctly.
- Errors: runtime, syntax and name errors each print a short traceback with the
  line number the kid sees in the editor.
- No regressions: Sáng tạo and Học still run and print; `arm` is undefined in
  plain mode (`NameError`), so mode isolation holds.

One open item remains, unblockable without hardware:

- **Which joint is on which servo is unconfirmed.** `settings.json`'s
  `arm_servos` defaults to `{yaw: 1, pitch: 2, grip: 3}`. The *numbering scheme*
  is now confirmed — telemetrix 2.2's `private_constants.py` defines
  `SERVO_1..SERVO_5 = 1..5` and `control_servo()` takes that number, so
  neo-robot's `RobotArm` 9/10/11 were indeed GPIO pins and stale. What is still
  a guess is the assignment of the three joints to indices 1/2/3. Verify against
  the board; it is a settings edit, not a code change.

Distribution was the other open item and is closed — see §7. With the library
now bundled, a machine with no board attached fails during port discovery
(~4 s with no serial ports present, longer where ports exist) instead of at
import. That runs on `ArmSession`'s worker thread, so the UI stays responsive
and the chip reads *Đang kết nối…* before settling on *Chế độ mô phỏng*, with
the technical reason going to stderr rather than the kid's screen.
