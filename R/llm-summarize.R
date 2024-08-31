#' @export
llm_summarize <- function(x,
                          var = NULL,
                          max_words = 100,
                          pred_var = ".summary") {
  UseMethod("llm_summarize")
}

#' @export
llm_summarize.character <- function(x,
                                    var = NULL,
                                    max_words = 100,
                                    pred_var = ".summary") {
  llm_custom(
    x = x, 
    prompt = summarize_prompt(max_words), 
    pred_name = pred_var
    )
}


#' @export
llm_summarize.data.frame <- function(x,
                                     var = NULL,
                                     max_words = 100,
                                     pred_var = ".summary") {
  llm_custom(
    x = x, 
    var = var,
    prompt = summarize_prompt(max_words), 
    pred_name = pred_var
  )
}

summarize_prompt <- function(max_words) {
  glue(
    "You are a helpful summarization engine. ",
    "Your answer will contain no no capitalization and no explanations. ",
    "Return no more than {max_words} words. ",
    "The answer is the summary of the following text:"
  )
}

#' @export
`llm_summarize.tbl_Spark SQL` <- function(x,
                                          var = NULL,
                                          max_words = 100,
                                          pred_var = ".summary") {
  mutate(
    .data = x,
    !!pred_var := ai_summarize({{ var }}, as.integer(max_words))
  )
}

globalVariables("ai_summarize")
