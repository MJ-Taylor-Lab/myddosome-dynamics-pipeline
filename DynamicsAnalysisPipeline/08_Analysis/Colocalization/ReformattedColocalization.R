#Reformats data so that R can access it

#Number of images to run
ColocReformatImageFx <- function(ImageX) {
  tryCatch({
    #Variables
    FOLDER = file.path(ANALYSIS_DIRECTORY, ColocalizationInput$COHORT[ImageX], ColocalizationInput$IMAGE[ImageX])
    COLOCALIZATION = ColocalizationInput$COLOCALIZATION[ImageX]
    COHORT = ColocalizationInput$COHORT[ImageX]
    GROUP = ColocalizationInput$GROUP[ImageX]
    IMAGE = ColocalizationInput$IMAGE[ImageX]
    LIGAND_DENSITY = ColocalizationInput$LIGAND_DENSITY[ImageX]
    LIGAND_DENSITY_CAT = ColocalizationInput$LIGAND_DENSITY_CAT[ImageX]
    CELLS = ColocalizationInput$CELLS[ImageX]
    #Protein data
    PROTEIN1 = ColocalizationInput$PROTEIN1[ImageX]
    PROTEIN2 = ColocalizationInput$PROTEIN2[ImageX]
    MAX_INTENSITY_THRESHOLD_1 = ColocalizationInput$MAX_INTENSITY_THRESHOLD_1[ImageX]
    MAX_INTENSITY_THRESHOLD_2 = ColocalizationInput$MAX_INTENSITY_THRESHOLD_2[ImageX]
    #Input feedback
    print(paste("   ColocReformatImageFx ImageX =", ImageX))
    
    #CELLS LOOP
    ColocReformatCellFx <- function (CellX) {
      tryCatch({
        print(paste("      ColocReformatCellFx ImageX =", ImageX, "CellX =", CellX))
        #Load colocalization data
        setwd(file.path(FOLDER, paste("Cell_", CellX, sep =""), COLOCALIZATION))
        ColocalizationData <- read.xlsx(
          "supporting_track_data.xlsx",
          sheet = "distance",
          colNames = TRUE
        )
        #Extract protein and track names
        ColocalizationData <- ColocalizationData %>%
          mutate(
            TRACK_KEY_ref_track_spots_table = sub("(.*)_Track", "\\1", TRACK_KEY_ref_track_spots_table),
            PROTEIN1_NAME =
              my.left(
                TRACK_KEY_ref_track_spots_table,
                gregexpr(
                  pattern = "_",
                  TRACK_KEY_ref_track_spots_table
                )[[1]][1]-1
              ),
            PROTEIN1_TRACK =
              my.right(
                TRACK_KEY_ref_track_spots_table,
                str_length(TRACK_KEY_ref_track_spots_table)-
                  gregexpr(
                    pattern = "_",
                    TRACK_KEY_ref_track_spots_table
                  )[[1]][1]
              ),
            TRACK_KEY_track_spots_table = sub("(.*)_Track", "\\1", TRACK_KEY_track_spots_table),
            PROTEIN2_NAME =
              my.left(
                TRACK_KEY_track_spots_table,
                gregexpr(
                  pattern = "_",
                  TRACK_KEY_track_spots_table
                )[[1]][1]-1
              ),
            PROTEIN2_TRACK =
              my.right(
                TRACK_KEY_track_spots_table,
                str_length(TRACK_KEY_track_spots_table)-
                  gregexpr(
                    pattern = "_",
                    TRACK_KEY_track_spots_table
                  )[[1]][1]
              )) %>%
          select(
            GROUP,
            PROTEIN1_NAME,
            PROTEIN1_TRACK,
            PROTEIN2_NAME,
            PROTEIN2_TRACK
          ) %>%
          mutate(
            UNIVERSAL_TRACK_ID_1 =
              paste(
                IMAGE,
                CellX,
                PROTEIN1_NAME,
                PROTEIN1_TRACK,
                sep = "..."),
            UNIVERSAL_TRACK_ID_2 =
              paste(
                IMAGE,
                CellX,
                PROTEIN2_NAME,
                PROTEIN2_TRACK,
                sep = "..."),
            COLOCALIZATION_GROUP = GROUP
          ) %>%
          select(-c(GROUP))
        #Save file of all colocalization tracks
        setwd(file.path(FOLDER, paste("Cell_", CellX, sep = "")))
        filename = "ReformattedColocalization"
        file.remove(paste(filename, ".csv.gz", sep = ""))
        data.table::fwrite(ColocalizationData, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
        ColocalizationData
      },
      error = function(e) {print(paste("      ERROR with ColocReformatCellFx ImageX =", ImageX, " CellX =", CellX))})
    }
    nCells = 1:CELLS
    ColocalizationData <- lapply(nCells, ColocReformatCellFx)
    ColocalizationData <- ColocalizationData[(which(sapply(ColocalizationData,is.list), arr.ind=TRUE))]
    ColocalizationData <- do.call(bind_rows, ColocalizationData)
    ColocalizationData
  }, error = function(e) {print(paste("   ERROR with ColocReformatImageFx ImageX =", ImageX))})
}
#Run colocalization loop by image
nImages = 1:NROW(ColocalizationInput)
ColocalizationData <- mclapply(nImages, ColocReformatImageFx)
ColocalizationData <- ColocalizationData[(which(sapply(ColocalizationData,is.list), arr.ind=TRUE))]
ColocalizationData <- do.call(bind_rows, ColocalizationData)

#Save colocalization data
setwd(COLOCALIZATION_DIRECTORY)
filename = "GrandTableReformatedColocalization"
file.remove(paste(filename, ".csv.gz", sep = ""))
data.table::fwrite(ColocalizationData, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")