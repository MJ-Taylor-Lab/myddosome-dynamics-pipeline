setwd(FOLDER)

#Filter data
PlotCellTracksSummary <- CellTracksSummary %>% filter(CATEGORY != "All")
PlotCellTracksImgSummary <- CellTracksImgSummary %>% filter(CATEGORY != "All")
PlotCellTracksGrandSummary <- CellTracksGrandSummary %>% filter(CATEGORY != "All")

#Plot
ggplot() +
  geom_crossbar(
    data = PlotCellTracksImgSummary,
    aes(
      x = IMAGENUMBER,
      ymin = MEAN*100,
      y = MEAN*100,
      ymax = MEAN*100
    ),
    color = "black",
    width = 0.75
  ) +
  geom_beeswarm(
    data = PlotCellTracksSummary,
    aes(
      x = IMAGENUMBER,
      y = MEAN*100
    ),
    size = 2,
    shape = 21,
    color = "black",
    fill = "#377eb8",
    cex = 2
  ) +
  facet_grid(
    ~ CATEGORY,
    scales = "free_x"
  ) +
  scale_y_continuous( 
    limits = c(0,100),
  ) +
  labs(
    y = paste("% ", lp.PROTEIN_FLUOROPHORE, " puncta\nper cell (≥", lp.MAX_INTENSITY_THRESHOLD, "x", lp.FLUOROPHORE, ")", sep = ""),
    x = "Replicate",
    color = "Replicate",
    shape = "Replicate"
  ) +
  theme_classic() +
  theme(
    legend.position = "none"
  ) +
  ggsave(
    file = paste(lp.PROTEIN, " Mean_MaxIntCatPct Cat_Lifetime By_Replicate Beeswarm ", DATE_TODAY,".svg", sep = ""),
    width = 5.33,
    height = 2
  ) +
  ggsave(
    file = paste(lp.PROTEIN, " Mean_MaxIntCatPct Cat_Lifetime By_Replicate Beeswarm ", DATE_TODAY,".pdf", sep = ""),
    width = 5.33,
    height = 2
  )