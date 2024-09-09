defaults_get <- function() {
  .env_llm$defaults
}

defaults_set <- function(...) {
  new_args <- list(...)
  for (i in seq_along(new_args)) {
    nm <- names(new_args[i])
    .env_llm$defaults[[nm]] <- new_args[[i]]
  }
  obj_class <- clean_names(c(
    .env_llm$defaults[["model"]],
    .env_llm$defaults[["backend"]],
    "defaults"
  ))
  class(.env_llm$defaults) <- paste0("mall_", obj_class)
  defaults_get()
}

#' @export
print.mall_defaults <- function(x, ...) {
  cli_inform(glue("{col_green('Provider:')} {x$backend}"))
  cli_inform(glue("{col_green('Model:')} {x$model}"))
}
