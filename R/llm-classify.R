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
  mutate(
    .data = .data,
    !!pred_name := llm_vec_classify(
      x = {{ x }},
      labels = labels,
      additional_prompt = additional_prompt
    )
  )
}

#' @export
llm_vec_classify <- function(x = NULL,
                             labels,
                             additional_prompt = "") {
  llm_vec_prompt(
    x = x, prompt_label = "classify",
    additional_prompt = additional_prompt,
    labels = labels,
    valid_resps = labels
  )
}
