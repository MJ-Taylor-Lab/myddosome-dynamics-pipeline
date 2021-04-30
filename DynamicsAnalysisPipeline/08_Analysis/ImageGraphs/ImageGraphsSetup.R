#Plots graphs for images

#Imports table
if(exists("GrandTracks")) {} else {
  setwd(ANALYSIS_DIRECTORY)
  filename = "GrandTableTracks"
  GrandTracks <-
    data.table::fread(paste(filename, ".csv.gz", sep = ""), integer64="character")
}

#Subset data to run only on R_Input.csv list
{
  SUB_LIST <- 
    InputDataImageSummary %>%
    summarize(
      UNIVERSAL_IMAGE_ID = paste(PROTEIN, IMAGE, sep = "...")
    ) %>%
    distinct()
  
  SUB_LIST <- SUB_LIST$UNIVERSAL_IMAGE_ID
  
  GrandTracks <-
    GrandTracks %>%
    mutate(
      UNIVERSAL_IMAGE_ID = paste(PROTEIN, IMAGE, sep = "...")
    ) %>%
    filter(
      UNIVERSAL_IMAGE_ID %in% SUB_LIST
    )
  
  remove(SUB_LIST) 
}

#Output folder
{
  #Specify directory path
  DENSITY_DIRECTORY <-
    file.path(
      ANALYSIS_DIRECTORY,
      "Density Plots")
  #Create if not present
  dir.create(
    DENSITY_DIRECTORY,
    showWarnings = FALSE)
}

#Make list of tables to plot
{
  DensityList <-
    InputDataImageSummary %>%
    select(
      LIGAND_DENSITY_CAT,
      GROUP,
      PROTEIN,
      FLUOROPHORE,
      MAX_INTENSITY_THRESHOLD,
      LIFETIME_THRESHOLD,
      ASSEMBLED_COMPLEX_SIZE
    ) %>%
    distinct()
}

#Density plots
DensityFx <- function(DensityX) {
  tryCatch({
    #Input feedback
    print(paste("Density Graphs DensityX =", DensityX))
    
    #Loop variables
    lp.LIGAND_DENSITY_CAT = DensityList$LIGAND_DENSITY_CAT[DensityX]
    lp.GROUP = DensityList$GROUP[DensityX]
    lp.PROTEIN = DensityList$PROTEIN[DensityX]
    lp.MAX_INTENSITY_THRESHOLD = DensityList$MAX_INTENSITY_THRESHOLD[DensityX]
    lp.LIFETIME_THRESHOLD = DensityList$LIFETIME_THRESHOLD[DensityX]
    lp.FLUOROPHORE = DensityList$FLUOROPHORE[DensityX]
    lp.PROTEIN_FLUOROPHORE = paste(lp.PROTEIN, lp.FLUOROPHORE, sep = "-")
    lp.ASSEMBLED_COMPLEX_SIZE = DensityList$ASSEMBLED_COMPLEX_SIZE[DensityX]
    #PATH 
    {
      FOLDER <-
        file.path(
          DENSITY_DIRECTORY,
          paste(
            lp.GROUP,
            lp.LIGAND_DENSITY_CAT 
          )
        )
      #Create folder if path doesn't exist
      dir.create(FOLDER, showWarnings = FALSE)
      #Change to path
      setwd(FOLDER)
    }
    
    #Filter data
    DensityData <-
      GrandTracks %>%
      filter(
        LIGAND_DENSITY_CAT == lp.LIGAND_DENSITY_CAT,
        GROUP == lp.GROUP,
        PROTEIN == lp.PROTEIN
      )
    
    #Max intensity proportion vs max intensity category
    #Table
    tryCatch({
      setwd(IMAGEGRAPHS_SCRIPTS)
      print("Running script Mean_MaxIntCatPct-Cat_MaxIntCat.R")
      source("Mean_MaxIntCatPct Cat_MaxIntCat.R", local = T)
    }, error = function(e) {print(paste("   ERROR with Mean_MaxIntCatPct Cat_MaxIntCat DensityX =", DensityX))})
    
    #Plot
    tryCatch({
      setwd(IMAGEGRAPHS_SCRIPTS)
      print("Running script Mean_MaxInt Cat_MaxIntCat Violin.R")
      source("Mean_MaxIntCatPct Cat_MaxIntCat Violin.R", local = T)
    }, error = function(e) {print(paste("   ERROR with Mean_MaxIntCatPct Cat_MaxIntCat Violin DensityX =", DensityX))})
    #Beeswarm Plot
    tryCatch({
      setwd(IMAGEGRAPHS_SCRIPTS)
      print("Running script Mean_MaxIntCatPct Cat_MaxIntCat By_Replicate Beeswarm.R")
      source("Mean_MaxIntCatPct Cat_MaxIntCat By_Replicate Beeswarm.R", local = T)
    }, error = function(e) {print(paste("   ERROR with Mean_MaxIntCatPct Cat_MaxIntCat By_Replicate Beeswarm DensityX =", DensityX))})
    
    
    #Max intensity proportion vs lifetime
    #Table
    tryCatch({
      setwd(IMAGEGRAPHS_SCRIPTS)
      print("Running script Mean_MaxIntCatPct Cat_Lifetime.R")
      source("Mean_MaxIntCatPct Cat_Lifetime.R", local = T)
    }, error = function(e) {print(paste("   ERROR with Mean_MaxIntCatPct Cat_Lifetime DensityX =", DensityX))})
    #Violin Plot
    tryCatch({
      setwd(IMAGEGRAPHS_SCRIPTS)
      print("Running script Mean_MaxInt Cat_Lifetime Violin.R")
      source("Mean_MaxIntCatPct Cat_Lifetime Violin.R", local = T)
    }, error = function(e) {print(paste("   ERROR with Mean_MaxIntCatPct Cat_Lifetime Violin DensityX =", DensityX))})
    #Beeswarm Plot
    tryCatch({
      setwd(IMAGEGRAPHS_SCRIPTS)
      print("Running script Mean_MaxIntCatPct Cat_Lifetime By_Replicate Beeswarm.R")
      source("Mean_MaxIntCatPct Cat_Lifetime By_Replicate Beeswarm.R", local = T)
    }, error = function(e) {print(paste("   ERROR with Mean_MaxIntCatPct Cat_Lifetime By_Replicate Beeswarm DensityX =", DensityX))})
    
  }, error = function(e) {print(paste("   ERROR with DensityFx DensityX =", DensityX))})
}
#Run tracks loop by image
nDensities = 1:NROW(DensityList)
lapply(nDensities, DensityFx)

