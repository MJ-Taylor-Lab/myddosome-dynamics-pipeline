cat(
  "To cite this work, please use:

  Deliz-Aguirre, Cao, et al. (2021) MyD88 oligomer size functions as a
       physical threshold to trigger IL1R Myddosome signaling.
       J. Cell Biol. https://doi.org/10.1083/jcb.202012071"
)

#Makes a list of all cells, recording their path, area and initial intensity (i.e., "background")
#Uses data exported from 01_TIFF-Subtract.ijm

remove(list = ls())
gc(reset = TRUE)

##################
###    INPUT   ###
##################

# Path containing setup and images
TOP_DIRECTORY = "~/ImageAnalysisWorkflow/"
# Path to images
INPUT_DIRECTORY = "06_Area-Background"
# Path to output
OUTPUT_DIRECTORY = "00_Setup"
# Input table name
INPUT_NAME = "_MED_Measurements.txt"
# Output table name
OUTPUT_NAME = "Experimental"
# OUTPUT_NAME = "Experimental"
# Protein Names
if(OUTPUT_NAME == "Experimental"){
  # Order is important
  PROTEINS = c(
    "MyD88", "IRAK4", "IRAK1")
  FLUOROPHORES = c(
    "GFP", "RFP", "RFP")
  ASSEMBLED_COMPLEX_SIZES = c(
    6, 4, 4)
  MAX_INTENSITY_THRESHOLDS = c(
    4.5, 2.67, 2.67)
  LIFETIME_THRESHOLDS = c(
    50, 25, 25)
  STARTING_INTENSITY_THESHOLDS = c(
    2.5, 1.67, 1.67)
}
if(OUTPUT_NAME == "Calibration"){
  PROTEINS = c("GFP", "RFP")
}

