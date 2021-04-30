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


RunTime <- 110 #s
OutputSize <- 2.9*3*2 #MB, 3x Channels (Orig + DF)

# Get image list
local({
  #Parameters
  InclusionCriteria = c(" C=", "-DFRm", ".tif")
  ExclusionCriteria = c(".nd2", "-FFMedRm", "-Avg", " Boundaries.tif", " Watershed.tif")
  
  # Images expected
  # Generate list of potential candidates
  ImagesExpected <- FileSearchFx(IMAGES_PATH, InclusionCriteria, ExclusionCriteria)
  ImagesExpected <- substr(ImagesExpected, 0, nchar(ImagesExpected)-nchar(".tif"))
  ImagesExpected <- paste0(ImagesExpected, "-FFMedRm.tif")

  ImagesMissing <- ImagesExpected[which(!file.exists(ImagesExpected))]
  
  # Only for 3 channels missing
  ImagesMissing <- as_tibble(ImagesMissing)
  names(ImagesMissing) <- "Path"
  
  ImagesMissing <<-
    ImagesMissing %>%
    mutate(
      WELL = dirname(Path),
      NAME = substr(Path, 1, nchar(Path)-nchar(" C=0-DFRm-FFMedRm.tif")),
      C = substr(Path, nchar(Path)-nchar("-DFRm-FFMedRm.tif"), nchar(Path)-nchar("-DFRm-FFMedRm.tif")),
      C = as.numeric(C)
    ) %>%
    group_by(
      WELL
    ) %>%
    mutate(
      C = n(),
      Path = WELL
    ) %>%
    filter(
      C == 3
    ) %>%
    ungroup() %>%
    select(
      Path
    ) %>%
    distinct() %>%
    mutate(
      # Get acquisition date
      Date = basename(dirname(dirname(Path))),
      Date = substr(Date, 0, 8)
    )
})
# Function to generate instructions and send to terminal
FlatFieldMedianRemoveFx <- function(ImageX) {
  IMAGE = ImagesMissing$Path[ImageX]
  DATE = ImagesMissing$Date[ImageX]
  print(paste("     ",ImageX , "-", basename(IMAGE)))
  INSTRUCTIONS <-
    paste0(
      # Load ImageJ
      FIJI_PATH,
      # Parameters for ImageJ
      #" --headless -macro ", #--headless, still it figuring out
      " --ij2 --run ", #--headless, still it figuring out
      
      #Script to run
      file.path(SCRIPTS_DIRECTORY, "A04_MedRm.ijm"),
      #file.path(SCRIPTS_DIRECTORY, "A04_MedRm_headless.ijm"),
      
      # # Arguments
      " 'dir=\"", IMAGE, "\",",
      " dir_FFMed=\"", file.path(IMAGES_PATH, "Flat-Field Images"), "\",",
      " acquisitionDate=\"", DATE, "\"'"
    )
  #Run
  RunName <- terminalExecute(INSTRUCTIONS)
}

# Run in parallel if enough storage left
#OutputSize <- StorageLeft(OutputSize*NROW(ImagesMissing))
if(NROW(ImagesMissing) > 0){# & OutputSize){
  ParallelFx(FlatFieldMedianRemoveFx)
}
# 
local({
  #Parameters
  InclusionCriteria = c(" C=", "-DFRm", ".tif")
  ExclusionCriteria = c(".nd2", "-FFMedRm", "-Avg", " Boundaries.tif", " Watershed.tif")

  # Images expected
  # Generate list of potential candidates
  ImagesExpected <- FileSearchFx(IMAGES_PATH, InclusionCriteria, ExclusionCriteria)
  ImagesExpected <- substr(ImagesExpected, 0, nchar(ImagesExpected)-nchar(".tif"))
  ImagesExpected <- paste0(ImagesExpected, "-FFMedRm.tif")

  ImagesMissing <- ImagesExpected[which(!file.exists(ImagesExpected))]

  # Only for 3 channels missing
  ImagesMissing <- as_tibble(ImagesMissing)
  names(ImagesMissing) <- "Path"

  ImagesMissing <<-
    ImagesMissing %>%
    mutate(
      WELL = dirname(Path),
      NAME = substr(Path, 1, nchar(Path)-nchar(" C=0-DFRm-FFMedRm.tif")),
      C = substr(Path, nchar(Path)-nchar("-DFRm-FFMedRm.tif"), nchar(Path)-nchar("-DFRm-FFMedRm.tif")),
      C = as.numeric(C)
    ) %>%
    group_by(
      WELL
    ) %>%
    mutate(
      C = n(),
      Path = WELL
    ) %>%
    filter(
      C != 3
    ) %>%
    ungroup() %>%
    select(
      Path
    ) %>%
    distinct() %>%
    mutate(
      # Get acquisition date
      Date = basename(dirname(dirname(Path))),
      Date = substr(Date, 0, 8)
    )
})
if(NROW(ImagesMissing) < 80){# & OutputSize){
  ParallelFx(FlatFieldMedianRemoveFx)
}
