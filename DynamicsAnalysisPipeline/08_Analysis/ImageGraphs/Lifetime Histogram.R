setwd(FOLDER)

#Lifetime graph
ggplot(
  ImgTracks
) +
  geom_histogram(
    data = ImgTracks,
    aes(
      x = LIFETIME,
      y = ..count..,
      fill = as.factor(MAX_INTENSITY_CAT),
    ),
    position = "dodge",
    binwidth = 25,
    alpha = 0.75
  ) +
  geom_vline(
    xintercept = 50,
    linetype = "dashed"
  ) +
  scale_y_continuous(
    trans = "log1p",
    expand = c(0, 0),
    breaks = c(0, 10^(0:10))) +
  scale_x_continuous(
    expand = c(0, 0)
    #breaks = c(0, 50, seq(0, max(ImgTracks$LIFETIME), by = signif(max(ImgTracks$LIFETIME)/8,1))
  ) +
  labs(
    x = "Lifetime (s)",
    y = paste(lp.PROTEIN, " (Count + 1)")) +
  theme_classic() +
  scale_fill_brewer(
    palette = "Set1",
    name = "Maximum Size",
    labels = c(
      paste("<", lp.MAX_INTENSITY_THRESHOLD, "x " , lp.PROTEIN, sep = ""),
      paste("≥", lp.MAX_INTENSITY_THRESHOLD, "x " , lp.PROTEIN, sep = "")
    )) +
  theme(
    legend.position = c(.8, .8),
    legend.background = element_blank()
  ) +
  ggsave(
    file= paste(lp.PROTEIN, " Lifetime Histogram", DATE_TODAY, ".pdf", sep = ""),
    width = 3*1.45,
    height = 3) +
  ggsave(
    file = paste(lp.PROTEIN, " Lifetime Histogram", DATE_TODAY, ".svg", sep = ""),
    width = 3*1.45,
    height = 3)