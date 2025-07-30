#' @rdname m_backend_submit
#' @export
m_backend_prompt <- function(backend, additional) {
  UseMethod("m_backend_prompt")
}

#' @export
m_backend_prompt.mall_ollama <- function(backend, additional = "") {
  next_method <- NextMethod()
  additional <- glue(paste0(
    additional,
    ". The answer is based on the following text:\n{{x}}"
  ))
  next_method
}

#' @export
m_backend_prompt.mall_llama3.2 <- function(backend, additional = "") {
  next_method <- NextMethod()
  next_method$extract <- function(labels) {
    no_labels <- length(labels)
    col_labels <- paste0(labels, collapse = ", ")
    plural <- ifelse(no_labels > 1, "s", "")
    text_multi <- ifelse(
      no_labels > 1,
      "Return the response exclusively in a pipe separated list, and no headers. ",
      ""
    )
    glue(paste(
      "You are a helpful text extraction engine.",
      "Extract the {col_labels} being referred to in the text.",
      "I expect {no_labels} item{plural} exactly.",
      "No capitalization. No explanations.",
      "{text_multi}",
      "{additional}"
    ))
  }
  next_method$classify <- function(labels) {
    labels <- process_labels(
      x = labels,
      if_character = "Determine if the text refers to one of the following: {x}",
      if_formula = "If it classifies as {f_lhs(x)} then return {f_rhs(x)}"
    )
    glue(paste(
      "You are a helpful classification engine.",
      "{labels}.",
      "No capitalization. No explanations.",
      "{additional}"
    ))
  }
  next_method
}

#' @export
m_backend_prompt.mall_session <- function(backend, additional = "") {
  list(
    sentiment = function(options) {
      options <- process_labels(
        x = options,
        if_character = "Return only one of the following answers: {x}",
        if_formula = "- If the text is {f_lhs(x)}, return {f_rhs(x)}"
      )
      glue(paste(
        "You are a helpful sentiment engine.",
        "{options}.",
        "No capitalization. No explanations.",
        "{additional}"
      ))
    },
    summarize = function(max_words) {
      glue(paste(
        "You are a helpful summarization engine.",
        "Your answer will contain no capitalization and no explanations.",
        "Return no more than {max_words} words.",
        "{additional}"
      ))
    },
    classify = function(labels) {
      labels <- process_labels(
        x = labels,
        if_character = "Determine if the text refers to one of the following: {x}",
        if_formula = "- For {f_lhs(x)}, return {f_rhs(x)}"
      )
      glue(paste(
        "You are a helpful classification engine.",
        "{labels}.",
        "No capitalization. No explanations.",
        "{additional}"
      ))
    },
    extract = function(labels) {
      no_labels <- length(labels)
      col_labels <- paste0(labels, collapse = ", ")
      plural <- ifelse(no_labels > 1, "s", "")
      text_multi <- ifelse(
        no_labels > 1,
        "Return the response in a simple list, pipe separated, and no headers. ",
        ""
      )
      glue(paste(
        "You are a helpful text extraction engine.",
        "Extract the {col_labels} being referred to in the text.",
        "I expect {no_labels} item{plural} exactly.",
        "No capitalization. No explanations.",
        "{text_multi}",
        "{additional}"
      ))
    },
    translate = function(language) {
      glue(paste(
        "You are a helpful translation engine.",
        "You will return only the translation text, no explanations.",
        "The target language to translate to is: {language}.",
        "{additional}"
      ))
    },
    verify = function(what, labels) {
      glue(paste(
        "You are a helpful text analysis engine.",
        "Determine if this is true ",
        "'{what}'.",
        "No capitalization. No explanations.",
        "{additional}"
      ))
    }
  )
}

all_formula <- function(x) {
  all(map_lgl(x, inherits, "formula"))
}

process_labels <- function(x, if_character = "", if_formula = "") {
  if (all_formula(x)) {
    labels_mapped <- map_chr(x, \(x) glue(if_formula))
    out <- paste0(labels_mapped, collapse = ", ")
  } else {
    x <- paste0(x, collapse = ", ")
    out <- glue(if_character)
  }
  out
}
