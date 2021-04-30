# For analyzing cell spots
# This loops over images

###########################
###    CELL ANALYSIS    ###
###########################
print(":::::::::::::::::::: START CELL ANALYSIS ::::::::::::::::::::")
tic()
#ANALYSIS LOOP
AnalysisFx <-
  function(ImageX) {
    tryCatch({
      #Clean table between cells
      ExpSummary = NULL
      #Temporary image variables
      lp.FOLDER = file.path(ANALYSIS_DIRECTORY, InputDataImageSummary$COHORT[ImageX], InputDataImageSummary$IMAGE[ImageX])
      lp.GROUP = InputDataImageSummary$GROUP[ImageX]
      lp.COHORT = InputDataImageSummary$COHORT[ImageX]
      lp.IMAGE = InputDataImageSummary$IMAGE[ImageX]
      lp.CELLS = InputDataImageSummary$CELLS[ImageX]
      lp.PROTEIN = InputDataImageSummary$PROTEIN[ImageX]
      lp.FLUOROPHORE = InputDataImageSummary$FLUOROPHORE[ImageX]
      lp.ASSEMBLED_COMPLEX_SIZE = InputDataImageSummary$ASSEMBLED_COMPLEX_SIZE[ImageX]
      lp.PROTEIN_BACKGROUND = InputDataImageSummary$PROTEIN_BACKGROUND[ImageX]
      lp.PROTEIN_INTENSITY = InputDataImageSummary$PROTEIN_INTENSITY[ImageX]
      lp.LIGAND_DENSITY = InputDataImageSummary$LIGAND_DENSITY[ImageX]
      lp.LIGAND_DENSITY_CAT = InputDataImageSummary$LIGAND_DENSITY_CAT[ImageX]
      lp.FPS = InputDataImageSummary$FPS[ImageX]
      #Separates assembled and abortive puncta
      lp.MAX_INTENSITY_THRESHOLD = InputDataImageSummary$MAX_INTENSITY_THRESHOLD[ImageX]
      #Separates short and long lived puncta
      lp.LIFETIME_THRESHOLD = InputDataImageSummary$LIFETIME_THRESHOLD[ImageX]
      #Separates de-novo and disassembling
      lp.STARTING_INTENSITY_THESHOLD = InputDataImageSummary$STARTING_INTENSITY_THESHOLD[ImageX]
      #Display which image is being analyzed
      print(paste("Analyzing ImageX =", ImageX, "with", max(lp.CELLS), "cells"))
      
      setwd(lp.FOLDER)
      
      #Loop by cells
      # For analyzing cell puncta
      # This loops over cells
      
      #Cell analysis function
      CellAnalysisFx <-
        function (CellX) {
          tryCatch({
            #Change cells directory
            setwd(paste(lp.FOLDER, "/Cell_", CellX, sep = ""))
            #Display working directory
            print(paste("     Analyzing ImageX =", ImageX, "CellX =", CellX))
            #Import TrackMate tables
            ExpData =
              read.csv(
                paste("Reformatted ", lp.PROTEIN, " spots in tracks statistics.csv", sep = ""),
                header = T)
            #Remove first column containing row headers
            ExpData[1] = NULL

            #Loop over basic variables
            LOCAL_DIRECTORY <- getwd()
            setwd(CELLANALYSIS_SCRIPTS)
            source("BasicVariables.R", local = T)
            
            #Resort data
            ExpData <-
              ExpData %>%
              arrange(
                TRACK_ID,
                FRAMES_ADJUSTED
              )
            #Remove columns where all rows are NA
            ExpData <-
              ExpData[,colSums(is.na(ExpData))<nrow(ExpData)]
            #Replace NA with blank cells
            ExpData[is.na(ExpData)] <- ""
            #Saves analysis table
            setwd(paste(lp.FOLDER, "/Cell_", CellX, sep = ""))
            filename = paste(lp.PROTEIN, "Analysis", sep ="_")
            file.remove(paste(filename, ".csv.gz", sep = ""))
            data.table::fwrite(ExpData, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
            #Export product
            ExpData
          }, error=function(e) print(paste("   ERROR with CellAnalysisFx. ImageX =", ImageX, "CellX =", CellX)))
        }
      #Loop and merge table
      nCells = 1:lp.CELLS
      ExpSummary <- mclapply(nCells, CellAnalysisFx)
      ExpSummary <- ExpSummary[(which(sapply(ExpSummary,is.list), arr.ind=TRUE))]
      ExpSummary <- do.call(bind_rows, ExpSummary)
      
      #Save table
      setwd(lp.FOLDER)
      filename = paste(lp.PROTEIN, "Analysis", sep ="_")
      file.remove(paste(filename, ".csv.gz", sep = ""))
      data.table::fwrite(ExpSummary, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
      
      ExpSummary
      
    }, error=function(e){print(paste("   ERROR with AnalysisFx. ImageX =", ImageX))})
  }
#Loop
nImages = 1:NROW(InputDataImageSummary)
ExpAll <- mclapply(nImages, AnalysisFx)
ExpAll <- ExpAll[(which(sapply(ExpAll,is.list), arr.ind=TRUE))]
ExpAll <- do.call(bind_rows, ExpAll)
#Combine tables
setwd(ANALYSIS_DIRECTORY)
filename = "ExpDataAll"
file.remove(paste(filename, ".csv.gz", sep = ""))
data.table::fwrite(ExpAll, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")

print(":::::::::::::::::::: END CELL ANALYSIS ::::::::::::::::::::")
toc()