#' @export
llm_custom <- function(
    .data,
    x,
    prompt,
    pred_name = ".pred",
    valid_resps = "") {
  UseMethod("llm_custom")
}

#' @export
llm_custom.data.frame <- function(.data,
                                  x,
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
