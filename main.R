library(dplyr)
library(ggplot2)
library(ggstance)
library(Hmisc)
library(ipumsr)
library(kableExtra)
library(knitr)
library(lmtest)
library(plm)
library(purrr)
library(readr)
library(sandwich)
library(stringr)
library(zoo)

options(pillar.sigfig = 22)
options(knitr.kable.NA = "")

flag_download <- FALSE
flag_process_data <- FALSE
flag_run_regressions <- FALSE
flag_compute_transitions <- TRUE

path_data_raw <- "data/raw/"
path_data_processed <- "data/processed/"
path_figures <- "figures/"
path_tables <- "tables/"

if (flag_download) {
  set_ipums_api_key(Sys.getenv("IPUMS_API_KEY"))
  source("R/extract_data.R");
}

if (flag_process_data) {
  source("R/process_data.R")
}

if (flag_run_regressions) {
  source("R/run_regressions.R")
}

if (flag_compute_transitions) {
  source("R/compute_transitions.R")
}