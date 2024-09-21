reference_index <- function(pkg = NULL, folder = "/reference") {
  if (is.character(pkg)) pkg <- pkgdown::as_pkgdown(pkg)
  ref_list <- reference_to_list_index(pkg)
  dir_out <- path(folder)
  ref_convert <- reference_index_convert(ref_list, dir_out)
  res <- imap(
    ref_convert,
    \(.x, .y) {
      if (.y == 1) {
        .x
      } else {
        c(" ", paste("##", .y), " ", .x)
      }
    }
  )
  res <- reduce(res, c)
  c(
    "---",
    paste0("title: ", pkg$package),
    paste0("description: ", pkg$desc$get_field("Title")),
    "---",
    res
  )
}

reference_index_convert <- function(index_list, dir_out = "") {
  out <- map(index_list, \(.x) map(.x, reference_links, dir_out))
  header <- c("Function(s) | Description", "|---|---|")
  map(
    out,
    \(.x) {
      c(
        header,
        map_chr(.x, \(.x) paste0("|", .x[[1]], "|", .x[[2]], "|"))
      )
    }
  )
}

reference_links <- function(x, dir_out) {
  # Manual fixes of special characters in funs variable
  funcs <- x$funs
  if (length(funcs) == 0) funcs <- x$alias
  funcs <- gsub("&lt;", "<", funcs)
  funcs <- gsub("&gt;", ">", funcs)
  funcs <- paste0(funcs, collapse = " \\| ")
  file_out <- path(dir_out, x$file_out)
  desc <- x$title
  c(
    paste0("[", funcs, "](", file_out, ")"),
    desc
  )
}

reference_to_list_index <- function(pkg) {
  if (is.character(pkg)) pkg <- as_pkgdown(pkg)
  pkg_ref <- pkg$meta$reference
  pkg_topics <- pkg$topics
  topics_env <- pkgdown:::match_env(pkg_topics)
  if (is.null(pkg_ref)) {
    x <- list(data.frame(contents = pkg_topics$name))
  } else {
    x <- pkg_ref
  }
  sections_list <- map(
    seq_along(x),
    \(.x) {
      ref <- x[[.x]]
      topic_list <- map(
        ref$contents,
        ~ {
          item_numbers <- NULL
          try(
            item_numbers <- eval(parse(text = paste0("`", .x, "`")), topics_env),
            silent = TRUE
          )
          if (is.null(item_numbers)) {
            item_numbers <- eval(parse(text = .x), topics_env)
          }
          item_numbers
        }
      )
      topic_ids <- as.numeric(list_c(topic_list))
      transpose(pkg_topics[topic_ids, ])
    }
  )
  if (!is.null(pkg_ref)) {
    sections_title <- map_chr(pkg_ref, \(.x) .x$title)
    names(sections_list) <- sections_title
  }
  sections_list
}
