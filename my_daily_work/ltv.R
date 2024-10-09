library(RJDBC)

# 读取 YAML 配置文件
config <- yaml::read_yaml("my_config.yaml")$my_hive

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
query <- "SELECT course_type_detail,
                 nvl(l1_sku,'NA') as l1_sku,
                 nvl(l1_user_group,'NA') as l1_user_group,
                 nvl(l1_goal_channel_type,'NA') as l1_goal_channel_type,
                 nvl(go_course_type_detail,'NA') as go_course_type_detail,
                 datedif,
                 total_gmv,
                 user_cnt
         FROM htba.test_ltv_course_type_xjh
         where pay_date>='2023-01-01'
         and   pay_date<='2023-06-30'
         "

result <- dbGetQuery(hive_conn, query)

# 查看查询结果
head(result)

# 关闭 Hive 连接
dbDisconnect(hive_conn)


library(tidyverse)
library(showtext)
showtext_auto()

# view(head(result))
# str(result)
# result[1,]
# result[,1] %>% unique()
# 
# result %>%
#   group_by(test_ltv_course_type_xjh.course_type_detail) %>% 
#   summarise(n=n())

# cumgmv1 <- 
#   result %>%
#   filter(course_type_detail == '编程L1-首单',datedif<=360) %>% 
#   mutate(datedif = as_factor(datedif)) %>% 
#   mutate(total_gmv = as.numeric(total_gmv)) %>% 
#   mutate(user_cnt = as.numeric(user_cnt)) %>% 
#   mutate(total_user_cnt = sum(user_cnt)) %>%
#   #group_by(datedif,total_user_cnt) %>%
#   group_by(total_user_cnt,datedif) %>% 
#   summarise(sum_gmv=sum(total_gmv), .groups = "drop") %>% 
#   mutate(cum_gmv = cumsum(sum_gmv)) %>% 
#   mutate(avg_gmv=cum_gmv/total_user_cnt)
#   
# ggplot(cumgmv1,aes(x = datedif, y = avg_gmv, group = 1)) + 
# geom_line() +
# scale_x_discrete(breaks = seq(0, 360, by = 60))



# cumgmv1 <- 
#   result %>%
#   filter(course_type_detail == '编程年课-首单',datedif<=360) %>% 
#   mutate(datedif = as_factor(datedif)) %>% 
#   mutate(total_gmv = as.numeric(total_gmv)) %>% 
#   mutate(user_cnt = as.numeric(user_cnt)) %>% 
#   mutate(user_cnt = ifelse(datedif == 0,user_cnt,0)) %>% 
#   mutate(total_user_cnt = sum(user_cnt)) %>%
#   group_by(total_user_cnt,datedif) %>% 
#   summarise(sum_gmv=sum(total_gmv), .groups = "drop") %>% 
#   mutate(cum_gmv = cumsum(sum_gmv)) %>% 
#   mutate(avg_gmv=cum_gmv/total_user_cnt)
# 
# ggplot(cumgmv1,aes(x = datedif, y = avg_gmv, group = 1)) + 
#   geom_line() +
#   scale_x_discrete(breaks = seq(0, 360, by = 60))
# 
# 
# cumgmv2 <- 
#   result %>%
#   filter(course_type_detail == '编程年课-首单',datedif<=360) %>% 
#   mutate(datedif = as_factor(datedif)) %>% 
#   mutate(total_gmv = as.numeric(total_gmv)) %>% 
#   mutate(user_cnt = as.numeric(user_cnt)) %>% 
#   mutate(user_cnt = ifelse(datedif == 0,user_cnt,0)) %>% 
#   mutate(total_user_cnt = sum(user_cnt)) %>%
#   group_by(total_user_cnt,l1_sku,datedif) %>% 
#   summarise(sum_gmv=sum(total_gmv), .groups = "drop") %>% 
#   mutate(cum_gmv = cumsum(sum_gmv)) %>% 
#   mutate(avg_gmv=cum_gmv/total_user_cnt)
# 
# ggplot(cumgmv2,aes(x = datedif, y = avg_gmv, colour = l1_sku , group = l1_sku)) + 
#   geom_line() +
#   scale_x_discrete(breaks = seq(0, 360, by = 60))




