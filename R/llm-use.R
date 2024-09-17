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
#' character: `""`. 'It defaults to '_mall_cache'. If this argument is left `NULL`
#' when calling this function, no changes to the path will be made.
#' 
#' @returns A `mall_defaults` object
#'
#' @export
llm_use <- function(
    backend = NULL, 
    model = NULL, 
    ..., 
    .silent = FALSE,
    .cache = NULL,
    .force = FALSE
    ) {
  models <- list()
  supplied <- sum(!is.null(backend), !is.null(model))
  not_init <- inherits(defaults_get(), "list")
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
  
  if(.force) {
    .env_llm$cache <- .cache %||% "_mall_cache"
    .env_llm$defaults <- list()
  } else {
    .env_llm$cache <- .cache %||% .env_llm$cache %||% "_mall_cache"
  }
  
  if (!is.null(backend) && !is.null(model)) {
    defaults_set(
      backend = backend,
      model = model,
      ...
    )
  }
  if (!.silent | not_init) {
    print(defaults_get())
  }
  invisible(defaults_get())
}
