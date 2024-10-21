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
#' @examples
#' \donttest{
#' library(mall)
#'
#' data("reviews")
#'
#' llm_use("ollama", "llama3.2", seed = 100, .silent = TRUE)
#'
#' llm_classify(reviews, review, c("appliance", "computer"))
#'
#' # Use 'pred_name' to customize the new column's name
#' llm_classify(
#'   reviews,
#'   review,
#'   c("appliance", "computer"),
#'   pred_name = "prod_type"
#' )
#'
#' # Pass custom values for each classification
#' llm_classify(reviews, review, c("appliance" ~ 1, "computer" ~ 2))
#'
#' # For character vectors, instead of a data frame, use this function
#' llm_vec_classify(
#'   c("this is important!", "just whenever"),
#'   c("urgent", "not urgent")
#' )
#'
#' # To preview the first call that will be made to the downstream R function
#' llm_vec_classify(
#'   c("this is important!", "just whenever"),
#'   c("urgent", "not urgent"),
#'   preview = TRUE
#' )
#' }
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

#' @export
`llm_classify.tbl_Spark SQL` <- function(.data,
                                         col,
                                         labels,
                                         pred_name = ".classify",
                                         additional_prompt = "") {
  prep_labels <- paste0("'", labels, "'", collapse = ", ")
  mutate(
    .data = .data,
    !!pred_name := ai_classify({{ col }}, array(sql(prep_labels)))
  )
}

globalVariables(c("ai_classify", "array"))

#' @rdname llm_classify
#' @export
llm_vec_classify <- function(x,
                             labels,
                             additional_prompt = "",
                             preview = FALSE) {
  m_vec_prompt(
    x = x,
    prompt_label = "classify",
    additional_prompt = additional_prompt,
    labels = labels,
    valid_resps = labels,
    preview = preview
  )
}
