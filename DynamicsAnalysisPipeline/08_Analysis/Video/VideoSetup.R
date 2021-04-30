#Make paths
{
  VideoData <-
    InputData %>%
    filter(
      IMAGE %in% VIDEO_IMAGE
    )
  VideoData <- VideoData[1,]
  VIDEO_COHORT <- VideoData$COHORT
  lp.STARTING_INTENSITY_THESHOLD <- VideoData$STARTING_INTENSITY_THESHOLD
  lp.ASSEMBLED_COMPLEX_SIZE <- VideoData$ASSEMBLED_COMPLEX_SIZE
  lp.MAX_INTENSITY_THRESHOLD <- VideoData$MAX_INTENSITY_THRESHOLD
  lp.LIFETIME_THRESHOLD <- VideoData$LIFETIME_THRESHOLD 
  lp.FLUOROPHORE <-  VideoData$FLUOROPHORE 
  lp.PROTEIN = VIDEO_PROTEIN
  lp.PROTEIN_FLUOROPHORE <- paste(lp.PROTEIN, lp.FLUOROPHORE, sep = "-")
  VIDEO_CELL_PATH = paste("Cell_", VIDEO_CELL, sep ="")
  CELL_PATH = file.path(ANALYSIS_DIRECTORY, VIDEO_COHORT, VIDEO_IMAGE, VIDEO_CELL_PATH)
  remove(VideoData, VIDEO_CELL_PATH, VIDEO_COHORT)
  #Image paths
  STACK_PATH = file.path(CELL_PATH, "Stack")
  EXPORT_PATH = file.path(CELL_PATH, "Animation")
  dir.create(EXPORT_PATH, showWarnings = FALSE)
}

#Import track data
{
  setwd(CELL_PATH)
  filename = paste(VIDEO_PROTEIN, "Analysis", sep = "_")
  ExpTracks <-
    data.table::fread(paste(filename, ".csv.gz", sep = ""), integer64="character")
  
  MAX_INTENSITY_CAT_ORDER <-
    c(
      paste("<", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE, sep = ""),
      paste("≥", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE, sep = "")
    )
  
  LIFETIME_CAT_ORDER <-
    c(
      paste("<", lp.LIFETIME_THRESHOLD, "s", sep = ""),
      paste("≥", lp.LIFETIME_THRESHOLD, "s", sep = "")
    ) 
}

#Image limits
{
  X_MIN = min(ExpTracks$POSITION_X)-PIXEL_SIZE*3
  X_MAX = max(ExpTracks$POSITION_X)+PIXEL_SIZE*3
  Y_MIN = min(ExpTracks$POSITION_Y)-PIXEL_SIZE*3
  Y_MAX = max(ExpTracks$POSITION_Y)+PIXEL_SIZE*3
}

#Tell track range
{
  ExpTracks <-
    ExpTracks %>%
    group_by(
      UNIVERSAL_TRACK_ID
    ) %>%
    mutate(
      MIN_FRAME = min(FRAME),
      MAX_FRAME = max(FRAME),
      MAX_INTENSITY_CAT =
        ifelse(
          MAX_INTENSITY_CAT==0,
          paste("<", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE, sep = ""),
          paste("≥", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE, sep = "")
        ),
      MAX_INTENSITY_CAT = factor(MAX_INTENSITY_CAT, levels = c(MAX_INTENSITY_CAT_ORDER)),
      LIFETIME_CAT =
        ifelse(
          LIFETIME_CAT==0,
          paste("<", lp.LIFETIME_THRESHOLD, "s", sep = ""),
          paste("≥", lp.LIFETIME_THRESHOLD, "s", sep = "")
        ),
      LIFETIME_CAT = factor(LIFETIME_CAT, levels = LIFETIME_CAT_ORDER)
    )
}

#Colors
{
  ColorScale <- c("#e41a1c", "#377eb8")
  names(ColorScale) <-
    c(
      paste("<", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE, sep = ""),
      paste("≥", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE, sep = "")
    )
}

#Import images
{
  setwd(STACK_PATH)
  FRAMES = list.files(pattern="*.tif")
  FRAMES = max(FRAMES)
  FRAMES = my.left(FRAMES, 4)
  FRAMES = as.numeric(FRAMES)
}

