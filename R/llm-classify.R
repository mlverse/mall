#' @export
llm_classify <- function(.data,
                         x = NULL,
                         labels,
                         pred_name = ".classify",
                         additional_prompt = "") {
  UseMethod("llm_classify")
}

#' @export
llm_classify.data.frame <- function(.data,
                                    x = NULL,
                                    labels,
                                    pred_name = ".classify",
                                    additional_prompt = "") {
  llm_custom(
    .data = .data,
    x = {{ x }},
    prompt = get_prompt("classify", labels, .additional = additional_prompt),
    pred_name = pred_name
  )
}
