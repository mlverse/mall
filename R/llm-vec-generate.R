#' @export
llm_vec_generate <- function(x, prompt, valid_resps = NULL) {
  resp <- llm_backend_generate(.env_llm$defaults, x, prompt)
  if (!is.null(valid_resps)) {
    errors <- !resp %in% valid_resps
    resp[errors] <- NA
    cli_alert_warning(
      "There were {sum(errors)} predictions with invalid output, they were coerced to NA"
    )
  }
  resp
}
