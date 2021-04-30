cat(
  "To cite this work, please use:

  Deliz-Aguirre, Cao, et al. (2021) MyD88 oligomer size functions as a
       physical threshold to trigger IL1R Myddosome signaling.
       J. Cell Biol. https://doi.org/10.1083/jcb.202012071"
)

#Run this code in R
#Mount server before extracting the image list  (smb://data-tay.mpiib-berlin.mpg.de/taylor-lab)
#Enter the folder name(s) to scan. Separate folders with coma and contain folders within quotes("), as shown below
#Clean everything
remove(list = ls())
gc(reset = TRUE)

##################
###    INPUT   ###
##################

#Don't end path with "/"
INPUT_DIRECTORY = "~/ImageAnalysisWorkflow/07_Colocalization"
OUTPUT_DIRECTORY = "~/ImageAnalysisWorkflow/00_Setup"

##################
###   SCRIPT   ###
##################
#Install libraries if not installed
if("dplyr" %in% rownames(installed.packages()) == FALSE) {install.packages("dplyr")}
library(dplyr)
if("parallel" %in% rownames(installed.packages()) == FALSE) {install.packages("parallel")}
library(parallel)
if("rlist" %in% rownames(installed.packages()) == FALSE) {install.packages("rlist")}
library(rlist)
if("openxlsx" %in% rownames(installed.packages()) == FALSE) {install.packages("dataframes2xls")}
library(openxlsx)

