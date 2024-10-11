library(purrr)
library(tibble)
library(pillar)

.env_knir_tbl <- new.env()

ctl_new_pillar.tbl_long <- function(controller, x, width, ...) {
  out <- NextMethod()
  max_width <- 90
  widths <- .env_knir_tbl$widths
  if(sum(widths) > max_width) {
    attr(out$data, "width") <- floor(max_width / 2)
  } 
  new_pillar(list(
    title = out$title,
    type = out$type,
    data = out$data
  ))
}

knit_print.data.frame = function(x, ...) {
  .env_knir_tbl$widths <- map_int(x, \(y) max(nchar(as.character(y[!is.na(y)]))))
  x <- new_tibble(x, class = "tbl_long") 
  knitr::normal_print(x)
}

registerS3method(
  "knit_print", "data.frame", knit_print.data.frame,
  envir = asNamespace("knitr")
)
 