test_that("Custom works", {
  test_text <- "this is a test"
  llm_use("simulate_llm", "echo", .silent = TRUE, .force = TRUE, .cache = .mall_test$cache)
  expect_equal(
    llm_vec_custom(test_text, "this is a test: "),
    test_text
  )
  expect_message(
    x <- llm_vec_custom(test_text, "this is a test: ", valid_resps = "not valid")
  )
  expect_equal(x, as.character(NA))

  expect_equal(
    llm_custom(data.frame(x = test_text), x, "this is a test: "),
    data.frame(x = test_text, .pred = test_text)
  )

  expect_equal(
    llm_custom(data.frame(x = test_text), x, "this is a test: ", pred_name = "new"),
    data.frame(x = test_text, new = test_text)
  )
})

test_that("Custom on Ollama works", {
  skip_if_no_ollama()
  my_prompt <- paste(
    "Answer a question.",
    "Return only the answer, no explanation",
    "Acceptable answers are 'yes', 'no'",
    "Answer this about the following text, is this a happy customer?:"
  )
  expect_snapshot(llm_custom(reviews_table(), review, my_prompt))
})
