# For drawing a density plot of signal intensity

tryCatch({
  #Set working directory to image folder
  setwd(LOCAL_DIRECTORY)
  
  #Compute density plot for the adjusted total intensity of the calibration
  CalibrationDensity <-
    density(CalData$TOTAL_INTENSITY_ADJUSTED)
  
  #For plotting signal intensity
  pdf(
    paste(DATE_TODAY, "_", PROTEIN, "_CalibrationDensityPlot", SOURCE,".pdf", sep = ""),
    width = 8,
    height = 4.5
  )
  plot(CalibrationDensity)
  dev.off()
  
}, error=function(e) {print(paste("ERROR CalibrationDensityPlot. CalibrationImageX =", CalibrationImageX))})