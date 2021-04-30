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
      x = (IMAGENUMBER),
      y = MEAN*100,
      group = IMAGENUMBER,
      fill = CATEGORY
    ),
    size = 2,
    shape = 21,
    color = "black",
    cex = 2
  ) +
  facet_grid(
    ~CATEGORY,
    scales = "free_x"
  ) +
  scale_y_continuous( 
    limits = c(0,100),
  ) +
  labs(
    y = "Share of Events\n(% Cell Mean ± S.E.M.)",
    x = "Replicate",
    color = paste(lp.PROTEIN_FLUOROPHORE, " Puncta Intensity Maxima", sep = ""),
    fill = paste(lp.PROTEIN_FLUOROPHORE, " Puncta Intensity Maxima", sep = "")
  ) +
  scale_fill_brewer(palette = "Set1") +
  theme_classic() +
  theme(
    legend.position = "bottom",
    strip.background = element_blank(),
    strip.text.x = element_blank()
  ) +
  ggsave(
    file = paste(lp.PROTEIN, " Mean_MaxIntCatPct Cat_MaxIntCat Beehive ", DATE_TODAY, ".svg", sep = ""),
    width = 5.33,
    height = 2
  ) +
  ggsave(
    file = paste(lp.PROTEIN, " Mean_MaxIntCatPct Cat_MaxIntCat Beehive ", DATE_TODAY, ".pdf", sep = ""),
    width = 5.33,
    height = 2
  )

remove(PlotCellTracksSummary, PlotCellTracksImgSummary, PlotCellTracksGrandSummary)