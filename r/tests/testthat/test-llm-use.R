test_that("Ollama not found error", {
  local_mocked_bindings(
    test_connection = function() {
      x <- list()
      x$status_code <- 400
      x
    }
  )
  m_defaults_reset()
  expect_error(llm_use())
})

test_that("Init code is covered", {
  local_mocked_bindings(
    test_connection = function() {
      x <- list()
      x$status_code <- 200
      x
    },
    list_models = function() data.frame(name = c("model1", "model2")),
    menu = function(...) 1
  )
  m_defaults_reset()
  expect_snapshot(llm_use(.cache = ""))
})

test_that("Stops cache", {
  expect_snapshot(
    llm_use("simulate_llm", "echo", .force = TRUE, .cache = "")
  )
})

test_that("Chat objects work", {
  withr::with_envvar(
    new = list(OPENAI_API_KEY = "test"),
    {
      m_defaults_reset()
      chat <- ellmer::chat_openai()
      expect_snapshot(
        llm_use(chat, .cache = "")
      )
    }
  )
})

test_that("Ensures empty llm_use works with Chat", {
  withr::with_envvar(
    new = list(OPENAI_API_KEY = "test"),
    {
      m_defaults_reset()
      chat <- ellmer::chat_openai()
      llm_use(chat, .cache = "", .silent = TRUE)
      expect_snapshot(
        llm_use()
      )
    }
  )
})

test_that("Chat error message", {
  withr::with_envvar(
    new = list(OPENAI_API_KEY = "test"),
    {
      m_defaults_reset()
      chat <- ellmer::chat_openai()
      expect_error(
        llm_use(chat, .cache = "", model = "test")
      )
    }
  )
})
