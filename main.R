library(dplyr)
library(ggplot2)
library(ggstance)
library(ipumsr)
library(lmtest)
library(plm)
library(purrr)
library(readr)
library(sandwich)
library(zoo)

options(pillar.sigfig = 22)

download_flag <- FALSE
process_data_flag <- FALSE
run_regressions_flag <- TRUE

path_data_raw <- "data/raw/"
path_data_processed <- "data/processed/"
path_figures <- "figures/"

if (download_flag) {
  set_ipums_api_key(Sys.getenv("IPUMS_API_KEY"))
  source("R/extract_data.R");
}

if (process_data_flag) {
  source("R/process_data.R")
}

if (run_regressions_flag) {
  source("R/run_regressions.R")
}