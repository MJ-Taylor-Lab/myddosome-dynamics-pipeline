# For merging tables

print(":::::::::::::::::::: START GRAND SUMMARY LOOP ::::::::::::::::::::")
tic()

#Prepare GrandTableSpots
#A table containing all pucta data
LOCAL_DIRECTORY <- getwd()
setwd(FINALSUMMARY_SCRIPTS)
source("GrandTableSpots.R", local = T)

#Prepare GrandTableTracks
#A table containing summarized puncta data
LOCAL_DIRECTORY <- getwd()
setwd(FINALSUMMARY_SCRIPTS)
source("GrandTableTracks.R", local = T)

#Error table
#For cells that were included in input,
#but that don't have an analysis output
LOCAL_DIRECTORY <- getwd()
setwd(FINALSUMMARY_SCRIPTS)
source("ErrorTable.R", local = T)

print(":::::::::::::::::::: END GRAND SUMMARY LOOP ::::::::::::::::::::")
toc()