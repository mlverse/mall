# Init code is covered

    Code
      llm_use(.cache = "")
    Message
      
      -- mall session object 
      Backend: Ollama
      LLM session: model:model1

# Stops cache

    Code
      llm_use("simulate_llm", "echo", .force = TRUE, .cache = "")
    Message
      
      -- mall session object 
      Backend: simulate_llm
      LLM session: model:echo

# Chat objects work

    Code
      llm_use(chat, .cache = "")
    Message
      
      -- mall session object 
      Backend: ellmer
      LLM session: model:gpt-4.1

# Ensures empty llm_use works with Chat

    Code
      llm_use()
    Message
      
      -- mall session object 
      Backend: ellmer
      LLM session: model:gpt-4.1

