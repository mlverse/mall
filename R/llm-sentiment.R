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
    prompt = get_prompt("sentiment", options),
    pred_name = pred_name,
    valid_resps = options
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
