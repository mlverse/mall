reference_to_list_page <- function(file_in, pkg) {
  if (is.character(pkg)) pkg <- as_pkgdown(pkg)
  out <- tags_process(tags_get(file_in, pkg))
  out$repo <- pkg$repo$url$home
  out
}

tags_get <- function(file_in, pkg) {
  pkg_topics <- pkg$topics
  topic_row <- pkg_topics[pkg_topics$file_in == file_in, ]
  topic <- transpose(topic_row)
  topic_rd <- topic[[1]]$rd
  tag_names <- map_chr(topic_rd, ~ class(.)[[1]])
  tag_split <- split(topic_rd, tag_names)
  tag_split <- tag_split[names(tag_split) != "TEXT"]
  imap(
    tag_split,
    ~ {
      nm <- .y
      class(.x) <- c(nm, class(.x))
      .x
    }
  )
}

tags_process <- function(x) {
  out <- map(x, ~ tag_convert(.x))
  comment <- NULL
  comment <- names(out) == "COMMENT"
  if (length(comment) > 0) {
    comment_list <- list_flatten(out$COMMENT)
    reg_list <- out[!comment]
    out <- c(comment_list, reg_list)
  }
  new_names <- substr(names(out), 5, nchar(names(out)))
  names(out) <- new_names
  out
}

## ------------------ Conversion methods for the Major Tags  -------------------

tag_convert <- function(x) {
  UseMethod("tag_convert", x)
}

tag_convert_default <- function(x) {
  x <- x[[1]]
  rf <- tag_flatten(x)
  rf_cr <- NULL
  cr <- NULL
  for (i in seq_along(rf)) {
    cl <- rf[[i]]
    if (cl == new_paragraph_symbol) {
      if (!is.null(cr)) rf_cr <- c(rf_cr, cr)
      cr <- NULL
    } else {
      cr <- paste0(cr, cl, collapse = "")
    }
  }
  rf_cr
}

tag_convert.COMMENT <- function(x) {
  edit_text <- "% Please edit documentation in "
  find_edit <- grepl(edit_text, x)
  out <- list(gsub(edit_text, "", x[find_edit]))
  names(out) <- "tag_source"
  out
}

tag_convert.default <- tag_convert_default

tag_convert.tag_section <- function(x) {
  map(x, ~ {
    list(
      title = tag_convert_default(.x[1]),
      contents = tag_convert_default(.x[2])
    )
  })
}

tag_convert.tag_examples <- function(x) {
  x <- x[[1]]
  rf <- tag_flatten(x)
  on_examples <- TRUE
  examples_run <- NULL
  examples_dont_run <- NULL
  cr <- NULL
  for (i in seq_along(rf)) {
    cl <- rf[[i]]
    if (cl == new_paragraph_symbol | cl == do_not_run_symbol) {
      if (!is.null(cr)) {
        if (on_examples) {
          examples_run <- c(examples_run, cr)
        } else {
          examples_dont_run <- c(examples_dont_run, cr)
        }
      }
      cr <- NULL
    } else {
      cr <- c(cr, cl)
    }
    if (cl == do_not_run_symbol) {
      on_examples <- FALSE
    }
  }
  if (all(examples_run == " ")) examples_run <- NULL
  if (all(examples_dont_run == " ")) examples_dont_run <- NULL
  list(
    code_run = examples_run,
    code_dont_run = examples_dont_run
  )
}

s3_label <- "## S3 method for class '"

tag_convert.tag_usage <- function(x) {
  x <- x[[1]]
  out <- NULL
  not_s3 <- TRUE
  for (i in seq_along(x)) {
    if (not_s3) {
      cs <- x[[i]]
      ts <- tag_single(cs)
      curr_s3 <- substr(ts[[1]], 1, nchar(s3_label)) == s3_label
      if (curr_s3) {
        ts1 <- tag_single(x[[i + 1]])
        ts1[[1]] <- paste0(ts[[2]], ts1[[1]], collapse = "")
        ts[[2]] <- ts1
        not_s3 <- FALSE
      }
      out <- c(out, ts)
    } else {
      not_s3 <- TRUE
    }
  }
  out[out == new_paragraph_symbol] <- ""
  if (out[[1]] == "" && length(out) > 1) out <- out[2:length(out)]
  out
}

tag_convert.tag_arguments <- function(x) {
  x <- x[[1]]
  res <- list()
  for (i in seq_along(x)) {
    item <- x[[i]]
    if ("tag_item" %in% class(item)) {
      res <- c(
        res,
        list(list(
          argument = tag_convert(item[1]),
          description = tag_convert(item[2])
        ))
      )
    }
  }
  res
}

## -------------------------------- Tag translation ----------------------------

tag_translate <- function(x) {
  UseMethod("tag_translate")
}

tag_translate.TEXT <- function(x) x
tag_translate.RCODE <- function(x) x
tag_translate.VERB <- function(x) x
tag_translate.character <- function(x) x

