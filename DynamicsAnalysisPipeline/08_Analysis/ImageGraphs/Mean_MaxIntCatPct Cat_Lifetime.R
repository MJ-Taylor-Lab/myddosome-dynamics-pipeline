setwd(FOLDER)

#Calculations for bar graph of assembled events by lifetime
{
  #Lifetime sorted table
  CellTracksSummary <-
    DensityData %>%
    group_by(
      LIGAND_DENSITY_CAT,
      GROUP,
      PROTEIN,
      IMAGE,
      CELL,
      LIFETIME_CAT
    ) %>%
    mutate(
      N = NROW(MAX_INTENSITY_CAT),
      MEAN = mean(MAX_INTENSITY_CAT)
    ) %>%
    select(
      LIGAND_DENSITY_CAT,
      GROUP,
      PROTEIN,
      IMAGE,
      CELL,
      LIFETIME_CAT,
      MEAN
    ) %>%
    distinct() %>%
    ungroup() %>%
    mutate(
      CATEGORY = gsub(0, paste("<",lp.LIFETIME_THRESHOLD, " s", sep =""), LIFETIME_CAT),
      CATEGORY = gsub(1, paste("\u2265",lp.LIFETIME_THRESHOLD, " s", sep =""), CATEGORY),
      CATEGORY =
        factor(
          CATEGORY,
          levels = c(
            "All",
            paste("<",lp.LIFETIME_THRESHOLD, " s", sep =""),
            paste("\u2265",lp.LIFETIME_THRESHOLD, " s", sep ="")
          ))
    )
  
  #All table
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
    ungroup() %>%
    mutate(
      CATEGORY = "All"
    )
  #Combine tables
  CellTracksSummary <- bind_rows(CellTracksSummaryAll, CellTracksSummary)
  CellTracksSummary <- setDT(CellTracksSummary)[,IMAGENUMBER:=.GRP, by = c("IMAGE")]
  CellTracksSummary$IMAGENUMBER <- as.factor(CellTracksSummary$IMAGENUMBER)
  CellTracksSummary <-
    CellTracksSummary %>%
    mutate(
      CATEGORY_BIN = ifelse(CATEGORY == "All", "All", "Time Sorted")
    )
  #Save
  filename = paste(lp.PROTEIN, "Mean_MaxIntCatPct Cat_Lifetime By_Cell")
  data.table::fwrite(CellTracksSummary, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
}

#Image average
{
  CellTracksImgSummary <-
    CellTracksSummary %>%
    ungroup() %>%
    na.omit() %>%
    group_by(
      LIGAND_DENSITY_CAT,
      GROUP,
      PROTEIN,
      CATEGORY_BIN,
      CATEGORY,
      IMAGENUMBER,
      IMAGE
    ) %>%
    summarize(
      SD = sd(MEAN),
      MEAN = mean(MEAN)
    )
  #Save
  filename = paste(lp.PROTEIN, "Mean_MaxIntCatPct Cat_Lifetime By_Image")
  data.table::fwrite(CellTracksImgSummary, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
}

#Ligand average
{
  CellTracksGrandSummary <-
    CellTracksSummary %>%
    ungroup() %>%
    na.omit() %>%
    group_by(
      LIGAND_DENSITY_CAT,
      GROUP,
      PROTEIN,
      IMAGE,
      CATEGORY_BIN,
      CATEGORY
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
  
  filename = paste(lp.PROTEIN, "Mean_MaxIntCatPct Cat_Lifetime By_LigandGrp")
  data.table::fwrite(CellTracksGrandSummary, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
}