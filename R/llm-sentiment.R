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
                                    pred_var = NULL) {
  llm_generate(
    x = x, 
    base_prompt = sentiment_prompt(options = options)
    )
}

#' @export
llm_sentiment.data.frame <- function(x,
                                    source_var = NULL,
                                    options = c("positive", "negative", "neutral"),
                                    pred_var = ".sentiment") {
  txt <- pull(.data = x, var = {{source_var}})
  base_prompt <- sentiment_prompt(options = options)
  pred <- llm_generate(
    x = txt, 
    base_prompt = base_prompt
  )
  x[, pred_var] <- pred
  x
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