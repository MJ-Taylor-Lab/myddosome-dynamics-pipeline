#Create path if nonexistent
{
  INHIBITOR_DIRECTORY = file.path(ANALYSIS_DIRECTORY, "Inhibitor Data")
  
  dir.create(
    INHIBITOR_DIRECTORY,
    showWarnings = FALSE)  
  
  setwd(INHIBITOR_DIRECTORY)
}

#Create list of which files to analyze
{
  InputInhibitor <-
    InputDataImageSummary %>%
    group_by(
      LIGAND_DENSITY_CAT,
      GROUP,
      FPS
    ) %>%
    mutate(
      PROTEIN_COUNT = length(unique(PROTEIN))
    ) %>%
    filter(
      PROTEIN_COUNT == 1
    ) %>%
    group_by(
      LIGAND_DENSITY_CAT,
      FPS
    ) %>%
    mutate(
      GROUP_COUNT = length(unique(GROUP))
    ) %>%
    filter(
      GROUP_COUNT != 1
    ) %>%
    select(-c(
      PROTEIN_COUNT,
      GROUP_COUNT
    )) %>%
    ungroup() %>%
    mutate(
      GROUPNUMBER = group_indices(., LIGAND_DENSITY_CAT, PROTEIN, FPS)
    )
  
  setwd(INHIBITOR_DIRECTORY)
  filename = "InputInhibitor"
  data.table::fwrite(InputInhibitor, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
  
  InputProteinInhibitor <-
    InputInhibitor %>%
    select(
      LIGAND_DENSITY_CAT,
      PROTEIN,
      FLUOROPHORE,
      FPS,
      GROUPNUMBER,
      MAX_INTENSITY_THRESHOLD,
      LIFETIME_THRESHOLD
    ) %>%
    unique()
  
  setwd(INHIBITOR_DIRECTORY)
  filename = "InputProteinInhibitor"
  data.table::fwrite(InputInhibitor, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
}
GENERATE_NEW_TABLE = T
if(GENERATE_NEW_TABLE == T) {
  tryCatch({
    setwd(INHIBITOR_SCRIPTS)
    print("Running script GrandTracksInhibitor.R")
    source("GrandTracksInhibitor.R", local = T)
  }, error = function(e) {print("Error with GrandTracksInhibitor.R")})
} else{
  if(exists("GrandTracksInhibitor")) {} else {
    setwd(INHIBITOR_DIRECTORY)
    filename = "GrandTracksInhibitor"
    GrandTracksInhibitor <-
      data.table::fread(paste(filename, ".csv.gz", sep = ""), integer64="character")
  }
}

InhibitorGroupFx <- function(GroupX) {
  tryCatch({
    lp.PROTEIN = InputProteinInhibitor$PROTEIN[GroupX]
    lp.FLUOROPHORE = InputProteinInhibitor$FLUOROPHORE[GroupX]
    lp.PROTEIN_FLUOROPHORE = paste(lp.PROTEIN, lp.FLUOROPHORE, sep = "-")
    lp.LIGAND_DENSITY_CAT = InputProteinInhibitor$LIGAND_DENSITY_CAT[GroupX]
    lp.MAX_INTENSITY_THRESHOLD = InputProteinInhibitor$MAX_INTENSITY_THRESHOLD[GroupX]
    lp.LIFETIME_THRESHOLD = InputProteinInhibitor$LIFETIME_THRESHOLD[GroupX]
    FOLDER = file.path(INHIBITOR_DIRECTORY, paste(lp.PROTEIN, lp.LIGAND_DENSITY_CAT))
    
    #Create directory and switch
    dir.create(FOLDER, showWarnings = FALSE)
    setwd(FOLDER)
    
    #Filter the data
    {
      #Image list
      IMAGES <-
        InputInhibitor %>%
        filter(
          GROUPNUMBER == GroupX
        )
      #Protein list
      GROUP_LIST <-
        InputInhibitor %>%
        filter(
          GROUPNUMBER == GroupX
        ) 
      
      GROUP_LIST <- unique(GROUP_LIST$GROUP)
      
      # Colors for proteins
      Colors <- NULL
      Colors$Color <- RColorBrewer::brewer.pal(NROW(GROUP_LIST), "Set2")
      Colors <- as_tibble(Colors)
      Colors <- t(Colors)
      Colors <- as_tibble(Colors)
      names(Colors) <- c("Control", "IRAK4-Inhibitor")
      #Filter
      GroupTracks <-
        GrandTracksInhibitor %>%
        filter(
          IMAGE %in% IMAGES$IMAGE
        ) %>%
        ungroup()%>%
        mutate(
          IMAGENUMBER = group_indices(.,LIGAND_DENSITY_CAT, GROUP, IMAGE)
        ) %>%
        group_by(
          LIGAND_DENSITY_CAT,
          GROUP
        ) %>%
        mutate(
          IMAGENUMBER = IMAGENUMBER - min(IMAGENUMBER) + 1,
          GROUP = factor(GROUP, levels = GROUP_LIST)
        )
    }
    
    #Lifetime plot
    tryCatch({
      setwd(INHIBITOR_SCRIPTS)
      print("Running script Lifetime Cat_MaxInt Histogram.R")
      source("Lifetime Cat_MaxInt Histogram.R", local = T)
    }, error = function(e) {print("Error with Lifetime Cat_MaxInt Histogram.R")})
    
    #Change in intensity plot
    tryCatch({
      setwd(INHIBITOR_SCRIPTS)
      print("Running script Delta-Lifetime By_Group 2DHistogram.R")
      source("Delta-Lifetime By_Group 2DHistogram.R", local = T)
    }, error = function(e) {print("Error with Delta-Lifetime By_Group 2DHistogram.R")})
    
    #Max intensity comparison
    #Table
    tryCatch({
      setwd(INHIBITOR_SCRIPTS)
      print("Running script Mean_MaxInt Cat_Lifetime.R")
      source("Mean_MaxInt Cat_Lifetime.R", local = T)
    }, error = function(e) {print("Error with Mean_MaxInt Cat_Lifetime.R")})
    #Violin plot
    tryCatch({
      setwd(INHIBITOR_SCRIPTS)
      print("Running script Mean_MaxInt Cat_Lifetime Violin.R")
      source("Mean_MaxInt Cat_Lifetime Violin.R", local = T)
    }, error = function(e) {print("Error with Mean_MaxInt Cat_Lifetime Violin.R")})
    
    #Max intensity category percent comparison
    #Table
    tryCatch({
      setwd(INHIBITOR_SCRIPTS)
      print("Running script Mean_MaxIntCatPct.R")
      source("Mean_MaxIntCatPct.R", local = T)
    }, error = function(e) {print("Error with Mean_MaxIntCatPct.R")})
    #Violin plot
    tryCatch({
      setwd(INHIBITOR_SCRIPTS)
      print("Running script Mean_MaxIntCatPct Violin.R")
      source("Mean_MaxIntCatPct Violin.R", local = T)
    }, error = function(e) {print("Error with Mean_MaxIntCatPct Violin.R")})
    #Violin plot by lifetime
    tryCatch({
      setwd(INHIBITOR_SCRIPTS)
      print("Running script Mean_MaxIntCatPct Violin.R")
      source("Mean_MaxIntCatPct Cat_Lifetime Violin.R", local = T)
    }, error = function(e) {print("Error with Mean_MaxIntCatPct Cat_Lifetime Violin.R")})
    
    tryCatch({
      setwd(INHIBITOR_SCRIPTS)
      print("Running script Panel 6E Inhibitor.R")
      source("Panel 6E Inhibitor.R", local = T)
    }, error = function(e) {print("Error with Panel 6E Inhibitor.R")})
    
  }, error = function(e) {print(paste("   ERROR with InhibitorGroupFx GroupX =", GroupX))})
}
nGROUPS = unique(InputInhibitor$GROUPNUMBER)
mclapply(nGROUPS, InhibitorGroupFx)
