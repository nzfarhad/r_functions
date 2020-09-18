library(rmarkdown)
library(readxl)
library(dplyr)
library(lubridate)

data1 <- read_excel("input/processed/msna_2020_processed_raw_data.xlsx")

partner_sample <- read_excel("input/sample/partner_sample.xlsx")
parner_gender_sample <- read_excel("input/sample/gender_sample_partner.xlsx")

sample_df <- read_excel("input/sample/WoAA_2020_Compiled_Sample_20200721.xlsx")
sample_df <- sample_df %>% mutate(
  pop_group_final = case_when(
    pop_group == "recent_returnees" | pop_group == "non_recent_returnees" ~ "returnees",
    TRUE ~ pop_group
  ),
  prov_key = paste0(province_kobo,"_",pop_group_final),
  dist_key = paste0(district_kobo,"_",pop_group_final)
)

# dist_sample_wrong_dist <- sample_df %>% group_by(dist_key, pop_group_final) %>% summarise(
#   Target = sum(survey_buffer, na.rm = T))
  
dist_sample_wrong_dist <- partner_sample %>% select(dist_key, pop_group_final,Target)

partner_report_field_path <- paste0("D:/REACH Afghanistan Dropbox/REACH_AFG/04_Field_Management/01_woa_msna/04_partner_reports/",today())
dir.create(partner_report_field_path)




for (i in unique(data1$organisation_final)) {
  render(paste0(getwd(), "/partner_MSNA_2020_Tracking_Monitorring.Rmd" ),
         output_file =  paste("Data_Collection_Tracking_report_", i, '_', Sys.Date(), ".html", sep=''), 
         output_dir = paste0(partner_report_field_path))
}
