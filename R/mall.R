#' @importFrom ollamar chat test_connection list_models
#' @importFrom dplyr mutate tibble bind_cols pull
#' @importFrom utils menu
#' @importFrom jsonlite fromJSON
#' @import rlang
#' @import glue
#' @import cli

.env_llm <- new.env()
.env_llm$defaults <- list()
