.env_llm$defaults <- list()

defaults_get <- function() {
  .env_llm$defaults
}

defaults_set <- function(..., .quiet = TRUE) {
  new_args <- list(...)
  for (i in seq_along(new_args)) {
    nm <- names(new_args[i])
    .env_llm$defaults[[nm]] <- new_args[[i]]
  }
  class(.env_llm$defaults) <- c(
    clean_names(.env_llm$defaults[["model"]], TRUE),
    clean_names(.env_llm$defaults[["backend"]], TRUE),
    "mall_defaults"
  )
  if (!.quiet) {
    return(defaults_get())
  } else {
    invisible()
  }
}

clean_names <- function(x, replace_periods = FALSE) {
  x <- tolower(x)
  map_chr(
    x, ~ {
      xs <- strsplit(.x, " ")[[1]]
      x <- paste0(xs, collapse = "_")
      if (replace_periods) {
        xs <- strsplit(.x, "\\.")[[1]]
        x <- paste0(xs, collapse = "_")
      }
      x
    }
  )
}
