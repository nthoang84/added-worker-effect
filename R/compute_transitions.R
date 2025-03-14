data <- read_csv(file.path(path_data_processed, "tiny_cleaned.csv"))

subset_ee <- data %>% 
  filter(trans_ind == 11,
         l_spempstat3 == 3,
         panlwt != -0.0001)

pct_table_ee <- subset_ee %>%
  group_by(trans_ind_sp) %>%
  dplyr::summarize(weight_sum = sum(panlwt, na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(percentage = round(100 * weight_sum / sum(weight_sum), 2))

print(pct_table_ee)

subset_eu <- data %>% 
  filter(trans_ind == 12,
         l_spempstat3 == 3,
         panlwt != -0.0001)

pct_table_eu <- subset_eu %>%
  group_by(trans_ind_sp) %>%
  dplyr::summarize(weight_sum = sum(panlwt, na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(percentage = round(100 * weight_sum / sum(weight_sum), 2))

print(pct_table_eu)

subset_en <- data %>% 
  filter(trans_ind == 13,
         l_spempstat3 == 3,
         panlwt != -0.0001)

pct_table_en <- subset_en %>%
  group_by(trans_ind_sp) %>%
  dplyr::summarize(weight_sum = sum(panlwt, na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(percentage = round(100 * weight_sum / sum(weight_sum), 2))

print(pct_table_en)

subset_head <- data %>% 
  filter(trans_ind %in% c(11, 12, 13),
         trans_ind_sp %in% c(31, 32, 33),
         l_spempstat3 == 3,
         panlwt != -0.0001)

pct_table_head <- subset_head %>%
  group_by(trans_ind) %>%
  dplyr::summarize(weight_sum = sum(panlwt, na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(percentage = round(100 * weight_sum / sum(weight_sum), 2))
  
print(pct_table_head)

table_data <- data.frame(
  Description = c("Average flow rates of primary earner", 
                  "Cond. prob. of spousal NE transition",
                  "Cond. prob. of spousal NU transition",
                  "Cond. prob. of spousal NN transition",
                  "AWE (total)"),
  EE  = rep(NA, 5),
  EU  = rep(NA, 5),
  EN  = rep(NA, 5),
  AWE = rep(NA, 5),
  stringsAsFactors = FALSE
)

table_data[table_data$Description == "Average flow rates of primary earner", "EE"] <- pct_table_head$percentage[pct_table_head$trans_ind == 11]
table_data[table_data$Description == "Average flow rates of primary earner", "EU"] <- pct_table_head$percentage[pct_table_head$trans_ind == 12]
table_data[table_data$Description == "Average flow rates of primary earner", "EN"] <- pct_table_head$percentage[pct_table_head$trans_ind == 13]

table_data[table_data$Description == "Cond. prob. of spousal NE transition", "EE"] <- pct_table_ee$percentage[pct_table_ee$trans_ind_sp == 31][1]
table_data[table_data$Description == "Cond. prob. of spousal NU transition", "EE"] <- pct_table_ee$percentage[pct_table_ee$trans_ind_sp == 32][1]
table_data[table_data$Description == "Cond. prob. of spousal NN transition", "EE"] <- pct_table_ee$percentage[pct_table_ee$trans_ind_sp == 33][1]

table_data[table_data$Description == "Cond. prob. of spousal NE transition", "EU"] <- pct_table_eu$percentage[pct_table_eu$trans_ind_sp == 31][1]
table_data[table_data$Description == "Cond. prob. of spousal NU transition", "EU"] <- pct_table_eu$percentage[pct_table_eu$trans_ind_sp == 32][1]
table_data[table_data$Description == "Cond. prob. of spousal NN transition", "EU"] <- pct_table_eu$percentage[pct_table_eu$trans_ind_sp == 33][1]

table_data[table_data$Description == "Cond. prob. of spousal NE transition", "EN"] <- pct_table_en$percentage[pct_table_en$trans_ind_sp == 31][1]
table_data[table_data$Description == "Cond. prob. of spousal NU transition", "EN"] <- pct_table_en$percentage[pct_table_en$trans_ind_sp == 32][1]
table_data[table_data$Description == "Cond. prob. of spousal NN transition", "EN"] <- pct_table_en$percentage[pct_table_en$trans_ind_sp == 33][1]

table_data[table_data$Description == "Cond. prob. of spousal NE transition", "AWE"] <- 
  table_data[table_data$Description == "Cond. prob. of spousal NE transition", "EU"] - 
  table_data[table_data$Description == "Cond. prob. of spousal NE transition", "EE"]

table_data[table_data$Description == "Cond. prob. of spousal NU transition", "AWE"] <- 
  table_data[table_data$Description == "Cond. prob. of spousal NU transition", "EU"] - 
  table_data[table_data$Description == "Cond. prob. of spousal NU transition", "EE"]

table_data[table_data$Description == "AWE (total)", "AWE"] <- 
  table_data[table_data$Description == "Cond. prob. of spousal NE transition", "AWE"] + 
  table_data[table_data$Description == "Cond. prob. of spousal NU transition", "AWE"]

print(table_data)

table_data[, 2:5] <- lapply(table_data[, 2:5], function(x) {
  ifelse(!is.na(x), paste0(x, "\\%"), "")
})

latex_table <- kable(table_data,
                     format = "latex",
                     booktabs = TRUE,
                     escape = FALSE,
                     col.names = c("", "EE", "EU", "EN", "AWE"))

latex_table <- add_header_above(latex_table, c(" " = 1, "Primary earner transition" = 4))
latex_table <- row_spec(latex_table, 1, extra_latex_after = "\\midrule")
latex_table <- row_spec(latex_table, 4, extra_latex_after = "\\midrule")
latex_table <- paste(latex_table, collapse = "\n")
latex_table <- str_replace_all(latex_table, "(\\\\midrule)\\\\+", "\\1")

cat(latex_table)

tex_document <- paste0(
"\\documentclass{article}\n",
"\\usepackage{booktabs}\n",
"\\usepackage[utf8]{inputenc}\n",
"\\begin{document}\n\n",
latex_table, "\n\n",
"\\end{document}\n"
)

writeLines(tex_document, con = file.path(path_tables, "transitions.tex"))

# for file in tables/*.tex; do pdflatex -output-directory=tables "$file"; done