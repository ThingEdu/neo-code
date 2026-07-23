# Bundled third-party code

**This directory is empty in git.** `scripts/build_deb.sh` fills it at build time
with `pip install --target`, so the `.deb` carries the libraries below while the
repo stays free of third-party source. Nothing here is NEO Code's own work, and
nothing here should be committed.

## thingbot_telemetrix

- Upstream: PyPI `thingbot-telemetrix` (<https://github.com/MEO-3/thingbot-telemetrix>)
- Version: pinned by `TELEMETRIX_VERSION` in `scripts/build_deb.sh`
- Licence: **AGPL-3.0-or-later** (NEO Code itself is MIT — `debian/copyright`
  records both)
- Used by: `features/arm/backends.py`, to drive the robot arm in Chơi mode

To move to a new version, bump `TELEMETRIX_VERSION` in `scripts/build_deb.sh` and
the floor in `pyproject.toml`, then test Chơi mode against a real board — none of
this is covered by tests.

## Why a .deb needs this at all

Everywhere else `thingbot-telemetrix` is an ordinary PyPI dependency:
`pip install .` resolves it and this directory is never used. But apt resolves
only apt packages, and there is no `python3-thingbot-telemetrix` in Debian — so
the `.deb` has to carry its own copy.

`pip install --target` is what makes that legal: bookworm marks the system Python
externally-managed and refuses installs *into it*, but installing into a plain
directory is fine.

## Why the libraries keep their own names

They are imported as `thingbot_telemetrix`, not
`neo_code._vendor.thingbot_telemetrix` — the library imports itself absolutely
(`from thingbot_telemetrix.transport import ...`), which a rename would break.
`backends._telemetrix_class()` tries the plain import first, so a real
installation always wins, and only falls back to putting this directory on
`sys.path`.
