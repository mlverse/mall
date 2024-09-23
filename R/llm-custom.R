#' Send a custom prompt to the LLM
#'
#' @description
#' Use a Large Language Model (LLM) to process the provided text using the
#' instructions from `prompt`
#'
#' @inheritParams llm_classify
#' @param prompt The prompt to append to each record sent to the LLM
#' @param valid_resps If the response from the LLM is not open, but
#' deterministic, provide the options in a vector. This function will set to
#' `NA` any response not in the options
#' @examples
#' \dontrun{
#' library(mall)
#'
#' llm_use("ollama", "llama3.1", seed = 100, .silent = TRUE)
#'
#' reviews <- data.frame(review = c(
#'   "This has been the best TV I've ever used. Great screen, and sound.",
#'   "I regret buying this laptop. It is too slow and the keyboard is too noisy",
#'   "Not sure how to feel about my new washing machine. Great color, but hard to figure"
#' ))
#' 
#' my_prompt <- paste(
#'   "Answer a question.",
#'   "Return only the answer, no explanation",
#'   "Acceptable answers are 'yes', 'no'",
#'   "Answer this about the following text, is this a happy customer?:"
#' )
#' 
#' reviews |>
#'   llm_custom(review, my_prompt)
#' 
#' } 
#' @returns `llm_custom` returns a `data.frame` or `tbl` object.
#' `llm_vec_custom` returns a vector that is the same length as `x`.
#' @export
llm_custom <- function(
    .data,
    col,
    prompt = "",
    pred_name = ".pred",
    valid_resps = "") {
  UseMethod("llm_custom")
}

#' @export
llm_custom.data.frame <- function(.data,
                                  col,
                                  prompt = "",
                                  pred_name = ".pred",
                                  valid_resps = NULL) {
  mutate(
    .data = .data,
    !!pred_name := llm_vec_custom(
      x = {{ col }},
      prompt = prompt,
      valid_resps = valid_resps
    )
  )
}

#' @rdname llm_custom
#' @export
llm_vec_custom <- function(x, prompt = "", valid_resps = NULL) {
  m_vec_prompt(
    x = x,
    prompt = prompt,
    valid_resps = valid_resps
  )
}
