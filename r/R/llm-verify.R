llm_vec_verify <- function(x,
                           question,
                           labels = factor(c(1, 0)),
                           additional_prompt = "",
                           preview = FALSE) {
  m_vec_prompt(
    x = x,
    prompt_label = "verify",
    question = question, 
    labels = labels,
    valid_resps = labels, 
    additional_prompt = additional_prompt,
    preview = preview
  )
}