# #Calibrations import
# {
#   
#   setwd(SETUP_DIRECTORY)
#   filename = "CalibrationsCombined"
#   CalData <-
#     data.table::fread(paste(filename, ".csv.gz", sep = ""), integer64 = "character", strip.white = FALSE)
# }

#Image plots
ImageFx <- function(ImageX) {
  tryCatch({
    #Input feedback
    print(paste("Image Graphs ImageX =", ImageX))
    
    #Loop variables
    FOLDER = file.path(ANALYSIS_DIRECTORY, InputDataImageSummary$COHORT[ImageX], InputDataImageSummary$IMAGE[ImageX])
    lp.PROTEIN = InputDataImageSummary$PROTEIN[ImageX]
    lp.IMAGE = InputDataImageSummary$IMAGE[ImageX]
    lp.MAX_INTENSITY_THRESHOLD = InputDataImageSummary$MAX_INTENSITY_THRESHOLD[ImageX]
    lp.PROTEIN_INTENSITY = InputDataImageSummary$PROTEIN_INTENSITY[ImageX]
    lp.PROTEIN_SD = InputDataImageSummary$PROTEIN_SD[ImageX]
    lp.FLUOROPHORE = InputDataImageSummary$FLUOROPHORE[ImageX]
    lp.ASSEMBLED_COMPLEX_SIZE = InputDataImageSummary$ASSEMBLED_COMPLEX_SIZE[ImageX]
    
    #Filter data
    ImgTracks <-
      GrandTracks %>%
      filter(
        PROTEIN == lp.PROTEIN,
        IMAGE == lp.IMAGE
      )
    # 
    # #Plot calibration-experimental density plot
    # tryCatch({
    #   setwd(IMAGEGRAPHS_SCRIPTS)
    #   print("Running script Calibration-Experimental Density.R")
    #   source("Calibration-Experimental Density.R", local = T)
    # }, error = function(e) {print(paste("   ERROR with Calibration-Experimental Density ImageX =", ImageX))})

    
    #Plot max intensity proportion
    tryCatch({
    setwd(IMAGEGRAPHS_SCRIPTS)
    print("Running script Lifetime Histogram.R")
    source("Lifetime Histogram.R", local = T)
    }, error = function(e) {print(paste("   ERROR with Lifetime Histogram.R ImageX =", ImageX))})
    
    #Plot max intensity proportion
    tryCatch({
    setwd(IMAGEGRAPHS_SCRIPTS)
    print("Running script Delta-Lifetime By_Group 2DHistogram.R")
    source("Delta-Lifetime By_Group 2DHistogram.R", local = T)
    }, error = function(e) {print(paste("   ERROR with Delta-Lifetime By_Group 2DHistogram.R ImageX =", ImageX))})
    
  }, error = function(e) {print(paste("   ERROR with ImageFx ImageX =", ImageX))})
}
#Run tracks loop by image
nImages = 1:NROW(InputDataImageSummary)
lapply(nImages, ImageFx)
