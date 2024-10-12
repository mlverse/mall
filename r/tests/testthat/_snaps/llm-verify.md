# Preview works

    Code
      llm_vec_verify("this is a test", "a test", preview = TRUE)
    Output
      ollamar::chat(messages = list(list(role = "user", content = "You are a helpful text analysis engine. Determine this is true  'a test'. No capitalization. No explanations.  The answer is based on the following text:\nthis is a test")), 
          output = "text", model = "llama3.2", seed = 100)

# Verify on Ollama works

    Code
      llm_verify(reviews, review, "is the customer happy")
    Output
                                                                                    review
      1                 This has been the best TV I've ever used. Great screen, and sound.
      2          I regret buying this laptop. It is too slow and the keyboard is too noisy
      3 Not sure how to feel about my new washing machine. Great color, but hard to figure
        .verify
      1       1
      2       0
      3       0

---

    Code
      llm_verify(reviews, review, "is the customer happy", yes_no = c("y", "n"))
    Output
                                                                                    review
      1                 This has been the best TV I've ever used. Great screen, and sound.
      2          I regret buying this laptop. It is too slow and the keyboard is too noisy
      3 Not sure how to feel about my new washing machine. Great color, but hard to figure
        .verify
      1       y
      2       n
      3       n

