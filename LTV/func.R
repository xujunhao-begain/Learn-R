library(tidyverse)
library(yaml)

set_choices <- \(tbl, col_name, desc=FALSE) {
  tbl %>%
    pull(col_name) %>%
    unique() %>%
    na.omit() %>%
    sort(decreasing = desc)
}

mapping_colname <- function(ls, col) {
  col <- as.character(col)
  re <- names(ls)[ls == col]
  
  if (length(re) > 0) {
    return(re)
  } else {
    return(col)
  }
}

con_tab <- yaml::read_yaml("con_tab.yaml")

