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
  mutate(
    .data = .data,
    !!pred_name := llm_vec_translate(
      x = {{ x }},
      language = language, 
      additional_prompt = additional_prompt
    )
  )  
}

#' @export
llm_vec_translate <- function(
    x,
    language,
    additional_prompt = "") {
  llm_vec_prompt(
    x = x, 
    prompt_label = "translate", 
    additional_prompt = additional_prompt, 
    language = language
  )
}
