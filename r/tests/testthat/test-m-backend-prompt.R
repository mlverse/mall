test_that("Prompt handles list()", {
  llm_use(
    backend = "simulate_llm",
    model = "prompt",
    .silent = TRUE,
    .force = TRUE,
    .cache = tempfile("_prompt_cache")
  )
  test_text <- "Custom:{prompt}\n{{x}}"
  expect_equal(
    llm_vec_custom(x = "new test", prompt = test_text),
    list(list(role = "user", content = test_text))
  )
})

test_that("Prompt handles list()", {
  backend <- llm_use("ollama", "llama3.2:latest", .silent = TRUE)
  x <- m_backend_prompt(backend)
  x_extract <- x$extract(labels = c("a", "b"))
  x_classify <- x$classify(labels = c("a" ~ 1, "b" ~ 2))
  backend <- llm_use("ollama", "llama1", .silent = TRUE)
  y <- m_backend_prompt(backend)
  y_extract <- y$extract(labels = c("a", "b"))
  y_classify <- y$classify(labels = c("a" ~ 1, "b" ~ 2))
  expect_false(x_extract[[1]]$content == y_extract[[1]]$content)
  expect_false(x_classify[[1]]$content == y_classify[[1]]$content)
})
