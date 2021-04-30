Title <-
  ggdraw() + 
  draw_label(
    paste(lp.PROTEIN, "dynamics over time"),
    fontface = 'bold',
    x = 0,
    hjust = 0,
    size = 21
  ) +
  theme(
    plot.margin = margin(0, 0, 0, 7)
  )

# Plot all
TopRow <-
  cowplot::plot_grid(
    Image,
    ImageTracks,
    CalibrationPlot,
    rel_widths = c(.71, 1, .5),
    labels = c("A","B", "C"),
    label_size = 24,
    nrow = 1
  )

TitleAndTopRow <-
  cowplot::plot_grid(
    Title,
    TopRow,
    rel_heights = c(0.1, 1),
    ncol = 1
  )

BottomRow <-
  cowplot::plot_grid(
    MaxCatPlot,
    Histogram,
    LifetimePlot,
    ChangeIntensityPlot,
    labels = c("D", "E", "F", "G"),
    rel_widths = c(.5,1,.5,1),
    label_size = 24,
    nrow = 1
  )

Combined <-
  cowplot::plot_grid(
    TitleAndTopRow,
    BottomRow,
    ncol = 1
  )

ggsave(
  file = paste(save_name, ".png", sep = ""),
  height = 9,
  width = 16,
  Combined
)