#' @export
llm_sentiment <- function(.data,
                          x = NULL,
                          options = c("positive", "negative", "neutral"),
                          pred_name = ".sentiment",
                          additional_prompt = "") {
  UseMethod("llm_sentiment")
}

#' @export
llm_sentiment.data.frame <- function(.data,
                                     x = NULL,
                                     options = c("positive", "negative", "neutral"),
                                     pred_name = ".sentiment",
                                     additional_prompt = "") {
  mutate(
    .data = .data,
    !!pred_name := llm_vec_sentiment(
      x = {{ x }},
      options = options,
      additional_prompt = additional_prompt
    )
  )
}

#' @export
`llm_sentiment.tbl_Spark SQL` <- function(.data,
                                          x = NULL,
                                          options = NULL,
                                          pred_name = ".sentiment",
                                          additional_prompt = NULL) {
  mutate(
    .data = .data,
    !!pred_name := ai_analyze_sentiment({{ x }})
  )
}

globalVariables("ai_analyze_sentiment")

#' @export
llm_vec_sentiment <- function(x,
                              options = c("positive", "negative", "neutral"),
                              additional_prompt = "") {
  llm_vec_prompt(
    x = x,
    prompt_label = "sentiment",
    additional_prompt = additional_prompt,
    valid_resps = options,
    options = options
  )
}
