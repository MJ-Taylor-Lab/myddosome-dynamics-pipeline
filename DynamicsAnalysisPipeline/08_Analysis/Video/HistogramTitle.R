#Histogram Title
{
  SPOTS = NROW(PlotTracks)
  N_SPOTS = str_pad(SPOTS, 3, pad = "0")
  
  ABORTIVES <-
    NROW(
      PlotTracks%>%
        filter(
          MAX_INTENSITY_CAT == paste("<", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE, sep = "")
        )
      )
  N_ABORTIVES = str_pad(ABORTIVES, 3, pad = "0")
  
  ABORTIVES_LIFETIME <-
    PlotTracks%>%
    filter(
      MAX_INTENSITY_CAT == paste("<", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE,  sep = "")) %>%
    ungroup()%>%
    summarize(
      LIFETIME = mean(LIFETIME, na.rm = T),
      LIFETIME = round(LIFETIME),
      LIFETIME = str_pad(LIFETIME, 3, pad = "0")
    )
  
  ASSEMBLED = SPOTS - ABORTIVES
  N_ASSEMBLED = str_pad(ASSEMBLED, 3, pad = "0")
  
  ASSEMBLED_LIFETIME <-
    PlotTracks%>%
    filter(MAX_INTENSITY_CAT == paste("≥", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE,  sep = "")) %>%
    ungroup()%>%
    summarize(
      LIFETIME = mean(LIFETIME, na.rm = T),
      LIFETIME = round(LIFETIME),
      LIFETIME = str_pad(LIFETIME, 3, pad = "0")
    )
  
  HISTOGRAM_TITLE <-
    paste(
      ifelse(
        SPOTS==0,
        paste(SPOTS, lp.PROTEIN_FLUOROPHORE, "Puncta"),
        paste(SPOTS, " ", lp.PROTEIN_FLUOROPHORE, " Puncta (", round(ASSEMBLED/SPOTS, 2)*100, "% ≥",lp.MAX_INTENSITY_THRESHOLD,"x ", lp.FLUOROPHORE,")", sep = "")
      ),
      "\n",
      ifelse(
        N_ABORTIVES == "000",
        "",
        paste("<", lp.MAX_INTENSITY_THRESHOLD, "x ",lp.FLUOROPHORE, ": ", N_ABORTIVES, " Puncta, ", ABORTIVES_LIFETIME, "s Average Lifetime", sep = "")
        
      ),
      "\n",
      ifelse(
        N_ASSEMBLED == "000",
        "",
        paste("≥", lp.MAX_INTENSITY_THRESHOLD,"x ", lp.FLUOROPHORE, ": ", N_ASSEMBLED, " Puncta, ", ASSEMBLED_LIFETIME, "s Average Lifetime", sep ="")
        
      ),
      sep = ""
    )
}