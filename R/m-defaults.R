m_defaults_set <- function(...) {
  new_args <- list2(...)
  defaults <- .env_llm$defaults
  for (i in seq_along(new_args)) {
    nm <- names(new_args[i])
    defaults[[nm]] <- new_args[[i]]
  }
  model <- defaults[["model"]]
  split_model <- strsplit(model, "\\:")[[1]]
  if (length(split_model) > 1) {
    sub_model <- split_model[[1]]
  } else {
    sub_model <- NULL
  }
  obj_class <- clean_names(c(
    model,
    sub_model,
    defaults[["backend"]],
    "session"
  ))
  .env_llm$defaults <- defaults
  .env_llm$session <- structure(
    list(
      name = defaults[["backend"]],
      args = defaults[names(defaults) != "backend" & names(defaults) != ".cache"],
      session = list(
        cache_folder = defaults[[".cache"]]
      )
    ),
    class = paste0("mall_", obj_class)
  )
  m_defaults_get()
}

m_defaults_get <- function() {
  .env_llm$session
}

m_defaults_backend <- function() {
  .env_llm$session$name
}

m_defaults_model <- function() {
  .env_llm$session$args$model
}

m_defaults_cache <- function() {
  .env_llm$session$session$cache_folder
}

m_defaults_reset <- function() {
  .env_llm$defaults <- list()
  .env_llm$session <- list()
}

m_defaults_args <- function(x = m_defaults_get()) {
  x$args
}

#' @export
print.mall_session <- function(x, ...) {
  cli_h3("{col_cyan('mall')} session object")
  cli_inform(glue("{col_green('Backend:')} {x$name}"))
  args <- imap(x$args, \(x, y) glue("{col_yellow({paste0(y, ':')})}{x}"))
  label_argument <- "{col_green('LLM session:')}"
  if (length(args) == 1) {
    cli_inform(paste(label_argument, args[[1]]))
  } else {
    cli_inform(label_argument)
    args <- as.character(args)
    args <- set_names(args, " ")
    cli_bullets(args)
  }
  session <- x$session
  if (session$cache_folder == "") {
    session$cache_folder <- NULL
  }
  if (length(session) > 0) {
    session <- imap(session, \(x, y) glue("{col_yellow({paste0(y, ':')})}{x}"))
    label_argument <- "{col_green('R session:')}"
    cli_inform(paste(label_argument, session[[1]]))
  }
}
