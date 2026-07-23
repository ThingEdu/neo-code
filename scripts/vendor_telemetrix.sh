#!/usr/bin/env bash
# ==============================================================================
# Refresh the bundled copy of thingbot-telemetrix from PyPI.
#
# The library is bundled rather than depended on because the NEO One installs a
# .deb, and a .deb cannot pull from PyPI — see src/neo_code/_vendor/README.md.
# Bundling it in the Python package means the wheel, and the .deb built from it,
# already carry it.
#
# Run this to move to a new upstream version, then commit the result.
#
# Usage:  bash scripts/vendor_telemetrix.sh [version]
# ==============================================================================
set -euo pipefail

VERSION="${1:-2.2}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR_DIR="$REPO_ROOT/src/neo_code/_vendor"

command -v pip3 >/dev/null || { echo "ERROR: pip3 is required." >&2; exit 1; }

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Fetching thingbot-telemetrix==${VERSION} ..."
pip3 download --no-deps --no-binary :all: --no-build-isolation \
    "thingbot-telemetrix==${VERSION}" -d "$TMP_DIR" >/dev/null
tar xzf "$TMP_DIR/thingbot_telemetrix-${VERSION}.tar.gz" -C "$TMP_DIR"

# Wholesale replacement, not a merge: local edits are not supported here, and a
# leftover module from the previous version would still be importable.
rm -rf "$VENDOR_DIR/thingbot_telemetrix"
cp -a "$TMP_DIR/thingbot_telemetrix-${VERSION}/thingbot_telemetrix" "$VENDOR_DIR/"
find "$VENDOR_DIR" -name __pycache__ -type d -exec rm -rf {} + 2>/dev/null || true

echo "Vendored $(find "$VENDOR_DIR/thingbot_telemetrix" -name '*.py' | wc -l) files into src/neo_code/_vendor/"
echo
echo "Next: update the version in src/neo_code/_vendor/README.md and debian/copyright,"
echo "then test Chơi mode against a real board — none of this is covered by tests."
