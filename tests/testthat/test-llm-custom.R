test_that("Custom works", {
  test_text <- "this is a test"
  llm_use("simulate_llm", "prompt", .silent = TRUE)
  expect_equal(
    llm_vec_custom(test_text, "this is a test: "),
    paste0("this is a test: \n", test_text)
  )
  expect_message(
    x <- llm_vec_custom(test_text, "this is a test: ", valid_resps = "not valid")
  )
  expect_equal(x, as.character(NA))

  expect_equal(
    llm_custom(data.frame(x = test_text), x, "this is a test: "),
    data.frame(x = test_text, .pred = paste0("this is a test: \n", test_text))
  )

  expect_equal(
    llm_custom(data.frame(x = test_text), x, "this is a test: ", pred_name = "new"),
    data.frame(x = test_text, new = paste0("this is a test: \n", test_text))
  )
})
