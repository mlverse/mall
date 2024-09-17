#' Functions to integrate different back-ends
#'
#' @param backend An `mall_defaults` object
#' @param x The body of the text to be submitted to the LLM
#' @param prompt The additional information to add to the submission
#' @param additional Additional text to insert to the `base_prompt`
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
  map_chr(
    x,
    \(x) {
      .args <- c(
        messages = list(map(prompt, \(i) map(i, \(j) glue(j, x = x)))),
        output = "text",
        backend
      )
      res <- NULL
      if (m_cache_use()) {
        hash_args <- hash(.args)
        res <- m_cache_check(hash_args)
      }
      if (is.null(res)) {
        .args$backend <- NULL
        res <- exec("chat", !!!.args)
        m_cache_record(.args, res, hash_args)
      }
      res
    }
  )
}

#' @export
m_backend_submit.mall_simulate_llm <- function(backend, x, prompt) {
  .args <- as.list(environment())
  args <- backend
  class(args) <- "list"
  if (args$model == "pipe") {
    out <- map_chr(x, \(x) trimws(strsplit(x, "\\|")[[1]][[2]]))
  } else if (args$model == "echo") {
    out <- x
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

m_cache_record <- function(.args, .response, hash_args) {
  if (!m_cache_use()) {
    return(invisible())
  }
  folder_root <- m_cache_folder()
  try(dir_create(folder_root))
  content <- list(
    request = .args,
    response = .response
  )
  folder_sub <- substr(hash_args, 1, 2)
  try(dir_create(path(folder_root)))
  try(dir_create(path(folder_root, folder_sub)))
  write_json(content, m_cache_file(hash_args))
}

m_cache_check <- function(hash_args) {
  if (!m_cache_use()) {
    return(invisible())
  }
  folder_root <- m_cache_folder()
  resp <- suppressWarnings(
    try(read_json(m_cache_file(hash_args)), TRUE)
  )
  if (inherits(resp, "try-error")) {
    out <- NULL
  } else {
    out <- resp$response[[1]]
  }
  out
}

m_cache_file <- function(hash_args) {
  folder_root <- m_cache_folder()
  folder_sub <- substr(hash_args, 1, 2)
  path(folder_root, folder_sub, hash_args, ext = "json")
}

m_cache_folder <- function() {
  .env_llm$cache
}

m_cache_use <- function() {
  folder <- m_cache_folder() %||% ""
  out <- FALSE
  if (folder != "") {
    out <- TRUE
  }
  out
}
