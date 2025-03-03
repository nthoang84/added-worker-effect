data <- read_csv(file.path(path_data_processed, "tiny_cleaned.csv"))

model <- lm(spouse_out ~ head_switch +
                         factor(month) +
                         factor(statefip) +
                         factor(year) +
                         factor(sex) +
                         factor(race) +
                         factor(nchild) +
                         factor(college) +
                         factor(college_sp),
            data = data,
            weights = panlwt)

robust_vcov <- vcovHC(model, type = "HC1")
robust_results <- coeftest(model, vcov = robust_vcov)
print(robust_results)