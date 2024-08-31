#' @export
llm_sentiment <- function(x,
                          source_var = NULL,
                          options = c("positive", "negative", "neutral"),
                          pred_var = ".sentiment") {
  UseMethod("llm_sentiment")
}

#' @export
llm_sentiment.character <- function(x,
                                    source_var = NULL,
                                    options = c("positive", "negative", "neutral"),
                                    pred_var = ".sentiment") {
  llm_vec_generate(
    x = x,
    base_prompt = sentiment_prompt(options = options)
  )
}

#' @export
llm_sentiment.data.frame <- function(x,
                                     source_var = NULL,
                                     options = c("positive", "negative", "neutral"),
                                     pred_var = ".sentiment") {
  mutate(
    .data = x,
    !!pred_var := llm_vec_generate({{ source_var }}, sentiment_prompt(options))
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
`llm_sentiment.tbl_Spark SQL` <- function(x,
                                          source_var = NULL,
                                          options = NULL,
                                          pred_var = ".sentiment") {
  mutate(
    .data = x,
    !!pred_var := ai_analyze_sentiment({{ source_var }})
  )
}

globalVariables("ai_analyze_sentiment")
