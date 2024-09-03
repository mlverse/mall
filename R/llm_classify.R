#' @export
llm_classify <- function(.data,
                         x = NULL,
                         labels,
                         pred_name = ".classify") {
  UseMethod("llm_classify")
}

#' @export
llm_classify.data.frame <- function(.data,
                                    x = NULL,
                                    labels,
                                    pred_name = ".classify") {
  llm_custom(
    .data = .data,
    x = {{ x }},
    prompt = classify_prompt(labels),
    pred_name = pred_name
  )
}


classify_prompt <- function(labels) {
  no_labels <- length(labels)
  labels <- paste0(labels, collapse = ", ")
  glue(
    "You are a helpful classification engine.",
    "Determine if the text refers to one of the following: {labels}. ",
    "No capitalization. No explanations.",
    "The answer is based on the following text:"
  )
}
