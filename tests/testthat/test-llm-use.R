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
  expect_message(llm_use())
})

test_that("Stops cache", {
  expect_snapshot(
    llm_use("simulate_llm", "echo", .force = TRUE, .cache = "")
  )
})
