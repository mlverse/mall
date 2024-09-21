library(purrr)
library(tibble)
library(pillar)

ctl_new_pillar.tbl_long <- function(controller, x, width, ...) {
  out <- NextMethod()
  if (attr(out$data, "width") > 50) {
    attr(out$data, "width") <- 40
  }
  new_pillar(list(
    title = out$title,
    type = out$type,
    data = out$data
  ))
}

knit_print.data.frame = function(x, ...) {
  x |> 
    new_tibble(class = "tbl_long") |> 
    knitr::normal_print()
}

registerS3method(
  "knit_print", "data.frame", knit_print.data.frame,
  envir = asNamespace("knitr")
)
