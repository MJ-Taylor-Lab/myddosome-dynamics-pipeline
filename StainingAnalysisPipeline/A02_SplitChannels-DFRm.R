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


RunTime <- 18 #s

# Get image list
local({
  #Parameters
  InclusionCriteria = c(".tif")
  ExclusionCriteria =
    c(".nd2", " C=", "-DFRm", "-FFMedRm",
      " Watershed.tif", " Boundaries.tif",
      " Input.tif", " Mask.tif",  " Marker.tif",
      "-Avg"
    )
  
  # Images expected
  # Generate list of potential candidates
  ImagesExpected <- FileSearchFx(IMAGES_PATH, InclusionCriteria, ExclusionCriteria)
  ImagesExpected <- substr(ImagesExpected, 0, nchar(ImagesExpected)-4)
  ImagesExpectedFx <- function (ChannelX) {
    ChannelImagesExpected <-
      paste(ImagesExpected, " C=", ChannelX, ".tif", sep ="")
    ChannelImagesExpected
  }
  # Number of channels
  ImagesExpected <- mclapply(0:2, ImagesExpectedFx)
  ImagesExpected <- do.call(unlist, ImagesExpected)
  # Determine images to analyze
  ImagesMissing <- ImagesExpected[which(!file.exists(ImagesExpected))]
  ImagesMissing <- substr(ImagesMissing, 0, nchar(ImagesMissing)-nchar(" C=0.tif"))
  ImagesMissing <- paste(ImagesMissing, ".tif", sep = "")
  ImagesMissing <<- unique(ImagesMissing)
})
# OutputSize <- 2.9*3*2 #MB, 3x Channels (Orig + DF)
# OutputSize <- StorageLeft(OutputSize*NROW(ImagesMissing))

# Function to generate instructions and send to terminal
SplitChannelsFx <- function(ImageX) {
  IMAGE = ImagesMissing[ImageX]
  #print(paste("     ", basename(IMAGE)))
  INSTRUCTIONS <-
    paste0(
      # Load ImageJ
      FIJI_PATH,
      # Parameters for ImageJ
      " --ij2 --run ", #--headless, still it figuring out
      
      #Script to run
      #file.path(SCRIPTS_DIRECTORY, "A02_DFRm.ijm"),
      file.path(SCRIPTS_DIRECTORY, "A02_SplitChannels-DFRm.ijm"),
      
      
      # # Arguments
      " 'dir=\"", IMAGE, "\",",
      " dir_df=\"", dir_df, "\",",
      
      "LUT_0=\"", LUT_0, "\",",
      "df_0=\"", df_0, "\",",
      
      "LUT_1=\"", LUT_1, "\",",
      "df_1=\"", df_1, "\",",
      
      "LUT_2=\"", LUT_2, "\",",
      "df_2=\"", df_2, "\"'"
    )
  #Run
  RunName <- terminalExecute(INSTRUCTIONS)
  return(RunName)
}
# Run in parallel if enough storage left
if(NROW(ImagesMissing)>0){# & OutputSize){
  ParallelFx(SplitChannelsFx)
}
# # Remove "C=" if "-DFRm" is present
local({
  #Parameters
  InclusionCriteria = c("-DFRm", "C=", ".tif")
  ExclusionCriteria = c(".nd2")

  # Images expected
  # Generate list of potential candidates
  ImagesExpected <- FileSearchFx(IMAGES_PATH, InclusionCriteria, ExclusionCriteria)
  ImagesExpected <- gsub("-DFRm", "", ImagesExpected)
  # Determine images to delete
  ImagesCreated <- ImagesExpected[which(file.exists(ImagesExpected))]
  mclapply(ImagesCreated, file.remove)
})

# # Remove ".tif" if all "C=" are present
local({
  #Parameters
  InclusionCriteria = c("-DFRm", "C=", ".tif")
  ExclusionCriteria =
    c(".nd2", "-FFMedRm",
      " Watershed.tif", " Boundaries.tif",
      " Input.tif", " Mask.tif",  " Marker.tif",
      "-Avg"
    )
  
  # Images expected
  # Generate list of potential candidates
  ImagesExpected <- FileSearchFx(IMAGES_PATH, InclusionCriteria, ExclusionCriteria)
  ImagesExpected <- as_tibble(ImagesExpected)
  names(ImagesExpected) <- "path"
  
  ImagesExpected <-
    ImagesExpected %>%
    mutate(
      NAME = basename(path),
      NAME =  substr(path, 1, nchar(path)-nchar(" C=0-DFRm.tif")),
      C = substr(path, nchar(path)-nchar("-DFRm.tif"), nchar(path)-nchar("-DFRm.tif")),
      C = as.numeric(C)
    ) %>%
    group_by(
      NAME
    ) %>%
    mutate(
      C = all(C == c(0, 1, 2)),
    ) %>%
    filter(
      C == TRUE
    ) %>%
    summarize(
      NAME = paste0(NAME, ".tif")
    ) %>%
    distinct()

  # Delete images
  ImagesExpected <- ImagesExpected$NAME[which(file.exists(ImagesExpected$NAME))]
  mclapply(ImagesExpected, file.remove)
})
