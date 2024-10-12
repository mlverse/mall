#' @export
llm_verify <- function(.data,
                       col,
                       question,
                       yes_no = factor(c(1, 0)),
                       pred_name = ".verify",
                       additional_prompt = "") {
  UseMethod("llm_verify")
}

#' @export
llm_verify.data.frame <- function(.data,
                                  col,
                                  question,
                                  yes_no = factor(c(1, 0)),
                                  pred_name = ".verify",
                                  additional_prompt = "") {
  mutate(
    .data = .data,
    !!pred_name := llm_vec_verify(
      x = {{ col }},
      question = question,
      yes_no = yes_no,
      additional_prompt = additional_prompt
    )
  )
}

llm_vec_verify <- function(x,
                           question,
                           yes_no = factor(c(1, 0)),
                           additional_prompt = "",
                           preview = FALSE) {
  m_vec_prompt(
    x = x,
    prompt_label = "verify",
    question = question,
    yes_no = yes_no,
    valid_resps = yes_no,
    convert = c("yes" = yes_no[1], "no" = yes_no[2]),
    additional_prompt = additional_prompt,
    preview = preview
  )
}
