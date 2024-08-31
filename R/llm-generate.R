#' @export
llm_vec_generate <- function(x, base_prompt) {
 l_generate(.env_llm$defaults, x, base_prompt)
}

#' @export
l_generate <- function(backend, x, base_prompt) {
  UseMethod("l_generate")
}

#' @export
l_generate.list <- function(backend, x, base_prompt) {
  try_connection <- ollamar::test_connection()
  
  if(try_connection$status_code == 200) {
    .env_llm$defaults$model <- "llama3.1" 
    class(.env_llm$defaults) <- "ollama"
    return(l_generate(.env_llm$defaults, x, base_prompt))
  }
  invisible()
}

#' @export
l_generate.ollama <- function(backend, x, base_prompt) {
  map_chr(x, ~ {
    ollamar::generate(
      model = backend$model,
      prompt = glue("{base_prompt} {.x}"),
      output = "text"
    )
  },
  .progress = TRUE
  )
}
  
