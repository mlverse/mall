To re-create the reference files, and capture the possibly new output from
the resulting Quarto files, use the following steps: 

```bash
rm -rf _freeze/reference
R -e 'pkgsite::write_reference()'
quartodoc build --verbose
quarto render
quarto preview
```
