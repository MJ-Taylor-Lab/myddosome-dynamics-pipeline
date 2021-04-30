#Analyzes calibration images

print(":::::::::::::::::::: START CALIBRATION LOOP ::::::::::::::::::::")

# For normalizing signals
tryCatch({
  #Reformat directory
  SETUP_DIRECTORY = file.path(TOP_DIRECTORY, SETUP_FOLDER)
  #Change directory to calibration folder
  setwd(SETUP_DIRECTORY)
  #Import list
  CalibrationInputOriginal <- read.csv(file = CALIBRATION_INPUT_DATA)
  #Get list of files to calibrate
  CalibrationInput <-
    CalibrationInputOriginal %>%
    mutate(
      PROTEIN_INTENSITY = is.na(PROTEIN_INTENSITY) | PROTEIN_INTENSITY == ""
    ) %>%
    filter(
      PROTEIN_INTENSITY == TRUE
    )
  
  #Save 
  CalibrationInputOriginal <-
    CalibrationInputOriginal %>%
    filter(
      PROTEIN_INTENSITY != ""
    ) 

  #Calibration fx
  CalibrationFx <-
    function(CalibrationImageX) {
      tryCatch({
        #CalibrationImageX properties saved as temp variables
        PROTEIN = CalibrationInput$PROTEIN[CalibrationImageX]
        IMAGE = CalibrationInput$IMAGE[CalibrationImageX]
        PROTEIN_CALIBRATION_BACKGROUND =
          CalibrationInput$PROTEIN_BACKGROUND_CELL[CalibrationImageX]
        KEEP = CalibrationInput$KEEP[CalibrationImageX]
        PROTEIN_CALIBRATION_DATE = CalibrationInput$DATE[CalibrationImageX]
        #Change directory
        setwd(file.path(SETUP_DIRECTORY, "Calibrations", IMAGE, "Cell_1"))
        #Import table
        CalData =
          read.csv(
            paste("Reformatted ", PROTEIN, " spots in tracks statistics.csv", sep = ""),
            header = T)
        #Subtract background from total intensity
        CalData <-
          CalData %>%
          filter(
            #Discard spots preceding detection
            FRAMES_ADJUSTED >= 0
          ) %>%
          group_by(
            TRACK_ID
          ) %>%
          mutate(
            TIME = NROW(TRACK_ID),
            #Total intensity minus the image background
            TOTAL_INTENSITY_ADJUSTED = TOTAL_INTENSITY - PROTEIN_CALIBRATION_BACKGROUND,
          ) %>%
          filter(
            #Keeps only images with 3+ frames
            TIME >= 3
          )
        #Save list
        filename = paste("Filtered", PROTEIN, "Calibration", sep = "")
        file.remove(paste(filename, ".csv.gz", sep = ""))
        data.table::fwrite(CalData, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")

        #Draw density plot
        #Helps identify quality of calibration image
        #(a prominent sharp Gaussian peak would be a "good" calibration)
        LOCAL_DIRECTORY <- getwd()
        setwd(CALIBRATION_SCRIPTS)
        SOURCE = ""
        CalDataMode <- CalData
        source("CalibrationDensityPlot.r", local = T)
       
        #Save data
        setwd(file.path(SETUP_DIRECTORY, "Calibrations", IMAGE, "Cell_1"))
        filename = paste("CalibrationData", PROTEIN, sep = "_")
        file.remove(paste(filename, ".csv.gz", sep = ""))
        data.table::fwrite(CalData, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
        #New table
        CalibrationInputNew <-
          data.frame(
            IMAGE,
            PROTEIN,
            PROTEIN_CALIBRATION_BACKGROUND,
            KEEP,
            PROTEIN_CALIBRATION_DATE
          )
        #Compute image summary
        CalibrationInputNew <-
          CalibrationInputNew %>%
          mutate(
            PROTEIN_CALIBRATION = IMAGE,
            PROTEIN_CALIBRATION = as.character(PROTEIN_CALIBRATION),
            PROTEIN_CALIBRATION_DATE = as.numeric(PROTEIN_CALIBRATION_DATE),
            PROTEIN_CALIBRATION_MEAN = mean(CalData$TOTAL_INTENSITY_ADJUSTED),
            PROTEIN_CALIBRATION_SD = sd(CalData$TOTAL_INTENSITY_ADJUSTED),
            SPOTS = NROW(CalData),
            PROTEIN_CALIBRATION_SE = PROTEIN_CALIBRATION_SD/SPOTS,
            NOTES = ""
          ) %>%
          select(-c(
            IMAGE
          ))
        
        CalibrationInputNew <<- CalibrationInputNew
        CalibrationInputNew
      },
      error = function(e){
        print(paste("   ERROR with CalibrationFx. CalibrationImageX =", CalibrationImageX))
      }
      )
    }
  #Loop
  nCalibrations = 1:NROW(CalibrationInput)
  CalibrationInputNew <- mclapply(nCalibrations, CalibrationFx)
  CalibrationInputNew <- CalibrationInputNew[(which(sapply(CalibrationInputNew,is.list), arr.ind=TRUE))]
  CalibrationInputNew <- do.call(bind_rows, CalibrationInputNew)
  
  #Merge calibration tables
  CalibrationInputOriginal <- as.data.frame(CalibrationInputOriginal)
  CalibrationInputNew <- as.data.frame(CalibrationInputNew)

  if(NROW(CalibrationInputOriginal)==0){
    CalibrationInput = CalibrationInputNew
  } else{
    CalibrationInput = bind_rows(CalibrationInputOriginal, CalibrationInputNew)
  }
  
  #Sort data
  CalibrationInput <-
    CalibrationInput %>%
    arrange(
      PROTEIN,
      PROTEIN_CALIBRATION_DATE,
      round(PROTEIN_CALIBRATION_SE, 2),
      -SPOTS
    ) %>%
    relocate(
      PROTEIN_CALIBRATION_MEAN,
      PROTEIN_CALIBRATION_SD,
      KEEP,
      .after = last_col()
    )
  
  #Save data
  setwd(SETUP_DIRECTORY)
  filename = paste(DATE_TODAY, "Calibrations", sep = "_")
  file.remove(paste(filename, ".csv.gz", sep = ""))
  data.table::fwrite(CalibrationInput, paste(filename, ".csv", sep = ""), row.names = F, na = "")

}, error=function(e) {print("ERROR CalibrationLoop")})

print(":::::::::::::::::::: END CALIBRATION LOOP ::::::::::::::::::::")