# # 创建文件路径
# creat_fld <- function(fld_path) {
#   if (!file.exists(fld_path)) {
#     dir.create(fld_path)
#     message("create folder: ", fld_path)
#   }
# }
# 
# # 创建或初始化文件路径
# init_fld <- function(fld_path) {
#   if (!file.exists(fld_path)) {
#     dir.create(fld_path)
#     message("create folder: ", fld_path)
#   } else {
#     file.remove(paste0(fld_path, list.files(fld_path)))
#   }
#   message(paste0("initialize folder: ", fld_path))
# }
# 
# 
# # 提取订阅列表信息
# extr_sub_info <- function(sub_app_token, sub_tableID, event_type, event_name) {
#   row <-
#     get_dat_from_bitbl(sub_app_token, sub_tableID) %>%
#     .$data %>%
#     filter(事件类型 == event_type) %>%
#     filter(`事件标识(唯一)` == event_name)
#   
#   sub_user_info <- extr_user_list(row$订阅人)
#   sub_group_info <- extr_group_list(row$订阅群)
#   abn_user_info <- extr_user_list(row$异常告知)
#   
#   return(list(
#     sub_user_info = sub_user_info,
#     sub_group_info = sub_group_info,
#     abn_user_info = abn_user_info
#   ))
# }
# 
# 
# # dt异常推送
# check_dt <- function(open_id, dt, tbl_name, title, text, stop = TRUE) {
#   print(tbl_name)
#   lst_dt <-
#     tbl(pool, tbl_name) %>%
#     select(dt) %>%
#     distinct() %>%
#     collect()
#   
#   if (format(dt, "%Y%m%d") != lst_dt) {
#     message(str_glue("{tbl_name}：dt检查未通过！"))
#     content <- list(list(list(tag = "text", text = text)))
#     send_post_to_user(open_id, title, content)
#     if (stop) stop()
#   } else {
#     message(str_glue("{tbl_name}：dt检查通过！"))
#   }
# }
# 
# # 事件依赖表dt异常推送模板
# check_event_tbl_dt <- function(sub_info, event_type, event_name, table_name, dt = Sys.Date() - 1, stop = TRUE) {
#   send_title <- str_glue("《{event_name}》异常：")
#   send_text <- stringr::str_glue("任务执行失败，依赖表{table_name}无最新dt!")
#   sub_info$abn_user_info %>%
#     group_split(id) %>%
#     walk(~ {
#       check_dt(.x$id, dt, table_name, send_title, send_text, stop = stop)
#     })
# }
