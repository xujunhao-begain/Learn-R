library(DBI)
library(odbc)
library(pool)
library(dplyr)


.config = config::get(file="my_config.yaml" ,config = "mysql_db")

pool <- dbPool(
  drv = RMySQL::MySQL(),
  host = .config$host,
  user = .config$user,
  password = .config$pwd,
  port = .config$port,
  db = .config$database
)

pool::dbExecute(pool, 'SET NAMES UTF8')
