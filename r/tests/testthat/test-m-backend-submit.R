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
  test_txt <- rep("positive", times = 15)
  local_mocked_bindings(
    m_ollama_tokens = function() 10,
    chat = function(...) "positive"
  )
  llm_use("ollama", "llama3.2", .silent = TRUE, .force = TRUE)
  expect_snapshot(
    llm_vec_sentiment(test_txt)
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
    m_ellmer_chat = function(...) "test"
  )
  llm_use("simulate_llm", "echo", .silent = TRUE, .force = TRUE, .cache = .mall_test$cache)
  ellmer_session <- .env_llm$session
  class(ellmer_session) <- c("mall_ellmer")
  test_txt <- rep("test", times = 15)
  expect_equal(
    m_backend_submit(
      backend = ellmer_session,
      x = test_txt,
      prompt = list(list(content = "test"))
      ),
    test_txt
  )
  expect_snapshot(
    m_backend_submit(
      backend = ellmer_session,
      x = "test",
      prompt = list(list(content = "test")),
      preview = TRUE
    )
  )
  expect_snapshot(
   m_ellmer_chat()
  )
})

test_that("ellmer code is covered - part II", {
  withr::with_envvar(
    new = list(OPENAI_API_KEY = "test"),
    {
      m_defaults_reset()
      chat <- ellmer::chat_openai()
      llm_use(chat, .cache = "", .silent = TRUE)
      expect_snapshot(
        str(m_ellmer_chat())
      )
    }
  )
})

