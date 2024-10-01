# Sentiment translates expected Spark SQL

    Code
      llm_sentiment(df_spark, x)
    Output
      <SQL>
      SELECT `df`.*, ai_analyze_sentiment(`x`) AS `.sentiment`
      FROM `df`

# Sentiment on Ollama works

    Code
      llm_vec_sentiment(vec_reviews)
    Output
      [1] "positive" "negative" "neutral" 

---

    Code
      llm_vec_sentiment(vec_reviews, options = c("positive", "negative"))
    Output
      [1] "positive" "negative" "negative"

---

    Code
      llm_vec_sentiment(vec_reviews, options = c("positive", "negative"),
      additional_prompt = "Consider someone not sure as a positive comment.")
    Output
      [1] "positive" "negative" "positive"

---

    Code
      llm_sentiment(reviews, review)
    Output
                                                                                    review
      1                 This has been the best TV I've ever used. Great screen, and sound.
      2          I regret buying this laptop. It is too slow and the keyboard is too noisy
      3 Not sure how to feel about my new washing machine. Great color, but hard to figure
        .sentiment
      1   positive
      2   negative
      3    neutral

---

    Code
      llm_sentiment(reviews, review, pred_name = "new")
    Output
                                                                                    review
      1                 This has been the best TV I've ever used. Great screen, and sound.
      2          I regret buying this laptop. It is too slow and the keyboard is too noisy
      3 Not sure how to feel about my new washing machine. Great color, but hard to figure
             new
      1 positive
      2 negative
      3  neutral

