#' @export
llm_extract <- function(.data,
                        x = NULL,
                        labels,
                        expand_cols = FALSE,
                        additional_prompt = "") {
  UseMethod("llm_extract")
}

#' @export
llm_extract.data.frame <- function(.data,
                                   x = NULL,
                                   labels = c(),
                                   expand_cols = FALSE,
                                   additional_prompt = "") {
  if (expand_cols && length(labels) > 1) {
    resp <- llm_vec_extract(
      x = .data$x, 
      labels = labels,
      additional_prompt = additional_prompt
      )
    resp <- map_df(
      resp,
      \(x) ({
        x <- trimws(strsplit(x, "\\|")[[1]])
        names(x) <- clean_names(labels)
        x
      })
    )
    resp <- bind_cols(.data, resp)
  } else {
    resp <- mutate(
      .data = .data,
       labels := llm_vec_extract(
        x = {{ x }},
        labels = labels, 
        additional_prompt = additional_prompt
      )
    )  
  }
  resp
}

#' @export
llm_vec_extract <- function(x,
                            labels = c(),
                            additional_prompt = "") {
  llm_vec_prompt(
    x = x, 
    prompt_label = "extract", 
    labels = labels, 
    additional_prompt = additional_prompt
  )
}
