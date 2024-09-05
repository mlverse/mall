#' @export
llm_classify <- function(.data,
                         x = NULL,
                         labels,
                         pred_name = ".classify") {
  UseMethod("llm_classify")
}

#' @export
llm_classify.data.frame <- function(.data,
                                    x = NULL,
                                    labels,
                                    pred_name = ".classify") {
  llm_custom(
    .data = .data,
    x = {{ x }},
    prompt = get_prompt("classify", labels),
    pred_name = pred_name
  )
}
