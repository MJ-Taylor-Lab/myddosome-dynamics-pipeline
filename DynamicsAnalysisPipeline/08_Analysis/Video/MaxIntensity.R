#Max intensity summary
{
  MaxTable <-
    PlotTracks %>%
    group_by(
      MAX_INTENSITY_CAT
    ) %>%
    summarize(
      N = n()
    ) %>%
    ungroup() %>%
    mutate(
      MEAN = N/sum(N),
      MEAN = round(MEAN, 2),
      MEAN = MEAN * 100
    )
}

#Fluorescent maxima
{
  N_MAX = sum(MaxTable$N)
  
  DIM = MaxTable%>%filter(MAX_INTENSITY_CAT==paste("<", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE, sep = ""),)
  N_DIM = DIM$N
  mu_DIM = DIM$MEAN
  
  BRIGHT = MaxTable%>%filter(MAX_INTENSITY_CAT==paste("≥", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE, sep = ""),)
  N_BRIGHT = BRIGHT$N
  mu_BRIGHT = BRIGHT$MEAN
  
  MAX_TITLE = paste(
    N_MAX, " puncta",
    "\n",
    ifelse(NROW(DIM)==0, "", paste(mu_DIM, "% <", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE, " n= ", N_DIM, sep = "")),
    "\n",
    ifelse(NROW(BRIGHT)==0, "", paste(mu_BRIGHT, "% ≥", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE, " n= ", N_BRIGHT, sep = "")),
    sep ="")
  
  if(NROW(MaxTable)==0){
    MaxCatPlot <-
      ggplot() +
      geom_bar(
        data = MaxTable,
        aes(
          x = MAX_INTENSITY_CAT,
          fill = MAX_INTENSITY_CAT,
          weight = MEAN
        ),
        width = .75,
        alpha = .75
      ) +
      labs(
        y = paste("% ", lp.PROTEIN_FLUOROPHORE, "Puncta", sep = ""),
        x = "Intensity Maxima",
        subtitle = MAX_TITLE
      ) +
      scale_y_continuous(
        limits = c(0, 100),
        expand = c(0,0)
      ) +
      scale_fill_manual(
        values = ColorScale,
        drop = FALSE
      ) +
      theme_classic(
        base_size = 14
      ) +
      theme(
        legend.position = "none"
      )
  } else{
    MaxCatPlot <-
      ggplot() +
      geom_bar(
        data = MaxTable,
        aes(
          x = MAX_INTENSITY_CAT,
          fill = MAX_INTENSITY_CAT,
          weight = MEAN
        ),
        width = .75,
        alpha = .75
      ) +
      labs(
        y = paste("% ", lp.PROTEIN_FLUOROPHORE, "Puncta", sep = ""),
        x = "Intensity Maxima",
        subtitle = MAX_TITLE
      ) +
      scale_x_discrete(
        drop = FALSE
      ) +
      scale_y_continuous(
        limits = c(0, 100),
        expand = c(0,0)
      ) +
      scale_fill_manual(
        values = ColorScale,
        drop = FALSE
      ) +
      theme_classic(
        base_size = 14
      ) +
      theme(
        legend.position = "none"
      )
  }
  
}