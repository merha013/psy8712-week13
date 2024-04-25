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

## download all three datasets on the UMN SQL server
employees_tbl <- dbGetQuery(conn, "SELECT * FROM 
                            cla_tntlab.datascience_employees;")
testscores_tbl <- dbGetQuery(conn, "SELECT * FROM 
                             cla_tntlab.datascience_testscores;")
offices_tbl <- dbGetQuery(conn, "SELECT * FROM 
                          cla_tntlab.datascience_offices;")

## Save them as .csv files 
write_csv(employees_tbl, "../data/employees.csv")
write_csv(testscores_tbl, "../data/testscores.csv")
write_csv(offices_tbl, "../data/offices.csv")

dbDisconnect(conn) # warning msg advised to use this when finished w/connection

## Combine the data with joins only
week13_tbl <- employees_tbl %>%
  inner_join(testscores_tbl, by = join_by(employee_id)) %>% 
    ## inner_join only keeps observations from x that have a matching key in y
  full_join(offices_tbl, by = join_by("city" == "office"))

## Save this file as week13.csv and place in out folder
write_csv(week13_tbl, "../out/week13.csv")


# Analysis
nrow(week13_tbl) # total number of managers
length(unique(week13_tbl$employee_id)) # total number of unique managers by ID
  ## unique returns a vector with duplicates removed, but there were none

## summary of number of managers
week13_tbl %>%
  filter(manager_hire == "N") %>% 
    ## include only those who were not originally hired as managers
  group_by(city) %>% # split by location (city)
  View

## Display the mean and standard deviation of number of years of employment split by performance level (bottom, middle, and top) - in addition to dplyr functions, you can use mean() and sd() for this task.

## Display each manager's location classification (urban vs. suburban), ID number, and test score, in alphabetical order by location type and then descending order of test score.
