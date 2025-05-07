test_that("Ollama code is covered", {
  local_mocked_bindings(
    chat = function(...) "positive"
  )
  llm_use("ollama", "llama3.2", .silent = TRUE, .force = TRUE)
  expect_equal(
    llm_vec_sentiment("I am happy"),
    "positive"
  )
})

test_that("Ollama code is covered", {
  local_mocked_bindings(
    m_ollama_tokens = function() 10,
    chat = function(...) "positive"
  )
  llm_use("ollama", "llama3.2", .silent = TRUE, .force = TRUE)
  expect_snapshot(
    llm_vec_sentiment("I am happy")
  )
})

test_that("No cache is saved if turned off", {
  llm_use("simulate_llm", "echo", .silent = TRUE, .force = TRUE, .cache = "")
  expect_equal(
    llm_vec_custom("test text", "nothing new: "),
    "test text"
  )
})

test_that("ellmer code is covered", {
  local_mocked_bindings(
    m_ellmer_chat = function(...) "this is a test"
  )
  llm_use("simulate_llm", "echo", .silent = TRUE, .force = TRUE, .cache = .mall_test$cache)
  ellmer_session <- .env_llm$session
  class(ellmer_session) <- c("mall_ellmer")
  expect_equal(
    m_backend_submit(
      backend = ellmer_session,
      x = "test",
      prompt = list(list(content = "test"))
      ),
    "this is a test"
  )
})
