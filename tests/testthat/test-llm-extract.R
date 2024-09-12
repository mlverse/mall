test_that("Extract works", {
  llm_use("simulate_llm", "echo", .silent = TRUE)

  expect_equal(
    llm_vec_extract("{\"product\":\"toaster\"}", labels = "product"),
    "toaster"
  )

  entries2 <- "{\"product\":\"toaster\", \"product\":\"TV\"}"
  entries2_result <- "toaster|TV"
  expect_equal(
    llm_vec_extract(
      entries2,
      labels = "product"
    ),
    entries2_result
  )
  expect_equal(
    llm_extract(data.frame(x = entries2), x, labels = "product"),
    data.frame(x = entries2, .extract = entries2_result)
  )
  expect_equal(
    llm_extract(
      .data = data.frame(x = entries2),
      col = x,
      labels = c("product1", "product2"),
      expand_cols = TRUE
    ),
    data.frame(x = entries2, product1 = "toaster", product2 = "TV")
  )
  expect_equal(
    llm_extract(
      .data = data.frame(x = entries2),
      col = x,
      labels = c(y = "product1", z = "product2"),
      expand_cols = TRUE
    ),
    data.frame(x = entries2, y = "toaster", z = "TV")
  )
})
