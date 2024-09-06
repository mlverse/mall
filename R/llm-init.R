#' @export
llm_init <- function(backend = NULL, model = NULL, ..., .silent = FALSE, .force = TRUE) {
  args <- list(...)
  models <- list()
  not_init <- inherits(defaults_get(), "list")
  if (not_init | .force) {
    if (is.null(backend)) {
      try_connection <- test_connection()
      if (try_connection$status_code == 200) {
        ollama_models <- list_models()
        for(model in ollama_models$name) {
          models <- c(models, list(list(backend = "Ollama", model = model)))
        }
      }
    }
    if (length(models) == 0) {
      cli_abort("No backend was selected, and Ollama is not available")
    }
    sel_model <- 1
    if(length(models) > 1) {
      mu <- map_chr(models, \(x) glue("{x$backend} - {x$model}"))
      sel_model <- menu(mu)
      cli_inform("") 
    }
    backend <- models[[sel_model]]$backend
    model <- models[[sel_model]]$model
    defaults_set(
      backend = backend,
      model = model,
      ...
    )
  }
  if (!.silent | not_init) {
    defaults <- defaults_get()
    cli_inform(glue("{col_green('Provider:')} {defaults$backend}"))
    cli_inform(glue("{col_green('Model:')} {defaults$model}"))
  }
  invisible()
}
