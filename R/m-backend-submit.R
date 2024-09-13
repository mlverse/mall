#' Functions to integrate different back-ends
#'
#' @param backend An `mall_defaults` object
#' @param x The body of the text to be submitted to the LLM
#' @param prompt The additional information to add to the submission
#' @param additional Additional text to insert to the `base_prompt`
#' @param cache Flag to save and re-use previous runs
#' @returns `m_backend_submit` does not return an object. `m_backend_prompt`
#' returns a list of functions that contain the base prompts.
#'
#' @keywords internal
#' @export
m_backend_submit <- function(backend, x, prompt, cache = TRUE) {
  UseMethod("m_backend_submit")
}

#' @export
m_backend_submit.mall_ollama <- function(backend, x, prompt, cache = TRUE) {
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
      res <- NULL
      if(cache) {
        hash_args <- hash(.args)
        res <- m_cache_check(hash_args)
      }
      if (is.null(res)) {
        res <- exec("chat", !!!.args)
        if(cache) {
          m_cache_record(.args, res, hash_args)  
        }
      }
      res
    }
  )
}

#' @export
m_backend_submit.mall_simulate_llm <- function(backend, x, prompt, cache = TRUE) {
  args <- backend
  class(args) <- "list"
  if (args$model == "pipe") {
    out <- map_chr(x, \(x) trimws(strsplit(x, "\\|")[[1]][[2]]))
  } else if (args$model == "echo") {
    out <- x
  }
  out
}

m_cache_record <- function(.args, .response, hash_args) {
  folder_root <- "_mall_cache"
  try(dir_create(folder_root))
  content <- list(
    request = .args,
    response = .response
  )
  folder_sub <- substr(hash_args, 1, 2)
  try(dir_create(path(folder_root, folder_sub)))
  write_json(content, m_cache_file(hash_args))
}

m_cache_file <- function(hash_args) {
  folder_root <- "_mall_cache"
  folder_sub <- substr(hash_args, 1, 2)
  path(folder_root, folder_sub, hash_args, ext = "json")
}

m_cache_check <- function(hash_args) {
  resp <- suppressWarnings(try(read_json(m_cache_file(hash_args)), TRUE))
  if (inherits(resp, "try-error")) {
    out <- NULL
  } else {
    out <- resp$response[[1]]
  }
  out
}
