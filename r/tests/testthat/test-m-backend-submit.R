test_that("Ollama code is covered", {
  local_mocked_bindings(
    chat = function(...) "positive"
  )
  llm_use("ollama", "llama3.2", .silent = TRUE, .force = TRUE)
  expect_equal(
    llm_vec_sentiment("I am happy"),
    "positive"
  )
})

test_that("Ollama code is covered", {
  local_mocked_bindings(
    warn_tokens = function() 10,
    chat = function(...) "positive"
  )
  llm_use("ollama", "llama3.2", .silent = TRUE, .force = TRUE)
  expect_snapshot(
    llm_vec_sentiment("I am happy")
  )
})

test_that("No cache is saved if turned off", {
  llm_use("simulate_llm", "echo", .silent = TRUE, .force = TRUE, .cache = "")
  expect_equal(
    llm_vec_custom("test text", "nothing new: "),
    "test text"
  )
})
