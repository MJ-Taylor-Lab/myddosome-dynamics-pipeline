#Combines analysis table with colocalization table

#Number of images to run
ColocalizationImageFx <- function(ImageX) {
  tryCatch({
    #Folder to image set
    FOLDER = paste(ANALYSIS_DIRECTORY, ColocalizationInput$COHORT[ImageX], ColocalizationInput$IMAGE[ImageX], sep = "/")
    COLOCALIZATION = ColocalizationInput$COLOCALIZATION[ImageX]
    COHORT = ColocalizationInput$COHORT[ImageX]
    GROUP = ColocalizationInput$GROUP[ImageX]
    IMAGE = ColocalizationInput$IMAGE[ImageX]
    LIGAND_DENSITY = ColocalizationInput$LIGAND_DENSITY[ImageX]
    LIGAND_DENSITY_CAT = ColocalizationInput$LIGAND_DENSITY_CAT[ImageX]
    CELLS = ColocalizationInput$CELLS[ImageX]
    
    PROTEIN1 = ColocalizationInput$PROTEIN1[ImageX]
    PROTEIN2 = ColocalizationInput$PROTEIN2[ImageX]
    MAX_INTENSITY_THRESHOLD_1 = ColocalizationInput$MAX_INTENSITY_THRESHOLD_1[ImageX]
    MAX_INTENSITY_THRESHOLD_2 = ColocalizationInput$MAX_INTENSITY_THRESHOLD_2[ImageX]
    #Input feedback
    print(paste("   Colocalizing ImageX =", ImageX))
    
    #CELLS LOOP
    ColocalizationCellFx <- function (CellX) {
      tryCatch({
        #Change cells directory
        setwd(file.path(FOLDER, paste0("Cell_", CellX), COLOCALIZATION))
        #Display working directory
        print(paste("      Analyzing ImageX =", ImageX, "CellX =", CellX))
        
        tryCatch({
          setwd(paste(FOLDER, "/Cell_", CellX, sep = ""))
          filename = "ReformattedColocalization"
          ColocalizationData <-
            data.table::fread(paste(filename, ".csv.gz", sep = ""), integer64="character")
        },
        error = function(e) {print(paste("          ERROR ColocalizationCellFx Table missing at ImageX =", ImageX, "CellX =", CellX))})  
        
        #Get colocalization data
        ColocalizationComparison1 <-
          ColocalizationData %>%
          select(
            UNIVERSAL_TRACK_ID_1,
            COLOCALIZATION_GROUP
          ) %>%
          mutate(
            COLOCALIZATION = 1
          ) %>%
          distinct()
        
        #Read csv
        setwd(paste(FOLDER, "/Cell_", CellX, sep = ""))
        filename = paste(ColocalizationData$PROTEIN1_NAME[1], "Analysis", sep = "_")
        ExpDataProt1 <-
          data.table::fread(paste(filename, ".csv.gz", sep = ""), integer64="character")
        
        ExpDataProt1 <-
          ExpDataProt1 %>%
          group_by(UNIVERSAL_TRACK_ID) %>%
          filter(
            FRAMES_ADJUSTED == 0
          ) %>%
          ungroup() %>%
          mutate(
            UNIVERSAL_TRACK_ID_1 = UNIVERSAL_TRACK_ID
          ) %>%
          select(-c(
            UNIVERSAL_TRACK_ID,
            POSITION_X,
            POSITION_Y,
            FRAMES_ADJUSTED,
            TOTAL_INTENSITY,
            NORMALIZED_INTENSITY,
            UNIVERSAL_SPOT_ID
          ))
        
        #Merge tables
        ColocalizationComparison1 = merge(ColocalizationComparison1, ExpDataProt1, by = "UNIVERSAL_TRACK_ID_1", all = T)
        remove(ExpDataProt1)
        
        #Get colocalization data
        ColocalizationComparison2 <-
          ColocalizationData %>%
          select(
            UNIVERSAL_TRACK_ID_2,
            COLOCALIZATION_GROUP
          ) %>%
          mutate(
            COLOCALIZATION = 1
          ) %>%
          distinct()
        
        #Read csv
        setwd(paste(FOLDER, "/Cell_", CellX, sep = ""))
        filename = paste(ColocalizationData$PROTEIN2_NAME[1], "Analysis", sep = "_")
        ExpDataProt2 <-
          data.table::fread(paste(filename, ".csv.gz", sep = ""), integer64="character")
        
        ExpDataProt2 <-
          ExpDataProt2 %>%
          group_by(UNIVERSAL_TRACK_ID) %>%
          filter(
            FRAMES_ADJUSTED == 0
          ) %>%
          ungroup() %>%
          mutate(
            UNIVERSAL_TRACK_ID_2 = UNIVERSAL_TRACK_ID
          ) %>%
          select(-c(
            UNIVERSAL_TRACK_ID,
            POSITION_X,
            POSITION_Y,
            FRAMES_ADJUSTED,
            TOTAL_INTENSITY,
            NORMALIZED_INTENSITY,
            UNIVERSAL_SPOT_ID
          ))
        
        #Merge tables
        ColocalizationComparison2 = merge(ColocalizationComparison2, ExpDataProt2, by = "UNIVERSAL_TRACK_ID_2", all = T)
        remove(ExpDataProt2)
        
        ColocalizationComparison <- bind_rows(ColocalizationComparison1, ColocalizationComparison2)
        remove(ColocalizationComparison1, ColocalizationComparison2)

        #Replace NA with 0
        ColocalizationComparison$COLOCALIZATION[is.na(ColocalizationComparison$COLOCALIZATION)] <- 0
        
        ColocalizationComparison <-
          ColocalizationComparison %>%
          ungroup() %>%
          mutate(
            PROTEIN = factor(PROTEIN, levels = PROTEIN_ORDER),
            GROUP = factor(GROUP, levels = PROTEIN_ORDER),
            UNIVERSAL_TRACK_ID = ifelse(is.na(UNIVERSAL_TRACK_ID_2) == T, UNIVERSAL_TRACK_ID_1, UNIVERSAL_TRACK_ID_2)
          ) %>%
          select(-c(
            UNIVERSAL_TRACK_ID_1,
            UNIVERSAL_TRACK_ID_2
          ))
        
        #Save file
        filename = "ColocalizationAnalysis"
        file.remove(paste(filename, ".csv.gz", sep = ""))
        data.table::fwrite(ColocalizationComparison, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
        
        ColocalizationComparison$CELLX = CellX
        
        ColocalizationComparison
      },
      error = function(e) {print(paste("      ERROR with ColocalizationMaxCellFx. ImageX =", ImageX, " CellX =", CellX))})
    }
    #Loop
    nCells = 1:CELLS
    ColocalizationCells <- mclapply(nCells, ColocalizationCellFx)
    ColocalizationCells <- ColocalizationCells[(which(sapply(ColocalizationCells,is.list), arr.ind=TRUE))]
    ColocalizationCells <- do.call(bind_rows, ColocalizationCells)
    
    setwd(FOLDER)
    filename = "ColocalizationComparison"
    file.remove(paste(filename, ".csv.gz", sep = ""))
    data.table::fwrite(ColocalizationCells, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
    
    ColocalizationCells$IMAGEX = ImageX
    ColocalizationCells
  }, error = function(e) {print(paste("   ERROR with ColocalizationImageFx. ImageX =", ImageX))})
}

#Run colocalization loop by image
nImages = 1:NROW(ColocalizationInput)
ColocalizationImgs <- mclapply(nImages, ColocalizationImageFx)
ColocalizationImgs <- ColocalizationImgs[(which(sapply(ColocalizationImgs,is.list), arr.ind=TRUE))]
ColocalizationImgs <- do.call(bind_rows, ColocalizationImgs)

#Assigns unique identifiers to images
ColocalizationImgs <-
  ColocalizationImgs %>%
  mutate(
    IMAGENUMBER = group_indices(., GROUP, LIGAND_DENSITY_CAT, IMAGE)
  ) %>%
  arrange(
    LIGAND_DENSITY_CAT,
    PROTEIN,
    GROUP,
  ) %>%
  group_by(
    GROUP,
    LIGAND_DENSITY_CAT
  ) %>%
  mutate(
    IMAGENUMBER = IMAGENUMBER - min(IMAGENUMBER) + 1,
    IMAGENUMBER = as.factor(IMAGENUMBER)
  ) %>%
  ungroup()

#Saves table
setwd(COLOCALIZATION_DIRECTORY)
filename = "GrandColocalizationComparison"
file.remove(paste(filename, ".csv.gz", sep = ""))
data.table::fwrite(ColocalizationImgs, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")