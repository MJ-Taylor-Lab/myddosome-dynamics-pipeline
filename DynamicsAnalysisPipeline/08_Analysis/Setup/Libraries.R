print(":::::::::::::::::::: START LIBRARIES ::::::::::::::::::::")

tryCatch({
  # For loading and installing required libraries
  
  if("data.table" %in% rownames(installed.packages()) == FALSE)
  {install.packages("data.table")}
  library(data.table)
  
  if("tidyverse" %in% rownames(installed.packages()) == FALSE)
  {install.packages("tidyverse")}
  library(tidyverse)
  
  if("zoo" %in% rownames(installed.packages()) == FALSE)
  {install.packages("zoo")}
  library(zoo)
  
  if("stats" %in% rownames(installed.packages()) == FALSE)
  {install.packages("stats")}
  library(stats)
  
  if("gridExtra" %in% rownames(installed.packages()) == FALSE)
  {install.packages("gridExtra")}
  library(gridExtra)
  
  if("hexbin" %in% rownames(installed.packages()) == FALSE)
  {install.packages("hexbin")}
  library(hexbin)
  
  if("ggplot2" %in% rownames(installed.packages()) == FALSE)
  {install.packages("ggplot2")}
  library(ggplot2)
  
  if("RColorBrewer" %in% rownames(installed.packages()) == FALSE)
  {install.packages("RColorBrewer")}
  library(RColorBrewer)
  
  if("ggdark" %in% rownames(installed.packages()) == FALSE)
  {install.packages("ggdark")}
  library(ggdark)
  
  if("PerformanceAnalytics" %in% rownames(installed.packages()) == FALSE)
  {install.packages("PerformanceAnalytics")}
  library(PerformanceAnalytics)
  
  if("ggpmisc" %in% rownames(installed.packages()) == FALSE)
  {install.packages("ggpmisc")}
  library(ggpmisc)
  
  if("parallel" %in% rownames(installed.packages()) == FALSE)
  {install.packages("parallel")}
  library(parallel)
  
  if("rlist" %in% rownames(installed.packages()) == FALSE)
  {install.packages("rlist")}
  library(rlist)
  
  if("tictoc" %in% rownames(installed.packages()) == FALSE)
  {install.packages("tictoc")}
  library(tictoc)
  
  if("openxlsx" %in% rownames(installed.packages()) == FALSE)
  {install.packages("openxlsx")}
  library(openxlsx)
  
  if("svglite" %in% rownames(installed.packages()) == FALSE)
  {install.packages("svglite")}
  library(svglite)
  
  if("R.utils" %in% rownames(installed.packages()) == FALSE)
  {install.packages("R.utils")}
  library(R.utils)
  
  if("scales" %in% rownames(installed.packages()) == FALSE)
  {install.packages("scales")}
  library(scales)
  
  if("viridis" %in% rownames(installed.packages()) == FALSE)
  {install.packages("viridis")}
  library(viridis)
  
  if("ggnewscale" %in% rownames(installed.packages()) == FALSE)
  {install.packages("ggnewscale")}
  library(ggnewscale)
  
  if("meanShiftR" %in% rownames(installed.packages()) == FALSE)
  {install.packages("meanShiftR")}
  library(meanShiftR)
  
  if("ggpubr" %in% rownames(installed.packages()) == FALSE)
  {install.packages("ggpubr")}
  library(ggpubr)
  
  if("ggforce" %in% rownames(installed.packages()) == FALSE)
  {install.packages("ggforce")}
  library(ggforce)
  
  if("RANN" %in% rownames(installed.packages()) == FALSE)
  {install.packages("RANN")}
  library(RANN)
  
  if("ggbeeswarm" %in% rownames(installed.packages()) == FALSE)
  {install.packages("ggbeeswarm")}
  library(ggbeeswarm)
  
  
  if("ggpubr" %in% rownames(installed.packages()) == FALSE)
  {install.packages("ggpubr")}
  library(ggpubr)
  
  if("changepoint" %in% rownames(installed.packages()) == FALSE)
  {install.packages("changepoint")}
  library(changepoint)
  
  #Don't load these libraries to prevent conflict of name functions
  #This is only to ensure that packages are installed
  #Call signal using signal::fx
  if("signal" %in% rownames(installed.packages()) == FALSE)
  {install.packages("signal")}
  
  if("raster" %in% rownames(installed.packages()) == FALSE)
  {install.packages("raster")}
  
  if("av" %in% rownames(installed.packages()) == FALSE)
  {install.packages("av")}
  
  if("cowplot" %in% rownames(installed.packages()) == FALSE)
  {install.packages("cowplot")}
  
  if("rgdal" %in% rownames(installed.packages()) == FALSE)
  {install.packages("rgdal")}
  
}, error=function(e) {print("ERROR Libraries")})

print(":::::::::::::::::::: END LIBRARIES ::::::::::::::::::::")