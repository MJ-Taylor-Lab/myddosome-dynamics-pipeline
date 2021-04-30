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


#Input
library(raster)

FILE_ENDING = "-DFRm-FFMedRm.tif"

#For getting characters left of 
substrLeft = function(text, num_char) {
  substr(text, 1, num_char)
}
#For getting characters right of 
substrRight <- function(word, n.characters){
  substr(word, nchar(word)-n.characters+1, nchar(word))
}

#Blank plot
empty_img_plot = matrix(nrow = IMAGE_PIXEL_SIZE, ncol = IMAGE_PIXEL_SIZE)
empty_img_plot = reshape2::melt(empty_img_plot)
names(empty_img_plot) = c("x", "y", "z")
empty_img_plot$z = 0

# Get image list
local({
  #Parameters
  InclusionCriteria = c(" C=", FILE_ENDING)
  ExclusionCriteria = c(".nd2"," Watershed.tif", " Boundaries.tif", "-Avg", "Well.tif")
  # Images expected
  # Generate list of potential candidates
  ImagesExpected <- FileSearchFx(IMAGES_PATH, InclusionCriteria, ExclusionCriteria)
  ImagesExpected <- dirname(dirname(ImagesExpected))
  ImagesExpected <- unique(ImagesExpected)
  ImagesExpected <- file.path(ImagesExpected, basename(ImagesExpected))
  ImagesExpected <- paste0(ImagesExpected, " C=", 0:2, tools::file_path_sans_ext(FILE_ENDING), " Well.tif")
  
  ImagesMissing <- ImagesExpected[which(!file.exists(ImagesExpected))]
  ImagesMissing <- dirname(ImagesMissing)
  ImagesMissing <<- unique(ImagesMissing)
})

#File search
FileNames <-
  list.files(
    path = ImagesMissing,#PATH
    full.names = TRUE,
    all.files = TRUE,
    include.dirs = FALSE,
    recursive = TRUE
  )

#Generate file list
FileNames <- as_tibble(FileNames)
names(FileNames) <- c("file")

FileNames <-
  FileNames %>%
  mutate(
    type = substrRight(file, nchar(FILE_ENDING))
  ) %>%
  filter(
    type == FILE_ENDING
  ) %>%
  mutate(
    image = basename(dirname(file)),
    image_wo_number = substrLeft(image, nchar(image)-4),
    well_path = dirname(dirname(file)),
    image_path = file.path(well_path, image_wo_number)
  ) %>%
  dplyr::select(
    image_path
  ) %>%
  distinct()

FileNames <- FileNames$image_path

#Save images
WellFx <- function(WellX) {
  tryCatch({
    LP_WELL = FileNames[WellX]
    #Set to well path
    WellPath = dirname(LP_WELL)
    print(paste("Well",basename(WellPath)))
    setwd(WellPath)
    
    #Sequence of image names
    ImageNames <- paste(
      basename(LP_WELL),
      stringr::str_pad(1:(IMAGES_PER_ROW^2), 3, pad = "0"),
      ")",
      sep = "")
    #Make it a path
    ImageNames <- file.path(WellPath, ImageNames)
    ImageNames <- as.data.frame(ImageNames)
    names(ImageNames) <- "Path"
    #Index only those that exist
    # ImageNames$Exists <- file.exists(ImageNames$Path)
    #Give unique ID and row, column position
    ImageNames <-
      ImageNames %>%
      # filter(
      #   Exists == TRUE
      # ) %>%
      mutate(
        Name = substrRight(Path, 4),
        Name = substrLeft(Name, 3),
        Name = as.numeric(Name),
        ID = group_indices(., Path),
        N_Row = round(sqrt(max(ID))),
        Row = ceiling(ID/N_Row),
        Column = ID-((Row-1)*(N_Row)),
        Column = ifelse(
          (Row %% 2) == 0,
          Column,
          N_Row - Column + 1
        )
      ) %>%
      filter(
        Row <= N_Row
      )
    
    #Analyze channels
    ChannelFx <- function(ChannelX){
      tryCatch({
        print(paste("     C=", ChannelX))
        #Image function
        ImageFx <- function(ImageX) {
          tryCatch({
            print(paste("          C =", ChannelX, "- Series =", ImageX))
            #Get variables
            IMG_PATH = ImageNames$Path[ImageX]
            ROW = ImageNames$Row[ImageX]
            COLUMN = ImageNames$Column[ImageX]
            
            #Check if image exists
            ImageChannel = paste(basename(IMG_PATH), " C=", ChannelX, FILE_ENDING, sep ="")
            ImageChannel = file.path(IMG_PATH, ImageChannel)
            
            #Upload image
            if(file.exists(ImageChannel)) {
              #Import image
              img_plot = raster::raster(ImageChannel)
              img_plot = raster::as.data.frame(img_plot, xy = T)
              names(img_plot) <- c("x", "y", "z")
              #Correct coordinates
              img_plot <-
                img_plot %>%
                mutate(
                  x = x + 0.5,
                  y = y + 0.5
                )
            } else {
              img_plot <- empty_img_plot
            }
            
            #Assign correct coordinates
            img_plot <-
              img_plot %>%
              mutate(
                x = x + ((ROW-1)*IMAGE_PIXEL_SIZE),
                y = y + ((COLUMN-1)*IMAGE_PIXEL_SIZE)
                #x = ceiling(x1/BIN_SIZE),
                #y = ceiling(y1/BIN_SIZE)
              )# %>%
              # group_by(
              #   x,
              #   y
              # ) %>%
              # summarize(
              #   z = mean(z),
              #   z = round(z)
              # )

            #Recall
            return(img_plot)
            
          }, error = function(e) {print(paste("   ERROR with C =", ChannelX, "- ImageFx ImageX =", ImageX))})
        }
        ImagesList <- mclapply(1:(IMAGES_PER_ROW^2), ImageFx, mc.cores = 4)
        ImagesList <- data.table::rbindlist(ImagesList)
        ImagesList <-
          ImagesList %>%
          arrange(
            y,
            x
          )
        ImagesList$z <- ImagesList$z/2^16
        ImagesList <- matrix(ImagesList$z, nrow=(IMAGE_PIXEL_SIZE*IMAGES_PER_ROW))
        
        save_name = paste(basename(dirname(LP_WELL))," C=", ChannelX, tools::file_path_sans_ext(FILE_ENDING), " Well.tif",sep = "")
        tiff::writeTIFF(ImagesList, save_name, reduce = T, bits.per.sample = 16L, compression = "deflate")
        
      }, error = function(e) {print(paste("ERROR with ChannelFx ChannelX =", ChannelX))})
    }
    lapply(0:1, ChannelFx)

  }, error = function(e) {print(paste("   ERROR with WellFx WellX =", WellX))})
}
tic()
lapply(1:NROW(FileNames), WellFx)
toc()
