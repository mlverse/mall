#' Summarize text
#'
#' @description
#' Use a Large Language Model (LLM) to summarize text
#'
#' @inheritParams llm_classify
#' @param max_words The maximum number of words that the LLM should use in the
#' summary. Defaults to 10.
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
                              additional_prompt = "") {
  l_vec_prompt(
    x = x,
    prompt_label = "summarize",
    additional_prompt = additional_prompt,
    max_words = max_words
  )
}
