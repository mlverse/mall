#' @export
mall_backend_generate <- function(backend, x, base_prompt) {
  UseMethod("mall_backend_generate")
}

#' @export
mall_backend_generate.ollama <- function(backend, x, base_prompt) {
  args <- as.list(backend)
  args$backend <- NULL
  map_chr(x, ~ {
    .args <- c(
      prompt = glue("{base_prompt}\n{.x}"),
      output = "text",
      args
    )
    rlang::exec("generate", !!!.args)
  },
  .progress = TRUE
  )
}
