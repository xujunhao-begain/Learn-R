library(config)
library(DBI)
library(odbc)
library(pool)
library(dplyr)
library(duckdb)
library(RSQLite)

con_tab <- yaml::read_yaml(file = "con_tab.yaml")
.config <- config::get(file = "my_config.yaml")

if(.config$origin == "mysql_db"){
  .config = config::get(config = "mysql_db",file = "my_config.yaml")
  pool <- dbPool(
    drv = RMySQL::MySQL(),
    host = .config$host,
    user = .config$user,
    password = .config$pwd,
    port = .config$port,
    db = .config$database
  )
  pool::dbExecute(pool, 'SET NAMES UTF8')
}

if(.config$origin == "duck_db") {
  .config = config::get(config = "duck_db",file = "my_config.yaml")
  pool <-  dbPool(duckdb(),
                  dbdir = .config$dbdir,
                  read_only = TRUE)
}

ads_eda_ltv_course_type_hdf_tbl <- tbl(pool, "ads_eda_ltv_course_type_hdf")


