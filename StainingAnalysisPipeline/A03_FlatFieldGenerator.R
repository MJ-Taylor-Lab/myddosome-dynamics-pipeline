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


# Parameters
ImageRunTime = 3 #s per image

# IMAGE FLAT FIELD GENERATOR----
# Get dates and images missing
local({
  # Parameters
  InclusionCriteria = c("-DFRm", "C=", ".tif")
  ExclusionCriteria = c(".nd2", "-Avg", "-FFMedRm", " Watershed.tif", " Boundaries.tif")
  # Search files
  Images <- FileSearchFx(IMAGES_PATH, InclusionCriteria, ExclusionCriteria)
  # Make it a table
  Images <- as_tibble(Images)
  names(Images) <- "Image"
  Images <-
    Images %>%
    mutate(
      # Get well names
      Well = dirname(dirname(Image)),
      # Get acquisition date
      Date = basename(dirname(dirname(dirname(Image)))),
      Date = substr(Date, 0, 8)
    ) %>%
    select(-c(
      Image
    )) %>%
    distinct()
  
  # Function to add channels
  ImageDatesChannelsFx <- function(DateX, WellX, ChannelX) {
    ImageExpectedX <- paste0(DateX, " C=", ChannelX-1, "-Avg.tif")
    ImageExpectedX <- file.path(WellX, ImageExpectedX)
    return(ImageExpectedX)
  }
  # Apply function
  ImagesExpected <-
    mcmapply(
      ImageDatesChannelsFx,
      sort(rep(Images$Date, numC)),
      sort(rep(Images$Well, numC)),
      1:numC
  )
  # Vectorize
  ImagesExpected <<- as.vector(ImagesExpected)
  ImagesMissing <- ImagesExpected[which(!file.exists(ImagesExpected))]
  ImagesMissing <- as_tibble(ImagesMissing)
  names(ImagesMissing) <- c("Path")
  ImagesMissing$Date <- substr(basename(ImagesMissing$Path), 0, 8)
  ImagesMissing$Path <- dirname(ImagesMissing$Path)
  ImagesMissing <- unique(ImagesMissing)
  ImagesMissing <<- ImagesMissing
})

#Parallel Run
if(NROW(ImagesMissing)>0){
  ImageFlatFieldGeneratorFx <- function(ImageX) {
    
    DATE = ImagesMissing$Date[ImageX]
    IMAGE = ImagesMissing$Path[ImageX]
    
    # print(paste("ImageFlatFieldGeneratorFx Image =", basename(IMAGE)))
    
    INSTRUCTIONS <-
      paste0(
        # Load ImageJ
        FIJI_PATH,
        # Parameters for ImageJ
        " --ij2 --run ", #--headless, still it figuring out
        
        #Script to run
        file.path(SCRIPTS_DIRECTORY, "A03a_ImageFlatFieldGenerator.ijm"),
        
        # # Arguments
        " 'dir=\"", IMAGE, "\",",
        "numC=\"", numC, "\",",
        "acquisitionDate=\"", DATE, "\"'"
      )
    
    #Run
    RunName <- terminalExecute(INSTRUCTIONS)
  }
  RunTime = 20 + 3*ImageRunTime*(IMAGES_PER_ROW^2)*0.2*TimeAdjustment
  ParallelFx(ImageFlatFieldGeneratorFx)
}

# DATE FLAT FIELD GENERATOR----
# Generate missing list
local({
  DatesExpected <- unique(basename(ImagesExpected))
  DatesExpected <- as.vector(DatesExpected)
  DatesExpected <- file.path(IMAGES_PATH, DatesExpected)
  DatesExpected <- basename(DatesExpected)
  DatesMissing <<- substr(DatesExpected, 1, 8)
  ImagesMissing <<- unique(DatesMissing)
})
#Parallel Run
RunTime = 20 + ImageRunTime*NROW(ImagesExpected)*1.33*TimeAdjustment
dir.create(file.path(IMAGES_PATH, "Flat-Field Images"))

if(NROW(ImagesMissing)>0){
  DateFlatFieldGeneratorFx <- function(DateX) {
    
    DATE = ImagesMissing[DateX]
    # print(paste("FlatFieldGeneratorFx Date =", DATE))
    
    INSTRUCTIONS <-
      paste0(
        # Load ImageJ
        FIJI_PATH,
        # Parameters for ImageJ
        " --ij2 --run ", #--headless, still it figuring out
        
        #Script to run
        file.path(SCRIPTS_DIRECTORY, "A03b_DateFlatFieldGenerator.ijm"),
        
        # # Arguments
        " 'dir=\"", IMAGES_PATH, "\",",
        " dir_FFMed=\"", file.path(IMAGES_PATH, "Flat-Field Images"), "\",",
        " numC=\"", numC, "\",",
        " acquisitionDate=\"", DATE, "\"'"
      )
    
    RunName <- terminalExecute(INSTRUCTIONS)
    return(RunName)
  }
  ParallelFx(DateFlatFieldGeneratorFx)
}
