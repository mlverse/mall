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
  .env_llm$defaults <- list()
  expect_message(llm_use())
})
