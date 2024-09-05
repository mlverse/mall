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
    prompt = get_prompt("summarize", max_words),
    pred_name = pred_name
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
