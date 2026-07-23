#!/usr/bin/env bash
# ==============================================================================
# Build the neo-code .deb inside a Debian bookworm container.
#
# The package is Architecture: all (pure Python + QML), so one build works on
# both arm64 and amd64 — apt resolves the binary deps (PyQt6, Qt6 QML) per
# architecture at install time. Requires docker (or podman via alias).
#
# Usage:  bash scripts/build_deb.sh
# Output: dist/neo-code_<version>_all.deb
# ==============================================================================
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="debian:bookworm"

# Installed into the package at build time; see the pip step below. Keep in step
# with the floor in pyproject.toml's dependencies.
TELEMETRIX_VERSION="2.2"

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
    -v "$REPO_ROOT:/src:ro" \
    -v "$REPO_ROOT/dist:/out" \
    -e TELEMETRIX_VERSION="$TELEMETRIX_VERSION" \
    "$IMAGE" bash -euo pipefail -c '
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -qq
        apt-get install -y -qq --no-install-recommends \
            build-essential debhelper dh-python devscripts \
            python3-all python3-setuptools pybuild-plugin-pyproject \
            python3-pip \
            >/dev/null

        # Work on a copy so the host repo stays clean.
        cp -a /src /build
        cd /build
        rm -rf dist .git

        # thingbot-telemetrix is a normal PyPI dependency everywhere else, but
        # apt resolves only apt packages, so the .deb has to carry it. Install
        # it into the package instead of vendoring the source into git.
        #
        # --target is what makes this work: bookworm marks the system Python
        # externally-managed and refuses pip installs *into it*, but installing
        # into a plain directory is allowed.
        #
        # --no-deps because its one dependency, pyserial, is python3-serial in
        # debian/control — a real apt package, not something to bundle.
        pip3 install --target=src/neo_code/_vendor --no-deps \
            "thingbot-telemetrix==${TELEMETRIX_VERSION}" >/dev/null

        dpkg-buildpackage -us -uc -b

        cp /neo-code_*_all.deb /out/
        chown "$(stat -c "%u:%g" /out)" /out/neo-code_*_all.deb || true
        echo ""
        echo "Built:"
        ls -lh /out/neo-code_*_all.deb
    '
