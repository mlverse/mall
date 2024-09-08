#' @importFrom ollamar generate test_connection list_models
#' @importFrom dplyr mutate tibble bind_cols
#' @importFrom purrr map_chr map_df
#' @importFrom utils menu
#' @import rlang
#' @import glue
#' @import cli

.env_llm <- new.env()
.env_llm$defaults <- list()
