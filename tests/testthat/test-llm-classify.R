test_that("Classify - vector function works", {
  # llm_use("simulate_llm", "echo", .silent = TRUE)
  expect_equal(
    llm_vec_classify("this is a test", labels = "this is a test"),
    "this is a test"
  )
  expect_message(
    x <- llm_vec_classify("this is a test", labels = "different test")
  )
  expect_equal(x, as.character(NA))
})

test_that("Classify - tbl function works", {
  llm_use("simulate_llm", "echo", .silent = TRUE)
  expect_equal(
    llm_classify(data.frame(x = "this is a test"), x, labels = "this is a test"),
    data.frame(x = "this is a test", .classify = "this is a test")
  )
})
