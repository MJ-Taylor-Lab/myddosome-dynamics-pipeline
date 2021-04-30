setwd(FOLDER)

mult_format <- function(x) {
  x*100
}

Y_AXIS_TITLE = paste(lp.OTHERPROTEIN, "Positive", lp.PROTEIN)

ggplot() +
  geom_violin(
    data = CellTracksSummary,
    aes(
      x = LIFETIME_CAT,
      y = MEAN
    ),
    color = "darkgrey",
    fill = "darkgrey",
    scale = "width"
  ) +
  geom_jitter(
    data = CellTracksImgSummary,
    aes(
      x = LIFETIME_CAT,
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
      x = LIFETIME_CAT,
      ymin = MEAN,
      y = MEAN,
      ymax = MEAN
    ),
    width = .75
  ) +
  geom_errorbar(
    data = CellTracksGrandSummary,
    aes(
      x = LIFETIME_CAT,
      ymin = MEAN - SE,
      ymax = MEAN + SE,
    ),
    width = 0.375
  ) +
  scale_y_continuous( 
    label = mult_format
  ) +
  labs(
    y = paste(Y_AXIS_TITLE, "(% ± S.E.M.)"),
    x = paste(lp.PROTEIN, "Puncta Lifetime"),
    title = paste(lp.PROTEIN, "Colocalized\nw/", lp.OTHERPROTEIN)
  ) +
  theme_classic() +
  theme(
    legend.position = "none",
    plot.title = element_text(hjust = 0.5)
  ) +
  ggsave(
    file = paste(lp.PROTEIN, " Mean_Colocalization Cat_Lifetime Violin ", DATE_TODAY,".svg", sep = ""),
    width = 4*(44/62),
    height = 4
  ) +
  ggsave(
    file = paste(lp.PROTEIN, " Mean_Colocalization Cat_Lifetime Violin ", DATE_TODAY,".pdf", sep = ""),
    width = 4*(44/62),
    height = 4
  )