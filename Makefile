.PHONY: install dev run lint format build deb clean

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

clean:
	rm -rf build dist *.egg-info
	find . -type d -name __pycache__ -exec rm -rf {} +
