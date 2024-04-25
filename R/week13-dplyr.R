# Script Settings and Resources
library(tidyverse)
library(RMariaDB)
library(keyring)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Data Import and Cleaning
conn <- dbConnect(MariaDB(),
                  user="merha013",
                  password=key_get("latis-mysql","merha013"),
                  host="mysql-prod5.oit.umn.edu",
                  port=3306,
                  ssl.ca='../mysql_hotel_umn_20220728_interm.cer')

show_databases <- dbGetQuery(conn,"SHOW DATABASES;") # show available databases
dbExecute(conn, "USE cla_tntlab;")
dbExecute(conn, "USE performance_schema;")
dbExecute(conn, "USE information_schema;")

## download all three datasets on the UMN SQL server
employees_tbl <- dbGetQuery(conn, "SELECT * FROM cla_tntlab;")
testscores_tbl <- dbGetQuery(conn, "SELECT * FROM performance_schema;")
offices_tbl <- dbGetQuery(conn, "SELECT * FROM information_schema;")

## Save them as .csv files 
employees_tbl <- write.csv(employees_tbl, 
                           "../data/employees.csv", row.names=FALSE)
testscores_tbl <- write.csv(testscores_tbl, 
                            "../data/testscores.csv", row.names=FALSE)
offices_tbl <- write.csv(offices_tbl, 
                         "../data/offices.csv", row.names=FALSE)

## Combine the data with joins only
week13_tbl <- employees_tbl %>%
  left_join(testscores_tbl, by = "employee_id") %>%
  left_join(offices_tbl, by = "employee_id") %>%
  filter(!is.na(test_score)) # Remove employees without test scores

## Save this file as week13.csv and place in out folder
write.csv(week13_tbl, "../out/week13.csv", row.names = FALSE)


# Analysis
## Using dplyr functions alone (do not use base), do the following:
## Display the total number of managers.

## Display the total number of unique managers (i.e., unique by id number).

## Display a summary of the number of managers split by location, but only include those who were not originally hired as managers.

## Display the mean and standard deviation of number of years of employment split by performance level (bottom, middle, and top) - in addition to dplyr functions, you can use mean() and sd() for this task.

## Display each manager's location classification (urban vs. suburban), ID number, and test score, in alphabetical order by location type and then descending order of test score.
