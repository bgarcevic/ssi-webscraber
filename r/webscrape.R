library(tidyverse)
library(rvest)
library(lubridate)

ssi_url <- "https://covid19.ssi.dk/overvagningsdata/download-fil-med-overvaagningdata"

ssi_webpage <- read_html(ssi_url)

ssi_webpage <-
  ssi_webpage %>% 
  html_nodes("a") %>% 
  html_attr('href')

# Create data frame for finding the latest file url
ssi_webpage_data <- tibble("url_text" = ssi_webpage)

ssi_webpage_data <- ssi_webpage_data %>%
  filter(grepl("https://files.ssi.dk/", url_text, ignore.case = TRUE)) %>%
  mutate(date = dmy(str_match(url_text, "\\d{8}"))) %>%
  unique() %>%
  filter(date == max(date)) %>%
  select(url_text)

# Get URL and create file destination name
ssi_url <- ssi_webpage_data$url_text
dest_name <- sub("https://files.ssi.dk/covid19/overvagning/data/", "", paste0("./data/downloaded/", ssi_url, ".zip"))


# Dont download if file already exists
if (!file.exists(dest_name)) {
  download.file(ssi_url, dest_name, mode="wb")
  unlink("./data/infected/*")
  unzip(dest_name, exdir = "./data/infected")
} 




