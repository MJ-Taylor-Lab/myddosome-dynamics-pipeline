cat(
  "To cite this work, please use:

  Deliz-Aguirre, Cao, et al. (2021) MyD88 oligomer size functions as a
       physical threshold to trigger IL1R Myddosome signaling.
       J. Cell Biol. https://doi.org/10.1083/jcb.202012071"
)

cat(
"Copyright 2020-21 (c) Rafael Deliz-Aguirre

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the 'Software'), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
)

# CLEAN ENVIRONMENT----
remove(list = ls())
gc(reset = TRUE)
pacman::p_unload(pacman::p_loaded(), character.only = TRUE)

# USER INPUT ----

# Folder containing all scripts
SCRIPTS_DIRECTORY = "~/image-analysis/SingleMolecule/08_Analysis"
# Folder containing all data
TOP_DIRECTORY = "~"
# Folder containing calibration and input data
SETUP_FOLDER = "00_Setup"
# Folder containing all images
ANALYSIS_FOLDER = "08_Analysis"
# List of images to analyze
INPUT_DATA = "2021-01-18 HOIL1 R_Input 300.csv"
# Calibration images
CALIBRATION_INPUT_DATA = "Calibrations.csv"
# Order to sort proteins
PROTEIN_ORDER_INPUT = c("MyD88", "IRAK4", "IRAK1","IRAK4_KO", "IRAK1_KO", "HOIL1")
# Ligand
LIGAND = "IL-1"
# Pixel size
PIXEL_SIZE = 0.1466667
# Reference protein for colocalization
REFERENCE_PROTEIN = "MyD88"
# Number of channels imaged
PROTEINS_IMAGED = 3
# Image properties` `
PIXEL_SIZE = 0.1467 # µm/px
IMAGE_SIZE = 88 # µm

# Scripts to run
# T is true, meaning run
# F is false, meaning do not run
RUN_CALIBRATION_SCRIPTS = F # May need to run twice if multiple files on the same date
RUN_CELLANALYSIS_SCRIPTS = T
RUN_FINALSUMMARY_SCRIPTS = T
RUN_TRACKGRAPHS_SCRIPTS = F
RUN_IMAGEGRAPHS_SCRIPTS = F
RUN_COLOCALIZATION_SCRIPTS = F
RUN_KO_SCRIPTS = F
RUN_VIDEO_SCRIPTS = F

# CALL SCRIPTS----

SETUP_SCRIPTS <- file.path(SCRIPTS_DIRECTORY, "Setup")
setwd(SETUP_SCRIPTS)
print("Setup.R")
source("Setup.R", local = T)

# RUN_CALIBRATION_SCRIPTS----
tryCatch({
  if(RUN_CALIBRATION_SCRIPTS == T){
    print(":::::::::::::::::::: CalibrationSetup.r ::::::::::::::::::::")
    CALIBRATION_SCRIPTS <- file.path(SCRIPTS_DIRECTORY, "Calibration")
    setwd(CALIBRATION_SCRIPTS)
    print("Running script CalibrationSetup.R")
    source("CalibrationSetup.R", local = T)
  }
}, error = function(e) {print("Error with CALIBRATION_SCRIPTS")})

# RUN_CELLANALYSIS_SCRIPTS----
tryCatch({
  if(RUN_CELLANALYSIS_SCRIPTS == T){
    print(":::::::::::::::::::: CellAnalysisSetup.r ::::::::::::::::::::")
    CELLANALYSIS_SCRIPTS <- file.path(SCRIPTS_DIRECTORY, "CellAnalysis")
    setwd(CELLANALYSIS_SCRIPTS)
    print("Running script CellAnalysisSetup.R")
    source("CellAnalysisSetup.R", local = T)
  }
}, error = function(e) {print("Error with CELLANALYSIS_SCRIPTS")})

# RUN_FINALSUMMARY_SCRIPTS----
tryCatch({
  if(RUN_FINALSUMMARY_SCRIPTS == T){
    print(":::::::::::::::::::: FinalSummarySetup.r ::::::::::::::::::::")
    FINALSUMMARY_SCRIPTS <- file.path(SCRIPTS_DIRECTORY, "FinalSummary")
    setwd(FINALSUMMARY_SCRIPTS)
    print("Running script FinalSummarySetup.R")
    source("FinalSummarySetup.R", local = T)
  }
}, error = function(e) {print("Error with FINALSUMMARY_SCRIPTS")})

