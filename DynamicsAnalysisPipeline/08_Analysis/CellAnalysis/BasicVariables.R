# For analyzing cell spots
setwd(LOCAL_DIRECTORY)

tryCatch({
  # Calculate when first spot appears in cell
  ExpDataLand <-
    ExpData %>%
    filter(FRAMES_ADJUSTED == 0) %>%
    select(FRAME)
  # Landing frame
  LANDED <-
    as.numeric(
      min(
        ExpDataLand$FRAME
      )
    )
  # Get image name
  IMAGES = lp.IMAGE
  # Get image area
  lp.AREA <-
    InputData %>%
    filter(
      IMAGE == IMAGES,
      CELL == CellX
    ) %>%
    ungroup () %>%
    select(AREA) %>%
    distinct()
  lp.AREA <- as.numeric(lp.AREA)
  # Remove temporary variables
  remove(IMAGES)
  remove(ExpDataLand)
  
  # Begin analysis computations
  ExpData <-
    ExpData %>%
    # Remove frames before cell lands
    filter(
      FRAMES_ADJUSTED >= 0
    ) %>%
    # Sort by track
    group_by(TRACK_ID) %>%
    # Remove tracks at border
    mutate(
      FRAME_LAND = FRAME - LANDED,
      FPS = lp.FPS,
      FRAME_LAND = FRAME_LAND/FPS#,
      # # Include commented lines to eliminate tracks that touch the image edge
      #   MIN_POSITION_X = min(POSITION_X),
      #   MAX_POSITION_X = max(POSITION_X),
      #   MIN_POSITION_Y = min(POSITION_Y),
      #   MAX_POSITION_Y = max(POSITION_Y),
    ) %>%
      # filter(
      #   MIN_POSITION_X > (PIXEL_SIZE*5),
      #   MIN_POSITION_Y > (PIXEL_SIZE*5),
      #   MAX_POSITION_X < (IMAGE_SIZE-PIXEL_SIZE*5),
      #   MAX_POSITION_Y < (IMAGE_SIZE-PIXEL_SIZE*5)
      # ) %>%
      # select(-c(
      #   MIN_POSITION_X,
      #   MIN_POSITION_Y,
      #   MAX_POSITION_X,
      #   MAX_POSITION_Y
      # )) %>%
      # Paste input Data into table
    mutate(
      # Determines lifetime of track
      LIFETIME = max(FRAMES_ADJUSTED, na.rm = T),
      LIFETIME = LIFETIME/FPS,
      TOTAL_FRAMES = n(),
      # Determine if track was present before imaging
      FRAME_1_CAT = ifelse(min(FRAME) == 1, 1, 0)
    ) %>%
    filter(
      # Remove tracks appearing on first frame
      FRAME_1_CAT == 0,
      # Keep only tracks with 3 or more frames
      LIFETIME >= (2/FPS)
    ) %>%
    # Discard first frame sorting variable
    select(-c(FRAME_1_CAT)) %>%
    # Saves image local variables into the table
    mutate(
      LIGAND_DENSITY =  lp.LIGAND_DENSITY,
      LIGAND_DENSITY_CAT = lp.LIGAND_DENSITY_CAT,
      PROTEIN = lp.PROTEIN,
      GROUP = lp.GROUP,
      COHORT = lp.COHORT,
      IMAGE = lp.IMAGE,
      CELL = CellX,
      AREA = lp.AREA,
      FLUOROPHORE = lp.FLUOROPHORE,
      ASSEMBLED_COMPLEX_SIZE = lp.ASSEMBLED_COMPLEX_SIZE,
      MAX_INTENSITY_THRESHOLD = lp.MAX_INTENSITY_THRESHOLD,
      LIFETIME_THRESHOLD = lp.LIFETIME_THRESHOLD,
      STARTING_INTENSITY_THESHOLD = lp.STARTING_INTENSITY_THESHOLD,
      PROTEIN_INTENSITY = lp.PROTEIN_INTENSITY,
      PROTEIN_BACKGROUND = lp.PROTEIN_BACKGROUND,
      # Intensity normalized to single molecule as per the calibration
      NORMALIZED_INTENSITY =
        # To ensure no negative total intensities
        ifelse(
          (TOTAL_INTENSITY - PROTEIN_BACKGROUND) <= 0,
          0,
          (TOTAL_INTENSITY - PROTEIN_BACKGROUND) / (PROTEIN_INTENSITY)
        )
    ) %>%
    # Universal track ID
    mutate(
      UNIVERSAL_TRACK_ID =
        paste(
          IMAGE,
          CELL,
          PROTEIN,
          TRACK_ID,
          sep = "..."),
      # Max total intensity of track
      MAX_NORMALIZED_INTENSITY = max(NORMALIZED_INTENSITY, na.rm = T),
      # Intensity without background removal
      MAX_TOTAL_INTENSITY_WO_BACKGROUND = (MAX_NORMALIZED_INTENSITY * PROTEIN_INTENSITY) + PROTEIN_BACKGROUND,
      # To be used later for overall delta and for categorizing de-novo and disassembling
      STARTING_NORMALIZED_INTENSITY = sum(case_when(FRAMES_ADJUSTED == 0 ~ NORMALIZED_INTENSITY), na.rm = T),
      # Ending intensity
      ENDING_NORMALIZED_INTENSITY = sum(case_when(FRAMES_ADJUSTED/FPS == LIFETIME - 1 ~ NORMALIZED_INTENSITY), na.rm = T),
    ) %>%
    mutate(
      # For sorting assembled and abortives
      MAX_INTENSITY_CAT = ifelse(MAX_NORMALIZED_INTENSITY >= MAX_INTENSITY_THRESHOLD, 1, 0),
      # Overall change in intensity from start to max
      START_TO_MAX_INTENSITY = as.numeric(MAX_NORMALIZED_INTENSITY) - as.numeric(STARTING_NORMALIZED_INTENSITY),
      # Separates short from long lived tracks
      LIFETIME_CAT = ifelse(LIFETIME >= LIFETIME_THRESHOLD, 1, 0),
      # Whole number for start intensity of track
      STARTING_NORMALIZED_INTENSITY_INTEGER = round(STARTING_NORMALIZED_INTENSITY),
      # Separates de-novo and disassembling processes based on the intensity of the starting frame
      STARTING_NORMALIZED_INTENSITY_CAT = ifelse(STARTING_NORMALIZED_INTENSITY >= STARTING_INTENSITY_THESHOLD, 1, 0),
      # For pointing out which frame contains the max intensity
      MAX_INTENSITY_FRAME = ifelse(MAX_NORMALIZED_INTENSITY == NORMALIZED_INTENSITY, FRAME, NA),
      # Get first frame to reach track max intensity in case of duplicates
      MAX_INTENSITY_FRAME = min(MAX_INTENSITY_FRAME, na.rm = T),
      # Combined puncta categories
      CATS_COMBINED = paste(
        MAX_INTENSITY_CAT,
        LIFETIME_CAT,
        STARTING_NORMALIZED_INTENSITY_CAT,
        sep = ""
      ),
      CATS_COMBINED = as.integer(CATS_COMBINED),
      # # Label will be used for sorting tracks in plot
      # LABEL = 
      #   paste(
      #     replace_na(
      #       formatC(
      #         # Sort tracks in plot grid based on overall change in intensity
      #         round(
      #           as.numeric(
      #             START_TO_MAX_INTENSITY),
      #           # Round to four digits
      #           digits = 4),
      #         # For equal length for all track names, filling rest with 0s
      #         width = 8,
      #         format = "f",
      #         flag = "0"
      #       ),
      #       ""),
      #     # Adds Track ID to the label
      #     " (ID ",
      #     TRACK_ID,
      #     ")",
      #     sep = ""),
      # Unique spot ID
      UNIVERSAL_SPOT_ID = paste(UNIVERSAL_TRACK_ID, FRAME, sep = "...")
    )
  # Saves analysis table
  setwd(file.path(lp.FOLDER, paste("Cell_", CellX, sep ="")))
  filename = paste(lp.PROTEIN, "BasicAnalysis", sep ="_")
  file.remove(paste(filename, ".csv.gz", sep = ""))
  data.table::fwrite(ExpData, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
  ExpData
},
error=function(e) print(paste("   ERROR with BasicVariables ImageX =", ImageX, "CellX =", CellX)))
