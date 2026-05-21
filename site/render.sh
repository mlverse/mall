#!/bin/bash
set -e

echo ">>> Creating Python virtual environment (.venv-site)..."
uv venv .venv-site

echo ">>> Syncing Python project dependencies into .venv-site..."
UV_PROJECT_ENVIRONMENT=$PWD/.venv-site uv sync --project python/

echo ">>> Installing jupyter, quartodoc, griffe into .venv-site..."
uv pip install jupyter quartodoc "griffe<1.0" --python .venv-site/bin/python3

echo ">>> Installing R package..."
R CMD INSTALL R/

echo ">>> Syncing Python project dependencies into python/.venv..."
UV_PROJECT_ENVIRONMENT=$PWD/python/.venv uv sync --project python/

echo ">>> Installing numpy into python/.venv..."
uv pip install numpy --python python/.venv/bin/python3

echo ">>> Clearing caches and freeze directories..."
rm -rf _freeze/reference
rm -rf _freeze/index
rm -rf _mall_cache
rm -rf _readme_cache
rm -rf reference/_mall_cache

echo ">>> Generating R reference files..."
R -e 'pkgsite::write_reference()'

echo ">>> Building quartodoc reference..."
.venv-site/bin/quartodoc build --verbose

echo ">>> Rendering site..."
export OPENAI_API_KEY="na"
export QUARTO_PYTHON=.venv-site/bin/python3
quarto render

echo ">>> Cleaning up .venv-site..."
rm -rf .venv-site

echo ">>> Done! Starting preview..."
quarto preview
