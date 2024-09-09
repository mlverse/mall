#' Functions to integrate different back-ends
#' 
#' @param backend An `mall_defaults` object
#' @param x The body of the text to be submitted to the LLM
#' @param base_prompt The instructions to the LLM about what to do with `x`
#' @param additional Additional text to insert to the `base_prompt`
#' 
#' @returns `m_backend_generate` does not return an object. `m_backend_prompt`
#' returns a list of functions that contain the base prompts.
#' 
#' @keywords internal
#' @export
m_backend_generate <- function(backend, x, base_prompt) {
  UseMethod("m_backend_generate")
}

#' @export
m_backend_generate.mall_ollama <- function(backend, x, base_prompt) {
  args <- as.list(backend)
  args$backend <- NULL
  map_chr(x,
    \(x) {
      .args <- c(
        prompt = glue("{base_prompt}\n{x}"),
        output = "text",
        args
      )
      exec("generate", !!!.args)
    }
  )
}

#' @export
m_backend_generate.mall_simulate_llm <- function(backend, x, base_prompt) {
  args <- backend
  class(args) <- "list"
  if(args$model == "pipe") {
    trimws(strsplit(x, "\\|")[[1]][[1]])
  } else if(args$model == "prompt") {
    paste(base_prompt, x)
  } else if(args$model == "echo") {
    x
  } else {
    list(
      x = x, 
      base_prompt = base_prompt,
      backend = args
    )
  }
}
