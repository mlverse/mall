defaults_get <- function() {
  .env_llm$session
}

defaults_set <- function(...) {
  new_args <- list(...)
  defaults <- .env_llm$defaults 
  for (i in seq_along(new_args)) {
    nm <- names(new_args[i])
    defaults[[nm]] <- new_args[[i]]
  }
  obj_class <- clean_names(c(
    defaults[["model"]],
    defaults[["backend"]],
    "session"
  ))
  class(defaults) <- paste0("mall_", obj_class)
  .env_llm$defaults <- defaults 
  .env_llm$session <- structure(
      list(
        name = defaults[["backend"]],
        args = defaults[names(defaults) != "backend" & names(defaults) != ".cache"],
        session = list(
          cache_folder = defaults[[".cache"]]
        )
      ),
      class = paste0("mall_", obj_class)
    )  
  defaults_get()
}

#' @export
print.mall_session <- function(x, ...) {
  cli_inform(glue("{col_green('Provider:')} {x$name}"))
  cli_inform(glue("{col_green('Model:')} {x$args$model}"))
  rlang::list2(x)
}
