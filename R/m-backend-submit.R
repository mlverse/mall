#' Functions to integrate different back-ends
#'
#' @param backend An `mall_session` object
#' @param x The body of the text to be submitted to the LLM
#' @param prompt The additional information to add to the submission
#' @param additional Additional text to insert to the `base_prompt`
#' @param preview If `TRUE`, it will display the resulting R call of the
#' first text in `x`
#' @returns `m_backend_submit` does not return an object. `m_backend_prompt`
#' returns a list of functions that contain the base prompts.
#'
#' @keywords internal
#' @export
m_backend_submit <- function(backend, x, prompt, preview = FALSE) {
  UseMethod("m_backend_submit")
}

#' @export
m_backend_submit.mall_ollama <- function(backend, x, prompt, preview = FALSE) {
  if (preview) {
    x <- head(x, 1)
    map_here <- map
  } else {
    map_here <- map_chr
  }
  map_here(
    x,
    \(x) {
      .args <- c(
        messages = list(map(prompt, \(i) map(i, \(j) glue(j, x = x)))),
        output = "text",
        m_defaults_args(backend)
      )
      res <- NULL
      if (preview) {
        res <- expr(ollamar::chat(!!!.args))
      }
      if (m_cache_use() && is.null(res)) {
        hash_args <- hash(.args)
        res <- m_cache_check(hash_args)
      }
      if (is.null(res)) {
        res <- exec("chat", !!!.args)
        m_cache_record(.args, res, hash_args)
      }
      res
    }
  )
}

#' @export
m_backend_submit.mall_simulate_llm <- function(backend,
                                               x,
                                               prompt,
                                               preview = FALSE) {
  .args <- as.list(environment())
  args <- m_defaults_args(backend)
  if (args$model == "pipe") {
    out <- map_chr(x, \(x) trimws(strsplit(x, "\\|")[[1]][[2]]))
  } else if (args$model == "echo") {
    out <- x
  } else if (args$model == "prompt") {
    out <- prompt
  }
  res <- NULL
  if (m_cache_use()) {
    hash_args <- hash(.args)
    res <- m_cache_check(hash_args)
  }
  if (is.null(res)) {
    .args$backend <- NULL
    m_cache_record(.args, out, hash_args)
  }
  out
}
