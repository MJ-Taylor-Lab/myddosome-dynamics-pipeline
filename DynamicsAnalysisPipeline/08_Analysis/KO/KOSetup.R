#Create path if nonexistent
{
  KO_DIRECTORY = file.path(ANALYSIS_DIRECTORY, "KO Data")
  
  dir.create(
    KO_DIRECTORY,
    showWarnings = FALSE)  
  
  setwd(KO_DIRECTORY)
}

#Create list of which files to analyze
{
  InputKO <-
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
  
  setwd(KO_DIRECTORY)
  filename = "InputKO"
  data.table::fwrite(InputKO, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
  
  InputProteinKO <-
    InputKO %>%
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
  
  setwd(KO_DIRECTORY)
  filename = "InputProteinKO"
  data.table::fwrite(InputKO, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
}

if(GENERATE_NEW_TABLE == T) {
  tryCatch({
    setwd(KO_SCRIPTS)
    print("Running script GrandTracksKO.R")
    source("GrandTracksKO.R", local = T)
  }, error = function(e) {print("Error with GrandTracksKO.R")})
} else{
  if(exists("GrandTracksKO")) {} else {
    setwd(KO_DIRECTORY)
    filename = "GrandTracksKO"
    GrandTracksKO <-
      data.table::fread(paste(filename, ".csv.gz", sep = ""), integer64="character")
  }
}

KOGroupFx <- function(GroupX) {
  tryCatch({
    lp.PROTEIN = InputProteinKO$PROTEIN[GroupX]
    lp.FLUOROPHORE = InputProteinKO$FLUOROPHORE[GroupX]
    lp.PROTEIN_FLUOROPHORE = paste(lp.PROTEIN, lp.FLUOROPHORE, sep = "-")
    lp.LIGAND_DENSITY_CAT = InputProteinKO$LIGAND_DENSITY_CAT[GroupX]
    lp.MAX_INTENSITY_THRESHOLD = InputProteinKO$MAX_INTENSITY_THRESHOLD[GroupX]
    lp.LIFETIME_THRESHOLD = InputProteinKO$LIFETIME_THRESHOLD[GroupX]
    FOLDER = file.path(KO_DIRECTORY, paste(lp.PROTEIN, lp.LIGAND_DENSITY_CAT))
    
    #Create directory and switch
    dir.create(FOLDER, showWarnings = FALSE)
    setwd(FOLDER)
    
    #Filter the data
    {
      #Image list
      IMAGES <-
        InputKO %>%
        filter(
          GROUPNUMBER == GroupX
        )
      #Protein list
      GROUP_LIST <-
        InputKO %>%
        filter(
          GROUPNUMBER == GroupX
        ) %>%
        mutate(
          GROUP = ifelse(GROUP == PROTEIN, "WT", str_replace_all(GROUP, paste(PROTEIN, ""), "")),
          GROUP = ifelse(GROUP == "IRAK4_KO_KI", "Rescue", GROUP)
        )
      GROUP_LIST <- unique(GROUP_LIST$GROUP)
      
      # Colors for proteins
      Colors <- NULL
      Colors$Color <- RColorBrewer::brewer.pal(NROW(GROUP_LIST), "Set2")
      Colors <- as_tibble(Colors)
      Colors <- t(Colors)
      Colors <- as_tibble(Colors)
      names(Colors) <- c("IRAK4_KO", "IRAK1_KO", "WT", "Rescue")
      Colors$WT <- "#3fc1ff"
      #Filter
      GroupTracks <-
        GrandTracksKO %>%
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
      setwd(KO_SCRIPTS)
      print("Running script Lifetime Cat_MaxInt Histogram.R")
      source("Lifetime Cat_MaxInt Histogram.R", local = T)
    }, error = function(e) {print("Error with Lifetime Cat_MaxInt Histogram.R")})
    
    #Change in intensity plot
    tryCatch({
      setwd(KO_SCRIPTS)
      print("Running script Delta-Lifetime By_Group 2DHistogram.R")
      source("Delta-Lifetime By_Group 2DHistogram.R", local = T)
    }, error = function(e) {print("Error with Delta-Lifetime By_Group 2DHistogram.R")})
    
    #Max intensity comparison
    #Table
    tryCatch({
      setwd(KO_SCRIPTS)
      print("Running script Mean_MaxInt Cat_Lifetime.R")
      source("Mean_MaxInt Cat_Lifetime.R", local = T)
    }, error = function(e) {print("Error with Mean_MaxInt Cat_Lifetime.R")})
    #Violin plot
    tryCatch({
      setwd(KO_SCRIPTS)
      print("Running script Mean_MaxInt Cat_Lifetime Violin.R")
      source("Mean_MaxInt Cat_Lifetime Violin.R", local = T)
    }, error = function(e) {print("Error with Mean_MaxInt Cat_Lifetime Violin.R")})
    
    #Max intensity category percent comparison
    #Table
    tryCatch({
      setwd(KO_SCRIPTS)
      print("Running script Mean_MaxIntCatPct.R")
      source("Mean_MaxIntCatPct.R", local = T)
    }, error = function(e) {print("Error with Mean_MaxIntCatPct.R")})
    #Violin plot
    tryCatch({
      setwd(KO_SCRIPTS)
      print("Running script Mean_MaxIntCatPct Violin.R")
      source("Mean_MaxIntCatPct Violin.R", local = T)
    }, error = function(e) {print("Error with Mean_MaxIntCatPct Violin.R")})
    #Violin plot by lifetime
    tryCatch({
      setwd(KO_SCRIPTS)
      print("Running script Mean_MaxIntCatPct Violin.R")
      source("Mean_MaxIntCatPct Cat_Lifetime Violin.R", local = T)
    }, error = function(e) {print("Error with Mean_MaxIntCatPct Cat_Lifetime Violin.R")})
    
    
  }, error = function(e) {print(paste("   ERROR with KOGroupFx GroupX =", GroupX))})
}
nGROUPS = unique(InputKO$GROUPNUMBER)
mclapply(nGROUPS, KOGroupFx)
