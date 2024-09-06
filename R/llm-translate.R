#' @export
llm_translate <- function(.data,
                          x,
                          language,
                          pred_name = ".translation",
                          additional_prompt = "") {
  UseMethod("llm_translate")
}

#' @export
llm_translate.data.frame <- function(.data,
                                     x,
                                     language,
                                     pred_name = ".translation",
                                     additional_prompt = "") {
  llm_custom(
    .data = .data,
    x = {{ x }},
    prompt = get_prompt("translate", language, .additional = additional_prompt),
    pred_name = pred_name
  )
}

#' @export
llm_vec_translate <- function(
    x,
    language,
    additional_prompt = "") {
  llm_vec_custom(
    x = x,
    prompt = get_prompt("translate", language, .additional = additional_prompt)
  )
}
