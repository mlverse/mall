#' @export
llm_extract <- function(.data,
                        x = NULL,
                        labels,
                        expand_cols = FALSE) {
  UseMethod("llm_extract")
}

#' @export
llm_extract.data.frame <- function(.data,
                                   x = NULL,
                                   labels = c(),
                                   expand_cols = FALSE) {
  prompt <- extract_prompt(labels)

  if (expand_cols && length(labels) > 1) {
    resp <- llm_vec_generate(x, prompt)
    resp <- map_df(
      resp, ~ {
        x <- trimws(strsplit(.x, "\\|")[[1]])
        names(x) <- clean_names(labels)
        x
      }
    )
    resp <- bind_cols(x, resp)
  } else {
    resp <- llm_custom(
      .data = .data,
      x = {{ x }},
      prompt = prompt,
      pred_name = clean_names(labels)
    )
  }
  resp
}

extract_prompt <- function(labels) {
  no_labels <- length(labels)
  labels <- paste0(labels, collapse = ", ")
  glue(
    "You are a helpful text extraction engine.",
    "Extract the {labels} being referred to on the text. ",
    "I expect {no_labels} item(s) exactly. ",
    "No capitalization. No explanations.",
    "Return the response in a simple pipe separated list, no headers. ",
    "The answer is based on the following text:"
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
