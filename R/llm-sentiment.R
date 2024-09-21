#' Sentiment analysis
#'
#' @description
#' Use a Large Language Model (LLM) to perform sentiment analysis
#' from the provided text
#'
#' @inheritParams llm_classify
#' @param options A vector with the options that the LLM should use to assign
#' a sentiment to the text. Defaults to: 'positive', 'negative', 'neutral'
#' @returns `llm_sentiment` returns a `data.frame` or `tbl` object.
#' `llm_vec_sentiment` returns a vector that is the same length as `x`.
#' @export
llm_sentiment <- function(.data,
                          col,
                          options = c("positive", "negative", "neutral"),
                          pred_name = ".sentiment",
                          additional_prompt = "") {
  UseMethod("llm_sentiment")
}

#' @export
llm_sentiment.data.frame <- function(.data,
                                     col,
                                     options = c("positive", "negative", "neutral"),
                                     pred_name = ".sentiment",
                                     additional_prompt = "") {
  mutate(
    .data = .data,
    !!pred_name := llm_vec_sentiment(
      x = {{ col }},
      options = options,
      additional_prompt = additional_prompt
    )
  )
}

#' @export
`llm_sentiment.tbl_Spark SQL` <- function(.data,
                                          col,
                                          options = NULL,
                                          pred_name = ".sentiment",
                                          additional_prompt = NULL) {
  mutate(
    .data = .data,
    !!pred_name := ai_analyze_sentiment({{ col }})
  )
}

globalVariables("ai_analyze_sentiment")

#' @rdname llm_sentiment
#'@examples
#'\dontrun{
#'library(mall)
#'
#'llm_use("ollama", "llama3.1", seed = 100, .silent = TRUE)
#'
#'llm_vec_sentiment("I am happy")
#'
#'# Specify values to return per sentiment
#'llm_vec_sentiment("I am happy", c("positive" ~ 1, "negative" ~ 0))
#'
#'llm_vec_sentiment("I am sad", c("positive" ~ 1, "negative" ~ 0))
#'
#'}
#' @export
llm_vec_sentiment <- function(x,
                              options = c("positive", "negative", "neutral"),
                              additional_prompt = "",
                              preview = FALSE) {
  m_vec_prompt(
    x = x,
    prompt_label = "sentiment",
    additional_prompt = additional_prompt,
    valid_resps = options,
    options = options,
    preview = preview
  )
}
