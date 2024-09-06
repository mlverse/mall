#' @importFrom purrr map_chr
#' @importFrom dplyr mutate tibble bind_cols
#' @importFrom ollamar generate test_connection list_models
#' @import glue
#' @import rlang
#' @import cli

.env_llm <- new.env()
