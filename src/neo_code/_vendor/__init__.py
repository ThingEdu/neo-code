"""Third-party libraries installed into the .deb at build time.

Empty in git — `scripts/build_deb.sh` fills it with `pip install --target`,
because apt cannot resolve a PyPI dependency. Everywhere else
`thingbot-telemetrix` is an ordinary dependency and this directory is unused.

Its contents are not imported as `neo_code._vendor.x`: `backends.py` puts this
directory on `sys.path` and imports them by their real top-level names, because
they import themselves absolutely. See README.md here.
"""
