test_that("Ollama cache exists and delete", {
  skip_if_no_ollama()
  expect_equal(
    length(fs::dir_ls(.mall_test$cache_ollama , recurse = TRUE)),
    59
  )
  fs::dir_delete(.mall_test$cache_ollama )
})
