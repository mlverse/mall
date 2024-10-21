test_that("Classify works", {
  test_text <- "this is a test"
  llm_use("simulate_llm", "echo", .silent = TRUE, .force = TRUE, .cache = .mall_test$cache)
  expect_equal(
    llm_vec_classify(test_text, labels = test_text),
    test_text
  )
  expect_message(
    x <- llm_vec_classify(test_text, labels = "different test")
  )
  expect_equal(x, as.character(NA))

  expect_equal(
    llm_classify(data.frame(x = test_text), x, labels = test_text),
    data.frame(x = test_text, .classify = test_text)
  )

  expect_equal(
    llm_classify(
      data.frame(x = test_text),
      x,
      labels = test_text,
      pred_name = "new"
    ),
    data.frame(x = test_text, new = test_text)
  )
})

test_that("Classify translates expected Spark SQL", {
  suppressPackageStartupMessages(library(dbplyr))
  df <- data.frame(x = 1)
  df_spark <- tbl_lazy(df, con = simulate_spark_sql())
  expect_snapshot(llm_classify(df_spark, x, c("a", "b")))
})

test_that("Preview works", {
  llm_use("ollama", "llama3.2", seed = 100, .silent = FALSE)
  expect_snapshot(
    llm_vec_classify("this is a test", c("a", "b"), preview = TRUE)
  )
})

test_that("Classify on Ollama works", {
  skip_if_no_ollama()
  reviews <- reviews_table()
  expect_snapshot(
    llm_classify(
      reviews,
      review,
      labels = c("appliance", "computer")
    )
  )
  expect_snapshot(
    llm_classify(
      reviews,
      review,
      pred_name = "new",
      labels = c("appliance", "computer")
    )
  )
  expect_snapshot(
    llm_classify(
      reviews,
      review,
      pred_name = "new",
      labels = c("appliance", "computer"),
      additional_prompt = "Consider all laptops as appliances."
    )
  )
})
