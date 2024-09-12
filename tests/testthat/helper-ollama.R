skip_if_no_ollama <- function() {
  con <- ollamar::test_connection()
  if (con$status_code != 200) {
    skip("No Ollama found")
  }
}

reviews_vec <- function() {
  c(
    "This has been the best TV I've ever used. Great screen, and sound.",
    "I regret buying this laptop. It is too slow and the keyboard is too noisy",
    "Not sure how to feel about my new washing machine. Great color, but hard to figure"
  )
}

reviews_table <- function() {
  data.frame(reviews = reviews_vec())
}
