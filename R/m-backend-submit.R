#' Functions to integrate different back-ends
#'
#' @param backend An `mall_defaults` object
#' @param x The body of the text to be submitted to the LLM
#' @param prompt The additional information to add to the submission 
#' @param additional Additional text to insert to the `base_prompt`
#'
#' @returns `m_backend_submit` does not return an object. `m_backend_prompt`
#' returns a list of functions that contain the base prompts.
#'
#' @keywords internal
#' @export
m_backend_submit <- function(backend, x, prompt) {
  UseMethod("m_backend_submit")
}

#' @export
m_backend_submit.mall_ollama <- function(backend, x, prompt) {
  args <- as.list(backend)
  args$backend <- NULL
  
  map_chr(
    x,
    \(x) {
      .args <- c(
        messages = list(map(prompt, \(i) map(i, \(j) glue(j, x = x)))),
        output = "text",
        args
      )
      exec("chat", !!!.args)
    }
  )
}

#' @export
m_backend_submit.mall_simulate_llm <- function(backend, x, prompt) {
  args <- backend
  class(args) <- "list"
  if (args$model == "pipe") {
    out <- trimws(strsplit(x, "\\|")[[1]][[2]])
  } else if (args$model == "prompt") {
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
