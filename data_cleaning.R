
library(dplyr)
library(readxl)
library(tidyr)
library(stringr)
library(lubridate)
source("functions/apply_log.R")

`%notin%` <- Negate(`%in%`)
# Raw Data
raw_data <- read_excel("asset/data/raw/AFG2005_WoA_MSNA_2020_-_all_versions_-_False_-_2020-09-08-04-49-06.xlsx")
hh_roster <- read_excel("asset/data/raw/AFG2005_WoA_MSNA_2020_-_all_versions_-_False_-_2020-09-08-04-49-06.xlsx", sheet = "c_2")
left <- read_excel("asset/data/raw/AFG2005_WoA_MSNA_2020_-_all_versions_-_False_-_2020-09-08-04-49-06.xlsx", sheet = "m1")
died <- read_excel("asset/data/raw/AFG2005_WoA_MSNA_2020_-_all_versions_-_False_-_2020-09-08-04-49-06.xlsx", sheet = "m2")


# Deletions log
deletion_log <- read_excel("asset/data/cleaning_log/Compiled_Cleaning_Log_Updated_07_Sept_08.xlsx", sheet = "deletions")

# Cleaning log
cleaning_log <- read_excel("asset/data/cleaning_log/Compiled_Cleaning_Log_Updated_07_Sept_08.xlsx")
cleaning_log <- cleaning_log %>% filter(uuid %notin% deletion_log$`_uuid`)

openxlsx::write.xlsx(cleaning_log, "New_cleaning_log.xlsx")

# filter invalid interviews
raw_data_valid <- raw_data %>% filter(`_uuid` %notin% deletion_log$`_uuid`)
raw_data_valid <- raw_data_valid %>% 
  filter(consent == "yes" & pop_group != "CHECK" & respondent_age == "yes")

# Dataframe to check if log is applied correctly
raw_data_valid_temp <- raw_data_valid

# filter out invalid entries form loops
hh_roster_valid <- hh_roster %>% filter(`_submission__uuid` %in% raw_data_valid$`_uuid`)
left_valid <- left %>% filter(`_submission__uuid` %in% raw_data_valid$`_uuid`)
died_valid <- died %>% filter(`_submission__uuid` %in% raw_data_valid$`_uuid` )


# Apply cleaning log on raw data
for (rowi in 1:nrow(cleaning_log)){
  
  uuid_i <- cleaning_log$uuid[rowi]
  var_i <- cleaning_log$question.name[rowi]
  old_i <- cleaning_log$old.value[rowi]
  new_i <- cleaning_log$new.value[rowi]
  print(paste("uuid", uuid_i, "Old value: ", old_i, "changed to", new_i, "for", var_i))
  # Find the variable according to the row of the cleaning log
  raw_data_valid[raw_data_valid$`_uuid` == uuid_i, var_i] <- new_i
}

# Check if log is correctly applied on the raw data
check <- check_log(raw_data_valid_temp, raw_data_valid, uuid_ = "_uuid")
check$key <- paste0(check$question, "_", check$uuid)
cleaning_log$key <- paste0(cleaning_log$question.name,"_",cleaning_log$uuid)

# find if any entry in log is not replaced in the dataset - if the result is 0 obs, then the log is correctly applied on the raw data
find_missing <- anti_join(cleaning_log, check, by = "key")


# NA hoh questions for non-hoh interviews
noh_hoh_uuid <- cleaning_log %>% filter(question.name == "interview_type") %>% select(uuid, new.value)

raw_data_valid <- raw_data_valid %>% left_join(noh_hoh_uuid, by = c("_uuid" = "uuid"))


list_of_questions <- c('pre_covid_work_days',
                       'thirty_days_work_days',
                       'main_income',
                       'total_cash_income',
                       'income_fluctuation',
                       'income_lower_reason',
                       'debt',
                       'debt_amount',
                       'debt_change',
                       'debt_change_amt',
                       'debt_reason',
                       'food_exp',
                       'water_exp',
                       'rent_exp',
                       'health_exp',
                       'fuel_exp',
                       'debt_exp',
                       'health_exp_types',
                       'hoh_sim_card',
                       'mortality_concent',
                       'members_left',
                       'members_died',
                       'main_income.agriculture',
                       'main_income.livestock',
                       'main_income.rent',
                       'main_income.small_business',
                       'main_income.daily_lab',
                       'main_income.formal_epml',
                       'main_income.gov_hum_assistance',
                       'main_income.gifts',
                       'main_income.loans',
                       'main_income.selling_assets',
                       'main_income.other',
                       'income_lower_reason.reduce_empl_opp',
                       'income_lower_reason.reduce_remit',
                       'income_lower_reason.more_copmt',
                       'income_lower_reason.migr_disp',
                       'income_lower_reason.death_illness',
                       'income_lower_reason.other',
                       'health_exp_types.medicine',
                       'health_exp_types.trav_health_faci',
                       'health_exp_types.treatment_fees',
                       'health_exp_types.trav_other_country_obt_health',
                       'health_exp_types.other'
                       )

for (i in 1:nrow(raw_data_valid)) {
  if(raw_data_valid$new.value[i] %in% "non_hoh"){
    for (variable in list_of_questions) {
      raw_data_valid[[variable]][i] <- NA
    }

  }
}



# cleaninginspectoR
check_outlier <- cleaninginspectoR::inspect_all(raw_data_valid, uuid.column.name = "_uuid")
write.csv(check_outlier, "outliers.csv", row.names = F)


df_list <- list(Data = raw_data_valid, roster = hh_roster_valid, left = left_valid, died = died_valid )

openxlsx::write.xlsx(df_list, "asset/data/clean/excel/MSNA_2020_clean_data_final_2020-09-09.xlsx")




