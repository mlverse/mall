test_that("Classify works", {
  test_text <- "this is a test"
  llm_use("simulate_llm", "echo", .silent = TRUE)
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
