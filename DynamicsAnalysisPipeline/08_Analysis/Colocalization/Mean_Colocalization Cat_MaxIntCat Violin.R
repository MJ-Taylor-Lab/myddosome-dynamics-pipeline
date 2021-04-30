setwd(FOLDER)

mult_format <- function(x) {
  x*100
}

ggplot() +
  geom_violin(
    data = CellTracksSummary,
    aes(
      x = MAX_INTENSITY_CAT,
      y = MEAN
    ),
    color = "darkgrey",
    fill = "darkgrey",
    scale = "width"
  ) +
  geom_jitter(
    data = CellTracksImgSummary,
    aes(
      x = MAX_INTENSITY_CAT,
      y = MEAN
    ),
    fill = PROTEIN_FILL,
    color = "black",
    size = 4,
    shape = 21
  ) +
  geom_crossbar(
    data = CellTracksGrandSummary,
    aes(
      x = MAX_INTENSITY_CAT,
      ymin = MEAN,
      y = MEAN,
      ymax = MEAN
    ),
    width = .75
  ) +
  geom_errorbar(
    data = CellTracksGrandSummary,
    aes(
      x = MAX_INTENSITY_CAT,
      ymin = MEAN - SE,
      ymax = MEAN + SE,
    ),
    width = 0.375
  ) +
  scale_y_continuous( 
    label = mult_format
  ) +
  labs(
    y = paste("% ", lp.OTHERPROTEIN, " +ve\nper cell", sep =""),
    x = paste(lp.PROTEIN_FLUOROPHORE, "Puncta Size")
  ) +
  theme_classic() +
  theme(
    legend.position = "none",
    plot.title = element_text(hjust = 0.5)
  ) +
  ggsave(
    file = paste(lp.PROTEIN, " Mean_Colocalization Cat_MaxInt Violin ", DATE_TODAY,".svg", sep = ""),
    width = 3,
    height = 2
  ) +
  ggsave(
    file = paste(lp.PROTEIN, " Mean_Colocalization Cat_MaxInt Violin ", DATE_TODAY,".pdf", sep = ""),
    width = 3,
    height = 2
  )