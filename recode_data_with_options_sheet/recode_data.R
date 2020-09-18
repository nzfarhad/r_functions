library(dplyr)
library(readxl)
library(stringr)


data <- read_excel("data/data.xlsx")
data_numbers <- data
data_short_names <- data

recode_df <- read_excel("kobo/kobo_form.xlsx", sheet = "recod_choices")

# Recode to short names
for (i in 1: length(data_short_names) ) {
  for (j in 1: nrow(data_short_names)) {
    for (k in 1:length(recode_df)) {
      for (l in 1:nrow(recode_df)) {
        if(data_short_names[j,i] %in% recode_df$label[l]){
          #print(recode_df$label[l])
          data_short_names[j,i] <- recode_df$name[l]
        } 
      }
    }
    
  }
  print(paste0("Column ",i , " checked/recoded!"))
}

# Recode to numbers
for (i in 1: length(data_numbers) ) {
  for (j in 1: nrow(data_numbers)) {
    for (k in 1:length(recode_df)) {
      for (l in 1:nrow(recode_df)) {
        if(data_numbers[j,i] %in% recode_df$label[l]){
          #print(recode_df$label[l])
          data_numbers[j,i] <- recode_df$level[l]
        } 
      }
    }
    
  }
  print(paste0("Column ",i , " checked/recoded!"))
}


write.csv(data_short_names,"data/recoded/recoded_short_names.csv", row.names = F)
write.csv(data_numbers,"data/recoded/recoded_nummbers.csv", row.names = F)
