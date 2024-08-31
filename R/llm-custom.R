#' @export
llm_custom <- function(x, var, prompt, pred_name = ".pred", source_name = "text") {
  UseMethod("llm_custom")
}

#' @export
llm_custom.character <- function(x,
                                 var = NULL,
                                 prompt,
                                 pred_name = ".pred",
                                 source_name = "text") {
  resp <- llm_vec_generate(x, prompt)
  tibble(!!source_name := x, !!pred_name := !!resp)
}

#' @export
llm_custom.data.frame <- function(x,
                                  var,
                                  prompt,
                                  pred_name = ".pred",
                                  source_name = NULL) {
  mutate(
    .data = x,
    !!pred_name := llm_vec_generate({{ var }}, prompt)
  )
}
