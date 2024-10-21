test_that("Summarize works", {
  test_text <- "this is a test"
  llm_use("simulate_llm", "echo", .silent = TRUE, .force = TRUE, .cache = .mall_test$cache)
  expect_equal(
    llm_vec_summarize(test_text),
    test_text
  )

  expect_equal(
    llm_summarize(data.frame(x = test_text), x),
    data.frame(x = test_text, .summary = test_text)
  )

  expect_equal(
    llm_summarize(
      data.frame(x = test_text),
      x,
      pred_name = "new"
    ),
    data.frame(x = test_text, new = test_text)
  )
})

test_that("Summarize translates expected Spark SQL", {
  suppressPackageStartupMessages(library(dbplyr))
  df <- data.frame(x = 1)
  df_spark <- tbl_lazy(df, con = simulate_spark_sql())
  expect_snapshot(llm_summarize(df_spark, x))
  expect_snapshot(llm_summarize(df_spark, x, max_words = 50))
})

test_that("Summarize on Ollama works", {
  skip_if_no_ollama()
  expect_snapshot(llm_summarize(reviews_table(), review, max_words = 5))
})
