cat(
  "To cite this work, please use:

  Deliz-Aguirre, Cao, et al. (2021) MyD88 oligomer size functions as a
       physical threshold to trigger IL1R Myddosome signaling.
       J. Cell Biol. https://doi.org/10.1083/jcb.202012071"
)


# Copyright 2020-21 (c) Rafael Deliz-Aguirre
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the 'Software'), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


remove(list = ls())
gc(reset = TRUE)
pacman::p_unload(pacman::p_loaded(), character.only = TRUE)

# User Input----
FIJI_PATH = "/Applications/Fiji.app/Contents/MacOS/ImageJ-macosx"
SCRIPTS_DIRECTORY = "~/image-analysis/Staining/00_Automated"
IMAGES_PATH = "~/Colocalization/ColocalizationPipeline/01_Unprocessed"
# Scripts to run ----
RUN_SPLIT_SERIES = FALSE
RUN_SPLIT_CHANNELS_DFRm = FALSE
RUN_FLAT_FIELD_GENERATOR = FALSE
RUN_FF_MEDIAN_REMOVE = FALSE
RUN_SEGMENTATION = FALSE
RUN_LABEL = FALSE
RUN_WELL_STITCH = TRUE
RUN_MEASUREMENTS = FALSE
RUN_NEW_LABELS = FALSE

# Instructions for ImageJ ----
# A02
dir_df = "~/Colocalization/ColocalizationPipeline/DarkFrames/"
LUT_0 = "Magenta"                         # C=0 LUT
df_0 = "AVG_20201026 Darkfield 100ms.tif" # C=0 Dark field name
LUT_1 = "Green"                           # C=1 LUT
df_1 = "AVG_20201026 Darkfield 200ms.tif" # C=1 Dark field name
LUT_2 = "Yellow"                          # C=2 LUT
df_2 = "AVG_20201026 Darkfield 100ms.tif" # C=2 Dark field name
# A03
numC = 3 # Number of channels
#A05
Marker_Channel = 0
Mask_Channel = 2
Measuring_Channel = 1

#A07 Well stitch
IMAGE_PIXEL_SIZE = 1200
IMAGES_PER_ROW = 13
BIN_SIZE = 2 #4x4
C0 = "b"
C1 = "r"
C2 = "g"
FILE_ENDING = "-DFRm-FFMedRm.tif"

# A08 Measurements
RUN_TABLE_MEASUREMENTS = TRUE
RUN_GRAPHS = TRUE

IMAGES_PER_ROW = 13
MAX_CENTROID_DISTANCE = 16
MIN_NUCLEUS_DIAMETER = 11
CELL_LINE_ORDER =
  c(
    "EL4-WT",
    "MyD88-GFP 027-1F7",
    "MyD88-GFP 027-2B9",
    "MyD88-GFP 028-3E10",
    "MyD88-GFP_IRAK4-mScarlet 085-3Z",
    "MyD88-GFP_IRAK1-mScarlet 082-3D",
    "IRAK4-KO 139-3C4",
    "IRAK1-KO 116-2E"
  )
IMAGE_PIXELS_WIDTH = 1200
MIN_BORDER_DISTANCE = 50

# A09
SAME_MEASUREMENTS_FILTER = FALSE

# Libraries ----
library(rstudioapi)
library(parallel)
library(dplyr)
library(R.utils)
library(tictoc)
LibrariesList <- pacman::p_loaded()

# Fix function names
select <- dplyr::select
summarize <- dplyr::summarize

# For getting files matching inclusion AND exclusion criteria
FileSearchFx <- function(PathX, IncludeX, ExcludeX) {
  tryCatch({
    #File search
    FileNames <-
      list.files(
        path = PathX,
        full.names = TRUE,
        all.files = TRUE,
        include.dirs = FALSE,
        recursive = TRUE
      )
    
    #List of included arguments
    tryCatch({
      FileNames <- FileNames[apply(sapply(IncludeX, grepl, FileNames), 1, all)]
    }, error = function(e){return(FileNames)})
    #List of excluded arguments
    tryCatch({
      FileNames <- FileNames[apply(!sapply(ExcludeX, grepl, FileNames), 1, all)]
    },  error = function(e){return(FileNames)})
    return(FileNames)
  }, error = function(e){})
}

