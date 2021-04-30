#Lifetime intensity summary
{
  LifetimeTable <-
    PlotTracks %>%
    group_by(
      MAX_INTENSITY_CAT,
      LIFETIME_CAT
    ) %>%
    summarize(
      N = n()
    ) %>%
    ungroup() %>%
    group_by(
      LIFETIME_CAT
    ) %>%
    mutate(
      MEAN = N/sum(N),
      MEAN = round(MEAN, 2),
      MEAN = MEAN * 100
    ) %>%
    filter(
      MAX_INTENSITY_CAT == paste("≥", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE, sep = "")
    )
}

#Lifetime plot
{
  N_LIFE = sum(LifetimeTable$N)
  
  SHORT = LifetimeTable%>%filter(LIFETIME_CAT==paste("<", lp.LIFETIME_THRESHOLD, "s", sep = ""))
  #N_DIM = BRIGHT$N
  mu_SHORT = SHORT$MEAN
  
  LONG = LifetimeTable%>%filter(LIFETIME_CAT==paste("≥", lp.LIFETIME_THRESHOLD, "s", sep = ""))
  #N_BRIGHT = BRIGHT$N
  mu_LONG = LONG$MEAN
  
  LIFE_TITLE = paste(
    N_LIFE, " puncta",
    "\n",
    #Short events
    ifelse(
      NROW(SHORT)==0,
      "",
      paste(
        mu_SHORT, "% ",
        paste("<", lp.LIFETIME_THRESHOLD, "s", sep = ""),
        " & ",
        paste("≥", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE, sep = "")
        , sep = "")
    ),
    "\n",
    #Long events
    ifelse(
      NROW(LONG)==0,
      "",
      paste(
        mu_LONG, "% ",
        paste("≥", lp.LIFETIME_THRESHOLD, "s", sep = ""),
        " & ",
        paste("≥", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE, sep = "")
        , sep = "")
    ),
    sep ="")
  
  if(NROW(LifetimeTable)==0){
    
    LifetimePlot <-
      ggplot() +
      geom_bar(
        data = LifetimeTable,
        aes(
          x = LIFETIME_CAT,
          weight = MEAN
        ),
        fill = "#377eb8",
        width = .75,
        alpha = .75
      ) +
      labs(
        y = paste("% ", lp.PROTEIN_FLUOROPHORE, " Puncta (≥", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE, ")", sep=""),
        x = "Lifetime",
        subtitle = LIFE_TITLE
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
  } else {
    LifetimePlot <-
      ggplot() +
      geom_bar(
        data = LifetimeTable,
        aes(
          x = LIFETIME_CAT,
          weight = MEAN
        ),
        fill = "#377eb8",
        width = .75,
        alpha = .75
      ) +
      labs(
        y = paste("% ", lp.PROTEIN_FLUOROPHORE, " Puncta (≥", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE, ")", sep=""),
        x = "Lifetime",
        subtitle = LIFE_TITLE
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