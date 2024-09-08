#' @export
llm_summarize <- function(.data,
                          x = NULL,
                          max_words = 100,
                          pred_name = ".summary",
                          additional_prompt = "") {
  UseMethod("llm_summarize")
}

#' @export
llm_summarize.data.frame <- function(.data,
                                     x = NULL,
                                     max_words = 100,
                                     pred_name = ".summary",
                                     additional_prompt = "") {
  mutate(
    .data = .data,
    !!pred_name := llm_vec_summarize(
      x = {{ x }},
      max_words = max_words, 
      additional_prompt = additional_prompt
    )
  )  
}

#' @export
`llm_summarize.tbl_Spark SQL` <- function(.data,
                                          x = NULL,
                                          max_words = 100,
                                          pred_name = ".summary",
                                          additional_prompt = NULL) {
  mutate(
    .data = .data,
    !!pred_name := ai_summarize({{ x }}, as.integer(max_words))
  )
}

globalVariables("ai_summarize")


#' @export
llm_vec_summarize <- function(x,
                              max_words = 100,
                              additional_prompt = "") {
  llm_vec_prompt(
    x = x, 
    prompt_label = "summarize", 
    additional_prompt = additional_prompt, 
    max_words = max_words
  )
}
