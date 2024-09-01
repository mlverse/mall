#' @export
llm_custom <- function(.data, x, prompt, pred_name = ".pred", source_name = "text") {
  UseMethod("llm_custom")
}

#' @export
llm_custom.data.frame <- function(.data,
                                  x,
                                  prompt,
                                  pred_name = ".pred",
                                  source_name = NULL) {
  mutate(
    .data = .data,
    !!pred_name := llm_vec_generate({{ x }}, prompt)
  )
}
