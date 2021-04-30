if(NROW(PlotTracks)==0){
  #Calibration density plot
  {
    CalibrationPlot <-
      ggplot() +
      geom_rect(
        aes(
          xmin = lp.MAX_INTENSITY_THRESHOLD * (PROTEIN_INTENSITY),
          xmax = Inf,
          ymin = 0,
          ymax = Inf),
        fill = "#377eb8",
        alpha = 0.5
      ) +
      geom_density(
        data = CalData,
        aes(
          y =  ..density..,
          x = TOTAL_INTENSITY_ADJUSTED,
          color = "1 GFP"
        ),
        size = 2,
      ) +
      stat_function(
        data = data.frame(x = c(0, 10 * PROTEIN_INTENSITY)),
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
          mean = lp.ASSEMBLED_COMPLEX_SIZE*PROTEIN_INTENSITY,
          sd = sqrt(lp.ASSEMBLED_COMPLEX_SIZE*PROTEIN_SD^2))) +
      scale_color_manual(
        values = my.palette
      ) +
      scale_y_continuous(
        expand = c(0, 0),
        labels = my.half,
        limits = c(0,0.028)
      ) +
      labs(
        x = "Fluorescence Intensity Maxima (a.u.)",
        y = paste("% of", lp.PROTEIN, "puncta"),
        color = "Data",
        subtitle = paste("0 puncta")
      ) +
      scale_x_continuous(
        expand = c(0, 0),
        limits = c(0, lp.ASSEMBLED_COMPLEX_SIZE*3/2 * PROTEIN_INTENSITY)
      ) +
      theme_classic(
        base_size = 14
      ) +
      theme(
        legend.position = c(0.8, 0.8),
        legend.background = element_blank()
      ) 
  }
} else{
  #Calibration density plot
  {
    CalibrationPlot <-
      ggplot() +
      geom_rect(
        aes(
          xmin = lp.MAX_INTENSITY_THRESHOLD * (PROTEIN_INTENSITY),
          xmax = Inf,
          ymin = 0,
          ymax = Inf),
        fill = "#377eb8",
        alpha = 0.5
      ) +
      geom_density(
        data = CalData,
        aes(
          y =  ..density..,
          x = TOTAL_INTENSITY_ADJUSTED,
          color = paste("1", lp.FLUOROPHORE)
        ),
        size = 2,
      ) +
      stat_function(
        data = data.frame(x = c(0, 10 * PROTEIN_INTENSITY)),
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
          mean = lp.ASSEMBLED_COMPLEX_SIZE*PROTEIN_INTENSITY,
          sd = sqrt(lp.ASSEMBLED_COMPLEX_SIZE*PROTEIN_SD^2))) +
      geom_density(
        data = PlotTracks,
        aes(
          y =  ..density..*3,
          x = MAX_TOTAL_INTENSITY_WO_BACKGROUND,
          color = paste(lp.PROTEIN, lp.FLUOROPHORE, sep = "-")
        ),
        size = 2,
      ) +
      scale_color_manual(
        values = my.palette
      ) +
      scale_y_continuous(
        expand = c(0, 0),
        labels = my.half
      ) +
      labs(
        x = "Fluorescence Intensity Maxima (a.u.)",
        y = paste("% of", lp.PROTEIN, "puncta"),
        color = "Data",
        subtitle = paste(NROW(PlotTracks), "puncta")
      ) +
      scale_x_continuous(
        expand = c(0, 0),
        limits = c(0, 9 * PROTEIN_INTENSITY)
      ) +
      theme_classic(
        base_size = 14
      ) +
      theme(
        legend.position = c(0.8, 0.8),
        legend.background = element_blank()
      ) 
  }
}
