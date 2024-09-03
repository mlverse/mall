#' @export
llm_init <- function(backend = NULL, model = NULL, ...) {
  args <- list(...)
  if(is.null(backend) && is.null(.env_llm$defaults)) {
    try_connection <- test_connection()
    if (try_connection$status_code == 200) {
      backend <- "ollama"
      model <- "llama3.1"
    }
  }
  if(is.null(backend)) {
    cli_abort("No backend was selected, and Ollama is not available")
  }
  defaults <- list(
    backend = backend, 
    model = model,
    ...
    )
  class(defaults) <- backend
  .env_llm$defaults <- defaults
  cli_inform(glue("{col_green('Provider:')} {defaults$backend}"))
  cli_inform(glue("{col_green('Model:')} {defaults$model}"))
  invisible()
}