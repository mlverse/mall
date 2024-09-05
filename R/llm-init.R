#' @export
llm_init <- function(backend = NULL, model = NULL, ..., .silent = FALSE, .force = TRUE) {
  
  not_init <- inherits(defaults_get(), "list")
  
  if(not_init | .force) {
    args <- list(...)
    if (is.null(backend)) {
      try_connection <- test_connection()
      if (try_connection$status_code == 200) {
        backend <- "ollama"
        model <- "llama3.1"
      }
    }
    if (is.null(backend)) {
      cli_abort("No backend was selected, and Ollama is not available")
    }
    defaults_set(
      backend = backend,
      model = model,
      ...
    )    
  }
  if(!.silent | not_init) {
    defaults <- defaults_get()
    cli_inform(glue("{col_green('Provider:')} {defaults$backend}"))
    cli_inform(glue("{col_green('Model:')} {defaults$model}"))
  }
  invisible()
}
