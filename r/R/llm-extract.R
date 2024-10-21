#' Extract entities from text
#'
#' @description
#' Use a Large Language Model (LLM) to extract specific entity, or entities,
#' from the provided text
#'
#' @inheritParams llm_classify
#' @param labels A vector with the entities to extract from the text
#' @param expand_cols If multiple `labels` are passed, this is a flag that
#' tells the function to create a new column per item in `labels`. If
#' `labels` is a named vector, this function will use those names as the
#' new column names, if not, the function will use a sanitized version of
#' the content as the name.
#' @examples
#' \donttest{
#' library(mall)
#'
#' data("reviews")
#'
#' llm_use("ollama", "llama3.2", seed = 100, .silent = TRUE)
#'
#' # Use 'labels' to let the function know what to extract
#' llm_extract(reviews, review, labels = "product")
#'
#' # Use 'pred_name' to customize the new column's name
#' llm_extract(reviews, review, "product", pred_name = "prod")
#'
#' # Pass a vector to request multiple things, the results will be pipe delimeted
#' # in a single column
#' llm_extract(reviews, review, c("product", "feelings"))
#'
#' # To get multiple columns, use 'expand_cols'
#' llm_extract(reviews, review, c("product", "feelings"), expand_cols = TRUE)
#'
#' # Pass a named vector to set the resulting column names
#' llm_extract(
#'   .data = reviews,
#'   col = review,
#'   labels = c(prod = "product", feels = "feelings"),
#'   expand_cols = TRUE
#' )
#'
#' # For character vectors, instead of a data frame, use this function
#' llm_vec_extract("bob smith, 123 3rd street", c("name", "address"))
#'
#' # To preview the first call that will be made to the downstream R function
#' llm_vec_extract(
#'   "bob smith, 123 3rd street",
#'   c("name", "address"),
#'   preview = TRUE
#' )
#' }
#' @returns `llm_extract` returns a `data.frame` or `tbl` object.
#' `llm_vec_extract` returns a vector that is the same length as `x`.
#' @export
llm_extract <- function(.data,
                        col,
                        labels,
                        expand_cols = FALSE,
                        additional_prompt = "",
                        pred_name = ".extract") {
  UseMethod("llm_extract")
}

#' @export
llm_extract.data.frame <- function(.data,
                                   col,
                                   labels = c(),
                                   expand_cols = FALSE,
                                   additional_prompt = "",
                                   pred_name = ".extract") {
  if (expand_cols && length(labels) > 1) {
    text <- pull(.data, {{ col }})
    resp <- llm_vec_extract(
      x = text,
      labels = labels,
      additional_prompt = additional_prompt
    )
    resp <- map(
      resp,
      \(x) ({
        x <- strsplit(x, "\\|")[[1]]
        names(x) <- clean_names(labels)
        x
      })
    )
    resp <- transpose(resp)
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
        x = {{ col }},
        labels = labels,
        additional_prompt = additional_prompt
      )
    )
  }
  resp
}

#' @rdname llm_extract
#' @export
llm_vec_extract <- function(x,
                            labels = c(),
                            additional_prompt = "",
                            preview = FALSE) {
  m_vec_prompt(
    x = x,
    prompt_label = "extract",
    labels = labels,
    additional_prompt = additional_prompt,
    preview = preview
  )
}
