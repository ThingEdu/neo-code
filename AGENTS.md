# AGENTS.md

This file provides guidance to AI AGENTS when working with code in this repository.

## Project

NEO Code is an educational Python IDE (**PyQt6 + QML**) for STEM/Robotics students
aged 6–12, shipped to low-resource Armbian/ARM devices ("Neo One", 2 GB RAM). All
user-facing UI strings are **Vietnamese** — keep new strings in Vietnamese to match.

Three modes, chosen from the home screen: **Chơi** (drive a robot arm), **Học**
(curriculum lessons), **Sáng tạo** (free coding). Chơi's design is written up in
[`docs/specs/play_mode.md`](docs/specs/play_mode.md).

Note: `docs/specs/architecture.md` and `qt6_migration.md` are referenced in older
notes but do not exist in this repo — this file is the architecture reference.

## Commands

```bash
# Run from source
python -m neo_code          # or: neo-code  (after pip install -e .)

# Dev install — --system-site-packages is required on ARM, where PyQt6 comes from apt
python3 -m venv --system-site-packages .venv && source .venv/bin/activate
pip install -e ".[dev]"

# Build the .deb (Debian bookworm container; needs docker/podman)
make deb                     # → dist/neo-code_X.Y.Z_all.deb
```

There is **no test suite and no lint config wired up** — `tests/` contains only
empty `__init__.py` files. `pyproject.toml` defines `[tool.ruff]`/`[tool.mypy]` but
nothing runs them automatically. Do not claim tests pass; if adding tests, add the
runner config alongside them.

Shortcuts: F5 run, F6 stop, F9 REPL toggle, Ctrl+N/O/S file ops.

### Verifying UI changes

The UI is QML. To verify a change renders on the **actual target** (Qt 6.4), run it
headless in a Debian bookworm container and grab a screenshot. Loading QML on a
newer host Qt is not sufficient; bookworm ships Qt 6.4.2.

```bash
# image: bookworm + the same Qt6/QML packages debian/control depends on
docker run --rm -v "$PWD/src":/app/src:ro -v /tmp/out:/out \
  -e PYTHONPATH=/app/src -e QT_QPA_PLATFORM=offscreen <image> python3 /out/shot.py play /out/play.png
```

where `shot.py` loads `NeoCodeApp`, sets `mode` on the root object, and saves
`root.grabWindow()` on a timer. Chơi mode falls back to a simulated arm when no
board is attached, so every mode is screenshot- and function-testable with no
hardware.

### Releasing

`pyproject.toml`'s `version` is the single source of truth. Bump it, `make debs`,
then attach **both** `.deb`s to a GitHub release (`gh release create vX.Y.Z dist/*.deb`).
`scripts/install_on_neo.sh` downloads them by tag and hands both to apt in one call,
which resolves PyQt6 + the Qt6 QML runtime per-architecture. **There is no in-app
updater** — updates go through the install script. Any new Qt6 QML module a feature
needs must be added to `debian/control` (e.g. `qml6-module-qtquick-dialogs`).

The second `.deb` is `python3-thingbot-telemetrix`, which Chơi mode depends on for
real hardware. It is a PyPI package, not a Debian one, and bookworm refuses `pip`
into the system Python — so `make telemetrix-deb` rebuilds the sdist as a package
(`scripts/build_telemetrix_deb.sh`). Don't hand-write it into `debian/control`:
`debian/py3dist-overrides` maps the import name so `${python3:Depends}` derives it
from `pyproject.toml`, keeping the two from drifting. Bump `TELEMETRIX_VERSION` in
`install_on_neo.sh` when that package's version changes.

## Architecture

Declarative QML views + thin Python `QObject` controllers. Components never call
each other directly; everything crosses layers through the `event_bus` singleton
(`core/event_bus.py`), a `QObject` with typed `pyqtSignal`s.

```
theme/, core/, execution/, features/*/(logic)  ← no Qt UI, no QML
ui/controllers/   ← QObject façades exposed to QML via setContextProperty
ui/bridge.py      ← re-emits event_bus signals for QML Connections
ui/qml/           ← MainWindow.qml + components/*.qml
```

Bootstrap: `__main__.main()` → `NeoCodeApp` (`app.py`) builds a `QGuiApplication` +
`QQmlApplicationEngine`, constructs the `Runner` (self-registers on the bus) and the
controllers, exposes them via `setContextProperty` (plus the palette as `Theme` =
`asdict(colors)`), and loads `ui/qml/MainWindow.qml`.

**Adding a feature:** put Qt-clean logic in `features/<name>/`, add a
`ui/controllers/<name>_controller.py` QObject, register it in `app.py` via
`setContextProperty`, and add `ui/qml/components/<name>/*.qml`. `MainWindow.qml`
is a toolbar plus one visible view per `mode` (`home`/`create`/`learn`/`play`);
a new mode means a `views/<Name>View.qml`, a `HomeView` card, and a branch in
`currentText()`/`currentMode()`.

All three IDE modes render program output through
`components/common/ResultConsole.qml` — header, scrollback, the input row that
answers `input()`, and the `signalBus` wiring. Do not hand-roll a fourth copy;
that duplication is what let the panels drift apart before.

Colors are never hardcoded — reference `Theme.<token>` in QML (backed by
`theme/colors.py`; add the token there). Persistent state lives in
`~/.config/neo-code/`: `settings.json` (`core/settings.py`).

### Execution flow

`ToolBar` Run → `ExecutionController.run(code, mode)` → `event_bus.execution_requested`
→ `runner.py` writes a temp script via `proxy_injector.prepare_script()`, runs it
with `QProcess(sys.executable, ["-X","utf8","-u", tmp])`, hard-kills at 30 s, deletes
the temp file. stdout goes line-by-line through `output_parser.parse_line()` →
`event_bus.stdout_received`; stderr is emitted raw. Both reach QML through
`SignalBusBridge`.

`mode` is `"plain"` or `"arm"`. `"arm"` (Chơi) runs the script through
`-m neo_code.execution.play_bootstrap`, which injects an `arm` object with runpy.
**Never prepend a preamble to student code** to achieve this — a preamble shifts
every line, and tracebacks then point at the wrong line in the kid's editor. That
bug is why `prepare_script` writes the file verbatim.

Both child processes get their environment from `execution/child_env.py` (UTF-8,
an importable `neo_code`, and the arm pose in Chơi mode); keep them in step there
rather than in each caller.

## Notes

- Chơi mode's arm never opens the serial port from the student's subprocess — the
  main process holds it and the subprocess proxies commands over stdout with a
  `\x1e@@ARM ` prefix. See `docs/specs/play_mode.md` §4 for why; the short version
  is that reconnecting per Run costs ~14 s of port scanning.
- QML change handlers are **not** ordered against re-evaluation of bindings derived
  from the same property. `onModeChanged` in `MainWindow.qml` tests `mode` directly
  rather than the `playActive` binding for exactly this reason — the derived value
  can still read stale inside the handler.

- The editor uses a QML `TextArea` with the Python `PythonHighlighter`
  (`ui/controllers/editor_bridge.py`) attached to its `QTextDocument`; the
  line-number gutter is a **virtualized `ListView`** (never a `Repeater` — that
  instantiated every line and wasted memory). Assumes `wrapMode: NoWrap`; there is
  no word-wrap setting.
- `docs/specs/app_context.md` and `build_deploy.md` predate the migration and may
  still say PyQt5/PyQt6-inconsistent things — trust `architecture.md` and
  `qt6_migration.md`, and update the older specs when you touch behavior they describe.
