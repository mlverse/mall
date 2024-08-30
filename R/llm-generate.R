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

#' @export
llm_summarize <- function(x, no_words = 100) {
  base_prompt <- glue(
    "You are a helpful summarization engine.",
    "Your answer will contain no no capitalization and no explanations.",
    "Return no more than {no_words} words", 
    "The answer is the summary of the following text:"
  )
  llm_generate(x = x, base_prompt = base_prompt)
}
