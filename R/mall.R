#' @importFrom purrr map_chr
#' @importFrom dplyr mutate
#' @importFrom ollamar chat
#' @import glue
#' @import rlang

.env_llm <- new.env()  
.env_llm$defaults <- list()