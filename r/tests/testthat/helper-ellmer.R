temp_ellmer_obj <- function() {
  list(
    clone = function() {
      list(
        set_turns = function(...) {
          list(
            chat = function(x) NULL,
            set_system_prompt = function(...) NULL
          )
        }
      )
    }
  )
}
