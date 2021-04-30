print(":::::::::::::::::::: START INPUT DATA ::::::::::::::::::::")

# Creates list of folder names in the pipeline
PROTEIN_ORDER = c(LIGAND, PROTEIN_ORDER_INPUT)
ProteinOrderFx <- function(GroupX) {
  tryCatch({
    if(GroupX >1){
      OrderTable = combn(PROTEIN_ORDER, GroupX)
      OrderTable = t(OrderTable)
      OrderTable = as_tibble(OrderTable)
      OrderTable = apply(OrderTable[, 1:GroupX] ,1 , paste ,collapse = " ")
      OrderTable
    }
    else {
      PROTEIN_ORDER
    }
  }, error = function(e) {print(paste("   ERROR with ProteinOrderFx GroupX =", GroupX))})
}
# Loop
nGroups = 1:PROTEINS_IMAGED
PROTEIN_ORDER <- lapply(nGroups, ProteinOrderFx)
PROTEIN_ORDER <- do.call(c, PROTEIN_ORDER)

# Creates tables of images, proteins to analyze
# Also saves global variables pertaining to images, proteins and ligand densities
tryCatch({
  # Input directory
  setwd(file.path(SETUP_DIRECTORY, "Input"))
  # Import input files table
  InputData <-
    read.csv(INPUT_DATA, header = T)
  
  # Format input files table
  InputData <-
    InputData %>%
    mutate(
    # Input path for loops
    PATH = file.path(ANALYSIS_DIRECTORY, COHORT, IMAGE),
    # Area in pixels
    PROTEIN_BACKGROUND = PROTEIN_BACKGROUND_CELL * 9,
    # Ligand density every 0.5 steps using log base 10
    LIGAND_DENSITY_CAT =
      # Round to nearest half log
      round(
        # Classifies ligands based on log using base 3.162 (10^.5)
        log(
          LIGAND_DENSITY,
          base = (10^.5)),
        digits = 0
      ) * 0.5,
    # Convert back to linear
    LIGAND_DENSITY_CAT = signif(10^LIGAND_DENSITY_CAT, 2),
    # Group discarding ligand information
    # since images may be acquired without ligand channel data
    GROUP = gsub(paste(LIGAND, " ", sep = ""), "", COHORT),
    NEW_PROTEIN = factor(PROTEIN, PROTEIN_ORDER),
    NEW_GROUP = factor(GROUP, PROTEIN_ORDER),
    NEW_COHORT = factor(COHORT, PROTEIN_ORDER)
  ) %>%
  group_by(
    IMAGE,
    PROTEIN
  ) %>%
  mutate(
    # Get number of cells
    CELLS = max(CELL, na.rm = T),
    # Average background of all cells in image by protein
    # To be subtracted later from image intensities
    PROTEIN_BACKGROUND = mean(PROTEIN_BACKGROUND)
  ) %>%
  arrange(
    NEW_PROTEIN,
    NEW_GROUP,
    LIGAND_DENSITY_CAT,
    NEW_COHORT,
    IMAGE,
    CELL
  ) %>%
  ungroup() %>%
  mutate(
    NEW_PROTEIN = as.character(NEW_PROTEIN),
    NEW_PROTEIN = ifelse(is.na(NEW_PROTEIN), PROTEIN, NEW_PROTEIN),
    TEST = grepl("^[0-9]{1,}$", NEW_PROTEIN),
    COHORT = ifelse(TEST == TRUE, PROTEIN, NEW_PROTEIN),
    
    NEW_GROUP = as.character(NEW_GROUP),
    NEW_GROUP = ifelse(is.na(NEW_GROUP), GROUP, NEW_GROUP),
    TEST = grepl("^[0-9]{1,}$", NEW_GROUP),
    COHORT = ifelse(TEST == TRUE, GROUP, NEW_GROUP),
    
    NEW_COHORT = as.character(NEW_COHORT),
    NEW_COHORT = ifelse(is.na(NEW_COHORT), COHORT, NEW_COHORT),
    TEST = grepl("^[0-9]{1,}$", NEW_COHORT),
    COHORT = ifelse(TEST == TRUE, COHORT, NEW_COHORT)
  ) %>%
  select(-c(
    NEW_PROTEIN,
    NEW_GROUP,
    NEW_COHORT,
    TEST
  ))
  
  # Save list
  filename = "InputData"
  data.table::fwrite(InputData, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
  
  # Input table of only images
  InputDataImageSummary <-
    InputData %>%
    select(
      -c(
        CELL,
        AREA,
        PROTEIN_BACKGROUND_CELL
      )
    ) %>%
    distinct()
  
  # Save only image list
  filename = "InputDataImageSummary"
  data.table::fwrite(InputDataImageSummary, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
  
  # Input table of only proteins
  InputDataProteinSummary <- InputDataImageSummary
  InputDataProteinSummary$GROUP <- NULL
  InputDataProteinSummary <-
    InputDataImageSummary %>%
    ungroup() %>%
    select(-c(
      COHORT,
      IMAGE,
      DATE,
      PROTEIN_INTENSITY,
      PROTEIN_SD,
      FPS,
      PATH,
      PROTEIN_BACKGROUND,
      LIGAND_DENSITY_CAT,
      LIGAND_DENSITY,
      CELLS
    )) %>%
    distinct()
  
  # Save protein list
  filename = "InputDataProteinSummary"
  data.table::fwrite(InputDataProteinSummary, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
  # Make list of ligand densities
  InputDataDensitySummary <-
    InputDataImageSummary %>%
    ungroup() %>%
    select(-c(
      LIGAND_DENSITY,
      COHORT,
      IMAGE,
      DATE,
      PROTEIN_INTENSITY,
      PROTEIN_SD,
      FPS,
      PATH,
      PROTEIN_BACKGROUND,
      CELLS
    )) %>%
    select(
      LIGAND_DENSITY_CAT,
      GROUP,
      PROTEIN,
      FLUOROPHORE,
      everything()
    ) %>%
    distinct()
  
  # Save density list per group
  filename = "InputDataDensitySummary"
  data.table::fwrite(InputDataDensitySummary, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
  
}, error=function(e) {print("ERROR InputData")})

print(":::::::::::::::::::: END INPUT DATA ::::::::::::::::::::")