##################
###   SCRIPT   ###
##################
#Install libraries if not installed and load them
if("dplyr" %in% rownames(installed.packages()) == FALSE) {install.packages("dplyr")}
library(dplyr)
if("plyr" %in% rownames(installed.packages()) == FALSE) {install.packages("dplyr")}
library(plyr)
if("parallel" %in% rownames(installed.packages()) == FALSE) {install.packages("parallel")}
library(parallel)
if("rlist" %in% rownames(installed.packages()) == FALSE) {install.packages("rlist")}
library(rlist)
#Start timer
START_TIME <- Sys.time()
#For getting characters left of 
substrLeft = function(text, num_char) {
  substr(text, 1, num_char)
}
#For getting characters right of 
substrRight <- function(word, n.characters){
  substr(word, nchar(word)-n.characters+1, nchar(word))
}
#For getting the file extension type
getType <- function (file)
{
  pos <- regexpr("\\.([[:alnum:]]+)$", file)
  ifelse(pos > -1L, substring(file, pos + 1L), "")
}
#Clear history
FileList = ""
#Adapt input name
ProteinFx <- function(ProteinX) {
  tryCatch({
    print(paste("Working on ProteinX =", ProteinX))
    PROTEIN_NAME = PROTEINS[ProteinX]
    
    INPUT_NAME = paste(PROTEIN_NAME, INPUT_NAME, sep = "")
    INPUT_TYPE = getType(INPUT_NAME)
    #Adapt directory for manipulation
    DIRECTORY = paste(TOP_DIRECTORY, INPUT_DIRECTORY, sep = "/")
    DIRECTORY <- as.data.frame(DIRECTORY)
    names(DIRECTORY) <- c("path")
    #Remove if it ends with "/"
    DIRECTORY <-
      DIRECTORY %>%
      #Remove last slash
      mutate(
        path = 
          ifelse(
            substr(
              path,
              nchar(as.character(path)),
              nchar(as.character(path))
            ) =="/",
            substr(
              path,
              1,
              nchar(as.character(path))-1
            ),
            as.character(path)
          )
      )
    #Adapt directory for later input
    DIRECTORY <- as.list(DIRECTORY$path)
    #Custom Fx for getting subfolders
    DirectoryLp <- function(DirectoryX){
      tryCatch(
        {
          print(paste("Working on DirectoryX =", DirectoryX))
          #Get directory item
          lp.DIRECTORY <- DIRECTORY[DirectoryX]
          lp.DIRECTORY <- as.character(lp.DIRECTORY)
          #Set directory
          setwd(lp.DIRECTORY)
          #Make list of subdirectory paths found under the main directory
          SUBDIRECTORY <-
            paste(
              lp.DIRECTORY,
              dir()[file.info(dir())$isdir],
              sep = "/"
            )
          #Custom Fx to get file list
          ImageLog <- function(SubdirectoryX) {
            tryCatch({
              print(paste("Working on SubdirectoryX =", SubdirectoryX))
              
              #Examine specific subdirectory
              folders = SUBDIRECTORY[SubdirectoryX]
              #Create data frame with file list
              FileNames <-
                list.files(
                  full.names = TRUE,
                  path = folders,
                  all.files = TRUE,
                  include.dirs = FALSE,
                  recursive = TRUE
                )
              #Limit search by file type
              FileNames <- as_tibble(FileNames)
              names(FileNames) <- c("file")
              FileNames <-
                FileNames %>%
                mutate(
                  end = substrRight(file, nchar(INPUT_NAME))
                ) %>%
                filter(
                  end == INPUT_NAME
                )
              #Write file name
              FileNames$name <- basename(FileNames$file)
              #Filter data frame
              FileListTemp <-
                FileNames %>%
                filter(name!="") %>%
                select (file, name)
              #Rename headers
              names(FileListTemp) <-
                c("Path",
                  "File"
                )
              
              FileListTemp <- FileListTemp
              FileListTemp
            },
            error = function(e) {}
            )
          }
          #Count subdirectories
          Loops4Sub = 1:NROW(SUBDIRECTORY)
          #Loop over subdirectories
          SubFileList <- mclapply(Loops4Sub, ImageLog)
          #Analyze parent directory
          tryCatch({
            #Create data frame with file list
            FileNames <-
              list.files(
                full.names = TRUE,
                path = lp.DIRECTORY,
                all.files = TRUE,
                include.dirs = FALSE,
                recursive = FALSE
              )
            #Limit search by file type
            FileNames <- as_tibble(FileNames)
            names(FileNames) <- c("file")
            FileNames <-
              FileNames %>%
              mutate(
                end = substrRight(file, nchar(INPUT_NAME))
              ) %>%
              filter(
                end == INPUT_NAME
              )
            #Write file name
            FileNames$name <- basename(FileNames$file)
            #Filter data frame
            FileListTemp <-
              FileNames %>%
              filter(name!="") %>%
              select (file, name)
            #Rename headers
            names(FileListTemp) <-
              c("Path",
                "File"
              )
            
            FileListTemp <<- FileListTemp
            FileListTemp
          },
          error = function(e) {}
          )
          FileListTemp = list(FileListTemp)
          #Merge parent directory with subdirectories
          SubFileList <- list.append(FileListTemp, SubFileList)
          SubFileList <- SubFileList[(which(sapply(SubFileList,is.list), arr.ind=TRUE))]
          SubFileList <- do.call(bind_rows, SubFileList)
          #Call subdirectories to see them out of the loop
          SubFileList <- SubFileList
          SubFileList
        },
        error = function(e) {}
      )
    }
    #Number of loops
    Loops4Dir = 1:NROW(DIRECTORY)
    #Save items created in loop as a list
    FileList <- mclapply(Loops4Dir, DirectoryLp)
    #Combine cell tables
    FileList <- bind_rows(FileList)
    #Combine sublists
    #FileList <- do.call(c, FileList)
    #FileList <- as_tibble(FileList)
    #FileList <- bind_rows(FileList)
    #names(FileList) <- c("Path")
    #Prepare table read
    InputData <-
      FileList %>%
      mutate(
        Image = substr(Path, nchar(dirname(dirname(Path)))+2, nchar(dirname(Path))),
        Folder = dirname(Path)
      ) %>%
      mutate(
        Container = substrRight(
          dirname(Folder),
          nchar(dirname(Folder))
          - nchar(dirname(dirname(Folder)))
          -1)
      ) %>%
      distinct()
    #Converting array to variable
    FOLDERS = InputData$Folder
    CONTAINERS = InputData$Container
    IMAGES = InputData$Image
    #Feedback message
    print("Input setup complete")
    MeasurementsFx <- function(img) {
      tryCatch({
        #Report headers
        Measurements = ""
        #CELLS LOOP
        for (folder in img) {
          tryCatch({
            #Change cells directory
            setwd(InputData$Folder[folder])
            #Import TrackMate tables
            MeasurementsTemp <-
              read.table(
                paste(
                  InputData$Image[folder],
                  INPUT_NAME,
                  sep = " "
                ),
                sep="\t",
                header=TRUE
              )
            names(MeasurementsTemp)[1] <- c("Cell")
            MeasurementsTemp$Image = InputData$Image[folder]
            MeasurementsTemp$Container = InputData$Container[folder]
            Measurements <- rbind(Measurements, MeasurementsTemp)
          })
        }
        setwd(DIRECTORY[[1]])
        Measurements <-
          Measurements %>%
          filter(Area != "") %>%
          mutate(
            Protein = PROTEIN_NAME
          )
        Measurements <-
          Measurements %>%
          filter(Area != "")
        
        #Export
        Measurements <<- Measurements
        Measurements
        
      }, error=function(e) {print("ERROR MeasurementsFx")})}
    lpCount = 1:NROW(InputData$Folder)
    Measurements <- mclapply(lpCount, MeasurementsFx)
    Measurements <- Measurements[(which(sapply(Measurements,is.list), arr.ind=TRUE))]
    Measurements <- do.call(bind_rows, Measurements)
    Measurements
  }, error = function(e) {print(paste("   ERROR with ProteinFx ProteinX =", ProteinX))})
}
nProteins = 1:NROW(PROTEINS)
Measurements <- mclapply(nProteins, ProteinFx)
Measurements <- Measurements[(which(sapply(Measurements,is.list), arr.ind=TRUE))]
Measurements <- do.call(bind_rows, Measurements)

