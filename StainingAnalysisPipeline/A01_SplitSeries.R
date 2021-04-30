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



RunTime <- 819.048 #s
OutputSize = 8.9 #MB

# Get image list
local({
  #Parameters
  InclusionCriteria = c(".nd2")
  ExclusionCriteria = c(".tif")
  
  # Images expected
  # Generate list of potential candidates
  ImagesExpected <- FileSearchFx(IMAGES_PATH, InclusionCriteria, ExclusionCriteria)
  ImagesExpected <- substr(ImagesExpected, 0, nchar(ImagesExpected)-4)
  ImagesExpectedFx <- function (SeriesX) {
    nSeries <- formatC(SeriesX, width = 3, flag = "0")
    SeriesName <- paste0(basename(ImagesExpected), " (series ", nSeries,")")
    ImagesExpected <- file.path(ImagesExpected, SeriesName, paste0(SeriesName, ".tif"))
    return(ImagesExpected)
  }
  ImagesExpected <- mclapply(1:(IMAGES_PER_ROW^2), ImagesExpectedFx)
  ImagesExpected <- do.call(c, ImagesExpected)
  # Determine images to analyze
  ImagesMissing <- ImagesExpected[which(!file.exists(ImagesExpected))]
  ImagesMissing <- sort(ImagesMissing)
  ImagesMissing <- dirname(dirname(ImagesMissing))
  ImagesMissing <- paste0(ImagesMissing, ".nd2")
  ImagesMissing <<- unique(ImagesMissing)
  
  return(ImagesMissing)
})
OutputSize <- StorageLeft(OutputSize*NROW(ImagesMissing))

# Function to generate instructions and send to terminal
SplitSeriesFx <- function(ImageX) {
  IMAGE = ImagesMissing[ImageX]
  
  INSTRUCTIONS <-
    paste(
      # Load ImageJ
      FIJI_PATH,
      # Parameters for ImageJ
      " --ij2 --run ", #--headless, still it figuring out
      
      #Script to run
      file.path(SCRIPTS_DIRECTORY, "A01_SplitSeries.ijm"),
      
      # # Arguments
      " 'dir=\"", IMAGE, "\"'",
      sep ="")
  
  #Run
  tic()
  RunName <- terminalExecute(INSTRUCTIONS)
  # Kill if too long
  withTimeout(
    {
      while(any(rstudioapi::terminalBusy(RunName))) {
        Sys.sleep(1)
      }
    },
    timeout = RunTime*TimeAdjustment*1.2,
    onTimeout = "silent"
  )
  # Kill order
  while(NROW(terminalList())>0){
    for(nRunName in terminalList()){
      rstudioapi::terminalKill(nRunName)
    }
    Sys.sleep(1)
  }
  # Pause
  Sys.sleep(20)
  # Clock out
  Time <- toc(quiet = TRUE)
  Time <- as.numeric(Time$toc - Time$tic)
  Time <- round(Time, 2)
  # Report progress
  print(
    paste0(
      "Image ", ImageX,
      " (", round(ImageX/NROW(ImagesMissing), 2)*100, "%) - ",
      Sys.time(),
      " (", Time, "s)"
      )
    )
}

if(NROW(ImagesMissing)>0 & OutputSize){
  lapply(1:NROW(ImagesMissing), SplitSeriesFx)
  # ParallelFx(SplitSeriesFx)
}
