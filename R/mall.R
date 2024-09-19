#' @importFrom ollamar chat test_connection list_models
#' @importFrom dplyr mutate tibble bind_cols pull
#' @importFrom utils menu head
#' @importFrom jsonlite fromJSON read_json write_json
#' @import fs
#' @import rlang
#' @import glue
#' @import cli

.env_llm <- new.env()
.env_llm$defaults <- list()
.env_llm$session <- list()
.env_llm$cache <- NULL
