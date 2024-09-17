test_that("Prompt handles list()", {
  llm_use(backend = "simulate_llm",
          model = "prompt",
          .silent = TRUE,
          .force = TRUE, 
          .cache = "_prompt_cache"
          )
  test_text <- "Custom:{prompt}\n{{x}}"
  expect_equal(
    llm_vec_custom(x = "new test", prompt = test_text),
    list(list(role = "user", content = test_text))
  )
})