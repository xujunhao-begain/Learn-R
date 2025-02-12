message("=========== LTV-Routine ===========")
message(Sys.time())

library(config)
library(tidyverse)

source("../../../src/database.R")
source("../../../src/fs_api.R")
source("../../../src/helper.R")
# source("../../src/gemini.R")
# source("mapping.R")

config_ <- config::get(file = "my_config.yaml",config = "feishu_app")
#config_$req_headers <- form_request_headers()
tenant_access_token <- get_tenant_access_token()
message(tenant_access_token)

# 获取EDA数据 ------------------------------------------------------------------
trg_dt <- Sys.Date() - 1
cohort_dims <- c("l1_user_group", "l1_sku")

eda_tbl <- tbl(pool, "ads_eda_ltv_course_type_hdf") |> collect()

trg <-
  eda_tbl |>
  group_by(course_type_detail, !!!syms(cohort_dims)) |>
  summarise(pay_date = max(pay_date),
            .groups = "drop") |>
  trg_re(pay_date, trg_dt)


# Cohort触发概览 ---------------------------------------------------------------
if(nrow(trg) > 0){
  message(stringr::str_glue("+----------------{trg_dt} 支付日期 ---------------+"))
  trg |> select(- pay_date) |> knitr::kable() |> print()
  message("+--------------------------------------------------+")
}else{stop(stringr::str_glue("----------------{trg_dt} 无触发记录 ---------------"))}


# Report生成 -------------------------------------------------------------------
cloud_folder_id <- "AmGIfZYKtlDKFJdsVS1c9XJznVe" # 云文件夹id
tags <- list() # 待推送消息容器

report_func <- source(paste0("reports/", 'ltv.R'))$value
report_res <- report_func(cloud_folder_id,eda_tbl,single_dim_tbl,trg)
tag <- list(tag = "a", text = report_res$title, href = report_res$url)
tags <- c(tags, list(tag))


# # Send message -----------------------------------------------------------------
if(length(tags)){
  whk <- yaml::yaml.load_file("../webhook.yml")
  content <- map(tags, list)
  # send_post("L1Routine-线索质量:", content, whk$机器人测试群)
  send_post("L1Routine-线索质量:", content, whk$天网播报)
  message(stringr::str_glue("========== L1Routine-线索质量: 发送消息成功 =========="))
}else{message(stringr::str_glue("========== L1Routine-线索质量: 无发送消息 =========="))}


# Disconnect -------------------------------------------------------------------
poolClose(pool)


















