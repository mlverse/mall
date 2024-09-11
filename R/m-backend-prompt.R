#' @rdname m_backend_submit
#' @export
m_backend_prompt <- function(backend, additional) {
  UseMethod("m_backend_prompt")
}

#' @export
m_backend_prompt.mall_defaults <- function(backend, x = "", additional = "") {
  list(
    sentiment = function(options) {
      options <- paste0(options, collapse = ", ")
      glue(paste(
        "You are a helpful sentiment engine.",
        "Return only one of the following answers: {options}.",
        "No capitalization. No explanations.",
        "{additional}",
        "The answer is based on the following text:\n{x}"
      ))
    },
    summarize = function(max_words) {
      glue(paste(
        "You are a helpful summarization engine.",
        "Your answer will contain no no capitalization and no explanations.",
        "Return no more than {max_words} words.",
        "{additional}",
        "The answer is the summary of the following text:\n{x}"
      ))
    },
    classify = function(labels) {
      labels <- paste0(labels, collapse = ", ")
      glue(paste(
        "You are a helpful classification engine.",
        "Determine if the text refers to one of the following: {labels}.",
        "No capitalization. No explanations.",
        "{additional}",
        "The answer is based on the following text:\n{x}"
      ))
    },
    extract = function(labels) {
      no_labels <- length(labels)
      labels <- paste0(labels, collapse = ", ")
      list(
        list(
          role = "system",
          content = paste("You are an assistant that only speak JSON.",
                          "Do not write normal text")
        ),
        list(
          role = "user", 
          content = glue(paste(
            "You are a helpful text extraction engine.",
            "Extract the {labels} being referred to on the text.",
            "I expect {no_labels} item(s) exactly.",
            "No capitalization. No explanations.",
            "{additional}",
            "The answer is based on the following text:\n{x}"
          ))          
        )
      )
    },
    translate = function(language) {
      glue(paste(
        "You are a helpful translation engine.",
        "You will return only the translation text, no explanations.",
        "The target language to translate to is: {language}.",
        "{additional}",
        "The answer is the summary of the following text:\n{x}"
      ))
    }
  )
}

get_prompt <- function(label, ..., .additional = "") {
  defaults <- m_backend_prompt(defaults_get(), .additional)
  fn <- defaults[[label]]
  fn(...)
}


llm_vec_prompt <- function(x,
                           prompt_label = "",
                           additional_prompt = "",
                           valid_resps = NULL,
                           ...) {
  llm_use(.silent = TRUE, force = FALSE)
  prompt <- get_prompt(prompt_label, ..., .additional = additional_prompt)
  llm_vec_custom(x, prompt, valid_resps)
}
