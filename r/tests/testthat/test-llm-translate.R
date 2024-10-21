test_that("Translate works", {
  test_text <- "this is a test"
  llm_use("simulate_llm", "echo", .silent = TRUE, .force = TRUE, .cache = .mall_test$cache)
  expect_equal(
    llm_vec_translate(test_text, language = "other"),
    test_text
  )

  expect_equal(
    llm_translate(data.frame(x = test_text), x, language = "other"),
    data.frame(x = test_text, .translation = test_text)
  )

  expect_equal(
    llm_translate(
      data.frame(x = test_text),
      x,
      pred_name = "new",
      language = "other"
    ),
    data.frame(x = test_text, new = test_text)
  )
})

test_that("Translate on Ollama works", {
  skip_if_no_ollama()
  expect_snapshot(llm_translate(reviews_table(), review, "spanish"))
})
