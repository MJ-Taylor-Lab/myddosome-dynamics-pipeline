setwd(FOLDER)

#Paginate
TrackPlotFx <- function (PageX) {
  tryCatch({
    
    #Subset data
    TrackData <-
      ExpData %>%
      filter(
        LABEL >= (((PageX-1)*PLOTS_PER_PAGE))+1,
        LABEL < (PageX*PLOTS_PER_PAGE)+1
      )
    
    #Plot
    Plot <-
      ggplot(
        TrackData,
        aes(
          x = FRAMES_ADJUSTED,
          y = NORMALIZED_INTENSITY
        )
      ) +
      geom_line() +
      facet_wrap(
        ~TRACK_ID,
        scales = "free"
      ) +
      labs(
        x = "Dwell Time (s)",
        y = "Intensity (a.u.)"
      ) +
      theme_classic()
    
    Plot
  },
  error = function(e) {print(paste("   ERROR with TrackGraphsCellFx ImageX =", ImageX, " CellX =", CellX))})
}
#Loop
TRACK_COUNT = max(ExpData$LABEL)
nPAGES = 1:ceiling(TRACK_COUNT/PLOTS_PER_PAGE)
Plots <- mclapply(nPAGES, TrackPlotFx)

remove(TRACK_COUNT, nPAGES)

pdf(paste(DATE_TODAY, LP_PROTEIN, "Tracks.pdf"), width = 16/1.5, height = 9/1.5)
print(Plots)
dev.off()

remove(Plots)