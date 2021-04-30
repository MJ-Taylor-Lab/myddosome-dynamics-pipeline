setwd(FOLDER)

PlotImgTracks <-
  ImgTracks %>% filter(
    STARTING_NORMALIZED_INTENSITY_CAT == 0
  )

#2-D Histogram of Change in Intensity by Lifetime
ggplot(
  PlotImgTracks,
  aes(
    x = LIFETIME,
    y = START_TO_MAX_INTENSITY
  )
) +
  stat_cor(method = "spearman")+
  geom_hex(
    aes(
      x = LIFETIME,
      y = START_TO_MAX_INTENSITY,
      fill = ..count..
    ),
    color = "black",
    bins = 10
  ) +
  stat_smooth(method=lm) +
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
    y = "Change in Intensity (a.u.)",
    x = "Lifetime (s)",
    fill = "Particle Count\n(log scale)") +
  theme_classic()+
  theme(
    legend.background = element_blank(),
    legend.key.width = unit(1, "line"),
    legend.position = c(0.88, 0.7)
  ) +
  ggsave(
    file = paste(lp.PROTEIN," Delta-Lifetime 2DHistogram ", DATE_TODAY, ".svg", sep = ""),
    width = 3*1.45,
    height = 3
  ) +
  ggsave(
    file = paste(lp.PROTEIN," Delta-Lifetime 2DHistogram ", DATE_TODAY, ".png", sep = ""),
    width = 3*1.45,
    height = 3
  )