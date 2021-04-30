#Change intensity table
{
  ChangeIntensityTable <-
    PlotTracks %>% filter(
      STARTING_NORMALIZED_INTENSITY_CAT == 0
    )
  
  N_DELTA = NROW(ChangeIntensityTable)
  CORRELATION =
    cor(
      ChangeIntensityTable$START_TO_MAX_INTENSITY,
      ChangeIntensityTable$LIFETIME,
      method = c("spearman")
    )
  CORRELATION = round(CORRELATION, 2)
  
  DELTA_TITLE = paste(
    N_DELTA,
    " ",
    lp.PROTEIN,
    "-",
    lp.FLUOROPHORE,
    " puncta (start <",
    lp.STARTING_INTENSITY_THESHOLD,
    "x ",
    lp.FLUOROPHORE,
    ")\n",
    ifelse(is.na(CORRELATION), "", paste("R = ", CORRELATION, sep = "")),
    sep ="")
  
  ChangeIntensityPlot <-
    ggplot(
      ChangeIntensityTable,
      aes(
        x = LIFETIME,
        y = START_TO_MAX_INTENSITY
      )
    ) +
    geom_hex(
      aes(
        x = LIFETIME,
        y = START_TO_MAX_INTENSITY,
        fill = ..count..
      ),
      color = "black",
      bins = 10
    ) +
    stat_smooth(
      method = lm
    ) +
    scale_fill_distiller(
      palette = "RdPu",
      direction = 1,
      trans = "log",
      labels = number_format(
        accuracy = 1,
        big.mark = " "
      )
    ) +
    labs(
      y = "Norm. ∆Intensity",
      x = "Lifetime (s)",
      fill = paste("# ", lp.PROTEIN_FLUOROPHORE, "\npuncta (log scale)", sep =""),
      subtitle = DELTA_TITLE
    ) +
    theme_classic(
      base_size = 14
    ) +
    theme(
      legend.background = element_rect(fill=alpha('white', 0.5)),
      legend.position = c(0.2, 0.75),
    )
}