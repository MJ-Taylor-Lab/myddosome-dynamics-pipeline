# cat(
#   "To cite this work, please use:
# 
#   Deliz-Aguirre, Cao, et al. (2021) MyD88 oligomer size functions as a
#        physical threshold to trigger IL1R Myddosome signaling.
#        J. Cell Biol. https://doi.org/10.1083/jcb.202012071"
# )
# 
# 
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


RunTime <- 9.03*2 #s

# Get table
Measurements <-
  data.table::fread(
    file.path(IMAGES_PATH, "Measurements.csv.gz")
  ) %>%
  filter(
    FilterCell == F
  )

# Create new ROI files----
Measurements <-
  Measurements %>%
  mutate(
    File = file.path(IMAGES_PATH, File)
  )

Measurements <-
  Measurements %>%
  filter(
    Well == "20201021 WellD02_EL4-WT_RelA"
  )

# If doing old measurements parameters
if(SAME_MEASUREMENTS_FILTER==FALSE){
  Measurements <-
    Measurements %>%
    mutate(
      ImageExpected = file.path(File, basename(File)),
      ImageExpected = paste(ImageExpected, "NewBoundaries.tif"),
      ImageExpected = file.exists(ImageExpected)
    ) %>%
    filter(
      ImageExpected == FALSE
    ) %>%
    select(-c(
      ImageExpected
    ))
}
# Do ROIs
Images <- unique(Measurements$File)
ROIFx <- function(FileX){
  tryCatch({
    # Change directory to image
    IMAGE = Images[FileX]
    setwd(IMAGE)
    
     # Get ROI list for image
    ImageMeasurements <-
      Measurements%>%
      filter(
        Image == basename(Images[FileX])
      )
    # Create nucleus new ROIs
    AllROI <- unzip(file.path(IMAGE, "Marker.zip"))
    SelectROI <- AllROI[ImageMeasurements$ID]
    invisible(file.remove("FilteredNucleus.zip"))
    zip("FilteredNucleus.zip", basename(SelectROI), flags="-q")
    invisible(file.remove(AllROI))
    remove(AllROI, SelectROI)
    
    # Create cytosol new ROIs
    AllROI <- unzip(file.path(IMAGE, "Watershed.zip"))
    SelectROI <- AllROI[ImageMeasurements$Cytosol_ID]
    invisible(file.remove("FilteredCytosol.zip"))
    zip("FilteredCytosol.zip", basename(SelectROI), flags="-q")
    invisible(file.remove(AllROI))
    remove(AllROI, SelectROI)
    Sys.sleep(0.5)
  }, error = function(e){print(paste("ERROR with ROIFx. FileX =", FileX))})
}
mclapply(1:NROW(Images), ROIFx)
remove(Measurements)

# Combine images with ROI
NewLabelsFx <- function(ImageX){
  IMAGE = Images[ImageX]
  print(paste("     ",ImageX , "-", basename(IMAGE)))
  
  INSTRUCTIONS <-
    paste0(
      # Load ImageJ
      FIJI_PATH,
      # Parameters for ImageJ
      " --ij2 --run ", #--headless, still it figuring out
      
      #Script to run
      file.path(SCRIPTS_DIRECTORY, "A09_NewLabel.ijm"),

      # # Arguments
      " 'dir=\"", IMAGE, "\",",
      " Marker_Channel=\"", Marker_Channel, "\",",
      " Measuring_Channel=\"", Measuring_Channel, "\"'"
    )
  
  RunName <- terminalExecute(INSTRUCTIONS)
}
# Parallel run----
if(NROW(ImagesMissing)>0){
  ParallelFx(NewLabelsFx)
}


# # Create new ROI files----
# Measurements <-
#   Measurements %>%
#   mutate(
#     File = file.path(IMAGES_PATH, File)
#   )
# Images <- unique(Measurements$File)
# N = 3
# ROIFx(N)
# tic()
# RunName <- NewLabelsFx(N)
# while(terminalBusy(RunName)){
#   Sys.sleep(1)
# }
# terminalKill(RunName)
# toc()

