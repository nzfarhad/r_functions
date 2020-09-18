

library(readxl)
library(dplyr)
### GIS Checks
library(sf)



# Gis flags
district_df <- st_read("shape_file/MSNA_20_Districts.shp", as_tibble = TRUE, quiet=TRUE )
district_df$Dstrct_Eng <- tolower(district_df$Dstrct_Eng)
district_df$Dstrct_Eng <- gsub(x = district_df$Dstrct_Eng, pattern = "\\ ", replacement = "_")
district_df$Dstrct_Eng <- gsub(x = district_df$Dstrct_Eng, pattern = "\\-", replacement = "_")
district_df$Dstrct_Eng <- gsub(x = district_df$Dstrct_Eng, pattern = "\\(", replacement = "")
district_df$Dstrct_Eng <- gsub(x = district_df$Dstrct_Eng, pattern = "\\)", replacement = "")

# filter extra vars 
district_df <- district_df %>% 
  select(Prvnce_Eng, Dstrct_Eng, geometry)


points <- read_excel("output/gis_checks/WoA_2020_GIS_Checks_2020-08-11.xlsx") %>% select(enumerator_uuid, village_eng, district, `_uuid` ,`_geopoint_longitude`, `_geopoint_latitude`)

# Convert CSV points df to sf object
points_sf <- points %>%
  mutate_at(vars(`_geopoint_longitude`, `_geopoint_latitude`), as.numeric) %>%   # coordinates must be numeric
  st_as_sf(
    coords = c("_geopoint_longitude", "_geopoint_latitude"),
    agr = "constant",
    crs = 4326,        # coordinate system
    stringsAsFactors = FALSE,
    remove = TRUE
  )

# filter extra vars 
# points_sf <- points_sf %>% 
#   select(id_num, province_label, district_label, settlement_name, settlement_label, pop_group, surveys, geometry)
# 



mapview::mapview(district_df, label = district_df$Dstrct_Eng, alpha.regions = 0.1) + 
  mapview::mapview(points_sf, color = "white", col.regions = "black" , label = points_sf$enumerator_uuid)





