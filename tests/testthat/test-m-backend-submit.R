test_that("Ollama code is covered", {
  local_mocked_bindings(
    chat = function(...) "positive"
  )
  llm_use("ollama", "model", .silent = TRUE)
  expect_equal(
    llm_vec_sentiment("I am happy"),
    "positive"
  )
})
