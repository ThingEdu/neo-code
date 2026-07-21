# AGENTS.md

This file provides guidance to AI AGENTS when working with code in this repository.

## Project

NEO Code is an educational Python IDE (**PyQt6 + QML**) for STEM/Robotics students
aged 6–12, shipped to low-resource Armbian/ARM devices ("Neo One", 2 GB RAM). All
user-facing UI strings are **Vietnamese** — keep new strings in Vietnamese to match.

Architecture reference: [`docs/specs/architecture.md`](docs/specs/architecture.md).
Migration history: [`docs/specs/qt6_migration.md`](docs/specs/qt6_migration.md).

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
headless in a Debian bookworm container and grab a screenshot — this is how the
whole migration was validated (see `docs/specs/qt6_migration.md`). Loading QML on a
newer host Qt is not sufficient; bookworm ships Qt 6.4.2.

### Releasing

`pyproject.toml`'s `version` is the single source of truth. Bump it, `make deb`,
then attach the `.deb` to a GitHub release (`gh release create vX.Y.Z dist/*.deb`).
`scripts/install_on_neo.sh` downloads that asset by tag and installs via apt, which
resolves PyQt6 + the Qt6 QML runtime per-architecture. **There is no in-app updater**
— updates go through the install script. Any new Qt6 QML module a feature needs must
be added to `debian/control` (e.g. `qml6-module-qtquick-dialogs`).

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
`setContextProperty`, and add `ui/qml/components/<Name>Panel.qml`. `MainWindow.qml`
is currently a single-pane canvas (toolbar → editor/terminal or REPL → status bar)
with no sidebar or nav shell — a feature panel needs its own host/toggle mechanism
in `MainWindow.qml` since none exists to plug into.

Colors are never hardcoded — reference `Theme.<token>` in QML (backed by
`theme/colors.py`; add the token there). Persistent state lives in
`~/.config/neo-code/`: `settings.json` (`core/settings.py`).

### Execution flow

`ToolBar` Run → `ExecutionController.run(code)` → `event_bus.execution_requested`
→ `runner.py` writes a temp script via `proxy_injector.prepare_script()`, runs it
with `QProcess(sys.executable, ["-X","utf8","-u", tmp])`, hard-kills at 30 s, deletes
the temp file. stdout goes line-by-line through `output_parser.parse_line()` →
`event_bus.stdout_received`; stderr is emitted raw. Both reach QML through
`SignalBusBridge`.

## Notes

- The curriculum (lessons) and robot features were removed from this app; they are
  being migrated to a separate UI. `features/` has no feature modules right now —
  only the empty package placeholder. Do not re-add lesson/robot code here.

- The editor uses a QML `TextArea` with the Python `PythonHighlighter`
  (`ui/controllers/editor_bridge.py`) attached to its `QTextDocument`; the
  line-number gutter is a **virtualized `ListView`** (never a `Repeater` — that
  instantiated every line and wasted memory). Assumes `wrapMode: NoWrap`; there is
  no word-wrap setting.
- `docs/specs/app_context.md` and `build_deploy.md` predate the migration and may
  still say PyQt5/PyQt6-inconsistent things — trust `architecture.md` and
  `qt6_migration.md`, and update the older specs when you touch behavior they describe.
