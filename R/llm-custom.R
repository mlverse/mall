#' Send a custom prompt to the LLM
#'
#' @description
#' Use a Large Language Model (LLM) to process the provided text using the
#' instructions from `prompt`
#'
#' @inheritParams llm_classify
#' @param prompt The prompt to append to each record sent to the LLM
#' @param valid_resps If the response from the LLM is not open, but deterministic,
#' provide the options in a vector. This function will set to `NA` any response
#' not in the options
#' @export
llm_custom <- function(
    .data,
    col,
    prompt,
    pred_name = ".pred",
    valid_resps = "") {
  UseMethod("llm_custom")
}

#' @export
llm_custom.data.frame <- function(.data,
                                  col,
                                  prompt,
                                  pred_name = ".pred",
                                  valid_resps = NULL) {
  mutate(
    .data = .data,
    !!pred_name := llm_vec_custom(
      x = {{ x }},
      prompt = prompt,
      valid_resps = valid_resps
    )
  )
}

#' @export
llm_vec_custom <- function(x, prompt, valid_resps = NULL) {
  mall_init(.silent = TRUE, force = FALSE)
  resp <- m_backend_generate(defaults_get(), x, prompt)
  if (!is.null(valid_resps)) {
    errors <- !resp %in% valid_resps
    resp[errors] <- NA
    if (any(errors)) {
      cli_alert_warning(
        c(
          "There were {sum(errors)} predictions with ",
          "invalid output, they were coerced to NA"
        )
      )
    }
  }
  resp
}
