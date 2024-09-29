# Summarize translates expected Spark SQL

    Code
      llm_summarize(df_spark, x)
    Output
      <SQL>
      SELECT `df`.*, ai_summarize(`x`, CAST(10.0 AS INT)) AS `.summary`
      FROM `df`

---

    Code
      llm_summarize(df_spark, x, max_words = 50)
    Output
      <SQL>
      SELECT `df`.*, ai_summarize(`x`, CAST(50.0 AS INT)) AS `.summary`
      FROM `df`

# Summarize on Ollama works

    Code
      llm_summarize(reviews_table(), review, max_words = 5)
    Output
                                                                                    review
      1                 This has been the best TV I've ever used. Great screen, and sound.
      2          I regret buying this laptop. It is too slow and the keyboard is too noisy
      3 Not sure how to feel about my new washing machine. Great color, but hard to figure
                              .summary
      1                it's a great tv
      2  laptop purchase was a mistake
      3 having mixed feelings about it

