#!/usr/bin/env bash
# ==============================================================================
# Build python3-thingbot-telemetrix_<version>-1_all.deb from the PyPI sdist.
#
# Why this exists: `thingbot-telemetrix` is what lets Chơi mode talk to a real
# ThingBot board, but it is a PyPI package and the target device installs
# everything through apt (bookworm marks the system Python externally-managed,
# so `pip install` into it is refused). Rather than vendor the source or fight
# PEP 668, we build it once into a .deb and ship it alongside neo-code's own.
#
# The upstream sdist is PEP 621 / pyproject-only with no setup.py, which is why
# this debianizes it by hand over pybuild-plugin-pyproject — the same toolchain
# scripts/build_deb.sh uses — instead of reaching for stdeb, which still needs
# a setup.py and fails on this package.
#
# Pure Python, no extensions, so Architecture: all — one build serves arm64 and
# amd64, same as the neo-code package.
#
# Usage:  bash scripts/build_telemetrix_deb.sh [version]
# Output: dist/python3-thingbot-telemetrix_<version>-1_all.deb
# ==============================================================================
set -euo pipefail

VERSION="${1:-2.2}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="debian:bookworm"

DOCKER="docker"
if ! command -v docker &>/dev/null; then
    if command -v podman &>/dev/null; then
        DOCKER="podman"
    else
        echo "ERROR: docker or podman is required." >&2
        exit 1
    fi
fi

mkdir -p "$REPO_ROOT/dist"

"$DOCKER" run --rm \
    -v "$REPO_ROOT/dist:/out" \
    -e VERSION="$VERSION" \
    "$IMAGE" bash -euo pipefail -c '
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -qq
        apt-get install -y -qq --no-install-recommends \
            build-essential debhelper dh-python python3-all python3-setuptools \
            pybuild-plugin-pyproject python3-pip python3-serial \
            >/dev/null

        mkdir -p /tmp/src && cd /tmp/src
        pip3 download --no-deps --no-binary :all: --no-build-isolation \
            "thingbot-telemetrix==${VERSION}" -d /tmp/src >/dev/null

        tar xzf "thingbot_telemetrix-${VERSION}.tar.gz"
        cd "thingbot_telemetrix-${VERSION}"

        mkdir -p debian/source
        # Compat level comes from debhelper-compat in debian/control below;
        # a debian/compat file alongside it is an error, not a fallback.
        echo "3.0 (quilt)" > debian/source/format

        cat > debian/changelog <<CHANGELOG
thingbot-telemetrix (${VERSION}-1) unstable; urgency=medium

  * Repackaged from the PyPI sdist for NEO Code (Chơi mode arm control).

 -- ThingEdu <everwellmax@gmail.com>  $(date -R)
CHANGELOG

        cat > debian/control <<"CONTROL"
Source: thingbot-telemetrix
Section: python
Priority: optional
Maintainer: ThingEdu <everwellmax@gmail.com>
Build-Depends: debhelper-compat (= 13),
 dh-python,
 python3-all,
 python3-setuptools,
 pybuild-plugin-pyproject,
 python3-serial
Standards-Version: 4.6.2
Homepage: https://github.com/MEO-3/thingbot-telemetrix
Rules-Requires-Root: no

Package: python3-thingbot-telemetrix
Architecture: all
Depends: ${misc:Depends}, ${python3:Depends}
Description: Python client for ThingBot hardware over Telemetrix
 Python API for controlling ThingBot boards over the Telemetrix protocol:
 digital and analog I/O, PWM, DHT and ultrasonic sensors, servos and DC
 motors, over serial, TCP or BLE transports.
 .
 NEO Code uses this in Chơi mode to drive the robot arm.
CONTROL

        cat > debian/copyright <<"COPYRIGHT"
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: thingbot-telemetrix
Source: https://github.com/MEO-3/thingbot-telemetrix

Files: *
Copyright: lgthevinh <everwellmax@gmail.com>
License: AGPL-3.0-or-later
 This program is free software: you can redistribute it and/or modify it
 under the terms of the GNU Affero General Public License as published by
 the Free Software Foundation, either version 3 of the License, or (at your
 option) any later version.
 .
 On Debian systems the full text of the GNU Affero General Public License
 version 3 can be found in /usr/share/common-licenses/AGPL-3.
COPYRIGHT

        cat > debian/rules <<"RULES"
#!/usr/bin/make -f
export PYBUILD_NAME=thingbot_telemetrix

%:
	dh $@ --buildsystem=pybuild
RULES
        chmod +x debian/rules

        dpkg-buildpackage -us -uc -b

        cp ../python3-thingbot-telemetrix_*_all.deb /out/
        chown "$(stat -c "%u:%g" /out)" /out/python3-thingbot-telemetrix_*_all.deb || true
        echo ""
        echo "Built:"
        ls -lh /out/python3-thingbot-telemetrix_*_all.deb
    '
