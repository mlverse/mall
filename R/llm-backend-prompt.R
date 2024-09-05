#' @export
llm_backend_prompt <- function(backend) {
  UseMethod("llm_backend_prompt")
}

#' @export
llm_backend_prompt.mall_defaults <- function(backend) {
  list(
    sentiment = function(options) {
      options <- paste0(options, collapse = ", ")
      glue(
        "You are a helpful sentiment engine.",
        "Return only one of the following answers: {options}.",
        "No capitalization. No explanations.",
        "The answer is based on the following text:"
      )
    }
  )
}

get_prompt <- function(label, ...) {
  defaults <- llm_backend_prompt(defaults_get())
  fn <- defaults[[label]]
  fn(...)
}