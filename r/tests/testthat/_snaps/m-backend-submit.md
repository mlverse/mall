# Ollama code is covered

    Code
      llm_vec_sentiment(test_txt)
    Message
      ! 15 records may be over 10 tokens
      Ollama may have truncated what was sent to the model 
      (https://github.com/ollama/ollama/issues/7043)
      * positive...
      * positive...
      * positive...
      * positive...
      * positive...
      * positive...
      * positive...
      * positive...
      * positive...
      * positive...
      i 5 more records
    Output
       [1] "positive" "positive" "positive" "positive" "positive" "positive"
       [7] "positive" "positive" "positive" "positive" "positive" "positive"
      [13] "positive" "positive" "positive"

# ellmer code is covered

    Code
      m_backend_submit(backend = ellmer_session, x = "test", prompt = list(list(
        content = "test")), preview = TRUE)
    Output
      [[1]]
      x$chat("test", echo = "none")
      

---

    Code
      m_ellmer_chat()
    Output
      [1] "test"

# ellmer code is covered - part II

    Code
      str(m_ellmer_chat())
    Output
      function (..., echo = NULL)  