tag_translate.tag_code <- function(x) tag_code(x)
tag_translate.tag_samp <- function(x) tag_code(x)
tag_translate.tag_verb <- function(x) tag_code(x)
tag_translate.tag_pkg <- function(x) tag_code(x)
tag_translate.tag_usage <- function(x) tag_code(x)

tag_translate.tag_if <- function(x) ""
tag_translate.tag_cr <- function(x) ""
tag_translate.tag_tabular <- function(x) ""


tag_translate.tag_R <- function(x) "`R`"
tag_translate.tag_link <- function(x) as.character(x[[1]])
tag_translate.tag_emph <- function(x) paste0("**", x, "**")
tag_translate.tag_strong <- function(x) paste0("**", x, "**")
tag_translate.tag_cite <- function(x) paste0("*", x, "*")
tag_translate.tag_eqn <- function(x) paste0("$", x, "$")
tag_translate.tag_deqn <- function(x) tag_deqn(x)
tag_translate.tag_item <- function(x) list(new_paragraph_symbol, "-")

tag_translate.tag_preformatted <- function(x) tag_preformatted(x)
tag_translate.tag_email <- function(x) tag_url(x)
tag_translate.tag_url <- function(x) tag_url(x)
tag_translate.tag_itemize <- function(x) tag_itemize1(x)
tag_translate.tag_dontrun <- function(x) tag_dontrun(x)
tag_translate.tag_enumerate <- function(x) tag_itemize1(x)
tag_translate.tag_describe <- function(x) tag_describe(x)
tag_translate.tag_subsection <- function(x) tag_sub_section(x)
tag_translate.tag_method <- function(x) tag_method(x)
tag_translate.tag_href <- function(x) tag_href(x)
tag_translate.LIST <- function(x) tag_LIST(x)

tag_translate.default <- function(x) {
  stop(paste0("Class '", class(x)[[1]], "' not recognized. Value: ", x))
}

## Revisit when able ---------
tag_translate.USERMACRO <- function(x) x[[2]]
tag_translate.tag_Sexpr <- function(x) ""
## ----------------------------

tag_single <- function(x, rm_return = TRUE) {
  out <- tag_translate(x)
  if (rm_return) out <- map_chr(out, remove_return)
  out
}

tag_flatten <- function(x) {
  x <- list_c(map(x, tag_single)) 
  c(x, new_paragraph_symbol)
}

new_paragraph_symbol <- "<<<<<<<<<<<<<<<<<<<<<<<<<"
do_not_run_symbol <- ";;;;;;;;;;;;;;;;;;;;;;;;;"

remove_return <- function(x) {
  if (trimws(x) == "\n") {
    x <- new_paragraph_symbol
  }
  remove_generic(x)
}

remove_return_code <- function(x) {
  if (x == "\n") x <- "```r"
  remove_generic(x)
}

remove_generic <- function(x) {
  if (substr(x, nchar(x), nchar(x)) == "\n") {
    x <- substr(x, 1, nchar(x) - 1)
    x <- paste0(x, " ")
  }
  x
}

## -------------------------- Atomic RD tag functions ---------------------------

tag_LIST <- function(x) {
  paste0(paste(map(x, tag_single), collapse = ""), "\n")
}

tag_describe <- function(x) {
  out <- map(list_c(x), \(.x) .x[[1]]) 
  out <- map(out, tag_single)
  out_nulls <- !map_lgl(out, is.null)
  out <- out[out_nulls]
  reduce(out, function(x, y) c(x, new_paragraph_symbol, y))
}

tag_dontrun <- function(x) {
  out <- list_c(map(x, tag_single)) 
  c(do_not_run_symbol, out)
}

tag_sub_section <- function(x) {
  x_class <- map_chr(x, class)
  if (any(x_class == "tag")) {
    out <- map(x, function(x) list_c(map(x, tag_single)))
  } else {
    out <- map(x, tag_single)
  }
  out <- map(list_c(out), remove_return) 
  c(out, new_paragraph_symbol)
}

tag_itemize1 <- function(x) {
  x <- map(x, tag_single, FALSE) 
  x <- map(list_c(x), remove_return) 
  c(x, new_paragraph_symbol)
}

tag_code <- function(x) {
  x <-  reduce(map(x, tag_single), paste0) 
  paste0("`", x, "`")
}

tag_preformatted <- function(x) {
  x <- reduce(as.character(x), function(x, y) c(x, new_paragraph_symbol, y)) 
  c("```", new_paragraph_symbol, x, new_paragraph_symbol, "```")
}

tag_url <- function(x) {
  label_list <- map_chr(x, ~.x)
  label <- paste0(label_list, collapse = " ")
  res <- paste0("[", label, "](", label, ")")
}

tag_href <- function(x) {
  address <- as.character(x[[1]])
  label_list <- map_chr(x[[2]], tag_single)
  label <- paste0(label_list, collapse = " ")
  res <- paste0("[", label, "](", address, ")")
}

tag_method <- function(x) {
  c(
    paste0(s3_label, x[[2]], "'"),
    as.character(x[[1]])
  )
}

tag_deqn <- function(x) {
  x_list <- map_chr(x, as.character)
  c("$", x_list, "$")
}
