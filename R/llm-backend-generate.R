#' @export
llm_backend_generate <- function(backend, x, base_prompt) {
  UseMethod("llm_backend_generate")
}

#' @export
llm_backend_generate.ollama <- function(backend, x, base_prompt) {
  args <- as.list(backend)
  args$backend <- NULL
  map_chr(x, ~ {
    .args <- c(
      prompt = glue("{base_prompt} {.x}"),
      output = "text",
      args
    )
    rlang::exec("generate", !!!.args)
  },
  .progress = TRUE
  )
}
