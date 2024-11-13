# 加载必要的包
library(DBI)
library(RMySQL)  # 如果你使用的是 MySQL 数据库

# # 读取 YAML 配置文件
config <- yaml::read_yaml("../my_config.yaml")$mysql_db

# 连接到 MySQL 数据库
mysql_con <- dbConnect(RMySQL::MySQL(), 
                       host = config$host, 
                       user = config$username, 
                       password = config$password, 
                       dbname = config$database)

# 读取数据表
result<- dbReadTable(mysql_con, "test_ltv_course_type_xjh") 

# 查看数据
#head(result)

# 断开数据库连接
dbDisconnect(mysql_con)



















