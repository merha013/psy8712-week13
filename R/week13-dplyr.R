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

## Download three dataset on UMN SQL server
employees_tbl <- dbGetQuery(  
  conn, "SELECT * FROM cla_tntlab.datascience_employees;")
testscores_tbl <- dbGetQuery(  
  conn, "SELECT * FROM cla_tntlab.datascience_testscores;")
offices_tbl <- dbGetQuery(  
  conn, "SELECT * FROM cla_tntlab.datascience_offices;")

## Save as .csv file in data folder
write_csv(employees_tbl, "../data/employees.csv") 
write_csv(testscores_tbl, "../data/testscores.csv")  
write_csv(offices_tbl, "../data/offices.csv")  

dbDisconnect(conn)  # warning msg advised to use when finished w/connection

## Combine data with joins only
week13_tbl <- employees_tbl %>%  
  inner_join(testscores_tbl, by = join_by(employee_id)) %>% 
    ## inner_join only keeps observations from x that have a matching key in y
    ## which means it removes employees without test scores
  full_join(offices_tbl, by = join_by("city" == "office"))

## Save as .csv file in out folder
write_csv(week13_tbl, "../out/week13.csv")


# Analysis

## Total number of managers
summary1 <- nrow(week13_tbl)  
print(summary1)

## Total number of unique managers by ID
summary2 <- length(unique(week13_tbl$employee_id))  
  ## unique() returns a vector w/duplicates removed, but there were none
print(summary2)

## Display summary of number of managers
summary3 <- week13_tbl %>%  
  filter(manager_hire == "N") %>% 
    ## include only those who were not originally hired as managers
  group_by(city) %>% # split by location (city)
  summarise(num_managers = n())
print(summary3)

## Display mean & sd of muber of years of employment
summary4 <- week13_tbl %>%  
  group_by(performance_group) %>% # split by performance level
  summarise(mean_years = mean(yrs_employed),
            sd_years = sd(yrs_employed))
print(summary4)

## Display manager location type, ID, & test score
summary5 <- week13_tbl %>%  
  select(employee_id, type, test_score) %>%
  arrange(type, desc(test_score))
    ## arranged in alphabetical order by location type 
    ## then descending order of test score
print(summary5) # it would be easier to look at this dataset with View() 
View(summary5)