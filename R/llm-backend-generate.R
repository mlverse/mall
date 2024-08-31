#' @export
llm_backend_generate <- function(backend, x, base_prompt) {
  UseMethod("llm_backend_generate")
}

#' @export
llm_backend_generate.list <- function(backend, x, base_prompt) {
  try_connection <- test_connection()

  if (try_connection$status_code == 200) {
    .env_llm$defaults$model <- "llama3.1"
    class(.env_llm$defaults) <- "ollama"
    return(llm_backend_generate(.env_llm$defaults, x, base_prompt))
  }
  invisible()
}

#' @export
llm_backend_generate.ollama <- function(backend, x, base_prompt) {
  map_chr(x, ~ {
    generate(
      model = backend$model,
      prompt = glue("{base_prompt} {.x}"),
      output = "text"
    )
  },
  .progress = TRUE
  )
}
