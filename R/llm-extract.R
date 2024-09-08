#' @export
llm_extract <- function(.data,
                        x = NULL,
                        labels,
                        expand_cols = FALSE,
                        additional_prompt = "",
                        pred_name = ".extract") {
  UseMethod("llm_extract")
}

#' @export
llm_extract.data.frame <- function(.data,
                                   x = NULL,
                                   labels = c(),
                                   expand_cols = FALSE,
                                   additional_prompt = "",
                                   pred_name = ".extract") {
  if (expand_cols && length(labels) > 1) {
    resp <- llm_vec_extract(
      x = .data$x,
      labels = labels,
      additional_prompt = additional_prompt
    )
    resp <- purrr::map(
      resp,
      \(x) ({
        x <- trimws(strsplit(x, "\\|")[[1]])
        names(x) <- clean_names(labels)
        x
      })
    )
    resp <- purrr::transpose(resp)
    var_names <- names(labels)
    resp_names <- names(resp)
    if (!is.null(var_names)) {
      var_names[var_names == ""] <- resp_names[var_names == ""]
    } else {
      var_names <- resp_names
    }
    var_names <- clean_names(var_names)
    for (i in seq_along(resp)) {
      vals <- as.character(resp[[i]])
      .data <- mutate(.data, !!var_names[[i]] := vals)
    }
    resp <- .data
  } else {
    resp <- mutate(
      .data = .data,
      !!pred_name := llm_vec_extract(
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
