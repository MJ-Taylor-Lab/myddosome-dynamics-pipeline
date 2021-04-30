#Plot tracks over image
ImageTracks <-
  ggplot() +
  geom_raster(
    data = img_plot,
    aes(
      x = x*PIXEL_SIZE,
      y = y*PIXEL_SIZE,
      fill = intensity
    )
  ) +
  geom_path(
    data = PlotTracks,
    aes(
      x = POSITION_X,
      y = POSITION_Y,
      group = UNIVERSAL_TRACK_ID,
      color = MAX_INTENSITY_CAT
    )
  ) +
  geom_point(
    data = PlotTracks %>% filter(FRAME == (FrameX+1)),
    aes(
      x = POSITION_X,
      y = POSITION_Y,
      group = UNIVERSAL_TRACK_ID
    ),
    color = "magenta",
    fill = NA,
    shape = 21,
    size = 3
  ) +
  scale_color_manual(
    values = ColorScale,
    drop = FALSE
  ) +
  scale_fill_gradient(
    low = "black",
    high = "white",
    limits = c(0, 255),
    na.value = "#000000"
  ) +
  scale_x_continuous(
    expand = c(-0.1,-.1),
    limits = c(X_MIN, X_MAX)
  ) +
  scale_y_reverse(
    expand = c(-0.1,-.1),
    limits = c(Y_MAX, Y_MIN)
  ) +
  labs(
    subtitle = "",
    x = "x-position (µm)",
    y = "y-position (µm)",
    color = paste(lp.PROTEIN, "Puncta\nIntensity Maxima"),
    fill = "Intensity\n(a.u.)"
  ) +
  theme_classic(
    base_size = 14
  )