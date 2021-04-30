cat(
  "To cite this work, please use:

  Deliz-Aguirre, Cao, et al. (2021) MyD88 oligomer size functions as a
       physical threshold to trigger IL1R Myddosome signaling.
       J. Cell Biol. https://doi.org/10.1083/jcb.202012071"
)

#Run this code in R
#Enter the folder name(s) to scan. Separate folders with coma and contain folders within quotes("), as shown below

#Clean environment
remove(list = ls())
gc(reset = TRUE)

##################
###    INPUT   ###
##################

INPUT_DIRECTORY = c(
  "~/ImageAnalysisWorkflow/04_ReextractIntensities"
)

OUTPUT_DIRECTORY = "~/ImageAnalysisWorkflow/00_Setup"

LIMIT_FILE_TYPE = TRUE #TRUE means yes, FALSE means no. Note that it is case sensitive
FILE_TYPE = "xml" #No dot

##################
###   SCRIPT   ###
##################
#Install libraries if not installed
if("dplyr" %in% rownames(installed.packages()) == FALSE) {install.packages("dplyr")}
if("parallel" %in% rownames(installed.packages()) == FALSE) {install.packages("parallel")}
if("rlist" %in% rownames(installed.packages()) == FALSE) {install.packages("rlist")}
if("openxlsx" %in% rownames(installed.packages()) == FALSE) {install.packages("dataframes2xls")}

#Start timer
START_TIME <- Sys.time()
#Load libraries
library(dplyr)
library(parallel)
library(rlist)
library(openxlsx)
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
names(INPUT_DIRECTORY) <- c("path")
#Remove if it ends with "/"
INPUT_DIRECTORY <-
  INPUT_DIRECTORY %>%
  mutate(
    path =  
      ifelse(
        substr(
          path,
          3, #Start at string position x
          10 #End at string position x
        ) == "path", #Add 'path' to Windows path
        gsub("\\\\", "/", path), #Make UNIX path
        as.character(path)
      )
  ) %>%
  #Make MacOS path
  mutate(
    path = gsub("//path", "/path", path)
  ) %>%
  #Remove last slash
  mutate(
    path = 
      ifelse(
        substr(
          path,
          nchar(as.character(path)),
          nchar(as.character(path))
        )=="/",
        substr(
          path,
          1,
          nchar(as.character(path))-1
        ),
        as.character(path)
      )
  )
#Adapt directory for later input
INPUT_DIRECTORY <- as.list(INPUT_DIRECTORY$path)
#Custom Fx for getting subfolders
DirectoryLp <- function(DirectoryX){
  tryCatch(
    {
      #Get directory item
      lp.INPUT_DIRECTORY <- INPUT_DIRECTORY[DirectoryX]
      lp.INPUT_DIRECTORY <- as.character(lp.INPUT_DIRECTORY)
      #Set directory
      setwd(lp.INPUT_DIRECTORY)
      #Make list of subdirectory paths found under the main directory
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
          FileListTemp <- as_tibble(FileListTemp)
          names(FileListTemp) <- c("file")
          #Write file name
          FileListTemp <-
            FileListTemp %>%
            mutate(
              Protein = basename(file),
              type = getType(Protein),
              Protein = substr(Protein, 1, nchar(Protein)-nchar(type)-1),
              Cells = dirname(file),
              PathUNIX = dirname(Cells),
              Cells = substr(Cells, nchar(PathUNIX)+7, nchar(Cells)),
              Path = (paste(
                "\\\\path",
                substr(PathUNIX, 9, nchar(PathUNIX)),
                sep=""
              )),
              Path = gsub("/", "\\\\", Path)
            ) %>%
            filter(
              type ==FILE_TYPE
            ) %>%
            select(-c(
              file,
              type
            )) %>%
            group_by(
              Path,
              Protein
            ) %>%
            mutate(
              Cells = as.numeric(Cells),
              Cells = max(Cells)
            ) %>%
            distinct() %>%
            select(
              Path,
              PathUNIX,
              Protein,
              Cells
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
        FileListTemp <- as_tibble(FileListTemp)
        names(FileListTemp) <- c("file")
        #Write file name
        FileListTemp <-
          FileListTemp %>%
          mutate(
            Protein = basename(file),
            type = getType(Protein),
            Protein = substr(Protein, 1, nchar(Protein)-nchar(type)-1),
            Cells = dirname(file),
            PathUNIX = dirname(Cells),
            Cells = substr(Cells, nchar(PathUNIX)+7, nchar(Cells)),
            Path = (paste(
              "\\\\path",
              substr(PathUNIX, 9, nchar(PathUNIX)),
              sep=""
            )),
            Path = gsub("/", "\\\\", Path)
          ) %>%
          filter(
            type ==FILE_TYPE
          ) %>%
          select(-c(
            file,
            type
          )) %>%
          group_by(
            Path,
            Protein
          ) %>%
          mutate(
            Cells = as.numeric(Cells),
            Cells = max(Cells)
          ) %>%
          distinct() %>%
          select(
            Path,
            PathUNIX,
            Protein,
            Cells
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
#Set export location. '~' is the home directory
setwd(OUTPUT_DIRECTORY)
#Write table to xls
write.xlsx(
  FileList,
  file = "xml2csv.xlsx",
  sheetName = "xml2csv"
)
END_TIME <- Sys.time()
#Get time
TOTAL_TIME <- END_TIME - START_TIME
#Show time it took to run
print(TOTAL_TIME)
#Show where file was saved
print(paste("Log saved at ", getwd(), sep=""))
#