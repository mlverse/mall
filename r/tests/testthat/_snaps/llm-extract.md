# Extract works

    Code
      llm_vec_extract("toaster", labels = "product")
    Output
      [[1]]
      [[1]]$role
      [1] "user"
      
      [[1]]$content
      You are a helpful text extraction engine. Extract the product being referred to on the text. I expect 1 item exactly. No capitalization. No explanations.   The answer is based on the following text:
      {x}
      
      

# Extract on Ollama works

    Code
      llm_extract(reviews_table(), review, "product")
    Output
                                                                                    review
      1                 This has been the best TV I've ever used. Great screen, and sound.
      2          I regret buying this laptop. It is too slow and the keyboard is too noisy
      3 Not sure how to feel about my new washing machine. Great color, but hard to figure
               .extract
      1              tv
      2          laptop
      3 washing machine

---

    Code
      llm_vec_extract("bob smith, 105 2nd street", c("name", "address"))
    Output
      [1] "| bob smith | 105 2nd street |"

