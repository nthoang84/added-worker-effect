# Read in the tiny CPS data
data <- read_csv(file.path(path_data_processed, "tiny_cleaned.csv"))

# Create leads and lags
data <- data %>%
  mutate(
    F2_head_switch = dplyr::lead(head_switch, n = 2), 
    F1_head_switch = dplyr::lead(head_switch, n = 1),
    L1_head_switch = dplyr::lag(head_switch, n = 1),
    L2_head_switch = dplyr::lag(head_switch, n = 2)
  )

# List of main independent variables
var_list <- c("F2_head_switch", "F1_head_switch", "head_switch", "L1_head_switch", "L2_head_switch")

# AWE regressions for full sample
run_model <- function(var_name) {
  formula_str <- paste0("spouse_out ~ ", var_name, " + factor(month) + factor(statefip) + factor(year) + factor(sex) + factor(race) + factor(nchild) + factor(college) + factor(college_sp)")
  fmla <- as.formula(formula_str)
  model <- lm(fmla, data = data, weights = panlwt)
  robust_vcov <- vcovHC(model, type = "HC1")
  robust_results <- coeftest(model, vcov = robust_vcov)
  coef_info <- robust_results[var_name, c("Estimate", "Std. Error")]
  data.frame(Variable = var_name,
             Estimate = coef_info[["Estimate"]],
             SE = coef_info[["Std. Error"]])
}

# Run all AWE regressions
df_coefs <- do.call(rbind, lapply(var_list, run_model))

# Label AWE estimates
df_coefs <- df_coefs %>%
  mutate(Label = case_when(
    Variable == "F2_head_switch"  ~ "in two months",
    Variable == "F1_head_switch"  ~ "next month",
    Variable == "head_switch"     ~ "this month",
    Variable == "L1_head_switch"  ~ "last month",
    Variable == "L2_head_switch"  ~ "two months ago"
  )) %>%
  mutate(Label = factor(Label, levels = c("two months ago", "last month", "this month", "next month", "in two months")))

# Calculate confidence intervals for AWE estimates
df_coefs <- df_coefs %>%
  mutate(
    Lower = Estimate - 1.96 * SE,
    Upper = Estimate + 1.96 * SE
  )

# Plot AWE regression estimates and CIs for full sample
coef_plot <- ggplot(df_coefs, aes(x = Estimate, y = Label)) +
  geom_point(shape = 20, size = 3, color = "black") + 
  geom_errorbarh(aes(xmin = Lower, xmax = Upper), height = 0.2, color = "black") +
  geom_text(aes(label = sprintf("%0.3f", Estimate)),
            vjust = -0.5,
            hjust = 0.5,
            size = 6,
            color = "black") +
  geom_vline(xintercept = 0, color = "maroon", linetype = "dashed") +
  scale_x_continuous(name = "AWE estimate",
                     breaks = seq(-0.02, 0.1, by = 0.02)) +
  ylab("Head loses job ...") +
  theme_bw(base_size = 18) +
  theme(legend.position = "none",
        panel.background = element_rect(fill = "white", color = NA),
        panel.grid.minor = element_blank())

ggsave(file.path(path_figures, "awe.pdf"), plot = coef_plot, width = 8, height = 6)

# AWE regressions for for subsamples (young and old spouses)
run_model <- function(var_name, data_subset) {
  formula_str <- paste0("spouse_out ~ ", var_name, " + factor(month) + factor(statefip) + factor(year) + factor(sex) + factor(race) + factor(nchild) + factor(college) + factor(college_sp)")
  fmla <- as.formula(formula_str)
  model <- lm(fmla, data = data_subset, weights = panlwt)
  robust_vcov <- vcovHC(model, type = "HC1")
  robust_results <- coeftest(model, vcov = robust_vcov)
  coef_info <- robust_results[var_name, c("Estimate", "Std. Error")]  
  data.frame(Variable = var_name,
             Estimate = coef_info[["Estimate"]],
             SE = coef_info[["Std. Error"]])
}

# Get subsamples for young and old spouses
young_data <- data %>% filter(age_sp > 25, age_sp <= 35)
old_data   <- data %>% filter(age_sp > 55, age_sp <= 65)

# Run AWE regressions for young-spouse subsample and get estimates
young_coefs <- do.call(rbind, lapply(var_list, function(v) run_model(v, young_data)))
young_coefs$Sample <- "Young spouse (26–35)"

# Run AWE regressions for old-spouse subsample and get estimates
old_coefs <- do.call(rbind, lapply(var_list, function(v) run_model(v, old_data)))
old_coefs$Sample <- "Old spouse (56–65)"

# Combine AWE estimates
df_coefs_all <- bind_rows(young_coefs, old_coefs)

# Label AWE estimates
df_coefs_all <- df_coefs_all %>%
  mutate(Sample = factor(Sample, levels = c("Young spouse (26–35)", "Old spouse (56–65)"))) %>%
  mutate(Label = case_when(
    Variable == "F2_head_switch"  ~ "in two months",
    Variable == "F1_head_switch"  ~ "next month",
    Variable == "head_switch"     ~ "this month",
    Variable == "L1_head_switch"  ~ "last month",
    Variable == "L2_head_switch"  ~ "two months ago"
  )) %>%
  mutate(Label = factor(Label, levels = c("two months ago", "last month", "this month", "next month", "in two months")))

# Calculate confidence intervals for AWE estimates
df_coefs_all <- df_coefs_all %>%
  mutate(
    Lower = Estimate - 1.96 * SE,
    Upper = Estimate + 1.96 * SE
  )

# Plot AWE regression estimates and CIs for subsamples (young and old spouses)
coef_plot <- ggplot(df_coefs_all, aes(x = Estimate, y = Label)) +
  geom_point(shape = 20, size = 3, color = "black") + 
  geom_errorbarh(aes(xmin = Lower, xmax = Upper), height = 0.2, color = "black") +
  geom_text(aes(label = sprintf("%0.3f", Estimate)),
            vjust = -0.5,
            hjust = 0.5,
            size = 6,
            color = "black") +
  geom_vline(xintercept = 0, color = "maroon", linetype = "dashed") +
  scale_x_continuous(name = "AWE estimate",
                     breaks = seq(-0.02, 0.12, by = 0.02)) +
  ylab("Head loses job ...") +
  facet_wrap(~ Sample, ncol = 2) +
  theme_bw(base_size = 18) +
  theme(legend.position = "none",
        panel.background = element_rect(fill = "white", color = NA),
        panel.grid.minor = element_blank())

ggsave(file.path(path_figures, "awe_by_age_spouse.pdf"), plot = coef_plot, width = 12, height = 6)