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

