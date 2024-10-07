## Build reference, and render site

```r
devtools::install(upgrade = "never")
#try(fs::dir_delete("_freeze/reference/"))
source(here::here("utils/website/build_reference.R"))
quarto::quarto_render(as_job = FALSE)
quarto::quarto_preview()
```

