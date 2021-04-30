setwd(FOLDER)

ggplot(
  CellTracksSummary
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
    data = CellTracksGrandSummary,
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
    data = CellTracksGrandSummary,
    aes(
      x = CATEGORY,
      ymin = MEAN*100 - SE*100,
      ymax = MEAN*100 + SE*100,
    ),
    color = "black",
    width = 0.5
  ) +
  geom_jitter(
    data = CellTracksImgSummary %>% filter(MAX_INT_CAT == 0),
    aes(
      x = CATEGORY,
      y = MEAN*100,
      group = IMAGE
    ),
    size = 3,
    shape = 21,
    fill = "#e41a1c",
    color = "black"
  ) +
  geom_jitter(
    data = CellTracksImgSummary %>% filter(MAX_INT_CAT == 1),
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
    limits = c(0, 100)
  ) +
  labs(
    y = paste("%  ", lp.PROTEIN_FLUOROPHORE, " tracks per cell", sep = ""),
    x = "Fluorescence Intensity Maxima",
    color = "Replicate",
    shape = "Replicate"
  ) +
  theme_classic() +
  theme(
    legend.position = "none"
  ) +
  ggsave(
    file = paste(lp.PROTEIN, " Mean_MaxIntCatPct Cat_MaxIntCat Violin ", DATE_TODAY, ".svg", sep = ""),
    width = 4,
    height = 3
  ) +
  ggsave(
    file = paste(lp.PROTEIN, " Mean_MaxIntCatPct Cat_MaxIntCat Violin ", DATE_TODAY, ".pdf", sep = ""),
    width = 4,
    height = 3
  )