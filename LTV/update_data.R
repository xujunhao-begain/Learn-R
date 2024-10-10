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
query <- "SELECT pay_date,
                 course_type_detail,
                 nvl(l1_sku,'NA') as l1_sku,
                 nvl(l1_user_group,'NA') as l1_user_group,
                 nvl(l1_goal_channel_type,'NA') as l1_goal_channel_type,
                 nvl(go_course_type_detail,'NA') as go_course_type_detail,
                 datedif,
                 total_gmv,
                 user_cnt
         FROM htba.test_ltv_course_type_xjh
         "

result <- dbGetQuery(hive_conn, query)

# 查看查询结果
#head(result)

# 关闭 Hive 连接
dbDisconnect(hive_conn)
#print(1)