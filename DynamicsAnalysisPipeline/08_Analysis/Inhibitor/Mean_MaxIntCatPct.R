setwd(FOLDER)

TracksSummary <-
  GroupTracks %>%
  mutate(
    LIFETIME_CAT = "All"
  )

TracksSummary <- rbind(TracksSummary, GroupTracks)

CellTracksSummary <-
  TracksSummary %>%
  group_by(
    LIFETIME_CAT
  ) %>%
  mutate(
    MEAN = ifelse(MAX_NORMALIZED_INTENSITY >= lp.MAX_INTENSITY_THRESHOLD, 1, 0),
  ) %>%
  group_by(
    LIFETIME_CAT,
    GROUP,
    IMAGENUMBER,
    IMAGE,
    CELL
  ) %>%
  summarize(
    MEAN = mean(MEAN, na.rm = T)
  )

filename = "Mean_MaxIntCatPct By_Cell"
file.remove(paste(filename, ".csv.gz", sep = ""))
data.table::fwrite(CellTracksSummary, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")

CellTracksImgSummary <-
  CellTracksSummary %>%
  group_by(
    LIFETIME_CAT,
    GROUP,
    IMAGE,
    IMAGENUMBER
  ) %>%
  summarize(
    MEAN = mean(MEAN, na.rm = T)
  )

filename = "Mean_MaxIntCatPct By_Img"
file.remove(paste(filename, ".csv.gz", sep = ""))
data.table::fwrite(CellTracksImgSummary, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")

CellTracksGrandSummary <-
  CellTracksImgSummary %>%
  group_by(
    LIFETIME_CAT,
    GROUP
  ) %>%
  summarize(
    SD = sd(MEAN, na.rm = T),
    SE = SD/sqrt(n()),
    MEAN = mean(MEAN, na.rm = T)
  )

filename = "Mean_MaxIntCatPct By_Group"
file.remove(paste(filename, ".csv.gz", sep = ""))
data.table::fwrite(CellTracksImgSummary, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")