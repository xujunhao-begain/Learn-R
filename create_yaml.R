# 加载 yaml 包
library(yaml)

# 创建一个列表，存储要写入 YAML 文件的数据
data <- list(
  name = "John Doe",
  age = 30,
  city = "New York",
  skills = c("Python", "Java", "SQL")
)

# 将数据写入 YAML 文件
write_yaml(data, "data.yaml")