# library(config)
# library(tidyverse)
# library(ggrepel)
# library(gt)
# 
# source("../../src/database.R")
# source("../../src/fs_api.R")
# source("../../src/gemini.R")
# source("../../src/common.R")
# source("../helper.R")
# source("mapping.R")
# config <- config::get(file = "../../config.yml")
# config_ <- config::get(config = "feishu_app")
# 
# config_$req_headers <- form_request_headers()
# message(config_$req_headers$headers)
# sub_cnf <- config::get(config = "subscriber") # 获取订阅列表
# 
# # pre-check --------------------------------------------------------------------
# event_type <- "分析报告"
# event_name <- "L1Routine续报结束复盘"
# sub_info <- extr_sub_info(sub_cnf$app_token, sub_cnf$tableID, event_type, event_name)
# 
# check_event_tbl_dt(sub_info, event_type, event_name, "eda_l1_business_regular")
# check_event_tbl_dt(sub_info, event_type, event_name, "eda_l1_business_counselor")
# 
# # 获取EDA数据 ------------------------------------------------------------------
# trg_dt <- Sys.Date() - 1
# cohort_dims <- c("user_group", "business_line", "goal_class_tag", "sku", "goal_operation_group")
# 
# eda_tbl <- tbl(pool, "eda_l1_business_regular") %>% 
#   mutate(goal_class_tag = ifelse(goal_class_tag == "0元4.5%单独运营",  "0元4.5单独运营",  goal_class_tag))
# ct_tbl <- tbl(pool, "eda_l1_business_counselor") %>% 
#   mutate(goal_class_tag = ifelse(goal_class_tag == "0元4.5%单独运营",  "0元4.5单独运营",  goal_class_tag))
# 
# trg <-
#   eda_tbl %>% 
#   group_by(term, !!!syms(cohort_dims)) %>% 
#   summarise(term_renewal_end_date = max(term_renewal_end_date),
#             .groups = "drop") %>% 
#   trg_re(term_renewal_end_date, trg_dt) %>% 
#   inner_join(cohort_analysis_config, # from “mapping.R”
#              by = cohort_dims)
# 
# # Cohort触发概览 ---------------------------------------------------------------
# if(nrow(trg) > 0){
#   message(stringr::str_glue("############# {trg_dt} 续报结束"))
#   trg %>% 
#     select(- term_renewal_end_date) %>% 
#     knitr::kable() %>% 
#     print()
# }else{stop(stringr::str_glue("############# {trg_dt} 无触发记录"))}
# 
# # Report生成 -------------------------------------------------------------------
# cloud_folder_id <- "M2sNf1Ddil7KDgdNoxJcrJ3inTb" # 云文件夹id
# 
# if(nrow(trg) > 0){
#   results <- 
#     trg %>% 
#     group_split(term, !!!syms(cohort_dims)) %>% 
#     purrr::map(~{
#       names(.x) <- paste(".", names(.x), sep = "")
#       params <- purrr::map(.x, ~ as.vector(.x))
#       params$.eda_tbl <- eda_tbl
#       params$.ct_tbl <- ct_tbl
#       params$.cohort_dims <- cohort_dims 
#       params$.cloud_folder_id <- cloud_folder_id # 云空间地址
#       
#       report_tmplt <- .x$.report_template
#       report_func <- source(paste0("reports/", report_tmplt))$value 
#       report_res <- report_func(params)
#       return(report_res)
#     })
# }else{stop("无可触发的报告...")}
# 
# res_df <-  
#   bind_rows(results) %>% 
#   rowwise() %>% 
#   mutate(prompt_row = paste0("报告标题：\n", title, "\n", highlight)) %>% 
#   mutate(href = str_glue("[{title}]({url})"))
# 
# gen_briefing <- 
#   . %>%
#   pull(prompt_row) %>%
#   paste(collapse = "\n") %>%
#   paste0(., "\n", "以上是全部报告") %>% 
#   gemini_QA("prompt/prompt_briefing.txt", ., model = "gemini-1.5-pro-latest") 
# 
# gen_hrefs <- 
#   . %>% 
#   pull(href) %>% 
#   paste(collapse = "\n")
# 
# ################################################################################
# # ------------------- 订阅事件：L1Routine续报结束复盘 ------------------------ #
# ################################################################################
# event_sub_send <- function(event_res_df, event_type, event_name, regex_str){
#   sub_info <- extr_sub_info(sub_cnf$app_token, sub_cnf$tableID, event_type, event_name)
#   
#   card <- list(
#     list(tag = "div",
#          text = list(content = gen_briefing(event_res_df),
#                      tag = "lark_md")),
#     list(tag = "div",
#          text = list(content = gen_hrefs(event_res_df),
#                      tag = "lark_md"))
#   )
#   
#   ## 向订阅群/人推送
#   sub_info$sub_group_info %>%
#     group_split(id) %>% 
#     walk(~{
#       send_card_to_group(.x$id, event_name, str_glue("数据快照:{trg_dt}"), card)
#       message(str_glue("《{event_type}-{event_name}》：{.x$name}({.x$id}) 推送成功！"))
#     })
#   
#   sub_info$sub_user_info %>%
#     group_split(id) %>% 
#     walk(~{
#       send_card_to_user(.x$id, event_name, str_glue("数据快照:{trg_dt}"), card)
#       message(str_glue("《{event_type}-{event_name}》：{.x$name}({.x$id}) 推送成功！"))
#     })
# }
# 
# event_type <- "分析报告"
# event_name <- "L1Routine续报结束复盘"
# event_res_df <- res_df
# 
# if(nrow(event_res_df)){
#   Sys.sleep(60)
#   event_sub_send(event_res_df, event_type, event_name, regex_str)
# }
# 
# 
# ################################################################################
# # --------------- 订阅事件：L1Routine续报结束复盘-0元团队 -------------------- #
# ################################################################################
# event_type <- "分析报告"
# event_name <- "L1Routine续报结束复盘-0元团队"
# event_res_df <- filter(res_df, grepl("0元团队", title))
# 
# if(nrow(event_res_df)){
#   Sys.sleep(60)
#   event_sub_send(event_res_df, event_type, event_name, regex_str)
# }
# 
# 
# ################################################################################
# # --------------- 订阅事件：L1Routine续报结束复盘-9元团队 -------------------- #
# ################################################################################
# event_type <- "分析报告"
# event_name <- "L1Routine续报结束复盘-9元团队"
# event_res_df <- filter(res_df, grepl("9元团队", title))
# 
# if(nrow(event_res_df)){
#   Sys.sleep(60)
#   event_sub_send(event_res_df, event_type, event_name, regex_str)
# }
# 
# 
# ################################################################################
# # --------------- 订阅事件：L1Routine续报结束复盘-蜀都团队 ------------------- #
# ################################################################################
# event_type <- "分析报告"
# event_name <- "L1Routine续报结束复盘-蜀都团队"
# event_res_df <- filter(res_df, grepl("蜀都团队", title))
# 
# if(nrow(event_res_df)){
#   Sys.sleep(60)
#   event_sub_send(event_res_df, event_type, event_name, regex_str)
# }
# 
# 
# ################################################################################
# # ---------------- 订阅事件：L1Routine续报结束复盘-转介绍 -------------------- #
# ################################################################################
# event_type <- "分析报告"
# event_name <- "L1Routine续报结束复盘-转介绍"
# event_res_df <- filter(res_df, grepl("转介绍单独运营|召回单独运营", title))
# 
# if(nrow(event_res_df)){
#   Sys.sleep(60)
#   event_sub_send(event_res_df, event_type, event_name, regex_str)
# }
# 
# 
# ################################################################################
# # ----------------- 订阅事件：L1Routine续报结束复盘-BTC ---------------------- #
# ################################################################################
# event_type <- "分析报告"
# event_name <- "L1Routine续报结束复盘-BTC"
# event_res_df <- filter(res_df, grepl("BTC", title))
# 
# if(nrow(event_res_df)){
#   Sys.sleep(60)
#   event_sub_send(event_res_df, event_type, event_name, regex_str)
# }
# 
# 
# poolClose(pool)
