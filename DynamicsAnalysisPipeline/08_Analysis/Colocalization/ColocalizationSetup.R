#Change folder
COLOCALIZATION_DIRECTORY = file.path(ANALYSIS_DIRECTORY, "Colocalization Data")
dir.create(COLOCALIZATION_DIRECTORY, showWarnings = FALSE)
setwd(COLOCALIZATION_DIRECTORY)

#Generate input table
{
  #Get list of reference files
  ColocalizationInputRef <- 
    InputDataImageSummary %>%
    group_by(IMAGE) %>%
    mutate(
      nPROTEINS = NROW(PROTEIN),
      MAX_INTENSITY_THRESHOLD_1 = MAX_INTENSITY_THRESHOLD
    ) %>%
    filter(
      nPROTEINS != 1,
      PROTEIN == REFERENCE_PROTEIN
    )
  #Rename protein column
  names(ColocalizationInputRef)[names(ColocalizationInputRef)=="PROTEIN"] <- "PROTEIN1"
  #Get colocalization protein
  ColocalizationInput <- 
    InputDataImageSummary %>%
    group_by(IMAGE) %>%
    mutate(
      nPROTEINS = NROW(PROTEIN),
      MAX_INTENSITY_THRESHOLD_2 = MAX_INTENSITY_THRESHOLD
    ) %>%
    filter(
      nPROTEINS != 1,
      PROTEIN != REFERENCE_PROTEIN
    ) %>%
    select(
      IMAGE,
      PROTEIN,
      MAX_INTENSITY_THRESHOLD_2
    )
  #Rename protein column
  names(ColocalizationInput)[names(ColocalizationInput)=="PROTEIN"] <- "PROTEIN2"
  ColocalizationInput = merge(ColocalizationInputRef, ColocalizationInput, by = "IMAGE")
  #Remove colocalization file
  #Prepare subfolder name
  ColocalizationInput <- ColocalizationInput %>% mutate(COLOCALIZATION = paste(PROTEIN2, PROTEIN1, sep = "_")) #Flipped parent/child
  remove(ColocalizationInputRef)
  
  ColocalizationInput <-
    ColocalizationInput %>%
    select(
      COLOCALIZATION,
      COHORT,
      GROUP,
      IMAGE,
      CELLS,
      LIGAND_DENSITY,
      LIGAND_DENSITY_CAT,
      PROTEIN1,
      MAX_INTENSITY_THRESHOLD_1,
      PROTEIN2,
      MAX_INTENSITY_THRESHOLD_2
    ) %>%
    ungroup() %>%
    mutate(
      GROUPNUMBER = group_indices(., GROUP, LIGAND_DENSITY_CAT),
      GROUP_ID = paste(GROUP, LIGAND_DENSITY_CAT)
    )
  
  #Save
  filename = "InputColocalization"
  data.table::fwrite(ColocalizationInput, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
  
}

#Import or make colocalization table
if(GENERATE_NEW_TABLE == T) {
  #Reformats colocalziation so that R can read it
  tryCatch({
    setwd(COLOCALIZATION_SCRIPTS)
    print("Running script ReformattedColocalization.R")
    source("ReformattedColocalization.R", local = T)
  }, error = function(e) {print("Error with ReformattedColocalization.R")})
  
  #Combines analysis table with colocalization table
  tryCatch({
    setwd(COLOCALIZATION_SCRIPTS)
    print("Running script ColocalizationTable.R")
    source("ColocalizationTable.R", local = T)
  }, error = function(e) {print("Error with ColocalizationTable.R")})
} else{
  if(exists("ColocalizationImgs")) {} else {
    setwd(COLOCALIZATION_DIRECTORY)
    filename = "GrandColocalizationComparison"
    ColocalizationImgs <-
      data.table::fread(paste(filename, ".csv.gz", sep = ""), integer64="character")
  }
}

ColocalizationImgs <-
  ColocalizationImgs %>%
  mutate(
    GROUP_ID = paste(GROUP, LIGAND_DENSITY_CAT),
    PROTEIN = factor(PROTEIN, levels = PROTEIN_ORDER),
    GROUP = factor(GROUP, levels = PROTEIN_ORDER)
  ) %>%
  filter(
    IMAGE != "",
    !is.na(TRACK_ID)
  )

#Plot colors
ALL_PROTEIN2 = unique(ColocalizationInput$PROTEIN2)
ALL_PROTEIN2 = factor(ALL_PROTEIN2, levels = PROTEIN_ORDER)
COLOR = brewer.pal(n = NROW(ALL_PROTEIN2), name = "Set2")

ColocalizationGroupsFx <- function(GroupX) {
  tryCatch({
    #Filter data
    {
      GROUP_IDS <-
        ColocalizationInput %>%
        filter(
          GROUPNUMBER == GroupX
        )
      #Variables
      lp.GROUP = unique(GROUP_IDS$GROUP)
      lp.LIGAND_DENSITY_CAT = unique(GROUP_IDS$LIGAND_DENSITY_CAT)
      lp.PROTEIN1 = unique(GROUP_IDS$PROTEIN1)
      lp.PROTEIN2 = unique(GROUP_IDS$PROTEIN2)
      
      GROUP_IDS <- unique(GROUP_IDS$GROUP_ID)
      
      GroupData <-
        ColocalizationImgs %>%
        filter(
          FRAMES_ADJUSTED == 0,
          GROUP_ID %in% GROUP_IDS
        ) %>%
        mutate(
          IMAGENUMBER = group_indices(., LIGAND_DENSITY_CAT, GROUP, IMAGE)
        )
    }
    #Folder
    {
      FOLDER = paste(lp.PROTEIN1, "_", lp.PROTEIN2," ", lp.LIGAND_DENSITY_CAT, sep ="")
      FOLDER = file.path(COLOCALIZATION_DIRECTORY, FOLDER)
      dir.create(FOLDER, showWarnings = FALSE)
      setwd(FOLDER)
    }
    PROTEINS <- unique(GroupData$PROTEIN)
    ProteinFx <- function(ProteinX) {
      tryCatch({
        #Variables
        lp.PROTEIN = PROTEINS[ProteinX]
        lp.OTHERPROTEIN = which(PROTEINS != lp.PROTEIN)
        lp.OTHERPROTEIN = PROTEINS[lp.OTHERPROTEIN]
        PROTEIN_FILL = COLOR[which(ALL_PROTEIN2==lp.PROTEIN2)]
        #Filter protein data
        ProteinData <-
          GroupData %>%
          filter(
            PROTEIN %in% lp.PROTEIN
          )
        #Fluorophore name
        lp.FLUOROPHORE <-
          InputDataImageSummary %>%
          filter(
            GROUP %in% lp.GROUP,
            PROTEIN %in% lp.PROTEIN
          )
        lp.FLUOROPHORE = lp.FLUOROPHORE$FLUOROPHORE[1]
        lp.PROTEIN_FLUOROPHORE = paste(lp.PROTEIN, lp.FLUOROPHORE, sep = "-")
        #Variables
        lp.LIFETIME_THRESHOLD = ProteinData$LIFETIME_THRESHOLD[1]
        lp.MAX_INTENSITY_THRESHOLD = ProteinData$MAX_INTENSITY_THRESHOLD[1]
        
        #Edit data labels
        ProteinData <-
          ProteinData %>%
          mutate(
            LIFETIME_CAT =
              ifelse(
                LIFETIME_CAT == 0,
                paste("<", lp.LIFETIME_THRESHOLD, "s", sep =""),
                paste("≥", lp.LIFETIME_THRESHOLD, "s", sep ="")
              ),
            MAX_INTENSITY_CAT =
              ifelse(
                MAX_INTENSITY_CAT == 0,
                paste("<", lp.MAX_INTENSITY_THRESHOLD, sep =""),
                paste("≥", lp.MAX_INTENSITY_THRESHOLD, sep ="")
              )
          )
        
        #Percent colocalization by lifetime
        #Table
        setwd(COLOCALIZATION_SCRIPTS)
        print("Running script Mean_Colocalization Cat_Lifetime.R")
        source("Mean_Colocalization Cat_Lifetime.R", local = T)
        #Violin plot
        setwd(COLOCALIZATION_SCRIPTS)
        print("Running script Mean_Colocalization Cat_Lifetime Violin.R")
        source("Mean_Colocalization Cat_Lifetime Violin.R", local = T)
        #Violin plot by replicate
        setwd(COLOCALIZATION_SCRIPTS)
        print("Running script Mean_Colocalization Cat_Lifetime By_Replicate Violin.R")
        source("Mean_Colocalization Cat_Lifetime By_Replicate Violin.R", local = T)
        
        #Percent colocalization by lifetime
        #Table
        setwd(COLOCALIZATION_SCRIPTS)
        print("Running script Mean_Colocalization Cat_MaxIntCat.R")
        source("Mean_Colocalization Cat_MaxIntCat.R", local = T)
        #Plot
        setwd(COLOCALIZATION_SCRIPTS)
        print("Running script Mean_Colocalization Cat_MaxIntCat Violin.R")
        source("Mean_Colocalization Cat_MaxIntCat Violin.R", local = T)
        
        #Max Intensity
        setwd(COLOCALIZATION_SCRIPTS)
        print("Running script MaxInt Density.R")
        source("MaxInt Density.R", local = T)
        #Max Intensity by Replicate
        setwd(COLOCALIZATION_SCRIPTS)
        print("Running script MaxInt By_Replictate Density.R")
        source("MaxInt By_Replictate Density.R", local = T)
        
      }, error = function(e) {print(paste("   ERROR with ProteinFx GroupX =", GroupX))})
    }
    nPROTEINS <- 1:NROW(PROTEINS)
    lapply(nPROTEINS, ProteinFx)
    
  }, error = function(e) {print(paste("   ERROR with ColocalizationGroupsFx GroupX =", GroupX))})
}
nGROUPS = unique(ColocalizationInput$GROUPNUMBER)
mclapply(nGROUPS, ColocalizationGroupsFx)

#Wait time
# NEEDS TO BE UPDATED
setwd(COLOCALIZATION_SCRIPTS)
print("Running script UPDATE_ColocalizationWaitTable.R")
source("UPDATE_ColocalizationWaitTable.R", local = T)

#Plot histogram
setwd(COLOCALIZATION_SCRIPTS)
print("Running script WaitTime Histogram.R")
source("WaitTime Histogram.R", local = T)
