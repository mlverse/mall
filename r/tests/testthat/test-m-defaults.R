test_that("Full print works", {
  llm_use(
    backend = "simulate_llm",
    model = "prompt",
    .silent = TRUE,
    .force = TRUE,
    .cache = tempdir()
  )
  x <- m_defaults_get()
  x$args <- list(model = "prompt", arg1 = "one", arg2 = "two")
  x$session$cache_folder <- "folder"
  expect_snapshot(x)
})
