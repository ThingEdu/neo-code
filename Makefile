.PHONY: install dev run lint format build deb telemetrix-deb debs clean

install:
	pip install -e .

dev:
	pip install -e ".[dev]"

run:
	python -m neo_code

lint:
	ruff check src
	mypy src

format:
	ruff format src
	ruff check --fix src

build:
	python -m build

deb:
	bash scripts/build_deb.sh

# thingbot-telemetrix is on PyPI, not in the Debian archive, and bookworm
# refuses pip into the system Python — so it ships as its own .deb.
telemetrix-deb:
	bash scripts/build_telemetrix_deb.sh

# Everything a release needs.
debs: deb telemetrix-deb

clean:
	rm -rf build dist *.egg-info
	find . -type d -name __pycache__ -exec rm -rf {} +
