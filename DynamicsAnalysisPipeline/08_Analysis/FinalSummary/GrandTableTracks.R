# For merging all tables containing summarized puncta data
#(only one row per puncta)

setwd(LOCAL_DIRECTORY)

print("Running GrandTracks")

GrandTracks <-
  GrandTable %>%
  #Keep only first frame as reference
  filter(FRAMES_ADJUSTED == 0) %>%
  #Take out spot-specific variables
  select(
    -one_of(c(
      "FRAME",
      "FRAMES_ADJUSTED",
      "TOTAL_INTENSITY",
      "NORMALIZED_INTENSITY",
      "NORMALIZED_INTENSITY_INTEGER",
      "SMOOTH_NORMALIZED_INTENSITY",
      "FRAME_MAX_INTENSITY_CAT",
      "NORMALIZED_INTENSITY_DELTA",
      "SMOOTH_NORMALIZED_INTENSITY_DELTA",
      "SMOOTH_NORMALIZED_INTENSITY_DELTA_CAT",
      "LOCAL_MAXIMA",
      "DELTA_LOCAL_MAXIMA",
      "LOCAL_EXTREMA",
      "EXTREMA_PHASE_TIME",
      "EXTREMA_AMPLITUDE",
      "EXTREMA_PERIOD"
  ))) %>%
  distinct()
#Save tracks
setwd(ANALYSIS_DIRECTORY)
filename = "GrandTableTracks"
file.remove(paste(filename, ".csv.gz", sep = ""))
data.table::fwrite(GrandTracks, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")
