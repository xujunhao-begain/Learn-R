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

con_tab <- yaml::read_yaml("../../con_tab.yaml")


# Customize sequence and colors ------------------------------------------------
# Set --------------------------------------------------------------------------
city_level_sort <- c("一线", "新一线", "二线", "三线", "四线", "五线", "")
city_level_color <- c("#08306b","#08519c","#2171b5","#4292c6","#6baed6","#9ecae1", "lightgrey")


fst_term_inclass_date_diff_bins_sort <- c("1_[0,5]", "2_[6, 10]", "3_[11, 15]", "4_[16, 20]", "5_[21, 25]", "6_[26, 30]", "7_[31, +)", "")
fst_term_inclass_date_diff_bins_color <- c("#a50f15", "#cb181d", "#ef3b2c", "#fb6a4a", "#fc9272", "#fcbba1", "#fee0d2", "lightgrey")

l1_pay_grade_sort <- c("幼儿", "一年级", "二年级", "三年级", "四年级", "五年级", "六年级", "初中", "其它", "")
#l1_pay_grade_color <- c("#f7fbff","#deebf7","#c6dbef","#9ecae1","#6baed6","#4292c6","#2171b5","#08519c","#d9d9d9","#d9d9d9")
l1_pay_grade_color <- c("#ffe6cc","#ffcc99","#ffb366","#ff9933","#ff8c1a","#ff8000","#e67300","#cc6600","#b35900","#994d00")




# Function ---------------------------------------------------------------------
mannual_dims_factor <- function(df, dim_vec){
  
  if(length(dim_vec) > 1 | length(dim_vec) == 0) return(df)
  
  if(dim_vec == "l1_city_level"){
    df <- df %>% mutate(dims_tag = factor(dims_tag, levels = city_level_sort))
    return(df)
  }
  
  if(dim_vec == "annual_city_level"){
    df <- df %>% mutate(dims_tag = factor(dims_tag, levels = city_level_sort))
    return(df)
  }
  
  if(dim_vec == "fst_term_inclass_date_diff_bins"){
    df <- df %>% mutate(dims_tag = factor(dims_tag, levels = fst_term_inclass_date_diff_bins_sort))
    return(df)
  }
  
  if(dim_vec == "l1_pay_grade"){
    df <- df %>% mutate(dims_tag = factor(dims_tag, levels = l1_pay_grade_sort))
    return(df)
  }
  
  if(dim_vec == "city_level"){
    df <- df %>% mutate(dims_tag = factor(dims_tag, levels = city_level_sort))
    return(df)
  }
  
  if(dim_vec == "pay_grade"){
    df <- df %>% mutate(dims_tag = factor(dims_tag, levels = l1_pay_grade_sort))
    return(df)
  }
  
  if(dim_vec == "inviter_parents_city_level"){
    df <- df %>% mutate(dims_tag = factor(dims_tag, levels = city_level_sort))
    return(df)
  }
  
  return(df)
}

mannual_dims_color <- function(plt, dim_vec, type){
  
  if(length(dim_vec) > 1 | length(dim_vec) == 0)  return(plt)
  
  if(dim_vec == "l1_city_level" & type == "fill"){
    plt <- plt + scale_fill_manual(values = city_level_color)
    return(plt)
  }
  
  if(dim_vec == "l1_city_level" & type == "col"){
    plt <- plt + scale_color_manual(values = city_level_color)
    return(plt)
  }
  
  if(dim_vec == "annual_city_level" & type == "fill"){
    plt <- plt + scale_fill_manual(values = city_level_color)
    return(plt)
  }
  
  if(dim_vec == "annual_city_level" & type == "col"){
    plt <- plt + scale_color_manual(values = city_level_color)
    return(plt)
  }
  
  if(dim_vec == "fst_term_inclass_date_diff_bins" & type == "fill"){
    plt <- plt + scale_fill_manual(values = fst_term_inclass_date_diff_bins_color)
    return(plt)
  }
  
  if(dim_vec == "fst_term_inclass_date_diff_bins" & type == "col"){
    plt <- plt + scale_color_manual(values = fst_term_inclass_date_diff_bins_color)
    return(plt)
  }
  
  if(dim_vec == "l1_pay_grade" & type == "fill"){
    plt <- plt + scale_fill_manual(values = l1_pay_grade_color)
    return(plt)
  }
  
  if(dim_vec == "l1_pay_grade" & type == "col"){
    plt <- plt + scale_color_manual(values = l1_pay_grade_color)
    return(plt)
  }
  
  if(dim_vec == "city_level" & type == "fill"){
    plt <- plt + scale_fill_manual(values = city_level_color)
    return(plt)
  }
  
  if(dim_vec == "city_level" & type == "col"){
    plt <- plt + scale_color_manual(values = city_level_color)
    return(plt)
  }
  
  if(dim_vec == "pay_grade" & type == "fill"){
    plt <- plt + scale_fill_manual(values = l1_pay_grade_color)
    return(plt)
  }
  
  if(dim_vec == "pay_grade" & type == "col"){
    plt <- plt + scale_color_manual(values = l1_pay_grade_color)
    return(plt)
  }
  
  if(dim_vec == "inviter_parents_city_level" & type == "fill"){
    plt <- plt + scale_fill_manual(values = city_level_color)
    return(plt)
  }
  
  if(dim_vec == "inviter_parents_city_level" & type == "col"){
    plt <- plt + scale_color_manual(values = city_level_color)
    return(plt)
  }
  
  return(plt)
}

