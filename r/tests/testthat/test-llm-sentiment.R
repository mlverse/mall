test_that("Sentiment works", {
  llm_use("simulate_llm", "pipe", .silent = TRUE, .force = TRUE, .cache = .mall_test$cache)
  expect_equal(
    llm_vec_sentiment("this is a test|positive"),
    "positive"
  )
  expect_equal(
    llm_vec_sentiment("this is a test|1", options = c("positive" ~ 1)),
    1
  )
  expect_message(
    x <- llm_vec_sentiment("this is a test|notvalid")
  )
  expect_equal(x, as.character(NA))

  entries <- c("a|positive", "b|negative")
  expect_equal(
    llm_sentiment(data.frame(x = entries), x),
    data.frame(x = entries, .sentiment = c("positive", "negative"))
  )
  expect_equal(
    llm_sentiment(data.frame(x = entries), x, pred_name = "new"),
    data.frame(x = entries, new = c("positive", "negative"))
  )
})

test_that("Sentiment translates expected Spark SQL", {
  suppressPackageStartupMessages(library(dbplyr))
  df <- data.frame(x = 1)
  df_spark <- tbl_lazy(df, con = simulate_spark_sql())
  expect_snapshot(llm_sentiment(df_spark, x))
})

test_that("Sentiment on Ollama works", {
  skip_if_no_ollama()
  vec_reviews <- reviews_vec()
  reviews <- reviews_table()
  expect_snapshot(llm_vec_sentiment(vec_reviews))
  expect_snapshot(
    llm_vec_sentiment(
      vec_reviews,
      options = c("positive", "negative")
    )
  )
  expect_snapshot(
    llm_vec_sentiment(
      vec_reviews,
      options = c("positive", "negative"),
      additional_prompt = "Consider someone not sure as a positive comment."
    )
  )
  expect_snapshot(llm_sentiment(reviews, review))
  expect_snapshot(llm_sentiment(reviews, review, pred_name = "new"))
})
