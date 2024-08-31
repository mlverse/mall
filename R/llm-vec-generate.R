#' @export
llm_vec_generate <- function(x, prompt) {
  llm_backend_generate(.env_llm$defaults, x, prompt)
}