#Start timer
START_TIME <- Sys.time()
#Load libraries
#Custom function to get file type type
getType <- function (x)
{
  pos <- regexpr("\\.([[:alnum:]]+)$", x)
  ifelse(pos > -1L, substring(x, pos + 1L), "")
}
#Clear history
FileList = ""
#Adapt directory for manipulation
INPUT_DIRECTORY <- as.data.frame(INPUT_DIRECTORY)
names(INPUT_DIRECTORY) <- c("PATH")
#Adapt directory for later input
INPUT_DIRECTORY <- as.list(INPUT_DIRECTORY$PATH)
#Custom Fx for getting subfolders
DirectoryLp <- function(DirectoryX){
  tryCatch(
    {
      print(paste("Working on DirectoryX =", DirectoryX))
      #Get directory item
      lp.INPUT_DIRECTORY <- INPUT_DIRECTORY[DirectoryX]
      lp.INPUT_DIRECTORY <- as.character(lp.INPUT_DIRECTORY)
      #Set directory
      setwd(lp.INPUT_DIRECTORY)
      #Make list of subdirectory PATHs found under the main directory
      SUBINPUT_DIRECTORY <-
        if(.Platform$OS.type == "unix"){
          paste(
            lp.INPUT_DIRECTORY,
            dir()[file.info(dir())$isdir],
            sep = "/"
          )
        } else{
          paste(
            lp.INPUT_DIRECTORY,
            dir()[file.info(dir())$isdir],
            sep = "\\"
          )
        }
      #Custom Fx to get file list
      ImageLog <- function(SubdirectoryX) {
        tryCatch({
          print(paste("Working on SubdirectoryX =", SubdirectoryX))
          
          #Examine specific subdirectory
          folders = SUBINPUT_DIRECTORY[SubdirectoryX]
          #Create data frame with file list
          FileListTemp <-
            list.files(
              full.names = TRUE,
              path = folders,
              all.files = TRUE,
              include.dirs = FALSE,
              recursive = TRUE
            )
          FileListTemp <- tibble::enframe(FileListTemp)
          FileListTemp <- FileListTemp[2]
          names(FileListTemp) <- c("FILE")
          #Write file name
          FileListTemp <-
            FileListTemp %>%
            mutate(
              PROTEIN = basename(FILE),
              TYPE = getType(PROTEIN),
              PROTEIN = substr(PROTEIN, 1, nchar(PROTEIN)-nchar(TYPE)-1),
              CELLS = dirname(FILE),
              PATH = dirname(CELLS),
              CELLS = substr(CELLS, nchar(PATH)+7, nchar(CELLS))
            ) %>%
            filter(
              TYPE == "xml"
            ) %>%
            select(-c(
              FILE,
              TYPE
            )) %>%
            group_by(
              PATH,
              PROTEIN
            ) %>%
            mutate(
              CELLS = as.numeric(CELLS),
              CELLS = max(CELLS)
            ) %>%
            distinct() %>%
            select(
              PATH,
              PROTEIN,
              CELLS
            )
          #Reformat to tibble
          FileListTemp <<- FileListTemp
          FileListTemp
        },
        error = function(e) {}
        )
      }
      #Count subdirectories
      Loops4Sub = 1:NROW(SUBINPUT_DIRECTORY)
      #Loop over subdirectories
      SubFileList <<- mclapply(Loops4Sub, ImageLog)
      #Analyze parent directory
      tryCatch({
        #Create data frame with file list
        FileListTemp <-
          list.files(
            full.names = TRUE,
            path = lp.INPUT_DIRECTORY,
            all.files = TRUE,
            include.dirs = FALSE,
            recursive = FALSE
          )
        #Limit search by file type
        FileListTemp <- tibble::enframe(FileListTemp)
        FileListTemp <- FileListTemp[2]
        names(FileListTemp) <- c("FILE")
        #Write file name
        FileListTemp <-
          FileListTemp %>%
          mutate(
            PROTEIN = basename(FILE),
            TYPE = getType(PROTEIN),
            PROTEIN = substr(PROTEIN, 1, nchar(PROTEIN)-nchar(TYPE)-1),
            CELLS = dirname(FILE),
            PATH = dirname(CELLS),
            CELLS = substr(CELLS, nchar(PATH)+7, nchar(CELLS))
          ) %>%
          filter(
            TYPE == "xml"
          ) %>%
          select(-c(
            FILE,
            TYPE
          )) %>%
          group_by(
            PATH,
            PROTEIN
          ) %>%
          mutate(
            CELLS = as.numeric(CELLS),
            CELLS = max(CELLS)
          ) %>%
          unique() %>%
          select(
            PATH,
            PROTEIN,
            CELLS
          )
        #Reformat to tibble
        FileListTemp <<- FileListTemp
      },
      error = function(e) {}
      )
      #Merge parent directory with subdirectories
      SubFileList = bind_rows(FileListTemp, SubFileList)
      #Call subdirectories to see them out of the loop
      SubFileList
    },
    error = function(e) {}
  )
}
#Number of loops
Loops4Dir = 1:NROW(INPUT_DIRECTORY)
#Save items created in loop as a list
FileList <<- mclapply(Loops4Dir, DirectoryLp)
#Combine lists
#FileList <- do.call(c, FileList)
#Take out empty lists
FileList <- FileList[mclapply(FileList,length)>0] 
#Combine sublists
FileList <- bind_rows(FileList)
FileList <-
  FileList %>%
  group_by(
    PATH
  ) %>%
  mutate(
    PROTEIN1 = NROW(PATH)
  ) %>%
  filter(
    PROTEIN1 == 2
  ) %>%
  mutate(
    PROTEIN1 = PROTEIN,
    PROTEIN2 = ifelse(is.na(lead(PROTEIN)), lag(PROTEIN), lead(PROTEIN))
  ) %>%
  select(-c(
    PROTEIN
  ))
#Set export location. '~' is the home directory
setwd(OUTPUT_DIRECTORY)
#Write table to xls
write.xlsx(
  FileList,
  file = "Colocalization.xlsx",
  sheetName = "Colocalization"
)
END_TIME <- Sys.time()
#Get time
TOTAL_TIME <- END_TIME - START_TIME
#Show time it took to run
print(TOTAL_TIME)
#Show where file was saved
print(paste("Log saved at ", getwd(), sep=""))
# 