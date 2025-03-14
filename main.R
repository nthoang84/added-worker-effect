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

# Set IPUMS API key
IPUMS_API_KEY <- "YOUR-IPUMS-API-KEY-HERE"

# Set options for displaying output
options(pillar.sigfig = 22)
options(knitr.kable.NA = "")

# Control flags for conditional execution
flag_extract_data <- FALSE    
flag_process_data <- FALSE    
flag_compute_transitions <- FALSE
flag_run_regressions <- FALSE 

# Define file paths
path_data_raw <- "data/raw/"
path_data_processed <- "data/processed/"
path_figures <- "figures/"
path_tables <- "tables/"

# Create directories if they do not exist
if (!dir.exists(path_data_raw)) dir.create(path_data_raw, recursive = TRUE)
if (!dir.exists(path_data_processed)) dir.create(path_data_processed, recursive = TRUE)
if (!dir.exists(path_figures)) dir.create(path_figures, recursive = TRUE)
if (!dir.exists(path_tables)) dir.create(path_tables, recursive = TRUE)

# Main execution starts here
if (flag_extract_data) {
  source("R/extract_data.R")
}

if (flag_process_data) {
  source("R/process_data.R")
}

if (flag_compute_transitions) {
  source("R/compute_transitions.R")
}

if (flag_run_regressions) {
  source("R/run_regressions.R")
}