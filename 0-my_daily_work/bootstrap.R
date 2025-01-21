library(tidyverse)
library(gt)
#最终生成的表格会展示 A 组的得分系数及其置信区间，反映了 A 组的平均分相对于整体
#平均分的水平，并提供了对估计结果的置信度度量

# 创建示例数据
raw_data <- tibble(
  student_id = 1:10,
  group = rep(c("A", "B"), each = 5),
  score = c(80, 85, 90, 95, 75, 70, 78, 82, 88, 92)
)

# 定义 bootstrapping 函数
perform_bootstrap <- function(data, group_name, trials = 1000) {
  1:trials %>% 
    map_dbl(~ {
      # 对指定组别进行有放回抽样
      bootstrap_sample <- data %>% 
        filter(group == group_name) %>% 
        sample_n(n(), replace = TRUE)
      
      # 计算抽样样本的平均分
      mean(bootstrap_sample$score)
    })
}

# 对 A 组进行 bootstrapping
group_A_bootstrap_means <- perform_bootstrap(raw_data, "A",100)

# 计算 A 组 bootstrapping 平均分的置信区间
group_A_ci <- quantile(group_A_bootstrap_means, c(0.025, 0.975))

# 对整体数据进行 bootstrapping
overall_bootstrap_means <- perform_bootstrap(raw_data, c("A", "B"),100)

# 计算整体数据 bootstrapping 平均分的置信区间
overall_ci <- quantile(overall_bootstrap_means, c(0.025, 0.975))

# 计算 A 组相对于整体的得分系数 (使用 bootstrapping 平均分)
score_coefficient <- mean(group_A_bootstrap_means) / mean(overall_bootstrap_means)

# 创建结果数据框
result_data <- tibble(
  group = "A",
  score_coefficient = score_coefficient,
  ci_lower = group_A_ci[1] / overall_ci[2],  # 系数置信区间下限
  ci_upper = group_A_ci[2] / overall_ci[1]   # 系数置信区间上限
)

# 生成表格：使用 gt 包生成表格
table <- result_data %>% 
  gt() %>% 
  cols_label(
    group = "组别",
    score_coefficient = "得分系数",
    ci_lower = "置信区间下限",
    ci_upper = "置信区间上限"
  )

# 显示表格
table
