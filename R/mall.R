#' @importFrom purrr map_chr map_df
#' @importFrom dplyr mutate tibble bind_cols
#' @importFrom ollamar generate test_connection
#' @import glue
#' @import rlang
#' @import cli

.env_llm <- new.env()
.env_llm$defaults <- list()
