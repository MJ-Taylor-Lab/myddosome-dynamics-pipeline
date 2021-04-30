#Iterative histogram data
tryCatch({
  PlotTracks <-
    ExpTracks %>%
    filter(
      FRAME <= (FrameX+1)
    ) %>%
    arrange(
      TRACK_ID,
      FRAMES_ADJUSTED
    ) %>%
    ungroup() %>%
    group_by(
      UNIVERSAL_TRACK_ID,
    ) %>%
    mutate(
      MAX_NORMALIZED_INTENSITY = max(NORMALIZED_INTENSITY, na.rm = T),
      MAX_INTENSITY_CAT =
        ifelse(
          MAX_NORMALIZED_INTENSITY < lp.MAX_INTENSITY_THRESHOLD,
          paste("<", MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE, sep = ""),
          paste("≥", MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE, sep = "")
        ),
      MAX_INTENSITY_CAT = factor(MAX_INTENSITY_CAT, levels = c(MAX_INTENSITY_CAT_ORDER)),
      LIFETIME = max(FRAMES_ADJUSTED, na.rm = T),
      LIFETIME_CAT =
        ifelse(
          LIFETIME < lp.LIFETIME_THRESHOLD,
          paste("<", LIFETIME_THRESHOLD, "s", sep = ""),
          paste("≥", LIFETIME_THRESHOLD, "s", sep = "")
        ),
      LIFETIME_CAT = factor(LIFETIME_CAT, levels = LIFETIME_CAT_ORDER),
      START_TO_MAX_INTENSITY = MAX_NORMALIZED_INTENSITY - STARTING_NORMALIZED_INTENSITY
    ) %>%
    filter(
      FRAMES_ADJUSTED == 0
    )
}, error = function(e){
  PlotTracks <- NULL
})