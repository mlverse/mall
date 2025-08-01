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
    test_text
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
  expect_false(x_extract == y_extract)
  expect_false(x_classify == y_classify)
})

test_that("Ellmer method works", {
  llm_use(
    backend = "simulate_llm",
    model = "echo",
    .silent = TRUE,
    .force = TRUE,
    .cache = ""
  )
  ellmer_session <- .env_llm$session
  class(ellmer_session) <- c("mall_ellmer", "mall_session")
  ellmer_funcs <- m_backend_prompt(ellmer_session, "")
  expect_snapshot(ellmer_funcs$sentiment("positive"))
})
