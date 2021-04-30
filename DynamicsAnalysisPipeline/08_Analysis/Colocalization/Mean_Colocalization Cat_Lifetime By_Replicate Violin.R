setwd(FOLDER)

#Supplementary figure
ggplot() +
  geom_violin(
    data = CellTracksSummary,
    aes(
      x = as.factor(IMAGENUMBER),
      y = MEAN
    ),
    color = "darkgrey",
    fill = "darkgrey",
    scale = "width"
  ) +
  geom_jitter(
    data = CellTracksSummary,
    aes(
      x = as.factor(IMAGENUMBER),
      y = MEAN
    ),
    fill = PROTEIN_FILL,
    color = "black",
    size = 2,
    shape = 21
  ) +
  geom_crossbar(
    data = CellTracksImgSummary,
    aes(
      x = as.factor(IMAGENUMBER),
      ymin = MEAN,
      y = MEAN,
      ymax = MEAN
    ),
    width = 0.25
  ) +
  facet_wrap(~LIFETIME_CAT, nrow = 1) +
  scale_y_continuous( 
    labels = mult_format
  ) +
  labs(
    y = paste(Y_AXIS_TITLE, "(% ± S.E.M.)"),
    x = "Replicate",
    shape = "Replicate",
    color = "Replicate"
  ) +
  theme_classic() +
  theme(legend.position = "none",
        axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()
  ) +
  ggsave(
    file = paste(lp.PROTEIN, " Mean_Colocalization Cat_Lifetime By_Replicate Violin ",DATE_TODAY,  ".svg", sep = ""),
    width = 4*(44/62),
    height = 4
  ) +
  ggsave(
    file = paste(lp.PROTEIN, " Mean_Colocalization Cat_Lifetime By_Replicate Violin ",DATE_TODAY,  ".pdf", sep = ""),
    width = 4*(44/62),
    height = 4
  )