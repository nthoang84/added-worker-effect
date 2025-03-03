library(dplyr)
library(ipumsr)
library(lmtest)
library(plm)
library(purrr)
library(readr)
library(zoo)

options(pillar.sigfig = 22)

download_flag <- FALSE

path_data_raw <- "data/raw/"
path_data_processed <- "data/processed/"
path_figures <- "figures/"

if (download_flag) {
  set_ipums_api_key(Sys.getenv("IPUMS_API_KEY"))
  source("R/extract_data.R");
}

source("R/process_data.R")

source("R/run_regressions.R")