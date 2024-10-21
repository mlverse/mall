.mall_test <- new.env()
.mall_test$ollama_present <- FALSE
.mall_test$ollama_checked <- FALSE
.mall_test$cache_ollama <- tempfile("_ollama_cache")
.mall_test$cache <- tempfile("_mall_cache")

ollama_is_present <- function() {
  if (.mall_test$ollama_checked) {
    ollama_present <- .mall_test$ollama_present
  } else {
    con <- ollamar::test_connection()
    ollama_present <- con$status_code == 200
    .mall_test$ollama_present <- ollama_present
    .mall_test$ollama_checked <- TRUE
  }
  ollama_present
}

skip_if_no_ollama <- function() {
  if (!ollama_is_present()) {
    skip("Ollama not found")
  } else {
    .mall_test$ollama_present <- TRUE
    llm_use(
      backend = "ollama",
      model = "llama3.2",
      seed = 100,
      .silent = TRUE,
      .force = TRUE,
      .cache = .mall_test$cache_ollama 
    )
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
  data.frame(review = reviews_vec())
}
