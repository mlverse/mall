#' Functions to integrate different back-ends
#'
#' @param backend An `mall_defaults` object
#' @param x The body of the text to be submitted to the LLM
#' @param base_prompt The instructions to the LLM about what to do with `x`
#' @param additional Additional text to insert to the `base_prompt`
#'
#' @returns `m_backend_submit` does not return an object. `m_backend_prompt`
#' returns a list of functions that contain the base prompts.
#'
#' @keywords internal
#' @export
m_backend_submit <- function(backend, x, base_prompt) {
  UseMethod("m_backend_submit")
}

#' @export
m_backend_submit.mall_ollama <- function(backend, x, base_prompt) {
  args <- as.list(backend)
  args$backend <- NULL
  map_chr(
    x,
    \(x) {
      .args <- c(
        prompt = glue("{base_prompt}\n{x}"),
        output = "text",
        system = "You are an assistant that only speak JSON. Do not write normal text",
        args
      )
      exec("generate", !!!.args)
    }
  )
}

#' @export
m_backend_submit.mall_simulate_llm <- function(backend, x, base_prompt) {
  args <- backend
  class(args) <- "list"
  if (args$model == "pipe") {
    out <- trimws(strsplit(x, "\\|")[[1]][[2]])
  } else if (args$model == "prompt") {
    out <- glue("{base_prompt}\n{x}")
  } else if (args$model == "echo") {
    out <- x
  } else {
    out <- list(
      x = x,
      base_prompt = base_prompt,
      backend = args
    )
  }
  out
}
