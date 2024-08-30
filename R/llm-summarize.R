#' @export
llm_summarize <- function(x,
                          source_var = NULL,
                          max_words = 100,
                          pred_var = ".summary") {
  UseMethod("llm_summarize")
}

#' @export
llm_summarize.character <- function(x,
                                    source_var = NULL,
                                    max_words = 100,
                                    pred_var = NULL) {
  llm_generate(x = x, base_prompt = summary_prompt(max_words))
}


#' @export
llm_summarize.data.frame <- function(x,
                                     source_var = NULL,
                                     max_words = 100,
                                     pred_var = ".summary") {
  mutate(
    .data = x,
    !!pred_var := llm_generate({{ source_var }}, summary_prompt(max_words))
  )
}

summary_prompt <- function(max_words) {
  glue(
    "You are a helpful summarization engine. ",
    "Your answer will contain no no capitalization and no explanations. ",
    "Return no more than {max_words} words. ",
    "The answer is the summary of the following text:"
  )
}

#' @export
`llm_summarize.tbl_Spark SQL` <- function(x,
                                          source_var = NULL,
                                          max_words = 100,
                                          pred_var = ".summary") {
  mutate(
    .data = x,
    !!pred_var := ai_summarize({{ source_var }}, as.integer(max_words))
  )
}

globalVariables("ai_summarize")
