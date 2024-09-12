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