cumgmv3 <- 
  result %>%
  filter(course_type_detail == '编程年课-首单',datedif<=360) %>% 
  mutate(datedif = as_factor(datedif)) %>% 
  mutate(total_gmv = as.numeric(total_gmv)) %>% 
  mutate(user_cnt = as.numeric(user_cnt)) %>% 
  mutate(user_cnt = ifelse(datedif == 0,user_cnt,0)) %>% 
  
  group_by(l1_user_group,datedif) %>% 
  summarise(sum_gmv=sum(total_gmv), 
            sum_user_cnt = sum(user_cnt),
            .groups = "drop") %>% 
  
  filter(l1_user_group %in% c('思维', 'NA')) %>%
  group_by(l1_user_group) %>%
  mutate(
    cum_gmv = cumsum(sum_gmv),
    cum_user_cnt = cumsum(sum_user_cnt),
    avg_gmv = cum_gmv / cum_user_cnt
  )

ggplot(cumgmv3,aes(x = datedif, y = avg_gmv, colour = l1_user_group , group = l1_user_group)) + 
  geom_line() +
  scale_x_discrete(breaks = seq(0, 360, by = 60))


cumgmv3 %>% 
  filter(datedif==0)
  distinct(l1_user_group)
  
  

cumgmv4 <- 
    result %>%
    filter(course_type_detail == '编程年课-首单',datedif<=360) %>% 
    mutate(datedif = as_factor(datedif)) %>% 
    mutate(total_gmv = as.numeric(total_gmv)) %>% 
    mutate(user_cnt = as.numeric(user_cnt)) %>% 
    mutate(user_cnt = ifelse(datedif == 0,user_cnt,0)) %>% 
    
    group_by(l1_sku,datedif) %>% 
    summarise(sum_gmv=sum(total_gmv), 
              sum_user_cnt = sum(user_cnt),
              .groups = "drop") %>% 
    
    #filter(l1_sku %in% c('思维', 'NA')) %>%
    group_by(l1_sku) %>%
    mutate(
      cum_gmv = cumsum(sum_gmv),
      cum_user_cnt = cumsum(sum_user_cnt),
      avg_gmv = cum_gmv / cum_user_cnt
    )
  
  ggplot(cumgmv4,aes(x = datedif, y = avg_gmv, colour = l1_sku , group = l1_sku)) + 
    geom_line() +
    scale_x_discrete(breaks = seq(0, 360, by = 60))

  
  
  cumgmv5 <- 
    result %>%
    filter(course_type_detail == '编程年课-首单',datedif<=360) %>% 
    mutate(datedif = as_factor(datedif)) %>% 
    mutate(total_gmv = as.numeric(total_gmv)) %>% 
    mutate(user_cnt = as.numeric(user_cnt)) %>% 
    mutate(user_cnt = ifelse(datedif == 0,user_cnt,0)) %>% 
    
    group_by(l1_goal_channel_type,datedif) %>% 
    summarise(sum_gmv=sum(total_gmv), 
              sum_user_cnt = sum(user_cnt),
              .groups = "drop") %>% 
    
    #filter(l1_sku %in% c('思维', 'NA')) %>%
    group_by(l1_goal_channel_type) %>%
    mutate(
      cum_gmv = cumsum(sum_gmv),
      cum_user_cnt = cumsum(sum_user_cnt),
      avg_gmv = cum_gmv / cum_user_cnt
    )
  
  ggplot(cumgmv5,aes(x = datedif, y = avg_gmv, colour = l1_goal_channel_type , group = l1_goal_channel_type)) + 
    geom_line() +
    scale_x_discrete(breaks = seq(0, 360, by = 60))