Measurements <-
  Measurements %>%
  mutate(
    LIGAND_DENSITY = NA,
    COHORT = Container,
    IMAGE = Image,
    DATE = substrLeft(Image, 8),
    CELL = Cell,
    AREA = Area,
    PROTEIN = Protein,
    FLUOROPHORE = ifelse(OUTPUT_NAME == "Experimental", FLUOROPHORES[which(Protein == PROTEINS)], ""),
    PROTEIN_BACKGROUND_CELL = Mean,
    PROTEIN_INTENSITY = NA,
    PROTEIN_SD = NA,
    FPS = NA,
    ASSEMBLED_COMPLEX_SIZE = ifelse(OUTPUT_NAME == "Experimental", ASSEMBLED_COMPLEX_SIZES[which(Protein == PROTEINS)], ""),
    
    MAX_INTENSITY_THRESHOLD = ifelse(OUTPUT_NAME == "Experimental", MAX_INTENSITY_THRESHOLDS[which(Protein == PROTEINS)], ""),
    LIFETIME_THRESHOLD = ifelse(OUTPUT_NAME == "Experimental", LIFETIME_THRESHOLDS[which(Protein == PROTEINS)], ""),
    STARTING_INTENSITY_THESHOLD = ifelse(OUTPUT_NAME == "Experimental", STARTING_INTENSITY_THESHOLDS[which(Protein == PROTEINS)], ""),
    
    DATE = as.numeric(DATE)
  ) %>%  
  select(
    COHORT,
    IMAGE,
    DATE,
    CELL,
    AREA,
    PROTEIN,
    FLUOROPHORE,
    PROTEIN_BACKGROUND_CELL,
    ASSEMBLED_COMPLEX_SIZE,
    MAX_INTENSITY_THRESHOLD,
    LIFETIME_THRESHOLD,
    STARTING_INTENSITY_THESHOLD,
    
    LIGAND_DENSITY,
    PROTEIN_INTENSITY,
    PROTEIN_SD,
    FPS
  )
#Set NA to blank
Measurements[is.na(Measurements)] <- ""
#Go to output directory
OUTPUT_DIRECTORY = paste(TOP_DIRECTORY, OUTPUT_DIRECTORY, sep = "/")
setwd(OUTPUT_DIRECTORY)
#Save file

if(OUTPUT_NAME == "Calibration"){
  Measurements <-
    Measurements %>%
    select(
      PROTEIN,
      IMAGE,
      DATE,
      PROTEIN_BACKGROUND_CELL,
      PROTEIN_INTENSITY,
      PROTEIN_SD
    ) %>%
    mutate(
      KEEP = NA
    )
}

write.csv(Measurements, paste(Sys.Date(), OUTPUT_NAME, "Combined Measurements.csv"), row.names = F)
#Give feedback
print("Table complete")
#Tell total time elapsed
END_TIME <- Sys.time()
TOTAL_TIME <- END_TIME - START_TIME
TOTAL_TIME
#Tell output location
print(paste("Log saved at ", getwd(), sep=""))
#