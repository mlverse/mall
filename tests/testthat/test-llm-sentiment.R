test_that("Sentiment works", {
  llm_use("simulate_llm", "pipe", .silent = TRUE)
  expect_equal(
    llm_vec_sentiment("this is a test|positive"),
    "positive"
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
