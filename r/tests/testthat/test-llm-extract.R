test_that("Extract works", {
  llm_use("simulate_llm", "prompt", .silent = TRUE, .force = TRUE, .cache = .mall_test$cache)

  expect_snapshot(
    llm_vec_extract("toaster", labels = "product")
  )
})

test_that("Extract data frame works", {
  llm_use("simulate_llm", "echo", .silent = TRUE, .force = TRUE)

  expect_equal(
    llm_extract(data.frame(x = "test"), x, labels = "product"),
    data.frame(x = "test", .extract = "test")
  )

  expect_equal(
    llm_extract(
      .data = data.frame(x = "test1|test2"),
      col = x,
      labels = c("product1", "product2"),
      expand_cols = TRUE
    ),
    data.frame(x = "test1|test2", product1 = "test1", product2 = "test2")
  )

  expect_equal(
    llm_extract(
      .data = data.frame(x = "test1|test2"),
      col = x,
      labels = c(y = "product1", z = "product2"),
      expand_cols = TRUE
    ),
    data.frame(x = "test1|test2", y = "test1", z = "test2")
  )
})

test_that("Extract on Ollama works", {
  skip_if_no_ollama()
  expect_snapshot(llm_extract(reviews_table(), review, "product"))
  expect_snapshot(
    llm_vec_extract("bob smith, 105 2nd street", c("name", "address"))
  )
})
