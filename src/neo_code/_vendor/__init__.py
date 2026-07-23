"""Third-party libraries bundled into NEO Code.

These are not NEO Code's own code and are not imported as `neo_code._vendor.x`.
`backends.py` puts this directory on `sys.path` and imports them by their real
top-level names, because they import themselves absolutely — telemetrix does
`from thingbot_telemetrix.transport import ...`, which a rename would break.

See README.md here for what lives in this directory and why.
"""
