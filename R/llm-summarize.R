#' @export
llm_summarize <- function(.data,
                          x = NULL,
                          max_words = 100,
                          pred_name = ".summary") {
  UseMethod("llm_summarize")
}

#' @export
llm_summarize.data.frame <- function(.data,
                                     x = NULL,
                                     max_words = 100,
                                     pred_name = ".summary") {
  llm_custom(
    .data = .data,
    x = {{ x }},
    prompt = summarize_prompt(max_words),
    pred_name = pred_name
  )
}

summarize_prompt <- function(max_words) {
  glue(
    "You are a helpful summarization engine. ",
    "Your answer will contain no no capitalization and no explanations. ",
    "Return no more than {max_words} words. ",
    "The answer is the summary of the following text:"
  )
}

#' @export
`llm_summarize.tbl_Spark SQL` <- function(.data,
                                          x = NULL,
                                          max_words = 100,
                                          pred_name = ".summary") {
  mutate(
    .data = .data,
    !!pred_name := ai_summarize({{ x }}, as.integer(max_words))
  )
}

globalVariables("ai_summarize")
