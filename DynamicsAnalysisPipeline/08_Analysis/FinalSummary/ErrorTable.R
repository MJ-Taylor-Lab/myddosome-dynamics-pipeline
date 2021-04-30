# Reports cells excluded from analysis

setwd(LOCAL_DIRECTORY)

#Get input table as in "00_Setup" folder
InputErrorTable <-
  InputData %>%
  ungroup() %>%
  mutate(
    #Make a unique cell identifier
    UNIVERSAL_CELL_ID = 
      paste(
        IMAGE,
        CELL,
        PROTEIN,
        sep = "..."
      )
  ) %>%
  select(
    UNIVERSAL_CELL_ID,
    IMAGE,
    CELL,
    PROTEIN
  )
#Get list of images from GrandTracks
OutputErrorTable <-
  GrandTracks %>%
  ungroup() %>%
  select(
    IMAGE,
    CELL,
    PROTEIN
  ) %>%
  distinct() %>%
  mutate(
    #Make a unique cell identifier
    UNIVERSAL_CELL_ID = 
      paste(
        IMAGE,
        CELL,
        PROTEIN,
        sep = "..."
      )
  ) %>%
  select(
    UNIVERSAL_CELL_ID,
    IMAGE,
    CELL,
    PROTEIN
  )
#Merge tables
ErrorTable <- merge(InputErrorTable, OutputErrorTable, by = "UNIVERSAL_CELL_ID", all = T)
#Discard old tables
remove(InputErrorTable, OutputErrorTable)
#Keep only missing cells
ErrorTable <-
  ErrorTable %>%
  #Keep only rows that have one column missing
  filter(is.na(IMAGE.x) | is.na(IMAGE.y)) %>%
  mutate(
    #Take out space in naming. CSV discards end spaces
    UNIVERSAL_CELL_ID = gsub(" ", "", UNIVERSAL_CELL_ID)
  ) %>%
  distinct(
    #Keep only 
    UNIVERSAL_CELL_ID,
    .keep_all = T
  )
#Replace NA with blank
ErrorTable[is.na(ErrorTable)] <- ""
#Interpret results
ErrorTable <-
  ErrorTable %>%
  #Merge input, output columns into one
  mutate(
    IMAGE = paste(IMAGE.x, IMAGE.y, sep = ""),
    CELL = paste(CELL.x, CELL.y, sep = ""),
    CELL = as.numeric(CELL),
    UNIVERSAL_CELL_ID = paste(IMAGE, CELL, sep = "..."),
    PROTEIN = paste(PROTEIN.x, PROTEIN.y, sep = ""),
  ) %>%
  group_by(UNIVERSAL_CELL_ID) %>%
  #Report if no cell activity
  mutate(
    NOTE = n(),
    NOTE = ifelse(
      NOTE > 1,
      "Cell has no activity",
      ifelse(
        PROTEIN != "MyD88",
        "IRAK has no activity",
        ""
      ))
  ) %>%
  ungroup()

ErrorTableLigands <-
  InputDataImageSummary %>%
  ungroup ()%>%
  group_by(IMAGE) %>%
  select(
    IMAGE,
    LIGAND_DENSITY_CAT,
    CELLS
  ) %>%
  distinct()

ErrorTable <- merge(ErrorTable, ErrorTableLigands, by = "IMAGE")
remove(ErrorTableLigands)

ErrorTable <-
  ErrorTable %>%
  group_by(
    IMAGE
  ) %>%
  #Report if all cells are missing in image set
  mutate(
    COUNT = n(),
    ALL_CELLS_MISSING = ifelse(COUNT == CELLS, "TRUE",""),
    NOTE = ifelse(
      NOTE == "",
      ifelse(
        ALL_CELLS_MISSING == TRUE,
        "All cells are missing",
        NOTE),
      NOTE
    )
  ) %>%
  ungroup() %>%
  #Discard analysis variables
  select(
    NOTE,
    PROTEIN,
    IMAGE,
    CELL,
    LIGAND_DENSITY_CAT
  ) %>%
  #Resort data
  arrange(
    NOTE,
    PROTEIN,
    IMAGE,
    CELL,
  )
#Save error table
setwd(ANALYSIS_DIRECTORY)
write.csv(ErrorTable, "MissingCellsFromAnalysis.csv", row.names = F, na = "")
