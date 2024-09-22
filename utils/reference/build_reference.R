source("utils/reference/index-page.R")
source("utils/reference/list-to-qmd.R")
source("utils/reference/rd-to-list.R")
suppressPackageStartupMessages(library(purrr))
library(fs)
library(cli)

build_reference_index <- function(pkg = ".", folder = "reference") {
  if (is.character(pkg)) pkg <- pkgdown::as_pkgdown(pkg)
  try(dir_create(folder))
  ref_path <- path(folder, "index", ext = "qmd")
  try(file_delete(ref_path))
  writeLines(reference_index(folder = folder), ref_path)
  cli_inform(col_green(ref_path))  
}

build_reference <- function(pkg = ".", folder = "reference") {
  if (is.character(pkg)) pkg <- pkgdown::as_pkgdown(pkg)
  walk(
    pkg$topics$file_in, 
    \(x) {
      p <- path_ext_remove(x)
      p <- paste0(folder, "/", p, ".qmd")
      qmd <- reference_to_qmd(x, pkg)    
      try(file_delete(p))
      writeLines(qmd, p)
      cli_inform(col_green(p))
    }
  )  
}

build_reference_index()
build_reference()
