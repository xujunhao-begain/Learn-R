library(config)
library(DBI)
library(odbc)
library(pool)
library(dplyr)
library(duckdb)
library(RSQLite)

.config <- config::get()

if(.config$origin == "mysql_db"){
  .config = config::get(config = "mysql_db")
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
  .config = config::get(config = "duck_db")
  pool <-  dbPool(duckdb(),
                  dbdir = .config$dbdir,
                  read_only = TRUE)
}

ads_eda_ltv_course_type_hdf_tbl <- tbl(pool, "ads_eda_ltv_course_type_hdf")
