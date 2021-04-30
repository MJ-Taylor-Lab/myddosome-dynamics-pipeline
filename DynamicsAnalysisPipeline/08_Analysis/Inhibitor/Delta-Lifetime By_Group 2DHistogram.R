setwd(FOLDER)

PlotImgTracks <-
  GroupTracks %>% filter(
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
  stat_cor(
    aes(label = ..r.label..),
    method = "spearman",
    label.x = 2000,
    label.y = 0
  ) +
  geom_hex(
    aes(
      x = LIFETIME,
      y = START_TO_MAX_INTENSITY,
      fill = ..count..
    ),
    color = "black",
    size = .1,
    bins = 25
  ) +
  stat_smooth(method=lm) +
  scale_fill_distiller(
    palette = "RdPu",
    direction = 1,
    trans = "log",
    breaks = trans_breaks("log10", function(x) 10^x),
    labels = trans_format("log10", math_format(10^.x))
  ) +
  scale_x_continuous(
    limits = c(0,max(PlotImgTracks$LIFETIME))
  ) +
  scale_y_continuous(
    limits = c(0,50)
  ) +
  facet_wrap(
    ~GROUP,
    nrow = 1,
    scales = "free"
  ) +
  labs(
    y = "Norm. ∆Intensity",
    x = "Lifetime (s)",
    fill = paste("#", lp.PROTEIN_FLUOROPHORE, "Puncta\n(Log Scale)")
  ) +
  theme_classic() +
  theme(
    legend.background = element_blank(),
    legend.position = "bottom",
    strip.background = element_blank()
  ) +
  ggsave(
    file = paste(lp.PROTEIN," Delta-Lifetime 2DHistogram ", DATE_TODAY, ".pdf", sep = ""),
    width = 2.85*NROW(GROUP_LIST),
    height = 2.85*1.3
  ) +
  ggsave(
    file = paste(lp.PROTEIN," Delta-Lifetime 2DHistogram ", DATE_TODAY, ".svg", sep = ""),
    width = 2.85*NROW(GROUP_LIST),
    height = 2.85*1.3
  )
