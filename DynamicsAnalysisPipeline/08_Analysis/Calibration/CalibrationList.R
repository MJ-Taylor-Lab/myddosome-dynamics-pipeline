# For retrieving calibration data

tryCatch({
  #Retrieve calibration data
  SETUP_DIRECTORY = file.path(TOP_DIRECTORY, SETUP_FOLDER)
  #Change directory to calibration folder
  setwd(SETUP_DIRECTORY)
  #Retrieve data
  CalibrationInput <- read.csv(file = CALIBRATION_INPUT_DATA)
  #Make list
  CalibrationInput <-
    CalibrationInput %>%
    filter(
      KEEP == 1,
      PROTEIN_CALIBRATION_MEAN > 1
    )
  #Number of loops
  nCalibrations = 1:NROW(CalibrationInput)
  CalData <- NULL
  #Reads calibration tables
  CalibrationListFx <-
    function (CalibrationImageX) {
      tryCatch({
        PROTEIN_CALIBRATION = CalibrationInput$PROTEIN_CALIBRATION[CalibrationImageX]
        PROTEIN = CalibrationInput$PROTEIN[CalibrationImageX]
        #Change directory
        setwd(
          file.path(
            SETUP_DIRECTORY,
            "Calibrations",
            PROTEIN_CALIBRATION,
            "Cell_1"
          ))
        
        #Load table
        filename = paste("Filtered", PROTEIN, "Calibration", sep = "")
        CalData <- data.table::fread(paste(filename, ".csv.gz", sep = ""), integer64="character")
        CalData$PROTEIN_CALIBRATION <- PROTEIN_CALIBRATION
        CalData
      }, error = function(e) {print("   ERROR CalibrationList. CalibrationImageX =", CalibrationImageX)}
      )
    }
  #Run fx
  CalData <- lapply(nCalibrations, CalibrationListFx)
  CalData <- do.call(rbind, CalData)
  CalData[,1] <- NULL
  
  #Create table
  CalData <- merge(CalibrationInput, CalData, by = "PROTEIN_CALIBRATION", all = T)
  
  #Create 
  tryCatch({
    setwd(file.path(SETUP_DIRECTORY, "Calibrations", "Graphs"))
  },error=function(e) {
    setwd(file.path(SETUP_DIRECTORY, "Calibrations"))
    dir.create("Graphs")
  })
  
  CalData <-
    CalData %>%
    group_by(
      PROTEIN,
      PROTEIN_CALIBRATION_DATE
    ) %>%
    mutate(
      DATE_N = NROW(PROTEIN),
      DATE_MEAN = mean(TOTAL_INTENSITY_ADJUSTED),
      DATE_SD = sd(TOTAL_INTENSITY_ADJUSTED),
      DATE_SE = DATE_SD / sqrt(DATE_N)
    ) %>%
    ungroup()
  
  #Save data
  setwd(SETUP_DIRECTORY)
  filename = "CalibrationsCombined"
  file.remove(paste(filename, ".csv.gz", sep = ""))
  data.table::fwrite(CalData, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
  
  #Select columns to save
  CalData <-
    CalData %>%
    select(
      PROTEIN,
      PROTEIN_CALIBRATION_DATE,
      DATE_N,
      DATE_MEAN,
      DATE_SD,
      DATE_SE
    ) %>%
    distinct()
  
  #Save data
  setwd(SETUP_DIRECTORY)
  filename = "CalibrationsList"
  file.remove(paste(filename, ".csv.gz", sep = ""))
  data.table::fwrite(CalData, paste(filename, ".csv", sep = ""), row.names = F, na = "")
  
}, error=function(e) {print("ERROR CalibrationList")})