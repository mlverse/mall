#' @export
llm_extract <- function(x,
                        source_var = NULL,
                        labels
                        ) {
  UseMethod("llm_extract")
}


#' @export
llm_extract.character <- function(x,
                        source_var = NULL,
                        labels
) {
  resp <- llm_generate(
    x = x,
    base_prompt = extract_prompt(labels)
  )
  vec_resp <- map_chr(strsplit(resp, "\\|")[[1]], trimws)
  names(vec_resp) <- labels
  vec_resp
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