# For parallel running
ParallelFx <- function(ImageJFx){
  if(NROW(ImagesMissing)>0){
    # Get number of parallel runs
    Sets = NROW(ImagesMissing)/Cores
    Sets = ceiling(Sets) - 1
    #For version of the loop
    for (Set in 0:Sets){
      tic()
      # Specify image range
      Start <- Set*Cores + 1
      End <- Set*Cores + Cores
      # Adjust end to max value
      if(End > NROW(ImagesMissing)){
        End = NROW(ImagesMissing)
      }
      # Range to analyze
      Range <- Start:End
      AllRunNames <- NULL
      # Execute
      for(Image in Range) {
        #print(paste(Image, "-", basename(ImagesMissing[Image]))) # Won't work with FF Generation
        RunName <- ImageJFx(Image)
        AllRunNames <- c(AllRunNames, RunName)
        Sys.sleep(0.5)
        # Time limit
        if(Image == End){
          # Timeout process
          withTimeout(
            {
              while(any(terminalBusy(AllRunNames))) {
                Sys.sleep(2)
              }
            },
            timeout = 2*Cores+RunTime*TimeAdjustment*3,
            onTimeout = "silent"
          )
          Sys.sleep(10)

          # Kill process
          while(NROW(terminalList())>0){
            for(nRunName in terminalList()){
              terminalKill(nRunName)
            }
            Sys.sleep(2)
          }
          # Pause
          Sys.sleep(5)
        }
      }
      # Report progress
      Time <- toc(quiet = TRUE)
      Time <- as.numeric(Time$toc - Time$tic)
      Time <- round(Time, 2)
      print(paste("Set ", Set, " (", round(Set/Sets, 2)*100, "%) - ", Sys.time(), " (", Time, "s)", sep = ""))
    }
  }
}

# Checks how much storage left
StorageLeft <- function(MB) {
  RunName <- terminalExecute("df -k . | tail -1 | awk '{print $4}'")
  Sys.sleep(0.5)
  AvailableSpace <- terminalBuffer(RunName)
  terminalKill(terminalList())
  Sys.sleep(0.5)
  AvailableSpace <- as.numeric(AvailableSpace[1])
  AvailableSpace <- AvailableSpace/1024 #In GB
  return(AvailableSpace+(5*1024*1024) > MB*1024)
}

# Benchmark ----
# Benchmark computer for appropriate timeouts
Runs = 5 # Parallel trials
Cores = detectCores(logical = F)
Tests <- 1:(Runs*Cores) # Total number of tests/trials
# Generate and time 20 million random numbers
TimeAdjustmentFx <- function(TimeX){
  tic()
  rnorm(2*10^7)
  Time <- toc(quiet = TRUE)
  as.numeric(Time$toc - Time$tic)
}
# Execute and make it a table
TimeAdjustment <- mclapply(Tests, TimeAdjustmentFx, mc.cores = Cores)
TimeAdjustment <- unlist(TimeAdjustment)
TimeAdjustment <- mean(TimeAdjustment)
remove(Runs, Tests, TimeAdjustmentFx)

# Kill all terminals
terminalKill(terminalList())
Sys.sleep(3)
# A01_SplitSeries.ijm ----
if(RUN_SPLIT_SERIES == T){
  setwd(SCRIPTS_DIRECTORY)
  print("Running script A01_SplitSeries")
  source("A01_SplitSeries.R", local = T)
}

# A02_SplitChannels-DFRm.ijm ----
if(RUN_SPLIT_CHANNELS_DFRm == T){
  setwd(SCRIPTS_DIRECTORY)
  print("Running script A02_SplitChannels-DFRm")
  source("A02_SplitChannels-DFRm.R", local = T)
}

# A03_FlatFieldGenerator.ijm ----
if(RUN_FLAT_FIELD_GENERATOR == T){
  setwd(SCRIPTS_DIRECTORY)
  print("Running script A03_FlatFieldGenerator")
  source("A03_FlatFieldGenerator.R", local = T)
}

# A04_MedRm.ijm ----
if(RUN_FF_MEDIAN_REMOVE == T){
  setwd(SCRIPTS_DIRECTORY)
  print("Running script A04_MedRm")
  source("A04_MedRm.R", local = T)
}

# A05_Segmentation.ijm ----
if(RUN_SEGMENTATION == T){
  setwd(SCRIPTS_DIRECTORY)
  print("Running script A05_Segmentation")
  source("A05_Segmentation.R", local = T)
}

# A06_Label.ijm ----
if(RUN_LABEL == T){
  setwd(SCRIPTS_DIRECTORY)
  print("Running script A06_Label")
  source("A06_Label.R", local = T)
}
# 07_WellPictureStitch.R ----
if(RUN_WELL_STITCH == T){
  PATH = IMAGES_PATH
  
  setwd(SCRIPTS_DIRECTORY)
  print("Running script 07_WellPictureStitch")
  source("A07_WellPictureStitch.R", local = T)
}

# 08_Measurements ----
if(RUN_MEASUREMENTS == T){
  
  TOP_DIRECTORY = IMAGES_PATH
  setwd(SCRIPTS_DIRECTORY)
  print("Running script A08_Measurements.R")
  source("A08_Measurements.R", local = T)
}

# 09_Measurements ----
if(RUN_NEW_LABELS == T){
  library(LibrariesList)
  # Restore scripts directory path
  if(grepl("08_Measurements", SCRIPTS_DIRECTORY)==TRUE){
    SCRIPTS_DIRECTORY = dirname(SCRIPTS_DIRECTORY)
  }
  
  setwd(SCRIPTS_DIRECTORY)
  print("Running script A09_NewLabel.R")
  source("A09_NewLabel.R", local = T)
}
