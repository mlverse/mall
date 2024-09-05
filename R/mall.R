#' @importFrom purrr map_chr map_df
#' @importFrom dplyr mutate tibble bind_cols
#' @importFrom ollamar generate test_connection
#' @import glue
#' @import rlang
#' @import cli

.env_llm <- new.env()
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
  class(.env_llm$defaults) <- .env_llm$defaults[["backend"]]
  if (!.quiet) {
    return(defaults_get())
  } else {
    invisible()
  }
}
