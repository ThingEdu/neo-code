# Bundled third-party code

Nothing here is NEO Code's own work. Don't edit these files — changes are lost
on the next update, which is a wholesale replacement, not a patch.

## thingbot_telemetrix 2.2

- Upstream: <https://github.com/MEO-3/thingbot-telemetrix>, also on PyPI as
  `thingbot-telemetrix`
- Licence: **AGPL-3.0-or-later** (NEO Code itself is MIT — see
  `debian/copyright`, which records both)
- Used by: `features/arm/backends.py`, to drive the robot arm in Chơi mode

Copied verbatim from the PyPI sdist, no local modifications.

### Why it is bundled rather than depended on

The NEO One installs NEO Code as a `.deb`. apt resolves only apt packages, and
Debian bookworm marks the system Python externally-managed, so `pip install`
into it is refused — a `.deb` therefore has no way to pull this from PyPI at
install time. Bundling it in the Python package means the wheel, and so the
`.deb` built from it, already contains it: one artifact, one install, and the
same code on a dev machine as on the device.

It keeps its own top-level name here instead of being imported as
`neo_code._vendor.thingbot_telemetrix`, because it imports itself absolutely
(`from thingbot_telemetrix.transport import ...`) and a rename would break it.

`pyserial` is *not* bundled — it is `python3-serial` in apt and a normal
dependency everywhere else.

### Updating

```bash
bash scripts/vendor_telemetrix.sh 2.3
```

Then run Chơi mode against a board before releasing; nothing here is covered by
tests.
