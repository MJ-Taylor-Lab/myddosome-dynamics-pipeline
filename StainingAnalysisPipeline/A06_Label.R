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



RunTime <- 10 #s

# Get image list
local({
  #Parameters
  InclusionCriteria = c(" Watershed.tif")
  ExclusionCriteria = c(".nd2")
  
  # Images expected
  # Generate list of potential candidates
  ImagesExpected <- FileSearchFx(IMAGES_PATH, InclusionCriteria, ExclusionCriteria)
  ImagesExpected <- substr(ImagesExpected, 0, nchar(ImagesExpected)-nchar(" Watershed.tif"))
  ImagesExpected <- paste0(ImagesExpected, " Boundaries.tif")

  ImagesMissing <- ImagesExpected[which(!file.exists(ImagesExpected))]
  ImagesMissing <- dirname(ImagesMissing)
  ImagesMissing <<- unique(ImagesMissing)
})
OutputSize <- 4.3 #MB, 3x Channels (Orig + DF)
OutputSize <- StorageLeft(OutputSize*NROW(ImagesMissing))

# Function to generate instructions and send to terminal
LabelFx <- function(ImageX) {
  IMAGE = ImagesMissing[ImageX]
  #print(paste("     ", basename(IMAGE)))
  INSTRUCTIONS <-
    paste0(
      # Load ImageJ
      FIJI_PATH,
      # Parameters for ImageJ
      " --ij2 --run ", #--headless, still it figuring out
      
      #Script to run
      file.path(SCRIPTS_DIRECTORY, "A06_Label.ijm"),
      
      # # Arguments
      " 'dir=\"", IMAGE, "\",",
      " Marker_Channel=\"", Marker_Channel, "\",",
      " Measuring_Channel=\"", Measuring_Channel, "\"'"
    )
  #Run
  RunName <- terminalExecute(INSTRUCTIONS)
}

# Run in parallel if enough storage left
if(NROW(ImagesMissing)>0){#& OutputSize){
  ParallelFx(LabelFx)
}
