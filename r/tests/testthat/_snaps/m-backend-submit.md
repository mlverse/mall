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

# ellmer code is covered with cache turned off

    Code
      m_backend_submit(backend = ellmer_session, x = test_txt, prompt = list(list(
        content = "test")), preview = TRUE)
    Output
      [[1]]
      ellmer_obj$set_system_prompt(list(list(content = "test")))
      
      [[2]]
      ellmer_obj$chat(as.list("test"))
      

