setwd(IMAGES_PATH)

# File list ----
# Get
FileNames <-
  list.files(
    full.names = TRUE,
    path = IMAGES_PATH,
    all.files = TRUE,
    include.dirs = FALSE,
    recursive = TRUE
  )

# Make table of list
FileNames <- as_tibble(FileNames)
names(FileNames) <- c("File")

# Get other parameters ----
# like image name and stain
print("Running File Search")
FileNames <-
  FileNames %>%
  mutate(
    Name = basename(File),
    Type = getType(Name)
  ) %>%
  filter(
    Name %in% c("Nucleus.csv", "Cytosol.csv")
  ) %>%
  mutate(
    Region0 = basename(File),
    RegionChar = nchar(Region0)-nchar(Type)-1,
    Region = substrLeft(Region0, RegionChar),
    Image = basename(dirname(File)),
    
    Well = basename(dirname(dirname(dirname(File)))),
    Date = substrLeft(Well, 8),
    
    Marker = basename(dirname(dirname(dirname(dirname(File))))),
    MarkerName = word(Marker, 1),
    Stimulation = word(Marker, 2),
    Stimulation = ifelse(Stimulation=="Stimulated", TRUE, FALSE),
    
    CellLine = basename(dirname(dirname(dirname(dirname(dirname(File)))))),
    CellLineName = word(CellLine, 1),
    CellLineNumber = ifelse(is.na(word(CellLine, 2)),"",word(CellLine, 2)),
    
    Eroded = ifelse(substrLeft(Region, nchar("Eroded"))=="Eroded", TRUE, FALSE)
  ) %>%
  select(-c(
    Name,
    Type,
    Region0,
    RegionChar
  ))

Groups <-
  FileNames %>%
  select(
    Marker,
    CellLine
  ) %>%
  distinct()

