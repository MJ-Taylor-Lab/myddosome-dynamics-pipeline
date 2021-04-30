setwd(FOLDER)

ggplot(
  GroupTracks %>% filter(STARTING_NORMALIZED_INTENSITY_CAT == 0)
) +
  geom_histogram(
    aes(
      x = LIFETIME,
      y = ..count..,
      fill = as.factor(MAX_INTENSITY_CAT),
    ),
    position = "dodge",
    binwidth = 50
  ) +
  scale_y_continuous(
    trans = "log1p",
    expand = c(0, 0),
    breaks = c(1, 10, 100, 1000, 10000, 100000)
  ) +
  scale_x_continuous(
    expand = c(0, 0),
    limits = c(0, max(GroupTracks$LIFETIME))
  ) +
  labs(
    x = "Lifetime (s)",
    y = paste("#", lp.PROTEIN_FLUOROPHORE, "Puncta (Log Scale)")
  ) +
  scale_fill_brewer(
    palette = "Set1",
    name = paste(lp.PROTEIN_FLUOROPHORE, "puncta\nIntensity Maxima:", sep = ""),
    labels = c(
      paste("<", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE),
      paste("≥", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE)
    )) +
  scale_color_brewer(
    palette = "Set1",
    name = paste(lp.PROTEIN_FLUOROPHORE, "puncta\nIntensity Maxima:", sep = ""),
    labels = c(
      paste("<", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE),
      paste("≥", lp.MAX_INTENSITY_THRESHOLD, "x ", lp.FLUOROPHORE)
    )) +
  facet_wrap(
    GROUP ~ MAX_INTENSITY_CAT,
    scales = "free",
    ncol = 2
  ) +
  theme_classic() +
  theme(
    legend.position = "none",
    legend.background = element_blank(),
    strip.background = element_blank(),
    strip.text.x = element_blank()
  ) + 
  ggsave(
    file= paste("Lifetime Histogram ", DATE_TODAY, ".pdf", sep=""),
    width = 6,
    height = 3
  ) +
  ggsave(
    file= paste("Lifetime Histogram ", DATE_TODAY, ".svg", sep=""),
    width = 6,
    height = 3
  )
  