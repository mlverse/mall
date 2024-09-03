#' @export
llm_sentiment <- function(.data,
                          x = NULL,
                          options = c("positive", "negative", "neutral"),
                          pred_name = ".sentiment") {
  UseMethod("llm_sentiment")
}

#' @export
llm_sentiment.data.frame <- function(.data,
                                     x = NULL,
                                     options = c("positive", "negative", "neutral"),
                                     pred_name = ".sentiment") {
  llm_custom(
    .data = .data,
    x = {{ x }},
    prompt = sentiment_prompt(options = options),
    pred_name = pred_name,
    valid_resps = options
  )
}

sentiment_prompt <- function(options) {
  options <- paste0(options, collapse = ", ")
  glue(
    "You are a helpful sentiment engine.",
    "Return only one of the following answers: {options}.",
    "No capitalization. No explanations.",
    "The answer is based on the following text:"
  )
}

#' @export
`llm_sentiment.tbl_Spark SQL` <- function(.data,
                                          x = NULL,
                                          options = NULL,
                                          pred_name = ".sentiment") {
  mutate(
    .data = .data,
    !!pred_name := ai_analyze_sentiment({{ x }})
  )
}

globalVariables("ai_analyze_sentiment")
