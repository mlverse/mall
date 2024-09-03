#' @export
llm_vec_generate <- function(x, prompt, valid_resps = NULL) {
  resp <- llm_backend_generate(.env_llm$defaults, x, prompt)
  if (!is.null(valid_resps)) {
    resp[!resp %in% valid_resps] <- "#err"
  }
  resp
}
