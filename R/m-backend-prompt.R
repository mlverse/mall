#' @rdname m_backend_submit
#' @export
m_backend_prompt <- function(backend, additional) {
  UseMethod("m_backend_prompt")
}

#' @export
m_backend_prompt.mall_defaults <- function(backend, additional = "") {
  list(
    sentiment = function(options) {
      options <- paste0(options, collapse = ", ")
      list(
        list(
          role = "user",
          content = glue(paste(
            "You are a helpful sentiment engine.",
            "Return only one of the following answers: {options}.",
            "No capitalization. No explanations.",
            "{additional}",
            "The answer is based on the following text:\n{{x}}"
          ))
        )
      )
    },
    summarize = function(max_words) {
      list(
        list(
          role = "user",
          content = glue(paste(
            "You are a helpful summarization engine.",
            "Your answer will contain no no capitalization and no explanations.",
            "Return no more than {max_words} words.",
            "{additional}",
            "The answer is the summary of the following text:\n{{x}}"
          ))
        )
      )
    },
    classify = function(labels) {
      labels <- paste0(labels, collapse = ", ")
      list(
        list(
          role = "user",
          content = glue(paste(
            "You are a helpful classification engine.",
            "Determine if the text refers to one of the following: {labels}.",
            "No capitalization. No explanations.",
            "{additional}",
            "The answer is based on the following text:\n{{x}}"
          ))
        )
      )
    },
    extract = function(labels) {
      no_labels <- length(labels)
      col_labels <- paste0(labels, collapse = ", ")
      json_labels <- paste0("\"", labels, "\":your answer", collapse = ",")
      json_labels <- paste0("{{", json_labels, "}}")
      plural <- ifelse(no_labels > 1, "s", "")
      list(
        list(
          role = "system",
          content = "You only speak simple JSON. Do not write normal text."
        ),
        list(
          role = "user",
          content = glue(paste(
            "You are a helpful text extraction engine.",
            "Extract the {col_labels} being referred to on the text.",
            "I expect {no_labels} item{plural} exactly.",
            "No capitalization. No explanations.",
            "You will use this JSON this format exclusively: {json_labels} .",
            "{additional}",
            "The answer is based on the following text:\n{{x}}"
          ))
        )
      )
    },
    translate = function(language) {
      list(
        list(
          role = "user",
          content = glue(paste(
            "You are a helpful translation engine.",
            "You will return only the translation text, no explanations.",
            "The target language to translate to is: {language}.",
            "{additional}",
            "The answer is the summary of the following text:\n{{x}}"
          ))
        )
      )
    }
  )
}

l_vec_prompt <- function(x,
                         prompt_label = "",
                         additional_prompt = "",
                         valid_resps = NULL,
                         prompt = NULL,
                         cache = TRUE,
                         ...) {
  # Initializes session LLM
  backend <- llm_use(.silent = TRUE, force = FALSE)
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
    cache = cache
  )
  # Checks for invalid output and marks them as NA
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
  resp
}
