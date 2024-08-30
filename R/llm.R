#' @export 
llm_generate <- function(x, base_prompt) {
  map_chr(x, ~{
    ollamar::chat(
      model = "llama3.1",
      messages = list(
        list(role = "user", content = glue("{base_prompt} {.x}"))
      ),
      output = "text"
    )
  }, 
  .progress = TRUE
  )
}