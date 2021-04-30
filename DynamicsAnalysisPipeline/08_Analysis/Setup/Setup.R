print(":::::::::::::::::::: START SETUP ::::::::::::::::::::")

#For setting up environment
tryCatch({
  #Get today's date
  DATE_TODAY = Sys.Date()
  #Number of Categories
  CATEGORIES = PROTEINS_IMAGED
  #BENCHMARK TIMER
  START_TIME = Sys.time()
  #Reformat directories
  SETUP_DIRECTORY = file.path(TOP_DIRECTORY, SETUP_FOLDER)
  ANALYSIS_DIRECTORY = file.path(TOP_DIRECTORY, ANALYSIS_FOLDER)
  
  #Loads libraries
  setwd(SETUP_SCRIPTS)
  source("Libraries.R", local = T)
  
  #Loads custom functions
  setwd(SETUP_SCRIPTS)
  source("CustomFx.R", local = T)
  
  #Loads input table (tells which images to analyze)
  setwd(SETUP_SCRIPTS)
  source("InputData.R", local = T)
  
  #Feedback message
}, error=function(e) {print("ERROR Setup")})
print(":::::::::::::::::::: END SETUP ::::::::::::::::::::")
