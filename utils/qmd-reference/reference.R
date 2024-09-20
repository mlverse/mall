source("utils/qmd-reference/utils-reference-index.R")
source("utils/qmd-reference/utils-reference-list.R")
source("utils/qmd-reference/utils-reference-pages.R")
source("utils/qmd-reference/pkgdown.R")
library(pkgdown)
library(magrittr)
library(purrr)
library(rlang)
library(fs)

pkg <- as_pkgdown(".")

try(dir_create("reference"))

ref_path <- path("reference", "index", ext = "qmd")
try(file_delete(ref_path))
writeLines(reference_index(pkg, "reference"), ref_path)

walk(
  pkg$topics$file_in, 
  \(x) {
    p <- path_ext_remove(x)
    p <- paste0("reference/", p, ".qmd")
    print(p)
    qmd <- reference_to_qmd(x, pkg)    
    print(qmd)
    try(file_delete(p))
    writeLines(qmd, p)
  }
)

