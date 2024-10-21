#' Specify the model to use
#' @description
#' Allows us to specify the back-end provider, model to use during the current
#' R session
#' @param backend The name of an supported back-end provider. Currently only
#' 'ollama' is supported.
#' @param .silent Avoids console output
#' @param model The name of model supported by the back-end provider
#' @param ... Additional arguments that this function will pass down to the
#' integrating function. In the case of Ollama, it will pass those arguments to
#' `ollamar::chat()`.
#' @param .force Flag that tell the function to reset all of the settings in the
#' R session
#' @param .cache The path to save model results, so they can be re-used if
#' the same operation is ran again. To turn off, set this argument to an empty
#' character: `""`. It defaults to a temp folder. If this argument is left
#' `NULL` when calling this function, no changes to the path will be made.
#' @examples
#' \donttest{
#' library(mall)
#'
#' llm_use("ollama", "llama3.2")
#'
#' # Additional arguments will be passed 'as-is' to the
#' # downstream R function in this example, to ollama::chat()
#' llm_use("ollama", "llama3.2", seed = 100, temperature = 0.1)
#'
#' # During the R session, you can change any argument
#' # individually and it will retain all of previous
#' # arguments used
#' llm_use(temperature = 0.3)
#'
#' # Use .cache to modify the target folder for caching
#' llm_use(.cache = "_my_cache")
#'
#' # Leave .cache empty to turn off this functionality
#' llm_use(.cache = "")
#'
#' # Use .silent to avoid the print out
#' llm_use(.silent = TRUE)
#' }
#' @returns A `mall_session` object
#'
#' @export
llm_use <- function(
    backend = NULL,
    model = NULL,
    ...,
    .silent = FALSE,
    .cache = NULL,
    .force = FALSE) {
  models <- list()
  supplied <- sum(!is.null(backend), !is.null(model))
  not_init <- inherits(m_defaults_get(), "list")
  if (supplied == 2) {
    not_init <- FALSE
  }
  if (not_init) {
    if (is.null(backend)) {
      try_connection <- test_connection()
      if (try_connection$status_code == 200) {
        ollama_models <- list_models()
        for (model in ollama_models$name) {
          models <- c(models, list(list(backend = "Ollama", model = model)))
        }
      }
    }
    if (length(models) == 0) {
      cli_abort("No backend was selected, and Ollama is not available")
    }
    sel_model <- 1
    if (length(models) > 1) {
      mu <- map_chr(models, \(x) glue("{x$backend} - {x$model}"))
      sel_model <- menu(mu)
      cli_inform("")
    }
    backend <- models[[sel_model]]$backend
    model <- models[[sel_model]]$model
  }

  if (.force) {
    cache <- .cache %||% tempfile("_mall_cache")
    m_defaults_reset()
  } else {
    cache <- .cache %||% m_defaults_cache() %||% tempfile("_mall_cache")
  }

  backend <- backend %||% m_defaults_backend()
  model <- model %||% m_defaults_model()

  m_defaults_set(
    backend = backend,
    model = model,
    .cache = cache,
    ...
  )
  if (!.silent || not_init) {
    print(m_defaults_get())
  }
  invisible(m_defaults_get())
}
