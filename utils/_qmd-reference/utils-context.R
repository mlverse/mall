ecodown_context <- new.env(parent = emptyenv())

ecodown_context_set <- function(id, vals = list()) {
  ecodown_context[[id]] <- vals
}

ecodown_context_get <- function(id) {
  if (id == "") {
    return(NULL)
  }
  ecodown_context[[id]]
}

get_package_name <- function() {
  ecodown_context_get("package_name")
}

