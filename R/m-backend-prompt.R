#' @export
m_backend_prompt <- function(backend, additional) {
  UseMethod("m_backend_prompt")
}

#' @export
m_backend_prompt.mall_defaults <- function(backend, additional = "") {
  list(
    sentiment = function(options) {
      options <- paste0(options, collapse = ", ")
      glue(
        "You are a helpful sentiment engine. ",
        "Return only one of the following answers: {options}. ",
        "No capitalization. No explanations. ",
        additional,
        "The answer is based on the following text:"
      )
    },
    summarize = function(max_words) {
      glue(
        "You are a helpful summarization engine. ",
        "Your answer will contain no no capitalization and no explanations. ",
        "Return no more than {max_words} words. ",
        additional,
        "The answer is the summary of the following text:"
      )
    },
    classify = function(labels) {
      labels <- paste0(labels, collapse = ", ")
      glue(
        "You are a helpful classification engine.",
        "Determine if the text refers to one of the following: {labels}. ",
        "No capitalization. No explanations.",
        additional,
        "The answer is based on the following text:"
      )
    },
    extract = function(labels) {
      no_labels <- length(labels)
      labels <- paste0(labels, collapse = ", ")
      glue(
        "You are a helpful text extraction engine.",
        "Extract the {labels} being referred to on the text. ",
        "I expect {no_labels} item(s) exactly. ",
        "No capitalization. No explanations.",
        "Return the response in a simple pipe separated list, no headers. ",
        additional,
        "The answer is based on the following text:"
      )
    },
    translate = function(language) {
      glue(
        "You are a helpful translation engine. ",
        "You will return only the translation text, no explanations. ",
        "The target language to translate to is: {language}. ",
        additional,
        "The answer is the summary of the following text: "
      )
    }
  )
}

get_prompt <- function(label, ..., .additional = "") {
  defaults <- m_backend_prompt(defaults_get(), .additional)
  fn <- defaults[[label]]
  fn(...)
}
