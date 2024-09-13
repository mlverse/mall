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
  mall_results <- m_results_directory()
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
      hash_args <- hash(.args)
      folder_sub <- substr(hash_args, 1, 2)
      folder_root <- "_mall_cache"
      if(hash_args %in% mall_results) {
        jres <- read_json(
          path(folder_root, folder_sub, hash_args, ext = "json")
        )
        res <- jres$response[[1]]
      } else {
        res <- exec("chat", !!!.args)
        m_results_record(.args, res, hash_args)
      }
      res
    }
  )
}

#' @export
m_backend_submit.mall_simulate_llm <- function(backend, x, prompt) {
  args <- backend
  class(args) <- "list"
  if (args$model == "pipe") {
    out <- map_chr(x, \(x) trimws(strsplit(x, "\\|")[[1]][[2]]))
  } else if (args$model == "echo") {
    out <- x
  }
  out
}

m_results_record <- function(.args, .response, hash_args) {
  folder_root <- "_mall_cache"
  try(dir_create(folder_root))
  content <- list(
    request = .args,
    response = .response
  )
  folder_sub <- substr(hash_args, 1, 2)
  try(dir_create(path(folder_root, folder_sub)))
  write_json(content, path(folder_root, folder_sub, hash_args, ext = "json"))
}

m_results_directory <- function() {
  folder_root <- "_mall_cache"
  json_files <- dir_ls(folder_root, recurse = TRUE, type = "file", glob = "*.json")
  path_ext_remove(path_file(json_files))
}



