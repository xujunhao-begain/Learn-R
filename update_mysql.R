# 加载必要的包
library(DBI)
library(RMySQL)  # 如果你使用的是 MySQL 数据库

# # 读取 YAML 配置文件
config <- yaml::read_yaml("../../my_config.yaml")$mysql_db

# 连接到 MySQL 数据库
mysql_con <- dbConnect(RMySQL::MySQL(), 
                       host = config$host, 
                       user = config$username, 
                       password = config$password, 
                       dbname = config$database)


# 函数定义
run_mysql_query <- function(sql_file_path, output_data_name) {
  # 从文件中读取 SQL 查询
  query <- readLines(sql_file_path, encoding = "UTF-8")
  # 将多行查询合并为一个字符串
  query <- paste(query, collapse = " ")
  # 执行查询
  #result<- dbReadTable(mysql_con, query) 
  result<- dbGetQuery(mysql_con, query) 
  # 将结果赋值给指定的输出变量名
  assign(output_data_name, result, envir = .GlobalEnv)
  # 返回结果（可选）
  return(result) 
}


# 用法
# print("开始执行 ads_l1_eda_multidimensional_indicators_df.sql")
# run_mysql_query("sql/ads_l1_eda_multidimensional_indicators_df.sql", "ads_l1_eda_multidimensional_indicators_df")
# print("完成执行 ads_l1_eda_multidimensional_indicators_df.sql")
print("开始执行 ltv.sql")
run_mysql_query("sql/ltv.sql", "ads_eda_ltv_course_type_hdf")
print("完成执行 ltv.sql")

# 断开数据库连接
dbDisconnect(mysql_con)



















