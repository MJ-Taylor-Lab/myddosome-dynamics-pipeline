{
  Histogram <-
    ggplot() +
    geom_histogram(
      data = PlotTracks,
      aes(
        x = as.numeric(LIFETIME),
        y = ..count..,
        fill = MAX_INTENSITY_CAT,
      ),
      position = "dodge",
      binwidth = 25,
      alpha = 0.75
    ) +
    scale_y_continuous(
      trans = "log1p",
      expand = c(0, 0),
      breaks = c(0, 1, 10, 100, 1000)) +
    scale_x_continuous(
      expand = c(0, 0)
    ) +
    scale_fill_manual(
      values = ColorScale,
      drop = FALSE
    ) +
    labs(
      subtitle = HISTOGRAM_TITLE,
      x = "Lifetime (s)",
      y = "# MyD88-GFP puncta (log scale)",
      color = "MyD88-GFP Puncta\nIntensity Maxima",
      fill = "MyD88-GFP Puncta\nIntensity Maxima"
    ) +
    theme_classic(
      base_size = 14
    ) +
    theme(
      legend.position = c(0.8, 0.8),
      legend.background = element_blank()
    ) 
}