# RUN_TRACKGRAPHS_SCRIPTS----
tryCatch({
  if(RUN_TRACKGRAPHS_SCRIPTS == T){
    print(":::::::::::::::::::: FinalSummarySetup.r ::::::::::::::::::::")
    
    PLOTS_PER_PAGE = 12
    
    TRACKGRAPHS_SCRIPTS <- file.path(SCRIPTS_DIRECTORY, "TrackGraphs")
    setwd(TRACKGRAPHS_SCRIPTS)
    print("Running script TrackGraphsSetup.R")
    source("TrackGraphsSetup.R", local = T)
  }
}, error = function(e) {print("Error with FINALSUMMARY_SCRIPTS")})

# RUN_IMAGEGRAPHS_SCRIPTS----
tryCatch({
  if(RUN_IMAGEGRAPHS_SCRIPTS == T){
    print(":::::::::::::::::::: ImageGraphsSetup.R ::::::::::::::::::::")
    IMAGEGRAPHS_SCRIPTS <- file.path(SCRIPTS_DIRECTORY, "ImageGraphs")
    setwd(IMAGEGRAPHS_SCRIPTS)
    print("Running script ImageGraphsSetup.R")
    source("ImageGraphsSetup.R", local = T)
  }
}, error = function(e) {print("Error with ImageGraphsSetup.R")})

# RUN_COLOCALIZATION_SCRIPTS----
tryCatch({
  if(RUN_COLOCALIZATION_SCRIPTS == T){
    print(":::::::::::::::::::: ColocalizationSetup.R ::::::::::::::::::::")
    
    # If TRUE (T), it generates a refomratted table
    # based on the output of 07_Colocalization
    GENERATE_NEW_TABLE = F
    # Limit of the max intensity plot
    MAX_INT_LIMIT = 30
    # A manually curated table of the wait times between two colocalized puncta
    # Must be a csv and end in ".csv"
    WAIT_TIME_TABLE = "ManualWaitTime.csv"
    
    COLOCALIZATION_SCRIPTS <- file.path(SCRIPTS_DIRECTORY, "Colocalization")
    setwd(COLOCALIZATION_SCRIPTS)
    print("Running script ColocalizationSetup.R")
    source("ColocalizationSetup.R", local = T)
  }
}, error = function(e) {print("Error with COLOCALIZATION_SCRIPTS")})

# RUN_KO_SCRIPTS----
tryCatch({
  if(RUN_KO_SCRIPTS == T){
    print(":::::::::::::::::::: KOSetup.R ::::::::::::::::::::")
    
    # Minimum number of frames for each cell
    FRAME_LAND_MIN = 500
    # New table of groups combined
    GENERATE_NEW_TABLE = T
    
    KO_SCRIPTS <- file.path(SCRIPTS_DIRECTORY, "KO")
    setwd(KO_SCRIPTS)
    print("Running script KOSetup.R")
    source("KOSetup.R", local = T)
  }
}, error = function(e) {print("Error with KO_SCRIPTS")})

tryCatch({
  if(RUN_KO_SCRIPTS == T){
    print(":::::::::::::::::::: InhibitorSetup.R ::::::::::::::::::::")
    
    # Minimum number of frames for each cell
    FRAME_LAND_MIN = 500
    # New table of groups combined
    GENERATE_NEW_TABLE = T
    
    INHIBITOR_SCRIPTS <- file.path(SCRIPTS_DIRECTORY, "Inhibitor")
    setwd(INHIBITOR_SCRIPTS)
    print("Running script InhibitorSetup.R")
    source("InhibitorSetup.R", local = T)
  }
}, error = function(e) {print("Error with KO_SCRIPTS")})

tryCatch({
  if(RUN_VIDEO_SCRIPTS == T){
    print(":::::::::::::::::::: VideoSetup.R ::::::::::::::::::::")
    
    # Image settings
    VIDEO_IMAGE = "201900503  201900503 cl028 MyD88gfp  il1 JF646 1 1000 4.4nM.n003"
    VIDEO_CELL = 4
    VIDEO_PROTEIN = "MyD88"
    # Separate frames into individual TIFFs
    # Pad with 0's to make it 4 characters wide (e.g., Frame 1 is 0001.tif)
    # Save inside a subfolder called "Stack"
    # From ImageJ
    IMG_MIN_INTENSITY = 9
    IMG_MAX_INTENSITY = 64
    # Frame rate for
    VIDEO_FRAME_RATE = 15
    
    VIDEO_SCRIPTS <- file.path(SCRIPTS_DIRECTORY, "Video")
    setwd(VIDEO_SCRIPTS)
    print("Running script VideoSetup.R")
    source("VideoSetup.R", local = T)
  }
}, error = function(e) {print("Error with VIDEO_SCRIPTS")})
