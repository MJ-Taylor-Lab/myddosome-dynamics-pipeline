setwd(FOLDER)

# Calibration data
{
  ImgCalData <-
    CalData %>%
    mutate(
      DATE_MEAN = round(DATE_MEAN, 4)
    ) %>%
    filter(
      KEEP == 1,
      DATE_MEAN == round(lp.PROTEIN_INTENSITY, 4)
    ) 
}

#Events captured by threshold
{
  EventsCaptured <-
    pnorm(
      lp.PROTEIN_INTENSITY * lp.MAX_INTENSITY_THRESHOLD,
      mean = lp.PROTEIN_INTENSITY*lp.ASSEMBLED_COMPLEX_SIZE,
      sd = sqrt(lp.ASSEMBLED_COMPLEX_SIZE*sd(ImgCalData$TOTAL_INTENSITY)^2)
    )
  EventsCaptured <- 1 - round(EventsCaptured, 2)
  EventsCaptured <- 100 * EventsCaptured
  print(paste(EventsCaptured[1], "% of large assemblies captured by maximum intensity threshold", sep = ""))
}

#Custom colors
my.palette = c(brewer.pal(9, "YlGnBu")[c(3,6,9)])

#Custom transformations
my.half <- function(x){ 
  paste(100*round(x*.3333, 3), "%")
}
my.transformation <- function(x){ 
  paste(100*round(x, 3), "%")
}

#Density plot
ggplot() +
  geom_rect(
    aes(
      xmin = lp.MAX_INTENSITY_THRESHOLD * (lp.PROTEIN_INTENSITY),
      xmax = Inf,
      ymin = 0,
      ymax = Inf),
    fill = "#377eb8",
    alpha = 0.5
  ) +
  geom_density(
    data = ImgCalData,
    aes(
      y =  ..density..,
      x = TOTAL_INTENSITY_ADJUSTED,
      color = paste("1", lp.FLUOROPHORE)
    ),
    size = 2,
  ) +
stat_function(
  data = data.frame(x = c(0, 10 * lp.PROTEIN_INTENSITY)),
  aes(
    x,
    color = paste(lp.ASSEMBLED_COMPLEX_SIZE, lp.FLUOROPHORE)
  ),
  fun = dnorm,
  fill =  NA,
  geom = "area",
  n = 300,
  size = 2,
  args = list(
    mean = lp.ASSEMBLED_COMPLEX_SIZE*lp.PROTEIN_INTENSITY,
    sd = sqrt(lp.ASSEMBLED_COMPLEX_SIZE*lp.PROTEIN_SD^2))) +
  geom_density(
    data = ImgTracks,
    aes(
      y =  ..density..*3,
      x = MAX_TOTAL_INTENSITY_WO_BACKGROUND,
      color = "Experimental"
    ),
    size = 2,
  ) +
  scale_color_manual(values = my.palette) +
  scale_y_continuous(
    expand = c(0, 0),
    labels = my.half,
    limits = c(0,0.03),
    sec.axis = sec_axis(
     labels = my.transformation,
     trans = ~ .,
     name = paste("% of", lp.FLUOROPHORE, "Puncta")
    )
  ) +
  labs(
    x = "Fluorescence Intensity Maxima (a.u.)",
    y = paste("% of", lp.PROTEIN, "Puncta"),
    color = "Data"
  ) +
  scale_x_continuous(
    expand = c(0, 0),
    limits = c(0, lp.ASSEMBLED_COMPLEX_SIZE*3/2 * lp.PROTEIN_INTENSITY)
  ) +
  theme_classic() +
  theme(
    legend.position = c(.8, .7),
    legend.background = element_blank()
  ) +
  ggsave(
    file = paste(lp.PROTEIN, " Calibration-Experimental Density ", DATE_TODAY, ".svg", sep = ""),
    width = 4,
    height = 3
  ) +
  ggsave(
    file = paste(lp.PROTEIN, " Calibration-Experimental Density ", DATE_TODAY, ".pdf", sep = ""),
    width = 4,
    height = 3
  )