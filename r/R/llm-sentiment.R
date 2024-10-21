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
#'
#' @examples
#' \donttest{
#' library(mall)
#'
#' data("reviews")
#'
#' llm_use("ollama", "llama3.2", seed = 100, .silent = TRUE)
#'
#' llm_sentiment(reviews, review)
#'
#' # Use 'pred_name' to customize the new column's name
#' llm_sentiment(reviews, review, pred_name = "review_sentiment")
#'
#' # Pass custom sentiment options
#' llm_sentiment(reviews, review, c("positive", "negative"))
#'
#' # Specify values to return per sentiment
#' llm_sentiment(reviews, review, c("positive" ~ 1, "negative" ~ 0))
#'
#' # For character vectors, instead of a data frame, use this function
#' llm_vec_sentiment(c("I am happy", "I am sad"))
#'
#' # To preview the first call that will be made to the downstream R function
#' llm_vec_sentiment(c("I am happy", "I am sad"), preview = TRUE)
#' }
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
