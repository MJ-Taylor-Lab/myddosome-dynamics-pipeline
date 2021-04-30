#Imports table
if(exists("GrandTracks")) {} else {
  setwd(ANALYSIS_DIRECTORY)
  filename = "GrandTableTracks"
  GrandTracks <-
    data.table::fread(paste(filename, ".csv.gz", sep = ""), integer64="character")
}

GrandTracksInhibitor <-
  GrandTracks %>%
  filter(
    IMAGE %in% InputInhibitor$IMAGE
  ) %>%
  group_by(
    IMAGE,
    CELL
  ) %>%
  group_by(
    UNIVERSAL_TRACK_ID
  ) %>%
  mutate(
    LIGAND_DENSITY_CAT = paste(LIGAND_DENSITY_CAT, "mol. µm^-2"),
    MAX_INTENSITY_CAT =
      ifelse(
        MAX_INTENSITY_CAT == 0 ,
        paste("<", MAX_INTENSITY_THRESHOLD, sep = ""),
        paste("≥", MAX_INTENSITY_THRESHOLD, sep = "")
      ),
    LIFETIME_CAT =
      ifelse(
        LIFETIME_CAT == 0,
        paste("<", LIFETIME_THRESHOLD,"s", sep = ""),
        paste("≥", LIFETIME_THRESHOLD,"s", sep = "")
      )
  ) %>%
  select(
    LIGAND_DENSITY_CAT,
    GROUP,
    COHORT,
    IMAGE,
    CELL,
    UNIVERSAL_TRACK_ID,
    MAX_NORMALIZED_INTENSITY,
    MAX_INTENSITY_CAT,
    START_TO_MAX_INTENSITY,
    LIFETIME,
    LIFETIME_CAT,
    STARTING_NORMALIZED_INTENSITY_CAT
  ) %>%
  distinct()

#Save file
setwd(INHIBITOR_DIRECTORY)
filename = "GrandTracksInhibitor"
file.remove(paste(filename, ".csv.gz", sep = ""))
data.table::fwrite(GrandTracksInhibitor, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")