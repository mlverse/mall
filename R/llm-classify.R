#' Categorize data as one of options given
#'
#' @description
#' Use a Large Language Model (LLM) to classify the provided text as one of the
#' options provided via the `labels` argument.
#'
#' @param .data A `data.frame` or `tbl` object that contains the text to be 
#' analyzed
#' @param col The name of the field to analyze, supports `tidy-eval`
#' @param x A vector that contains the text to be analyzed
#' @param additional_prompt Inserts this text into the prompt sent to the LLM
#' @param pred_name A character vector with the name of the new column where the
#' prediction will be placed
#' @param labels A character vector with at least 2 labels to classify the text
#' as
#' @param preview It returns the R call that would have been used to run the
#' prediction. It only returns the first record in `x`. Defaults to `FALSE`
#' Applies to vector function only.
#' @returns `llm_classify` returns a `data.frame` or `tbl` object. 
#' `llm_vec_classify` returns a vector that is the same length as `x`.
#' @export
llm_classify <- function(.data,
                         col,
                         labels,
                         pred_name = ".classify",
                         additional_prompt = "") {
  UseMethod("llm_classify")
}

#' @export
llm_classify.data.frame <- function(.data,
                                    col,
                                    labels,
                                    pred_name = ".classify",
                                    additional_prompt = "") {
    mutate(
      .data = .data,
      !!pred_name := llm_vec_classify(
        x = {{ col }},
        labels = labels,
        additional_prompt = additional_prompt
      )
    )
}

#' @rdname llm_classify
#' @export
llm_vec_classify <- function(x,
                             labels,
                             additional_prompt = "",
                             preview = FALSE) {
  l_vec_prompt(
    x = x,
    prompt_label = "classify",
    additional_prompt = additional_prompt,
    labels = labels,
    valid_resps = labels,
    preview = preview
  )
}
