# 用于时间匹配触发，并返回数据集
trg_re <- function(tbl, col, dt) {
  tbl |>
    filter({{col}} == dt) |>
    collect()
}