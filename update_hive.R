library(RJDBC)

# 读取 YAML 配置文件
config <- yaml::read_yaml("../my_config.yaml")$my_hive
 
# 配置 Hive 连接信息
hive_driver <- JDBC("org.apache.hive.jdbc.HiveDriver",
                    config$hive_jdbc_path, # 从配置文件读取 Hive JDBC 驱动路径
                    identifier.quote="`")

hive_host <- config$host # 从配置文件读取 Hive 服务器地址和数据库名
hive_port <- config$port
hive_user <- config$username # 从配置文件读取 Hive 用户名
hive_password <- config$password # 从配置文件读取 Hive 密码

# 建立 Hive 连接
hive_conn <- dbConnect(hive_driver, paste0("jdbc:hive2://",hive_host,":",hive_port), hive_user, hive_password)

# 执行 Hive 查询
# ltv_query <- "SELECT pay_date,
#                  course_type_detail,
#                  nvl(l1_sku,'NA') as l1_sku,
#                  nvl(l1_user_group,'NA') as l1_user_group,
#                  nvl(l1_goal_channel_type,'NA') as l1_goal_channel_type,
#                  nvl(go_course_type_detail,'NA') as go_course_type_detail,
#                  datedif,
#                  total_gmv,
#                  user_cnt
#          FROM htba.test_ltv_course_type_xjh
#          "

# ltv
# SQL 文件路径
# ltv_sql <- "sql/ltv.sql" #  将路径替换为您的 SQL 文件的实际路径
# # 从文件中读取 SQL 查询
# ltv_query <- readLines(ltv_sql, encoding = "UTF-8")
# # 将多行查询合并为一个字符串
# ltv_query <- paste(ltv_query, collapse = " ")
# ltv_result <- dbGetQuery(hive_conn, ltv_query)


# 函数定义
run_hive_query <- function(sql_file_path, output_data_name) {
  # 从文件中读取 SQL 查询
  query <- readLines(sql_file_path, encoding = "UTF-8")
  # 将多行查询合并为一个字符串
  query <- paste(query, collapse = " ")
  # 执行查询
  result <- dbGetQuery(hive_conn, query) # hive_conn 应该是预先定义好的连接
  # 将结果赋值给指定的输出变量名
  assign(output_data_name, result, envir = .GlobalEnv)
  # 返回结果（可选）
  return(result) 
}
# 用法
#print("开始执行ltv.sql")
#run_hive_query("sql/ltv.sql", "ltv_sql_result")
#print("完成执行ltv.sql")
print("开始执行B2C简报数据.sql")
run_hive_query("sql/B2C简报数据.sql", "b2c_report_sql_result")
print("完成执行B2C简报数据.sql")
print("开始执行cluster_city.sql")
run_hive_query("sql/cluster_city.sql", "cluster_city_sql_result")
print("完成执行cluster_city.sql")
print("开始执行cluster_district.sql")
run_hive_query("sql/cluster_district.sql", "cluster_district_sql_result")
print("完成执行cluster_district.sql")
print("开始执行new_score.sql")
run_hive_query("sql/new_score.sql", "new_score_sql_result")
print("完成执行new_score.sql")

# 关闭 Hive 连接
dbDisconnect(hive_conn)
















