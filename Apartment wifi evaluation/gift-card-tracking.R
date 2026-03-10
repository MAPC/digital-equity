library(tidyverse)

data_path <- "C:/Users/aderosa/OneDrive - Metropolitan Area Planning Council/Digital Equity - Resident Engagement Release Forms/Survey data pulls for gitf card tracking"

pre_survey <- read_csv(file.path(data_path, "Apartment+Wifi+Evaluation+Pre-Survey_March+9,+2026_13.11.csv")) |> 
  janitor::clean_names() |> 
  rename(unit_no = q88, phone_no = q89, building = q77, gc_type = q97, email_old = q94, email_new = q98_1, 
         first_name = q99_1, last_name = q99_2, address = q99_3) |> 
  select(recorded_date, progress, duration_in_seconds, finished, #user_language, 
         first_name, last_name, building, unit_no, phone_no, gc_type, email_old, email_new, address) |> 
  slice(3:n())

post_survey <- read_csv(file.path(data_path, ".csv")) |> 
  janitor::clean_names() 

colnames(post_survey)

# pre-survey list of those who completed the survey
pre_survey_review <- pre_survey |> 
  #filtering out responses that qualtrics marked as unfinished - can review progress and duration fields to confirm
  filter(finished == "True") |> 
  mutate(
    duration_in_seconds = as.integer(duration_in_seconds),
    #flag surveys to review that were completed in less than 3 minutes
    review = ifelse(duration_in_seconds <= 180, 1, 0)
    )

# check for duplicate unit responses
duplicates <- pre_survey_review |> 
  mutate(join = paste0(unit_no, building, sep = "_"))
  
# pre-survey export of respondents who should receive gift cards
pre_survey_gc <- pre_survey_review |> 
  mutate(email = ifelse(!is.na(email_old), email_old, email_new)) |> 
  select(first_name, last_name, building, unit_no, gc_type, email, address)






