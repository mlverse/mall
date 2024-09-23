#' Summarize text
#'
#' @description
#' Use a Large Language Model (LLM) to summarize text
#'
#' @inheritParams llm_classify
#' @param max_words The maximum number of words that the LLM should use in the
#' summary. Defaults to 10.
#' @examples
#' \dontrun{
#' library(mall) 
#' 
#' llm_use("ollama", "llama3.1", seed = 100, .silent = TRUE) 
#' 
#' reviews <- data.frame(review = c( 
#'   "This has been the best TV I've ever used. Great screen, and sound.", 
#'   "I regret buying this laptop. It is too slow and the keyboard is too noisy", 
#'   "Not sure how to feel about my new washing machine. Great color, but hard to figure" 
#' )) 
#' 
#' # Use max_words to set the maximum number of words to use for the summary
#' llm_summarize(reviews, review, max_words = 5) 
#' 
#' # Use 'pred_name' to customize the new column's name 
#' llm_summarize(reviews, review, 5, pred_name = "review_sentiment") 
#' 
#' # For character vectors, instead of a data frame, use this function 
#' llm_vec_summarize(
#'   "This has been the best TV I've ever used. Great screen, and sound.",
#'   max_words = 5
#'   ) 
#' 
#' # For character vectors, instead of a data frame, use this function 
#' llm_vec_summarize(
#'   "This has been the best TV I've ever used. Great screen, and sound.",
#'   max_words = 5, 
#'   preview = TRUE
#' ) 
#' }
#' @returns `llm_summarize` returns a `data.frame` or `tbl` object.
#' `llm_vec_summarize` returns a vector that is the same length as `x`.
#' @export
llm_summarize <- function(.data,
                          col,
                          max_words = 10,
                          pred_name = ".summary",
                          additional_prompt = "") {
  UseMethod("llm_summarize")
}

#' @export
llm_summarize.data.frame <- function(.data,
                                     col,
                                     max_words = 10,
                                     pred_name = ".summary",
                                     additional_prompt = "") {
  mutate(
    .data = .data,
    !!pred_name := llm_vec_summarize(
      x = {{ col }},
      max_words = max_words,
      additional_prompt = additional_prompt
    )
  )
}

#' @export
`llm_summarize.tbl_Spark SQL` <- function(.data,
                                          col,
                                          max_words = 10,
                                          pred_name = ".summary",
                                          additional_prompt = NULL) {
  mutate(
    .data = .data,
    !!pred_name := ai_summarize({{ col }}, as.integer(max_words))
  )
}

globalVariables("ai_summarize")

#' @rdname llm_summarize
#' @export
llm_vec_summarize <- function(x,
                              max_words = 10,
                              additional_prompt = "",
                              preview = FALSE) {
  m_vec_prompt(
    x = x,
    prompt_label = "summarize",
    additional_prompt = additional_prompt,
    max_words = max_words,
    preview = preview
  )
}
