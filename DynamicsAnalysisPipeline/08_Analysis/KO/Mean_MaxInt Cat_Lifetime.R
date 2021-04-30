setwd(KO_DIRECTORY)

#Table
{
  TracksSummary <-
    GroupTracks %>%
    mutate(
      LIFETIME_CAT = "All",
      GROUP = factor(GROUP, levels = GROUP_LIST)
    )
  
  TracksSummary <- bind_rows(GroupTracks, TracksSummary)
  
  CellTracksSummary <-
    TracksSummary %>%
    group_by(
      GROUP,
      LIGAND_DENSITY_CAT,
      IMAGE,
      IMAGENUMBER,
      CELL,
      LIFETIME_CAT
    ) %>%
    summarize(
      MEAN = mean(MAX_NORMALIZED_INTENSITY, na.rm =T)
    )
  
  filename = "Mean_MaxInt By_Cell"
  file.remove(paste(filename, ".csv.gz", sep = ""))
  data.table::fwrite(CellTracksSummary, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
  
  CellTracksImgSummary <-
    CellTracksSummary %>%
    ungroup() %>%
    group_by(
      GROUP,
      LIGAND_DENSITY_CAT,
      IMAGE,
      IMAGENUMBER,
      LIFETIME_CAT
    ) %>%
    summarize(
      MEAN = mean(MEAN, na.rm =T)
    )
  
  filename = "Mean_MaxInt By_Img"
  file.remove(paste(filename, ".csv.gz", sep = ""))
  data.table::fwrite(CellTracksImgSummary, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
  
  CellTracksGrandSummary <-
    CellTracksImgSummary %>%
    ungroup() %>%
    group_by(
      GROUP,
      LIGAND_DENSITY_CAT,
      LIFETIME_CAT
    ) %>%
    summarize(
      SD = sd(MEAN, na.rm = T),
      SE = SD/sqrt(n()),
      MEAN = mean(MEAN, na.rm =T)
    )
  
  filename = "Mean_MaxInt By_Group"
  file.remove(paste(filename, ".csv.gz", sep = ""))
  data.table::fwrite(CellTracksGrandSummary, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
}