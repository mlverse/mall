To re-create the reference files, and capture the possibly new output from
the resulting Quarto files, use the following steps: 

```bash
uv venv .venv-site
UV_PROJECT_ENVIRONMENT=$PWD/.venv-site uv sync --project python/
uv pip install jupyter quartodoc "griffe<1.0" --python .venv-site/bin/python3
R CMD INSTALL R/
rm -rf _freeze/reference
rm -rf _freeze/index
R -e 'pkgsite::write_reference()'
.venv-site/bin/quartodoc build --verbose
export OPENAI_API_KEY="na"
export QUARTO_PYTHON=.venv-site/bin/python3
quarto render
rm -rf .venv-site
quarto preview
```
