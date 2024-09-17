clean_names <- function(x) {
  x <- tolower(x)
  map_chr(
    x,
    \(x) {
      out <- str_replace_clean(x, " ")
      out <- str_replace_clean(out, "\\:")
      out
    }
  )
}

str_replace_clean <- function(x, y, z = "_") {
  xs <- strsplit(x, y)[[1]]
  paste0(xs, collapse = z)
}
