#Plots graphs for tracks

#Imports table
if(exists("GrandTable")) {} else {
  setwd(ANALYSIS_DIRECTORY)
  filename = "GrandTableSpots"
  GrandTable <-
    data.table::fread(paste(filename, ".csv.gz", sep = ""), integer64="character")
}

SUB_LIST <- 
  InputData %>%
  summarize(
    UNIVERSAL_CELL_ID = paste(PROTEIN, IMAGE, CELL, sep = "...")
  ) %>%
  distinct()

SUB_LIST <- SUB_LIST$UNIVERSAL_CELL_ID

GrandTable <-
  GrandTable %>%
  mutate(
    UNIVERSAL_CELL_ID = paste(PROTEIN, IMAGE, CELL, sep = "...")
  ) %>%
  filter(
    UNIVERSAL_CELL_ID %in% SUB_LIST
  )

remove(SUB_LIST)

#Number of images to run
TracksImageFx <- function(ImageX) {
  tryCatch({
    #Input feedback
    print(paste("Track Graphs ImageX =", ImageX))
    
    #Loop variables
    FOLDER = file.path(ANALYSIS_DIRECTORY, InputData$COHORT[ImageX], InputData$IMAGE[ImageX])
    LP_PROTEIN = InputData$PROTEIN[ImageX]
    LP_IMAGE = InputData$IMAGE[ImageX]
    CELLS = InputData$CELLS[ImageX]
    
    #Filter data
    ImgData <-
      GrandTable %>%
      filter(
        PROTEIN == LP_PROTEIN,
        IMAGE == LP_IMAGE
      )
    
    #CELLS LOOP
    TrackGraphsCellFx <- function (CellX) {
      tryCatch({
        #Change cells directory
        setwd(file.path(FOLDER, paste("Cell_", CellX, sep = "")))
        #Display working directory
        print(paste("TrackGraphsCellFx ImageX =", ImageX, "CellX =", CellX))
        
        #Filter data
        ExpData <-
          ImgData %>%
          filter(
            CELL == CellX
          ) %>%
          #Assign track for pagination
          group_by(
            IMAGE,
            PROTEIN,
            CELL
          ) %>%
          arrange(
            TRACK_ID
          ) %>%
          mutate(
            LABEL = group_indices(., IMAGE, PROTEIN, CELL, TRACK_ID)
          )
        
        #Run
        FOLDER <- getwd()
        setwd(TRACKGRAPHS_SCRIPTS)
        print("Running script TrackGraphsPlot.R")
        source("TrackPlot.R", local = T)
      },
      error = function(e) {print(paste("   ERROR with TrackGraphsCellFx ImageX =", ImageX, " CellX =", CellX))})
    }
    #Loop
    nCells = 1:CELLS
    mclapply(nCells, TrackGraphsCellFx)
    
  }, error = function(e) {print(paste("   ERROR with TracksImageFx ImageX =", ImageX))})
}

#Run tracks loop by image
nImages = 1:NROW(InputData)
mclapply(nImages, TracksImageFx)