m_cache_record <- function(.args, .response, hash_args) {
  if (!m_cache_use()) {
    return(invisible())
  }
  folder_root <- m_defaults_cache()
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
  folder_root <- m_defaults_cache()
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
  folder_root <- m_defaults_cache()
  folder_sub <- substr(hash_args, 1, 2)
  path(folder_root, folder_sub, hash_args, ext = "json")
}

m_cache_use <- function() {
  folder <- m_defaults_cache() %||% ""
  out <- FALSE
  if (folder != "") {
    out <- TRUE
  }
  out
}
