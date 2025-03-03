data <- read_csv(file.path(path_data_raw, "tiny.csv"))

data <- data %>%
  filter(age >= 26, age <= 65)

data <- data %>% 
  filter(relate %in% c(101, 201, 202, 203, 1114, 1116, 1117))

data <- data %>%
  group_by(serial, year, month) %>%
  mutate(n_hh_year_month = n()) %>%
  ungroup()

data <- data %>%
  filter(n_hh_year_month != 1) %>%
  filter(!(n_hh_year_month > 2 & sploc == 0)) %>%
  filter(sploc != 0) %>%
  select(-n_hh_year_month)

data <- data %>%
  mutate(empstat3 = case_when(
    empstat %in% c(1, 10, 12)      ~ 1,
    empstat %in% c(20, 21, 22)     ~ 2,
    empstat >= 30 & empstat <= 36  ~ 3,
    TRUE                           ~ NA_real_
  ))

data <- data %>%
  mutate(nilf_reason = case_when(
    empstat == 32                ~ 1,
    empstat == 36                ~ 2,
    empstat == 34 & nilfact == 1 ~ 3,
    empstat == 34 & nilfact == 2 ~ 4,
    empstat == 34 & nilfact == 3 ~ 5,
    empstat == 34 & nilfact == 4 ~ 6,
    empstat == 34 & nilfact == 6 ~ 7,
    TRUE                         ~ NA_real_
  ))

dup_check <- data %>%
  count(year, month, serial, pernum) %>%
  filter(n != 1)

if (nrow(dup_check) > 0) {
  stop("Duplicates found in year, month, serial, pernum combination!")
} else {
  message("Unique identifier confirmed.")
}

data <- data %>%
  mutate(ym = as.Date(paste(data$year, data$month, "15", sep = "-")))

data <- data %>% 
  arrange(cpsidv, ym)

temp <- data %>%
  select(year, month, serial, pernum, empstat3) %>%
  rename(spouse_pernum = pernum, spouse_empstat3 = empstat3)

data <- data %>%
  left_join(temp, by = c("year", "month", "serial"), relationship = "many-to-many") %>%
  mutate(spempstat3 = if_else(sploc == spouse_pernum, spouse_empstat3, NA_real_)) %>%
  filter(!is.na(spempstat3)) %>% 
  select(-spouse_pernum, -spouse_empstat3)

temp <- data %>%
  select(year, month, serial, pernum, age) %>%
  rename(spouse_pernum = pernum, spouse_age = age)

data <- data %>%
  left_join(temp, by = c("year", "month", "serial"), relationship = "many-to-many") %>%
  mutate(age_sp = if_else(sploc == spouse_pernum, spouse_age, NA_real_)) %>%
  filter(!is.na(age_sp)) %>%
  select(-spouse_pernum, -spouse_age)

data <- data %>%
  mutate(college = if_else(educ >= 111, 1, 0))

temp <- data %>%
  select(year, month, serial, pernum, college) %>%
  rename(spouse_pernum = pernum, spouse_college = college)

data <- data %>%
  left_join(temp, by = c("year", "month", "serial"), relationship = "many-to-many") %>%
  mutate(college_sp = if_else(sploc == spouse_pernum, spouse_college, NA_real_)) %>%
  filter(!is.na(college_sp)) %>%
  select(-spouse_pernum, -spouse_college)

data <- data %>%
  arrange(cpsidv, ym) %>%
  group_by(cpsidv) %>%
  mutate(
    l_empstat3 = dplyr::lag(empstat3), 
    l_spempstat3 = dplyr::lag(spempstat3)
  ) %>%
  ungroup()

temp <- data %>%
  select(year, month, serial, pernum, nilf_reason) %>%
  rename(spouse_pernum = pernum,
         spouse_nilf_reason = nilf_reason)

data <- data %>%
  left_join(temp, by = c("year", "month", "serial"), relationship = "many-to-many") %>%
  mutate(nilf_reason_sp = if_else(sploc == spouse_pernum,
                                  spouse_nilf_reason,
                                  NA_real_)) %>%
  filter(sploc == spouse_pernum) %>%
  select(-spouse_pernum, -spouse_nilf_reason)

data <- data %>%
  arrange(cpsidv, ym) %>%
  group_by(cpsidv) %>%
  mutate(nilf_reason_sp_lag = dplyr::lag(nilf_reason_sp)) %>%
  ungroup()

data <- data %>%
  mutate(trans_ind = case_when(
    empstat3 == 1 & l_empstat3 == 1 ~ 11,  # EE
    empstat3 == 2 & l_empstat3 == 1 ~ 12,  # EU
    empstat3 == 3 & l_empstat3 == 1 ~ 13,  # EN
    empstat3 == 1 & l_empstat3 == 2 ~ 21,  # UE
    empstat3 == 2 & l_empstat3 == 2 ~ 22,  # UU
    empstat3 == 3 & l_empstat3 == 2 ~ 23,  # UN
    empstat3 == 1 & l_empstat3 == 3 ~ 31,  # NE
    empstat3 == 2 & l_empstat3 == 3 ~ 32,  # NU
    empstat3 == 3 & l_empstat3 == 3 ~ 33,  # NN
    TRUE                            ~ NA_real_                       
  ))

temp <- data %>%
  select(year, month, serial, pernum, cpsidv) %>%
  rename(spouse_pernum = pernum,
         cpsidv_sp = cpsidv)

data <- data %>%
  left_join(temp, by = c("year", "month", "serial"), relationship = "many-to-many") %>%
  mutate(cpsidv_sp = if_else(sploc == spouse_pernum,
                             cpsidv_sp, 
                             NA_real_)) %>%
  filter(sploc == spouse_pernum) %>%
  select(-spouse_pernum)

data <- data %>%
  arrange(cpsidv, ym) %>%
  group_by(cpsidv) %>%
  mutate(cpsidv_sp_lag = dplyr::lag(cpsidv_sp)) %>%
  ungroup()

temp <- data %>%
  select(year, month, serial, pernum, trans_ind) %>%
  rename(spouse_pernum = pernum,
         spouse_trans_ind = trans_ind)

data <- data %>%
  left_join(temp, by = c("year", "month", "serial"), relationship = "many-to-many") %>%
  mutate(trans_ind_sp = if_else(sploc == spouse_pernum & (cpsidv_sp == cpsidv_sp_lag),
                                spouse_trans_ind,
                                NA_real_)) %>%
  filter(sploc == spouse_pernum) %>%
  select(-spouse_pernum, -spouse_trans_ind)

data <- data %>%
  mutate(race = case_when(
    race == 100               ~ 1,                         
    !is.na(race) & race > 100 ~ 0,           
    TRUE                      ~ race                              
  ))

data <- data %>%
  mutate(nchild = if_else(!is.na(nchild) & nchild > 3, 3, nchild))

data <- data %>%
  mutate(
    spouse_out = case_when(
      trans_ind_sp %in% c(31, 32) ~ 1,  
      trans_ind_sp == 33          ~ 0,  
      TRUE                        ~ NA_real_ 
    ),
    head_switch = case_when(
      trans_ind == 12 ~ 1, 
      trans_ind == 11 ~ 0, 
      TRUE            ~ NA_real_ 
    )
  )

data <- data %>% filter(!is.na(panlwt) & panlwt >= 0)

write.csv(data, file.path(path_data_processed, "tiny_cleaned.csv"), row.names = FALSE)