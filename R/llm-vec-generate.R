#' @export
llm_vec_generate <- function(x, prompt, valid_resps = NULL) {
  llm_init(.silent = TRUE, .force = FALSE)
  resp <- mall_backend_generate(defaults_get(), x, prompt)
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
