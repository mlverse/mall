To re-create the reference files, and capture the possibly new output from
the resulting Quarto files, use the following steps: 

```bash
uv pip install python/
rm -rf _freeze/reference
R -e 'pkgsite::write_reference()'
quartodoc build --verbose
export OPENAI_API_KEY="na"
quarto render
quarto preview
```
