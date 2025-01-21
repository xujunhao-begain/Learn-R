library(readxl)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(hrbrthemes)
library(plotly)
theme_set(theme_ipsum())

new_score<-read_excel("data/raw.xlsx", sheet = "Data")

raw<-read_excel("data/raw_raw.xlsx")

bins<-c(-Inf, 60, 90,110, 130, 140, Inf)

clipr::write_clip(new_score |> filter(term_year=='2023年'&
                                        l1_user_group=='思维') |> 
                    mutate(score_bins = cut(city_score, breaks = bins)) |> 
                    group_by(score_bins) |> 
                    summarise(b2c_enroll = sum(b2c_user_cnt),
                              rate1=sum(l1_user_cnt)/sum(b2c_user_cnt),
                              rate2=sum(l1_renew)/sum(l1_user_cnt),
                              rate = sum(l1_renew)/sum(b2c_user_cnt)))



null_df <- raw |> mutate(province=b2c_school_province,
                         city=b2c_school_city,
                         district=b2c_school_district) |> 
  group_by(province, city, district,city_score) |> 
  summarise(enroll=sum(b2c_user_cnt)) |> 
  ungroup() |> 
  filter(is.na(city_score)) 


# 未匹配上的空值，类型判断（是否属于标准地级市行政区？）

price_dat <- read_excel("data/区县级房价数据_.xlsx") |> 
  mutate(
    city = if_else(省级类=='直辖市', 省级, 地级),
    district = 县级,
    price = 价格) |> 
  select(city, district, price)


null_df |> left_join(price_dat) |> 
  view()


# 属于标准行政区但未匹配上，评分使用城市平均值填充----

city_score<-read_csv("data/new_score.csv") |> 
  group_by(city) |> 
  summarise(score=mean(score)) |> 
  ungroup()


df <- raw |> mutate(term_year = substr(b2c_term_tag_name, 1, 5)) |>
  filter(term_year == '2023年' &
           l1_user_group == '思维') |>
  mutate(province = b2c_school_province,
         city = b2c_school_city,
         district = b2c_school_district) |>
  group_by(province, city, district, city_score) |>
  summarise(b2c_user_cnt = sum(b2c_user_cnt),
            l1_user_cnt=sum(l1_user_cnt),
            l1_renew=sum(l1_renew)) |>
  ungroup() |>
  left_join(city_score) |>
  left_join(price_dat) |>
  mutate(city_score = if_else((is.na(city_score)) &
                                (!is.na(price)), score, city_score))
# filter(is.na(city_score)) |> view()

df %>% 
  filter(city=='临沂市') %>% 
  view()

# 匹配完的效果验证----
df |> 
  group_by(province, city, district,city_score) |> 
  summarise(enroll=sum(b2c_user_cnt)) |> 
  ungroup() |> 
  filter(is.na(city_score)) 

clipr::write_clip(
  df |> 
    mutate(score_bins = cut(city_score, breaks = bins)) |> 
    group_by(score_bins) |> 
    summarise(b2c_enroll = sum(b2c_user_cnt),
              rate1=sum(l1_user_cnt)/sum(b2c_user_cnt),
              rate2=sum(l1_renew)/sum(l1_user_cnt),
              rate = sum(l1_renew)/sum(b2c_user_cnt))
)

