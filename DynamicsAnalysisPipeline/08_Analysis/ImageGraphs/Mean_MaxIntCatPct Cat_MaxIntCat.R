setwd(FOLDER)

#CELL
{
  CellTracksSummaryAll <-
    DensityData %>%
    ungroup() %>%
    group_by(
      CELL,
      IMAGE,
      PROTEIN,
      GROUP,
      LIGAND_DENSITY_CAT
    ) %>%
    mutate(
      N = NROW(MAX_INTENSITY_CAT),
      MEAN = mean(MAX_INTENSITY_CAT)
    ) %>%
    filter(
      N > 1
    ) %>%
    select(
      LIGAND_DENSITY_CAT,
      GROUP,
      PROTEIN,
      IMAGE,
      CELL,
      MEAN
    ) %>%
    distinct() %>%
    group_by(
      GROUP,
      LIGAND_DENSITY_CAT
    ) %>%
    mutate(
      IMAGENUMBER = group_indices(., GROUP, LIGAND_DENSITY_CAT, IMAGE)
    )
  
  IMG <- CellTracksSummaryAll %>%select(IMAGE, IMAGENUMBER) %>% distinct()
  
  MinTracksSummary <-
    CellTracksSummaryAll %>% 
    mutate(
      MEAN = 1 - MEAN,
      MAX_INT_CAT = 0,
      CATEGORY = paste("<", lp.MAX_INTENSITY_THRESHOLD,"x ", lp.PROTEIN_FLUOROPHORE, sep ="")
    )
  
  MaxTracksSummary <-
    CellTracksSummaryAll %>% 
    mutate(
      MAX_INT_CAT = 1,
      CATEGORY = paste("≥", lp.MAX_INTENSITY_THRESHOLD,"x ", lp.PROTEIN_FLUOROPHORE, sep ="")
    )
  
  CellTracksSummary <- rbind(MinTracksSummary, MaxTracksSummary)
  remove(MinTracksSummary, MaxTracksSummary, CellTracksSummaryAll)
  
  filename = paste(lp.PROTEIN, "Mean_MaxIntCatPct Cat_MaxIntCat By_Cell")
  data.table::fwrite(CellTracksSummary, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
  
}
#IMAGE
{
  CellTracksImgSummary <-
    CellTracksSummary %>%
    ungroup() %>%
    group_by(
      MAX_INT_CAT,
      CATEGORY,
      IMAGENUMBER,
      IMAGE
    ) %>%
    summarize(
      SD = sd(MEAN),
      MEAN = mean(MEAN)
    )
  
  filename = paste(lp.PROTEIN, "Mean_MaxIntCatPct Cat_MaxIntCat By_Image")
  data.table::fwrite(CellTracksImgSummary, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
}
#LIGAND AND GROUP
{
  CellTracksGrandSummary <-
    CellTracksSummary %>%
    ungroup() %>%
    group_by(
      MAX_INT_CAT,
      CATEGORY,
      IMAGE
    ) %>%
    summarize(
      MEAN = mean(MEAN)
    ) %>%
    ungroup()%>%
    group_by(
      CATEGORY
    ) %>%
    mutate(
      N = NROW(MEAN),
      SE = sd(MEAN)/sqrt(N),
      MEAN = mean(MEAN)
    ) %>%
    select(-c(
      IMAGE
    )) %>%
    distinct()
  
  filename = paste(lp.PROTEIN, "Mean_MaxIntCatPct Cat_MaxIntCat By_LigandGrp")
  data.table::fwrite(CellTracksGrandSummary, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
}