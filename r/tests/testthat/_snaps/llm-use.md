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
      LLM session: model:gpt-4o

# Ensures empty llm_use works with Chat

    Code
      llm_use()
    Message
      
      -- mall session object 
      Backend: ellmer
      LLM session: model:gpt-4o

