#Accessing CHAS Data
## Tutorial Link: https://walker-data.com/census-r/other-census-and-government-data-resources.html

## Setting up HUD Token

library(usethis)

edit_r_environ()
## In the R.env write a new line with HUD_TOKEN = "[token copied from HUD]"

library(glue)
library(httr)
library(jsonlite)
library(tidyverse)

#This should appear as an object in your global environment --->
my_token <- Sys.getenv("HUD_TOKEN")


hud_chas_request <- GET("https://www.huduser.gov/hudapi/public/chas?type=3&year=2012-2016&stateId=51&entityId=59",
                        add_headers(Authorization = glue("Bearer {my_token}")))

# Succesful output: [1] 200
hud_chas_request$status_code
