m_vec_prompt <- function(x,
                         prompt_label = "",
                         additional_prompt = "",
                         valid_resps = NULL,
                         prompt = NULL,
                         convert = NULL,
                         preview = FALSE,
                         ...) {
  # Initializes session LLM
  backend <- llm_use(.silent = TRUE, .force = FALSE)
  # If there is no 'prompt', then assumes that we're looking for a
  # prompt label (sentiment, classify, etc) to set 'prompt'
  if (is.null(prompt)) {
    defaults <- m_backend_prompt(
      backend = backend,
      additional = additional_prompt
    )
    fn <- defaults[[prompt_label]]
    prompt <- fn(...)
  }
  # If the prompt is a character, it will convert it to
  # a list so it can be processed
  if (!inherits(prompt, "list")) {
    p_split <- strsplit(prompt, "\\{\\{x\\}\\}")[[1]]
    if (length(p_split) == 1 && p_split == prompt) {
      content <- glue("{prompt}\n{{x}}")
    } else {
      content <- prompt
    }
    prompt <- list(
      list(role = "user", content = content)
    )
  }
  # Submits final prompt to the LLM
  resp <- m_backend_submit(
    backend = backend,
    x = x,
    prompt = prompt,
    preview = preview
  )
  if (preview) {
    return(resp[[1]])
  }

  # Checks for invalid output and marks them as NA
  if (all_formula(valid_resps)) {
    valid_resps <- list_c(map(valid_resps, f_rhs))
  }

  if (!is.null(convert)) {
    for (i in seq_along(convert)) {
      resp[resp == names(convert[i])] <- as.character(convert[[i]])
    }
  }

  if (!is.null(valid_resps)) {
    errors <- !resp %in% valid_resps
    resp[errors] <- NA
    if (any(errors)) {
      cli_alert_warning(
        c(
          "There were {sum(errors)} predictions with ",
          "invalid output, they were coerced to NA"
        )
      )
    }
  }

  if (is.numeric(valid_resps)) {
    resp <- as.numeric(resp)
  }
  if (is.factor(valid_resps)) {
    resp <- as.factor(resp)
  }
  resp
}
