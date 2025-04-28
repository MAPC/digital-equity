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


# Accessing Data
content(hud_chas_request, as = "text")

content_test<-hud_chas_request %>%
  content(as = "text") %>%
  fromJSON()

# Writing an Access Function
get_hud_chas <- function(
    type, 
    year = "2016-2020", 
    state_id = NULL, 
    entity_id = NULL, 
    token = NULL
) {
  
  # Check to see if a token exists
  if (is.null(token)) {
    if (Sys.getenv("HUD_TOKEN") != "") {
      token <- Sys.getenv("HUD_TOKEN")
    }
  }
  
  # Specify the base URL
  base_url <- "https://www.huduser.gov/hudapi/public/chas"
  
  # Make the query
  hud_query <- httr::GET(
    base_url,
    httr::add_headers(Authorization = glue::glue("Bearer {token}")),
    query = list(
      type = type,
      year = year,
      stateId = state_id,
      entityId = entity_id)
  )
  
  # Return the HTTP error message if query failed
  if (hud_query$status_code != "200") {
    msg <- httr::content(hud_query, as = "text")
    return(msg)
  }
  
  # Return the content as text
  hud_content <- httr::content(hud_query, as = "text")
  
  # Convert the data to a long-form tibble
  hud_tibble <- hud_content %>%
    jsonlite::fromJSON() %>%
    dplyr::as_data_frame() %>%
    tidyr::pivot_longer(cols = !dplyr::all_of(c("geoname", "sumlevel", "year")),
                        names_to = "indicator",
                        values_to = "value")

  return(hud_tibble)
  
}

chazzed<-get_hud_chas(type = 4, state_id = 25, entity_id = 617)
