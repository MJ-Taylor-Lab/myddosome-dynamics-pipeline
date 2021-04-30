setwd(FOLDER)

CellTracksSummary <-
  ProteinData %>%
  group_by(
    GROUP,
    LIGAND_DENSITY_CAT,
    MAX_INTENSITY_CAT
  ) %>%
  group_by(
    GROUP,
    PROTEIN,
    LIGAND_DENSITY_CAT,
    IMAGE,
    IMAGENUMBER,
    CELL,
    MAX_INTENSITY_CAT
  ) %>%
  summarize(
    N_TRACKS = NROW(COLOCALIZATION),
    MEAN = mean(COLOCALIZATION, na.rm = T),
    SD = sd(COLOCALIZATION, na.rm = T),
    SE = SD/sqrt(N_TRACKS),
    DEV = SD^2*N_TRACKS
  )

filename = paste(lp.PROTEIN, "Mean_Colocalization Cat_MaxInt By_Cells")
file.remove(paste(filename, ".csv.gz", sep = ""))
data.table::fwrite(CellTracksSummary, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")

CellTracksImgSummary <-
  CellTracksSummary %>%
  group_by(
    LIGAND_DENSITY_CAT,
    GROUP,
    PROTEIN,
    IMAGENUMBER,
    MAX_INTENSITY_CAT
  ) %>%
  summarize(
    N_TRACKS = sum(N_TRACKS),
    N_CELLS = NROW(MEAN),
    SD = sqrt(sum(DEV)/sum(N_TRACKS)),
    SE = sd(MEAN, na.rm = T)/sqrt(N_CELLS),
    MEAN = mean(MEAN, na.rm = T),
    DEV = SD^2*N_CELLS
  ) %>%
  ungroup()

filename = paste(lp.PROTEIN, "Mean_Colocalization Cat_MaxInt By_Imgs")
file.remove(paste(filename, ".csv.gz", sep = ""))
data.table::fwrite(CellTracksImgSummary, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")

CellTracksGrandSummary <-
  CellTracksImgSummary %>%
  group_by(
    LIGAND_DENSITY_CAT,
    GROUP,
    PROTEIN,
    MAX_INTENSITY_CAT
  ) %>%
  summarise(
    N_TRACKS = sum(N_TRACKS),
    N_CELLS = sum(N_CELLS),
    N_IMAGES = NROW(MEAN),
    SD = sqrt(sum(DEV)/sum(N_CELLS)),
    SE = sd(MEAN, na.rm = T)/sqrt(N_IMAGES),
    MEAN = mean(MEAN, na.rm = T),
    DEV = SD^2*N_IMAGES
  )

filename = paste(lp.PROTEIN, "Mean_Colocalization Cat_MaxInt By_Group")
file.remove(paste(filename, ".csv.gz", sep = ""))
data.table::fwrite(CellTracksGrandSummary, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
