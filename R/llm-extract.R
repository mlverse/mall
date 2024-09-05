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
  prompt <- get_prompt("extract", labels)

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
