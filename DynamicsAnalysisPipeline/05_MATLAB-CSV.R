cat(
  "To cite this work, please use:

  Deliz-Aguirre, Cao, et al. (2021) MyD88 oligomer size functions as a
       physical threshold to trigger IL1R Myddosome signaling.
       J. Cell Biol. https://doi.org/10.1083/jcb.202012071"
)

#Make  table the output of ReextractIntensitiesWindows_04.m readable by R

#Reset all
rm(list = ls())
gc(reset = TRUE)

###########################
###     USER INPUT      ###
###########################

DIRECTORY = "~/ImageAnalysisWorkflow/05_MATLAB-CSV"
PROTEINS = c("MyD88", "IRAK4", "IRAK1", "GFP", "RFP")
FILE_NAME = "spots in tracks statistics.csv" #PROTEINS + space + FILE_NAME

###########################
###       SETUP         ###
###########################
START_TIME <- Sys.time()
#libraries
if("parallel" %in% rownames(installed.packages()) == FALSE) {install.packages("parallel")}
library(parallel)

if("tidyverse" %in% rownames(installed.packages()) == FALSE) {install.packages("tidyverse")}
library(tidyverse)

if("rlist" %in% rownames(installed.packages()) == FALSE) {install.packages("rlist")}
library(rlist)

#Custom fx for NA removal
na.lomf <- function(x) {
  na.lomf.0 <- function(x) {
    non.na.idx <- which(!is.na(x))
    if (is.na(x[1L])) {
      non.na.idx <- c(1L, non.na.idx)
    }
    rep.int(x[non.na.idx], diff(c(non.na.idx, length(x) + 1L)))
  }
  
  dim.len <- length(dim(x))
  
  if (dim.len == 0L) {
    na.lomf.0(x)
  } else {
    apply(x, dim.len, na.lomf.0)
  }
}
#Custom fx for finding the maximum while ignoring NA
my.max <- function(x)
  ifelse(!all(is.na(x)), max(x, na.rm = T), NA)

#Custom fx to get file extension type
getType <- function (x)
{
  pos <- regexpr("\\.([[:alnum:]]+)$", x)
  ifelse(pos > -1L, substring(x, pos + 1L), "")
}
#Prepare directory
DIRECTORY <- as.data.frame(DIRECTORY)
names(DIRECTORY) <- c("path")
DIRECTORY <-
  DIRECTORY %>%
  mutate(
    path =  
      ifelse(
        substr(
          path,
          3,
          10
        ) == "data-tay",
        gsub("\\\\", "/", path),
        as.character(path)
      )
  ) %>%
  mutate(
    path = gsub("//data-tay", "/Volumes", path)
  )
DIRECTORY <- as.list(DIRECTORY)
#Custom Fx for getting subfolders
ReformatProteinsFx <- function(ProteinX) {
  tryCatch({
    PROTEIN = PROTEINS[ProteinX]
    INPUT_NAME = paste(PROTEIN, FILE_NAME)
    
    DirectoryLp <- function(DirectoryX){
      tryCatch(
        {
          #Get directory item
          lp.DIRECTORY <- DIRECTORY[DirectoryX]
          lp.DIRECTORY <- as.character(lp.DIRECTORY)
          #Set directory
          setwd(lp.DIRECTORY)
          #Make list of subdirectory paths found under the main directory
          SUBDIRECTORY <-
            if(.Platform$OS.type == "unix"){
              paste(
                lp.DIRECTORY,
                dir()[file.info(dir())$isdir],
                sep = "/"
              )
            } else{
              paste(
                lp.DIRECTORY,
                dir()[file.info(dir())$isdir],
                sep = "\\"
              )
            }
          #Custom Fx to get file list
          ImageLog <- function(SubdirectoryX) {
            tryCatch({
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
              names(FileNames) <- c("path")
              FileNames <-
                FileNames %>%
                mutate(
                  name = basename(path),
                ) %>%
                filter(
                  name == INPUT_NAME
                ) %>%
                mutate(
                  path = substr(path, 1, nchar(path) - nchar(name))
                )
              #Reformat to tibble
              FileListTemp <<- FileNames
            },
            error = function(e) {}
            )
          }
          #Count subdirectories
          Loops4Sub = 1:NROW(SUBDIRECTORY)
          #Loop over subdirectories
          SubFileList <<- mclapply(Loops4Sub, ImageLog)
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
            names(FileNames) <- c("path")
            FileNames <-
              FileNames %>%
              mutate(
                name = basename(path)
              ) %>%
              filter(
                name == INPUT_NAME
              )
            #Reformat to tibble
            FileListTemp <<- FileNames
          },
          error = function(e) {}
          )
          FileListTemp = list(FileListTemp)
          #Merge parent directory with subdirectories
          SubFileList = bind_rows(FileListTemp, SubFileList)
          #Call subdirectories to see them out of the loop
          SubFileList
        },
        error = function(e) {}
      )
    }
    #Number of loops
    Loops4Dir = 1:NROW(DIRECTORY)
    #Save items created in loop as a list
    FileList <<- mclapply(Loops4Dir, DirectoryLp)
    #Take out empty lists
    FileList <- FileList[mclapply(FileList,length)>0] 
    FileList <- Filter(NROW, FileList)
    #Combine sublists
    FileList <- do.call(c, FileList)
    FileList <- bind_rows(FileList)
    #Feedback message
    print("Input setup complete")
    #Reformatting function
    ReformatFx <-function(ImageX) {
      #CELLS LOOP
      tryCatch({
        folder = FileList$path[ImageX]
        folder = as.character(folder)
        #Change cells directory
        setwd(folder)
        print(paste("Working on", getwd()))
        #Import TrackMate tables
        ExpData = read.csv(INPUT_NAME, header = F)
        ExpData[1] <- NULL
        ExpData <- ExpData[-c(1:5),]
        names(ExpData) = c("TRACK_ID", "FRAME", "FRAMES_ADJUSTED", "TOTAL_INTENSITY", "POSITION_X", "POSITION_Y")
        ExpData$TRACK_ID <- as.numeric(gsub("Track_", "", ExpData$TRACK_ID))
        ExpData$TRACK_ID <- na.lomf(ExpData$TRACK_ID)
        ExpData <- ExpData %>% filter(FRAME != "")
        write.csv(ExpData, paste("Reformatted", INPUT_NAME))
      })
    }
    lp.Reformatting = 1:NROW(FileList)
    mclapply(lp.Reformatting, ReformatFx)
  }, error = function(e) {print(paste("   ERROR with ReformatProteinsFx ProteinX =", ProteinX))})
}
nProteins = 1:NROW(PROTEINS)
mclapply(nProteins, ReformatProteinsFx)

print("Reformatting complete")

END_TIME <- Sys.time()
TOTAL_TIME <- END_TIME - START_TIME
TOTAL_TIME
#
