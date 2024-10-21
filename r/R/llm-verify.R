#' Verify if a statement about the text is true or not
#' @description
#' Use a Large Language Model (LLM) to see if something is true or not
#' based the provided text
#'
#' @inheritParams llm_classify
#' @param what The statement or question that needs to be verified against the
#' provided text
#' @param yes_no A size 2 vector that specifies the expected output. It is
#' positional. The first item is expected to be value to return if the
#' statement about the provided text is true, and the second if it is not. Defaults
#' to: `factor(c(1, 0))`
#' @returns `llm_verify` returns a `data.frame` or `tbl` object.
#' `llm_vec_verify` returns a vector that is the same length as `x`.
#'
#' @examples
#' \donttest{
#' library(mall)
#'
#' data("reviews")
#'
#' llm_use("ollama", "llama3.2", seed = 100, .silent = TRUE)
#'
#' # By default it will return 1 for 'true', and 0 for 'false',
#' # the new column will be a factor type
#' llm_verify(reviews, review, "is the customer happy")
#'
#' # The yes_no argument can be modified to return a different response
#' # than 1 or 0. First position will be 'true' and second, 'false'
#' llm_verify(reviews, review, "is the customer happy", c("y", "n"))
#'
#' # Number can also be used, this would be in the case that you wish to match
#' # the output values of existing predictions
#' llm_verify(reviews, review, "is the customer happy", c(2, 1))
#' }
#'
#' @export
llm_verify <- function(.data,
                       col,
                       what,
                       yes_no = factor(c(1, 0)),
                       pred_name = ".verify",
                       additional_prompt = "") {
  UseMethod("llm_verify")
}

#' @export
llm_verify.data.frame <- function(.data,
                                  col,
                                  what,
                                  yes_no = factor(c(1, 0)),
                                  pred_name = ".verify",
                                  additional_prompt = "") {
  mutate(
    .data = .data,
    !!pred_name := llm_vec_verify(
      x = {{ col }},
      what = what,
      yes_no = yes_no,
      additional_prompt = additional_prompt
    )
  )
}

#' @rdname llm_verify
#' @export
llm_vec_verify <- function(x,
                           what,
                           yes_no = factor(c(1, 0)),
                           additional_prompt = "",
                           preview = FALSE) {
  m_vec_prompt(
    x = x,
    prompt_label = "verify",
    what = what,
    labels = yes_no,
    valid_resps = yes_no,
    convert = c("yes" = yes_no[1], "no" = yes_no[2]),
    additional_prompt = additional_prompt,
    preview = preview
  )
}
