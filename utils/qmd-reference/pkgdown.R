match_env <- function(topics) {
  out <- rlang::env(rlang::empty_env(),
             "-" = function(x) -x,
             "c" = function(...) c(...)
  )
  
  topic_index <- seq_along(topics$name)
  
  # Each \alias{} is matched to its position
  topics$alias <- lapply(topics$alias, unique)
  aliases <- rlang::set_names(
    rep(topic_index, lengths(topics$alias)),
    unlist(topics$alias)
  )
  rlang::env_bind(out, !!!aliases)
  
  # As is each \name{} - we bind these second so that if \name{x} and \alias{x}
  # are in different files, \name{x} wins. This doesn't usually matter, but
  # \name{} needs to win so that the default_reference_index() matches the
  # correct files
  rlang::env_bind(out, !!!rlang::set_names(topic_index, topics$name))
  
  # dplyr-like matching functions
  
  any_alias <- function(f, ..., .internal = FALSE) {
    alias_match <- topics$alias %>%
      unname() %>%
      map(f, ...) %>%
      map_lgl(any)
    
    name_match <- topics$name %>%
      map_lgl(f, ...)
    
    which((alias_match | name_match) & is_public(.internal))
  }
  
  is_public <- function(internal) {
    if (!internal) !topics$internal else rep(TRUE, nrow(topics))
  }
  out$starts_with <- function(x, internal = FALSE) {
    any_alias(~ grepl(paste0("^", x), .), .internal = internal)
  }
  out$ends_with <- function(x, internal = FALSE) {
    any_alias(~ grepl(paste0(x, "$"), .), .internal = internal)
  }
  out$matches <- function(x, internal = FALSE) {
    any_alias(~ grepl(x, .), .internal = internal)
  }
  out$contains <- function(x, internal = FALSE) {
    any_alias(~ grepl(x, ., fixed = TRUE), .internal = internal)
  }
  out$has_keyword <- function(x) {
    which(map_lgl(topics$keywords, ~ any(. %in% x)))
  }
  out$has_concept <- function(x, internal = FALSE) {
    match <- topics$concepts %>%
      map(~ str_trim(.) == x) %>%
      map_lgl(any)
    
    which(match & is_public(internal))
  }
  out$lacks_concepts <- function(x, internal = FALSE) {
    nomatch <- topics$concepts %>%
      map(~ match(str_trim(.), x, nomatch = FALSE)) %>%
      map_lgl(~ length(.) == 0L | all(. == 0L))
    
    which(nomatch & is_public(internal))
  }
  out$lacks_concept <- out$lacks_concepts
  out
}

is_infix <- function(x) {
  if (is.null(x)) {
    return(FALSE)
  }
  
  x <- as.character(x)
  ops <- c(
    "+", "-", "*", "^", "/",
    "==", ">", "<", "!=", "<=", ">=",
    "&", "|",
    "[[", "[", "$"
  )
  
  grepl("^%.*%$", x) || x %in% ops
}
