To re-create the reference files, and capture the possibly new output from
the resulting Quarto files, run the following script from the project root:

```bash
bash site/render.sh
```

The script will:
1. Create a temporary `.venv-site` Python environment with all rendering dependencies
2. Install the R package
3. Set up `python/.venv` (used by reticulate in `index.qmd`) and install numpy
4. Clear all caches (`_mall_cache`, `_readme_cache`, `reference/_mall_cache`) and freeze directories
5. Regenerate R and Python reference files
6. Render the full site
7. Clean up `.venv-site` and launch `quarto preview`
