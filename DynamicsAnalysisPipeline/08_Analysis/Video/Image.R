#Image name
setwd(STACK_PATH)

str_name <-
  paste(
    str_pad(FrameX, 4, pad = "0"),
    ".tif",
    sep = "")

save_name <-
  my.left(str_name, 4)

#Import image
img = raster::raster(str_name)
img_plot = raster::as.data.frame(img, xy = T)
names(img_plot) <- c("x", "y", "intensity")

#Adjust y
ydim <- dim(img)[1]
img_plot <-
  img_plot %>%
  mutate(
    intensity = ifelse(intensity<IMG_MIN_INTENSITY, NA, intensity),
    intensity = ifelse(intensity>IMG_MAX_INTENSITY, IMG_MAX_INTENSITY, intensity),
    intensity = intensity-IMG_MIN_INTENSITY,
    intensity = intensity/(IMG_MAX_INTENSITY-IMG_MIN_INTENSITY)*255,
    y = ydim - y
  )

setwd(EXPORT_PATH)

#Plot image
Image <-
  ggplot() +
  geom_raster(
    data = img_plot,
    aes(
      x = x*PIXEL_SIZE,
      y = y*PIXEL_SIZE,
      fill = intensity
    )
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
    subtitle = paste(FrameX, "s", sep = ""),
    x = "x-position (µm)",
    y = "y-position (µm)",
    fill = "Intensity\n(a.u.)"
  ) +
  theme_classic(
    base_size = 14
  ) +
  theme(
    legend.position = "none"
  )