#Calibraton data
{
  if(exists("CalDataAll")){} else{
    setwd(SETUP_DIRECTORY)
    filename = "CalibrationsCombined"
    CalDataAll <-
      data.table::fread(paste(filename, ".csv.gz", sep = ""), integer64="character", strip.white = FALSE)
  }
  
  #Intensity to filter from list
  PROTEIN_INTENSITY = ExpTracks$PROTEIN_INTENSITY[1]
  PROTEIN_INTENSITY = round(PROTEIN_INTENSITY, 4)
  #Calibration data
  CalData <-
    CalDataAll %>%
    mutate(
      DATE_MEAN = round(DATE_MEAN, 4)
    ) %>%
    filter(
      KEEP == 1,
      DATE_MEAN == PROTEIN_INTENSITY
    )
  
  PROTEIN_SD = CalData$PROTEIN_CALIBRATION_SD[1]
  
  #Custom colors
  my.palette = c(brewer.pal(9, "YlGnBu")[c(3,6,9)])
  
  #Custom transformations
  my.half <- function(x){ 
    100*round(x*.3333, 3)
  }
  
}

FramesFx <- function(FrameX) {
  
  print(paste("Working on", FrameX,"s"))
  
  #Filter track data
  PlotTracks <-
    ExpTracks %>%
    filter(
      FRAME <= (FrameX+1),
      MAX_FRAME >= (FrameX+1)
    ) %>%
    arrange(
      TRACK_ID,
      FRAMES_ADJUSTED
    )
  
  #Add empty rows
  PlotTracksEmpty <- NULL
  PlotTracksEmpty$MAX_INTENSITY_CAT <-
    c(
      paste("<", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE, sep = ""),
      paste("≥", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE, sep = "")
    )
  PlotTracksEmpty <- as.data.frame(PlotTracksEmpty)
  PlotTracks <- plyr::rbind.fill(PlotTracks, PlotTracksEmpty)
  
  #Image plot
  setwd(VIDEO_SCRIPTS)
  #print("Running script Image.R")
  source("Image.R", local = T)
  
  #Tracks over image plot
  setwd(VIDEO_SCRIPTS)
  #print("Running script ImageTracks.R")
  source("ImageTracks.R", local = T)
  
  setwd(VIDEO_SCRIPTS)
  #print("Running script HistogramTable.R")
  source("HistogramTable.R", local = T)
  
  setwd(VIDEO_SCRIPTS)
  #print("Running script CalibrationPlot.R")
  source("CalibrationPlot.R", local = T)
  
  #HISTOGRAM
  #Title
  setwd(VIDEO_SCRIPTS)
  #print("Running script HistogramTitle.R")
  source("HistogramTitle.R", local = T)
  #Plot
  setwd(VIDEO_SCRIPTS)
  #print("Running script HistogramPlot.R")
  source("HistogramPlot.R", local = T)

  setwd(VIDEO_SCRIPTS)
  #print("Running script MaxIntensity.R")
  source("MaxIntensity.R", local = T)
  
  setwd(VIDEO_SCRIPTS)
  #print("Running script LifetimePlot.R")
  source("LifetimePlot.R", local = T)
  
  setwd(VIDEO_SCRIPTS)
  #print("Running script ChangeIntensityLifetimePlot.R")
  source("ChangeIntensityLifetimePlot.R", local = T)
  
  setwd(VIDEO_SCRIPTS)
  #print("Running script StitchPictures.R")
  source("StitchPictures.R", local = T)

}
nFrames <- 0:FRAMES
tic()
lapply(nFrames, FramesFx)
toc()

tic()
setwd(EXPORT_PATH)

#Make video from images
{
  FILE_LIST = max(list.files(EXPORT_PATH, '*.png'))
  FILE_LIST = my.left(FILE_LIST, 4)
  FILE_LIST = as.numeric(FILE_LIST)
  FILE_LIST = 0:(FILE_LIST/4)
  FILE_LIST = FILE_LIST*4
  FILE_LIST = paste(str_pad(FILE_LIST, 4, pad = "0"), ".png", sep = "")
  
  av::av_encode_video(FILE_LIST, framerate = VIDEO_FRAME_RATE, output = paste(lp.PROTEIN, '.mp4', sep="")) 
}
toc()