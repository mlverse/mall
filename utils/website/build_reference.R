local_folder <- here::here()
pkg <- "r"
if(path_file(local_folder) == "r") {
  pkg <- "."
  local_folder = path_dir(local_folder)
}

library(fs)
source(path(local_folder, "utils/website/index-page.R"))
source(path(local_folder, "utils/website/list-to-qmd.R"))
source(path(local_folder, "utils/website/rd-to-list.R"))
suppressPackageStartupMessages(library(purrr))
library(fs)
library(cli)

build_reference_index <- function(pkg = ".", folder = "reference") {
  if (is.character(pkg)) pkg <- pkgdown::as_pkgdown(pkg)
  try(dir_create(folder))
  ref_path <- path(folder, "r_index", ext = "qmd")
  try(file_delete(ref_path))
  writeLines(reference_index(pkg), ref_path)
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

build_reference_index(pkg, path(local_folder, "reference"))
build_reference(pkg, path(local_folder, "reference"))
