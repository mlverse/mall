#' Translates text to a specific language
#'
#' @description
#' Use a Large Language Model (LLM) to translate a text to a specific
#' language
#'
#' @inheritParams llm_classify
#' @param language Target language to translate the text to
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
#' # Pass the desired language to translate to
#' llm_translate(reviews, review, "spanish")
#' 
#' }
#' @returns `llm_translate` returns a `data.frame` or `tbl` object.
#' `llm_vec_translate` returns a vector that is the same length as `x`.
#' @export
llm_translate <- function(.data,
                          col,
                          language,
                          pred_name = ".translation",
                          additional_prompt = "") {
  UseMethod("llm_translate")
}

#' @export
llm_translate.data.frame <- function(.data,
                                     col,
                                     language,
                                     pred_name = ".translation",
                                     additional_prompt = "") {
  mutate(
    .data = .data,
    !!pred_name := llm_vec_translate(
      x = {{ col }},
      language = language,
      additional_prompt = additional_prompt
    )
  )
}

#' @rdname llm_translate
#' @export
llm_vec_translate <- function(
    x,
    language,
    additional_prompt = "",
    preview = FALSE) {
  m_vec_prompt(
    x = x,
    prompt_label = "translate",
    additional_prompt = additional_prompt,
    language = language,
    preview = preview
  )
}
