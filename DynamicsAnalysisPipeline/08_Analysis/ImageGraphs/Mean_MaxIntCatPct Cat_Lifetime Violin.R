setwd(FOLDER)

PlotCellTracksSummary <- CellTracksSummary %>% filter(CATEGORY != "All")
PlotCellTracksImgSummary <- CellTracksImgSummary %>% filter(CATEGORY != "All")
PlotCellTracksGrandSummary <- CellTracksGrandSummary %>% filter(CATEGORY != "All")

ggplot(
  PlotCellTracksSummary
) +
  geom_violin(
    aes(
      x = CATEGORY,
      y = MEAN*100
    ),
    size = 2,
    fill = "darkgrey",
    color = "darkgrey"
  ) +
  geom_crossbar(
    data = PlotCellTracksGrandSummary,
    aes(
      x = CATEGORY,
      ymin = MEAN*100,
      y = MEAN*100,
      ymax = MEAN*100
    ),
    color = "black",
    width = 0.75
  ) +
  geom_errorbar(
    data = PlotCellTracksGrandSummary,
    aes(
      x = CATEGORY,
      ymin = MEAN*100 - SE*100,
      ymax = MEAN*100 + SE*100,
    ),
    color = "black",
    width = 0.5
  ) +
  geom_jitter(
    data = PlotCellTracksImgSummary,
    aes(
      x = CATEGORY,
      y = MEAN*100,
      group = IMAGE
    ),
    size = 3,
    shape = 21,
    fill = "#377eb8",
    color = "black"
  ) +
  scale_color_brewer(palette = "Set1") +
  scale_fill_brewer(palette = "Set1") +
  scale_y_continuous( 
    limits = c(0,100)
  ) +
  labs(
    y = paste("% ", lp.PROTEIN,"-",lp.FLUOROPHORE, " puncta per cell\n(≥", lp.MAX_INTENSITY_THRESHOLD, "x",lp.FLUOROPHORE , ")", sep = ""),
    x = "Lifetime",
    color = "Replicate",
    shape = "Replicate"
  ) +
  theme_classic() +
  theme(
    legend.position = "none"
  ) +
  ggsave(
    file = paste(lp.PROTEIN, " Mean_MaxIntCatPct Cat_Lifetime Violin ", DATE_TODAY, ".svg", sep = ""),
    width = 4,
    height = 3
  ) +
  ggsave(
    file = paste(lp.PROTEIN, " Mean_MaxIntCatPct Cat_Lifetime Violin ", DATE_TODAY, ".pdf", sep = ""),
    width = 4,
    height = 3
  )