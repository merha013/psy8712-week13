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
dbExecute(conn, "USE cla_tntlab;")


# Analysis

## Total number of managers
results1 <- dbGetQuery(  
  conn, "SELECT COUNT(*) AS total_managers 
  FROM cla_tntlab.datascience_employees
  WHERE employee_id IN (
  SELECT DISTINCT employee_id    # selecting only those with test scores
  FROM cla_tntlab.datascience_testscores);")
print(results1)

## Total number of unique managers by ID
results2 <- dbGetQuery(  
  conn, "SELECT COUNT(DISTINCT employee_id) 
  AS total_unique_managers 
  FROM cla_tntlab.datascience_employees
  WHERE employee_id IN (
    SELECT DISTINCT employee_id    # selecting only those with test scores
    FROM cla_tntlab.datascience_testscores);")
print(results2)

## Display summary of number of managers
results3 <- dbGetQuery(  
  conn, "SELECT city, COUNT(*) AS num_managers
  FROM cla_tntlab.datascience_employees
  WHERE employee_id IN (
    SELECT DISTINCT employee_id    # selecting only those with test scores
    FROM cla_tntlab.datascience_testscores)
  AND manager_hire = 'N'     # only those not origionally hired as managers
  GROUP BY city;")     # split by location (city)
print(results3)

## Display mean & sd of number of years of employment
results4 <- dbGetQuery(  
  conn, "SELECT performance_group, 
  AVG(yrs_employed) AS mean_years,
  STDDEV(yrs_employed) AS sd_years
  FROM cla_tntlab.datascience_employees
  WHERE employee_id IN (
    SELECT DISTINCT employee_id    # selecting only those with test scores
    FROM cla_tntlab.datascience_testscores)
  GROUP BY performance_group;")     # split by performance level
print(results4)

## Display manager location type, ID, & test score
results5 <- dbGetQuery(  
  conn, "SELECT o.type, e.employee_id, t.test_score
  FROM cla_tntlab.datascience_employees AS e
  INNER JOIN cla_tntlab.datascience_testscores AS t
  ON e.employee_id = t.employee_id
  INNER JOIN cla_tntlab.datascience_offices AS o
  ON e.city = o.office
  WHERE e.employee_id IN (
    SELECT DISTINCT employee_id    # selecting only those with test scores
    FROM cla_tntlab.datascience_testscores)
  ORDER BY o.type ASC, t.test_score DESC;") 
    ## arranged in alphabetical order by location type 
    ## then descending order of test score
print(results5) # it would be easier to look at this dataset with View()
View(results5)

dbDisconnect(conn) 