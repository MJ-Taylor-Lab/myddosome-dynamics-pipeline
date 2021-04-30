# For merging all tables containing detailed puncta data

setwd(LOCAL_DIRECTORY)

print("Running GrandTableSpots")
#Function to get image table
GrandTableFx <- 
  function(ImageX){
    tryCatch({
      #Local variables
      FOLDER = InputDataImageSummary$PATH[ImageX]
      PROTEIN = InputDataImageSummary$PROTEIN[ImageX]
      #Change directory to image location
      setwd(FOLDER)
      print(paste("     Getting ImageX =", ImageX))
      #Read image table
      filename = paste(PROTEIN, "Analysis", sep ="_")
      GrandTableImageX <-
        data.table::fread(paste(filename, ".csv.gz", sep = ""), integer64 = "character", strip.white = FALSE)
      GrandTableImageX
    }, error = function(e){print(paste("   ERROR with merging Grand Table (GrandTableFx). ImageX =", ImageX))})
  }
#Loop
nImages = 1:NROW(InputDataImageSummary)
GrandTable <- lapply(nImages, GrandTableFx)
GrandTable <- GrandTable[(which(sapply(GrandTable,is.list), arr.ind = TRUE))]
GrandTable <- do.call(bind_rows, GrandTable)

#Write Grand Table File
setwd(ANALYSIS_DIRECTORY)
filename = "GrandTableSpots"
file.remove(paste(filename, ".csv.gz", sep = ""))
data.table::fwrite(GrandTable, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")