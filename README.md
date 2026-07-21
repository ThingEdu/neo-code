# NEO Code

**A kid-friendly Python IDE for STEM & Robotics learners (ages 6–12).**

NEO Code is a lightweight educational Python IDE built for the
[NEO One](https://github.com/ThingEdu) education device (ARM64 / Armbian, 2 GB
RAM) and standard Linux desktops. It pairs a clean code editor with a live REPL —
everything runs locally, no internet required.

> **App language:** the user interface is in **Vietnamese**, matching its
> audience of Vietnamese primary-school students. This README (project docs) is
> in English.

## Requirements

- **Python 3.10+**
- **Linux** (x86-64 or ARM64 / Armbian) with a running display server (X11 or Wayland)
- **Qt 6.4+** and its QML runtime — installed from apt by the `.deb` package (never built from pip on ARM)

---

## Installation

### NEO One / Debian / Ubuntu (recommended)

The `.deb` is `Architecture: all`; apt pulls the correct PyQt6 and Qt6 QML
binaries for your architecture at install time.

```bash
curl -sSL https://raw.githubusercontent.com/ThingEdu/neo-code/main/scripts/install_on_neo.sh | bash
```

Options:

| Flag | Effect |
| --- | --- |
| `--version=X.Y.Z` | Install a specific release (default: latest) |
| `--uninstall` | Remove NEO Code (and clean up legacy pip installs) |

### Manual `.deb` install

Download the latest `neo-code_<version>_all.deb` from the
[releases page](https://github.com/ThingEdu/neo-code/releases), then:

```bash
sudo apt-get install ./neo-code_<version>_all.deb
```

---

## Running the app

- **Desktop menu:** *Applications → Education → NEO Code*
- **Terminal:** `neo-code`

Once open:

| Feature | How to use |
| --- | --- |
| Editor | Type Python in the editor; syntax and line numbers update automatically |
| Run / Stop | `F5` runs (30-second limit), `F6` stops |
| REPL | `F9` toggles the interactive console |
| Output | Expand the console panel to read stdout / stderr |

### Keyboard shortcuts

| Action | Shortcut |
| --- | --- |
| Run code | `F5` |
| Stop execution | `F6` |
| Toggle REPL | `F9` |
| New file | `Ctrl+N` |
| Open file | `Ctrl+O` |
| Save file | `Ctrl+S` |

---

## Development

```bash
git clone https://github.com/ThingEdu/neo-code.git
cd neo-code

# PyQt6 comes from apt on ARM — --system-site-packages lets the venv see it.
python3 -m venv --system-site-packages .venv
source .venv/bin/activate
pip install -e ".[dev]"

# Run from source
python -m neo_code        # or: neo-code
make run

# Build the .deb (in a Debian bookworm container; needs docker/podman)
make deb
```

The project is layered and event-driven — components communicate only through
the `event_bus` singleton. See [`AGENTS.md`](AGENTS.md) for the architecture and
contributor guide, and [`docs/specs/`](docs/specs/) for design notes.

There is **no test suite or linter config wired up yet** — please don't claim
tests pass.

---

## Releasing

`pyproject.toml`'s `version` is the single source of truth. To cut a release:

```bash
# 1. Bump `version` in pyproject.toml
# 2. Build the package
make deb                                    # → dist/neo-code_X.Y.Z_all.deb
# 3. Attach it to a GitHub release
gh release create vX.Y.Z dist/*.deb
```

`install_on_neo.sh` downloads that asset by tag.

---

## License

[MIT](LICENSE)