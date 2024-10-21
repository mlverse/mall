test_that("Verify works", {
  test_text <- "this is a test"
  llm_use("simulate_llm", "echo", .silent = TRUE, .force = TRUE, .cache = .mall_test$cache)
  expect_equal(
    llm_vec_verify(test_text, "test", yes_no = test_text),
    test_text
  )
  expect_equal(
    llm_vec_verify(0, "question", factor(0, 0)),
    as.factor(0)
  )
  expect_message(
    x <- llm_vec_verify(test_text, "test", yes_no = "different test")
  )
  expect_equal(x, as.character(NA))

  expect_equal(
    llm_verify(data.frame(x = test_text), x, "test", yes_no = test_text),
    data.frame(x = test_text, .verify = test_text)
  )

  expect_equal(
    llm_verify(
      data.frame(x = test_text),
      x,
      what = "test",
      yes_no = test_text,
      pred_name = "new"
    ),
    data.frame(x = test_text, new = test_text)
  )
})

test_that("Preview works", {
  llm_use("ollama", "llama3.2", seed = 100, .silent = TRUE)
  expect_snapshot(
    llm_vec_verify("this is a test", "a test", preview = TRUE)
  )
})

test_that("Verify on Ollama works", {
  skip_if_no_ollama()
  reviews <- reviews_table()
  expect_snapshot(
    llm_verify(
      reviews,
      review,
      "is the customer happy"
    )
  )
  reviews <- reviews_table()
  expect_snapshot(
    llm_verify(
      reviews,
      review,
      "is the customer happy",
      yes_no = c("y", "n")
    )
  )
})
