.PHONY: install dev run lint format build deb vendor clean

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

# Refresh the bundled thingbot-telemetrix; see src/neo_code/_vendor/README.md.
vendor:
	bash scripts/vendor_telemetrix.sh

clean:
	rm -rf build dist *.egg-info
	find . -type d -name __pycache__ -exec rm -rf {} +
