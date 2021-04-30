#Imports table
if(exists("GrandTracks")) {} else {
  setwd(ANALYSIS_DIRECTORY)
  filename = "GrandTableTracks"
  GrandTracks <-
    data.table::fread(paste(filename, ".csv.gz", sep = ""), integer64="character")
}

GrandTracksKO <-
  GrandTracks %>%
  filter(
    IMAGE %in% InputKO$IMAGE
  ) %>%
  group_by(
    IMAGE,
    CELL
  ) %>%
  mutate(
    MAX_FRAME_LAND = max(FRAME_LAND, na.rm = T),
    MAX_FRAME_LAND = ifelse(MAX_FRAME_LAND >= FRAME_LAND_MIN, 1, 0),
    GROUP = ifelse(GROUP == PROTEIN, "WT", str_replace_all(GROUP, paste(PROTEIN, ""), "")),
    GROUP = ifelse(GROUP == "IRAK4_KO_KI", "Rescue", GROUP)
  ) %>%
  filter(
    MAX_FRAME_LAND == 1
  ) %>%
  select(-c(MAX_FRAME_LAND)) %>%
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
setwd(KO_DIRECTORY)
filename = "GrandTracksKO"
file.remove(paste(filename, ".csv.gz", sep = ""))
data.table::fwrite(GrandTracksKO, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")