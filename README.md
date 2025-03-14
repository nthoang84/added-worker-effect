# added-worker-effect

Documenting empirical evidence of added worker effect (AWE) among US households using IPUMS Current Population Survey (CPS) microdata.

## Overview
Marriage offers an economic benefit by sharing risks through pooled resources and joint financial management. During economic challenges, having a partner serves as a safety net; if one partner faces illness or job loss, the other can provide support, reducing the overall burden. This risk diversification enhances family resilience. The AWE refers to an increase in labor supply among spouses when one partner becomes unemployed.

## Program Description
This section explains how to run the main R program, details each subprogram, and summarizes the expected outputs from each module.

### Main program

The source file `main.R` in the root directory serves as the master file and calls all subprograms located in the `R` subfolder. Ideally, you should edit only this file rather than the individual subprograms. There are two important steps you need to complete before running this master file, described below. To run the master file, simply execute `source("main.R")` in the R terminal.

#### Get IPUMS API key to download CPS microdata

This program uses the IPUMS API to extract CPS data. First, register for a user account on the [IPUMS CPS data website](https://cps.ipums.org/cps/). Note that IPUMS may require you to verify your account via email. Next, [request an API key](https://account.ipums.org/api_keys) then paste your API key into the following line in `main.R`:

```r
# Set IPUMS API key
IPUMS_API_KEY <- "YOUR-IPUMS-API-KEY-HERE"
```

For more details, please visit the [IPUMS API documentation](https://developer.ipums.org/docs/v2/get-started/).

#### Control flags for execution of subprograms

In `main.R`, several control flags allow you to select which subprograms to run. It is recommended that you first extract data as an isolated step to ensure that the raw (and very large) data is downloaded correctly before proceeding with data cleaning and analysis.

Now, I provide a description of each subprogram below and the expected outputs produced by them.

### Extract CPS microdata

The source file `R/extract_data.R` defines the data extraction API request for IPUMS CPS with specified samples and variables. The extraction request currently includes samples from 1994 to 2020. For more details on this procedure and the IPUMS CPS API methods, please visit the [IPUMS CPS Data Extraction documentation](https://developer.ipums.org/docs/v1/workflows/create_extracts/cps/).

This is a large dataset (about 2GB) and may take several minutes to execute. To ensure the program runs on a standard personal computer, the subsequent analysis is restricted to samples from 1994 to 1997 only. You can change the sample years to any range from 1994 to 2020, but this is not recommended unless you have access to a computing cluster. After selecting the necessary variables and restricting the sample years, the expected output is a data file named `tiny.csv` located in the raw data path `data/raw`.

### Data cleaning and variable construction

The source file `R/process_data.R` cleans the data and creates the necessary variables for analysis. It requires that the data extraction step has been completed and that `data/raw/tiny.csv` has been produced. 

This subprogram matches household heads with their spouses and creates essential variables such as employment status and indicators of employment transitions. Additional control variables for subsequent regressions are also cleaned. The expected output is a cleaned data file named `tiny_cleaned.csv` located in the processed data path `data/processed`.

### Compute probabilities of employment status transitions

The source file `R/compute_transitions.R` computes the probability of a spousal transition from out of the labor force, conditional on primary earner transitions. It requires that the data cleaning step has been completed and that `data/processed/tiny_cleaned.csv` has been produced.

The expected output is a TeX table summarizing the transition probabilities for primary earners and spouses, saved as `tables/transitions.tex`. To produce the PDF version of the table without invoking a system call to `pdflatex` within R, open a separate terminal in the root directory and run:

```bash
for file in tables/*.tex; do pdflatex -output-directory=tables "$file"; done
```
This command will create `tables/transitions.pdf` which includes the PDF version of the table. If you have not installed `pdflatex` on your machine, you can also use Overleaf or other methods to render the table.


### Running AWE regressions

The source file `R/run_regressions.R` performs a regression analysis on the transition probability that a spouse enters the labor force when the primary earner transitions into unemployment. It requires that the data cleaning step has been completed and that `data/processed/tiny_cleaned.csv` is available.

The analysis compares the change in probability that a non-participating spouse enters the labor force (either as employed or unemployed) relative to a baseline where the head remains employed. In particular, the regressions estimate this effect for the head losing their job at different time points: two months before, one month before, in the same month, one month after, and two months after the head becomes unemployed. The expected output is shown in the plot `figures/awe.pdf`, which displays the AWE regression coefficient estimates along with their confidence intervals.

Additionally, the same procedure is applied to subsamples of couples where one spouse is employed and the other is out of the labor force, specifically for couples with a spouse aged 26–35 (young) and 56–65 (old). The expected output is shown in the plot `figures/awe_by_age_spouse.pdf`, which displays the AWE regression coefficient estimates with confidence intervals.

## Acknowledgements

This project serves as my final assignment for _ECON 2020: Applied Economic Analysis_, taught by [Matthew DeHaven](https://github.com/matdehaven) in Spring 2025. The AWE and its empirical evidence, which my project is based on, have been extensively discussed in [Lundberg](https://www.jstor.org/stable/2535048) (1985, _Journal of Labor Economics_), [Mankart and Oikonomou](https://doi.org/10.1093/restud/rdw055) (2016, _Review of Economic Studies_), and [Bacher, Grübener, and Nord](https://doi.org/10.1016/j.jmoneco.2024.103696) (2025, _Journal of Monetary Economics_). The data used in this project is from _IPUMS CPS: Version 11.0_ by [Flood et al.](https://doi.org/10.18128/D030.V11.0) (2023). I thank the course instructor and my classmates for their helpful comments during the project proposal and presentation. Any remaining errors are my own.