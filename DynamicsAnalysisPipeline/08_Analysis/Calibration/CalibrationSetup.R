# For setting up calibrations

print(":::::::::::::::::::: START CALIBRATION SETUP ::::::::::::::::::::")

tryCatch({
  tic()
  
  #Runs calibrations
  LOCAL_DIRECTORY <- getwd()
  setwd(CALIBRATION_SCRIPTS)
  source("CalibrationLoop.r", local = T)
  
  #Generates file merging all usable (i.e., "keep") calibrations
  LOCAL_DIRECTORY <- getwd()
  setwd(CALIBRATION_SCRIPTS)
  source("CalibrationList.r", local = T)
  
  toc()
}, error=function(e) {print("ERROR CalibrationSetup")})

print(":::::::::::::::::::: END CALIBRATION SETUP ::::::::::::::::::::")