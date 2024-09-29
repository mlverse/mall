# Classify translates expected Spark SQL

    Code
      llm_classify(df_spark, x, c("a", "b"))
    Output
      <SQL>
      SELECT `df`.*, ai_classify(`x`, array('a', 'b')) AS `.classify`
      FROM `df`

# Preview works

    Code
      llm_vec_classify("this is a test", c("a", "b"), preview = TRUE)
    Output
      ollamar::chat(messages = list(list(role = "user", content = "You are a helpful classification engine. Determine if the text refers to one of the following: a, b. No capitalization. No explanations.  The answer is based on the following text:\nthis is a test")), 
          output = "text", model = "llama3.2", seed = 100)

# Classify on Ollama works

    Code
      llm_classify(reviews, review, labels = c("appliance", "computer"))
    Output
                                                                                    review
      1                 This has been the best TV I've ever used. Great screen, and sound.
      2          I regret buying this laptop. It is too slow and the keyboard is too noisy
      3 Not sure how to feel about my new washing machine. Great color, but hard to figure
        .classify
      1  computer
      2  computer
      3 appliance

---

    Code
      llm_classify(reviews, review, pred_name = "new", labels = c("appliance",
        "computer"))
    Output
                                                                                    review
      1                 This has been the best TV I've ever used. Great screen, and sound.
      2          I regret buying this laptop. It is too slow and the keyboard is too noisy
      3 Not sure how to feel about my new washing machine. Great color, but hard to figure
              new
      1  computer
      2  computer
      3 appliance

---

    Code
      llm_classify(reviews, review, pred_name = "new", labels = c("appliance",
        "computer"), additional_prompt = "Consider all laptops as appliances.")
    Output
                                                                                    review
      1                 This has been the best TV I've ever used. Great screen, and sound.
      2          I regret buying this laptop. It is too slow and the keyboard is too noisy
      3 Not sure how to feel about my new washing machine. Great color, but hard to figure
              new
      1 appliance
      2  computer
      3 appliance

