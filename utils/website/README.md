## Build reference, and render site

```r
try(fs::dir_delete("_freeze/reference/"))
source("utils/website/build_reference.R")
quarto::quarto_render(as_job = FALSE)
```
