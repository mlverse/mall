#' @export
llm_extract <- function(x,
                        source_var = NULL,
                        labels,
                        expand_cols = FALSE) {
  UseMethod("llm_extract")
}

#' @export
llm_extract.character <- function(x,
                                  source_var = NULL,
                                  labels,
                                  expand_cols = FALSE) {
  resp <- llm_vec_generate(
    x = x,
    base_prompt = extract_prompt(labels)
  )
  vec_resp <- purrr::map(resp, ~ map_chr(strsplit(.x, "\\|")[[1]], trimws))
  as.data.frame(vec_resp, col.names = clean_names(labels))
}

extract_prompt <- function(labels) {
  labels <- paste0(labels, collapse = ", ")
  glue(
    "Look for and return the {labels} being ",
    "referred to in the following text. ",
    "Do not include explanations. ",
    "No capitalization. ",
    "Return the response in a simple pipe separated list, no headers"
  )
}

clean_names <- function(x) {
  x <- tolower(x)
  map_chr(
    x, ~ {
      xs <- strsplit(.x, " ")[[1]]
      paste0(xs, collapse = "_")
    }
  )
}
