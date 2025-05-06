# Ollama code is covered

    Code
      llm_vec_sentiment("I am happy")
    Message
      ! 1 record may be over 10 tokens
      Ollama may have truncated what was sent to the model 
      (https://github.com/ollama/ollama/issues/7043)
      * I am happy...
    Output
      [1] "positive"

