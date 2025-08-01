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

# -------------------------------- Ollama --------------------------------------

#' @export
m_backend_submit.mall_ollama <- function(backend, x, prompt, preview = FALSE) {
  prompt <- list(
    list(role = "user", content = prompt)
  )
  if (preview) {
    x <- head(x, 1)
    map_here <- map
  } else {
    map_here <- map_chr
  }
  warnings <- NULL
  out <- map_here(
    x,
    \(x) {
      .args <- c(
        messages = list(
          map(prompt, \(i)
          map(i, \(j) {
            out <- glue(j, x = x)
            ln <- length(unlist(strsplit(out, " ")))
            if (ln > m_ollama_tokens()) {
              warnings <<- c(
                warnings,
                list(list(row = substr(x, 1, 20), len = ln))
              )
            }
            out
          }))
        ),
        output = "text",
        m_defaults_args(backend)
      )
      res <- NULL
      if (preview) {
        res <- expr(ollamar::chat(!!!.args))
      }
      if (m_cache_use(backend) && is.null(res)) {
        hash_args <- hash(.args)
        res <- m_cache_check(hash_args)
      }
      if (is.null(res)) {
        res <- exec("chat", !!!.args)
        if (m_cache_use(backend)) {
          m_cache_record(.args, res, hash_args)
        }
      }
      res
    }
  )
  if (!is.null(warnings)) {
    warn_len <- length(warnings)
    cli_alert_warning(c(
      "{warn_len} record{?s} may be over {m_ollama_tokens()} tokens\n",
      "Ollama may have truncated what was sent to the model \n",
      "(https://github.com/ollama/ollama/issues/7043)"
    ))
    limit <- 10
    limit <- ifelse(limit > warn_len, warn_len, limit)
    warn_text <- map(warnings[1:limit], \(x) paste0(x[["row"]], "..."))
    cli_bullets(set_names(warn_text, "*"))
    if (warn_len > limit) {
      cli_inform(c("i" = "{warn_len - limit} more record{?s}"))
    }
  }
  out
}

# Using a function so that it can be mocked in testing
m_ollama_tokens <- function() {
  4096
}

# -------------------------------- ellmer --------------------------------------

#' @export
m_backend_submit.mall_ellmer <- function(backend, x, prompt, preview = FALSE) {
  if (preview) {
    return(
      exprs(
        ellmer_obj$set_system_prompt(!!prompt),
        ellmer_obj$chat(as.list(!!head(x, 1)))
      )
    )
  }
  ellmer_obj <- backend[["args"]][["ellmer_obj"]]
  if (m_cache_use(backend)) {
    hashed_x <- map(x, function(x) hash(c(ellmer_obj, prompt, x)))
    from_cache <- map(hashed_x, m_cache_check)
    null_cache <- map_lgl(from_cache, is.null)
    x <- x[null_cache]
  }
  from_llm <- NULL
  if (length(x) > 0) {
    temp_ellmer <- ellmer_obj$clone()$set_turns(list())
    temp_ellmer$set_system_prompt(prompt)
    from_llm <- parallel_chat_text(temp_ellmer, as.list(x))
  }
  if (m_cache_use(backend)) {
    walk(
      seq_along(from_llm),
      function(y) {
        m_cache_record(list(prompt, x[y]), from_llm[y], hashed_x[y])
      }
    )
    res <- rep("", times = length(null_cache))
    res[null_cache] <- from_llm
    res[!null_cache] <- from_cache[!null_cache]
    res
  } else {
    res <- from_llm
  }
  map_chr(res, ~.x)
}

# Using a function so that it can be mocked in testing
m_ellmer_chat <- function(...) {
  defaults <- m_defaults_args()
  ellmer_obj <- defaults[["ellmer_obj"]]
  temp_ellmer <- ellmer_obj$clone()$set_turns(list())
  temp_ellmer$chat(...)
}


# ------------------------------ Simulate --------------------------------------

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
  if (m_cache_use(backend)) {
    hash_args <- hash(.args)
    res <- m_cache_check(hash_args)
  }
  if (is.null(res)) {
    .args$backend <- NULL
    if (m_cache_use(backend)) {
      m_cache_record(.args, out, hash_args)
    }
  }
  out
}