# Function ----
GroupsFx <- function(GroupX){
  tryCatch({
    # Group parameters
    GroupMarker <- Groups$Marker[GroupX]
    GroupCellLine <- Groups$CellLine[GroupX]
    print(paste("Group", GroupMarker, GroupCellLine))
    FilteredFileNames <-
      FileNames %>%
      filter(
        Marker == GroupMarker,
        CellLine == GroupCellLine
      )
    
    # Get measurements from all images----
    print("Running MeasurementsFx")
    MeasurementsFx <- function(SetX){
      tryCatch({
        # Get table
        Table <- read.csv(FilteredFileNames$File[SetX])
        Table[1] <- NULL
        
        # Add image info
        Table <- merge(Table, FilteredFileNames[SetX,])
        # Correct file path
        Table <-
          Table %>%
          mutate(
            File = str_remove(File, IMAGES_PATH),
            File = str_remove(File, basename(File)),
            File = paste0(".", File),
            # Add Row ID
            ID = 1:n()
          )
        
        # if(SetX%%(round(NROW(FilteredFileNames)/100))==0){
        #   print(paste("     MeasurementsFx", SetX, "of", NROW(FilteredFileNames), "-", round(SetX/NROW(FilteredFileNames), 2)*100, "% Done"))
        # }
        
        return(Table)
      }, error = function(e){print(paste("     ERROR with SetX =", SetX))})
    }
    nSets <- 1:NROW(FilteredFileNames)
    ImageList <- mclapply(nSets, MeasurementsFx)
    ImageList <- ImageList[(which(sapply(ImageList,is.list), arr.ind=TRUE))]
    ImageList <- do.call(bind_rows, ImageList)
    
    # Find nucleus-cytosol pair----
    print("Running DistanceFx")
    Images <- unique(ImageList$File)
    DistanceFx <- function(ImageX){
      tryCatch({
        #Filter to image
        Table <-
          ImageList %>%
          filter(
            File == Images[ImageX]
          )
        
        #Adapt table for RANN::nn2 analysis
        Nucleus <-
          Table %>%
          filter(
            Region == "Nucleus"
            #Region == "ErodedNucleus"
          ) %>%
          select(
            X,
            Y
          )
        
        Cytosol <-
          Table %>%
          filter(
            #Region == "ErodedCytosol"
            Region == "Cytosol"
          ) %>%
          select(
            X,
            Y
          )
        
        #Find nearest neighbor
        Pair <- as.data.frame(RANN::nn2(Cytosol, Nucleus, k=1))
        names(Pair) <- c("Cytosol_Row", "Distance")
        
        #Index cytosol
        Cytosol <-
          Table %>%
          filter(
            #Region == "ErodedCytosol"
            Region == "Cytosol"
          ) %>%
          mutate(
            Row = 1:n()
          ) %>%
          select(-c(
            names(FilteredFileNames)
          ))
        
        #Rename columns
        names(Cytosol) = paste("Cytosol", names(Cytosol), sep ="_")
        
        #Get nucleus data
        Nucleus <-
          Table %>%
          filter(
            #Region == "ErodedNucleus"
            Region == "Nucleus"
          )
        
        #Merge nucleus and neighbor data
        Nucleus <- bind_cols(Nucleus, Pair)
        
        #Filter duplicate cytosol neighbors
        Nucleus <-
          Nucleus %>%
          arrange(
            Distance
          ) %>%
          group_by(
            Cytosol_Row
          ) %>%
          mutate(
            N = 1:n()
          ) %>%
          filter(
            N == 1
          ) %>%
          select(
            -c(
              N
            )
          )
        
        Table <- merge(Nucleus, Cytosol, by = "Cytosol_Row")
        
        Nucleus <-
          Table %>%
          select(
            X,
            Y
          )
        
        if(NROW(Nucleus)==1){
          Table$NearestNucleus <- IMAGE_PIXELS_WIDTH
        }
        
        if(NROW(Nucleus)>1 & NROW(Nucleus)<5){
          KSIZE = NROW(Nucleus)
          
          NearestNucleus <- as.data.frame(RANN::nn2(Nucleus, k=KSIZE))[2*KSIZE]
          NearestNucleus <- as.numeric(NearestNucleus[,1])
          Table$NearestNucleus <- NearestNucleus
          
        } else{
          KSIZE = 5
          
          NearestNucleus <- as.data.frame(RANN::nn2(Nucleus, k=KSIZE))[2*KSIZE]
          NearestNucleus <- as.numeric(NearestNucleus[,1])
          Table$NearestNucleus <- NearestNucleus
          
        }
        
        Table <-
          Table %>%
          mutate(
            TotalIntensity = Mean*Area,
            CellCount = n(),
            Circularity = Major/Minor,
            
            Cytosol_TotalIntensity = (Cytosol_Area*Cytosol_Mean)-TotalIntensity,
            Cytosol_Area = Cytosol_Area-Area,
            Cytosol_Mean = Cytosol_TotalIntensity/Cytosol_Area,
            Cytosol_Circularity = Cytosol_Major/Cytosol_Minor,
            
            Nucleus2Cytosol_Totals = TotalIntensity/Cytosol_TotalIntensity,
            Nucleus2Cytosol_Means = Mean/Cytosol_Mean,
            Nucleus2Cytosol_Max = Max/Cytosol_Max,
            
            Activation = ifelse(Mean > Cytosol_Mean, TRUE, FALSE),
            Cytosol_Radius = sqrt(Cytosol_Area)/pi,
            Radius = sqrt(Area)/pi,
            Radii_Difference = Cytosol_Radius/Radius,
            
            Combined_TotalIntensity = Cytosol_TotalIntensity + TotalIntensity,
            Combined_Area = Cytosol_Area + Area,
            Combined_Mean = Combined_TotalIntensity/Combined_Area,
          ) %>%
          mutate(
            FilterCell = ifelse(MarkerName == "RelA", Mean + Cytosol_Mean >= 1400, TRUE),
            FilterCell = ifelse(
              FilterCell == T &
              NearestNucleus > 50 &
                
                Min >= 0 &
                Cytosol_Min >= 0 &
                
                Radius > 5.5 &
                Radius < 10 &
                Cytosol_Radius < 15 &
                
                Radii_Difference > 1.1 &
                Radii_Difference < 2.25 &
                
                Circularity < 1.66 &
                Cytosol_Circularity < 2.25 &
                
                Distance < 16 &
                
                X > MIN_BORDER_DISTANCE &
                Y > MIN_BORDER_DISTANCE &
                Cytosol_X > MIN_BORDER_DISTANCE &
                Cytosol_Y > MIN_BORDER_DISTANCE &
                
                X < IMAGE_PIXELS_WIDTH-MIN_BORDER_DISTANCE &
                Y < IMAGE_PIXELS_WIDTH-MIN_BORDER_DISTANCE &
                Cytosol_X < IMAGE_PIXELS_WIDTH-MIN_BORDER_DISTANCE &
                Cytosol_Y < IMAGE_PIXELS_WIDTH-MIN_BORDER_DISTANCE,
              FALSE,
              TRUE
            ),
            FilterCell = ifelse(Max > 0 | Cytosol_Max > 0, FilterCell, TRUE),
            FilterCell = ifelse(TotalIntensity >= 0 & Cytosol_TotalIntensity >= 0, FilterCell, TRUE)
          ) %>%
          group_by(
            FilterCell
          ) %>%
          mutate(
            NewCellID = 1:n(),
          )
        
        Table$NewCellID = ifelse(Table$FilterCell==FALSE, Table$NewCellID, NA)
        
        return(Table)
        
      }, error = function(e) {print(paste("   ERROR with DistanceFx ImageX =", ImageX))})
    }
    Distances <- mclapply(1:NROW(Images), DistanceFx)
    Distances <- Distances[(which(sapply(Distances,is.list), arr.ind=TRUE))]
    Distances <- do.call(bind_rows, Distances)
    remove(ImageList)
    
    #Give wells unique IDs----
    Measurements <-
      Distances %>%
      ungroup() %>%
      mutate(
        CellLine = factor(CellLine, levels = CELL_LINE_ORDER),
        CellLineName = factor(CellLineName, levels = unique(word(CELL_LINE_ORDER, 1))),
        WellNumber = group_indices(., CellLine, Marker, Well)
      ) %>%
      group_by(
        CellLine,
        Marker
      ) %>%
      mutate(
        WellNumber = WellNumber - min(WellNumber) + 1,
        WellNumber = as.factor(WellNumber),
        # Position in well
        ImageID = substrRight(Image, 4),
        ImageID = substrLeft(ImageID, 3),
        ImageID = as.numeric(ImageID),
        Row = ceiling(ImageID/IMAGES_PER_ROW),
        Column = ImageID-((Row-1)*(IMAGES_PER_ROW)),
        Column = ifelse(
          (Row %% 2) == 0,
          Column,
          IMAGES_PER_ROW - Column + 1
        )
      ) %>%
      ungroup()
    
    remove(Distances)
    
    print("Saving table")
    setwd(TABLES_DIRECTORY)
    filename = paste(GroupMarker, GroupCellLine, "Measurements")
    file.remove(paste(filename, ".csv.gz", sep = ""))
    data.table::fwrite(Measurements, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
    
    return(Measurements)
    
  }, error = function(e){print(paste("     ERROR with GroupX =", GroupX))})
}
GroupTables <- lapply(1:NROW(Groups), GroupsFx)
GroupTables <- GroupTables[(which(sapply(GroupTables,is.list), arr.ind=TRUE))]
GroupTables <- do.call(bind_rows, GroupTables)

print("Saving table")
setwd(TABLES_DIRECTORY)
filename = "Measurements"
file.remove(paste(filename, ".csv.gz", sep = ""))
data.table::fwrite(GroupTables, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")

Measurements <- GroupTables
remove(GroupTables)
#Tables paste(Groups$Marker, Groups$CellLine, "Measurements")
