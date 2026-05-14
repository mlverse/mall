To re-create the reference files, and capture the possibly new output from
the resulting Quarto files, use the following steps: 

```bash
uv sync --project python/
uv pip install python/ jupyter quartodoc --python python/.venv/bin/python3
R CMD INSTALL R/
rm -rf _freeze/reference
rm -rf _freeze/index
R -e 'pkgsite::write_reference()'
python/.venv/bin/quartodoc build --verbose
export OPENAI_API_KEY="na"
export QUARTO_PYTHON=python/.venv/bin/python3
quarto render
quarto preview
```
