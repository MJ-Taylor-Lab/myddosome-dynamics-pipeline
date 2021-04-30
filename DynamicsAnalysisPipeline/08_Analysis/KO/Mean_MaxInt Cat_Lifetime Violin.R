setwd(FOLDER)

#Exclude combined data
PlotCellTracksSummary <- CellTracksSummary %>% filter(LIFETIME_CAT != "All")
PlotCellTracksImgSummary <- CellTracksImgSummary %>% filter(LIFETIME_CAT != "All")
PlotCellTracksGrandSummary <- CellTracksGrandSummary %>% filter(LIFETIME_CAT != "All")

#Plot limits
YPos <- max(CellTracksSummary$MEAN)

#t-Test
{
  #T Test
  TestL <-
    PlotCellTracksSummary %>%
    filter(
      LIFETIME_CAT == paste("<", lp.LIFETIME_THRESHOLD, "s", sep = "")
    ) %>%
    group_by(
      GROUP,
      IMAGENUMBER,
    ) %>%
    summarize(
      MEAN = mean(MEAN)
    )
  
  stat.test.l <- compare_means(
    MEAN ~ GROUP, data = TestL,
    method = "t.test" #for non-parametric, use wilcox.test
  )
  
  #stat.test.l <- stat.test.l[1:2,]
  stat.test.l <- stat.test.l[c(1:3, 5), ]
  stat.test.l$LIFETIME_CAT = paste("<", lp.LIFETIME_THRESHOLD, "s", sep = "")
  
  #T Test
  TestH <-
    PlotCellTracksSummary %>%
    filter(
      LIFETIME_CAT ==  paste("≥", lp.LIFETIME_THRESHOLD, "s", sep = "")
    ) %>%
    group_by(
      GROUP,
      IMAGENUMBER,
    ) %>%
    summarize(
      MEAN = mean(MEAN)
    )
  
  stat.test.h <- compare_means(
    MEAN ~ GROUP, data = TestH,
    method = "t.test" #for non-parametric, use wilcox.test
  )
  
  stat.test.h <- stat.test.h[c(1:3, 5), ]
  stat.test.h$LIFETIME_CAT =  paste("≥", lp.LIFETIME_THRESHOLD, "s", sep = "")
}

ggplot(
  PlotCellTracksSummary
) +
  geom_violin(
    aes(
      x = GROUP,
      y = MEAN
    ),
    size = 2,
    fill = "darkgrey",
    color = "darkgrey"
  ) +
  geom_crossbar(
    data = PlotCellTracksGrandSummary,
    aes(
      x = GROUP,
      ymin = MEAN,
      y = MEAN,
      ymax = MEAN
    ),
    color = "black",
    width = 0.75
  ) +
  geom_errorbar(
    data = PlotCellTracksGrandSummary,
    aes(
      x = GROUP,
      ymin = MEAN - SE,
      ymax = MEAN + SE,
    ),
    color = "black",
    width = 0.5
  ) +
  geom_jitter(
    data = PlotCellTracksImgSummary,
    aes(
      x = GROUP,
      y = MEAN,
      group = IMAGENUMBER,
      fill = GROUP
    ),
    color = "black",
    size = 3,
    shape = 21,
  ) +
  # stat_pvalue_manual(
  #   stat.test.l,
  #   y.position = c(YPos+5, YPos+15, YPos+25, YPos+35),
  #   label = paste("p = {p.format}", " ({p.signif})")
  # ) +
  # stat_pvalue_manual(
  #   stat.test.h,
  #   y.position = c(YPos+5, YPos+15, YPos+25, YPos+35),
  #   label = paste("p = {p.format}", " ({p.signif})")
  # ) +
  scale_fill_manual(
    values = Colors
  ) +
  scale_color_manual(
    values = Colors
  ) +
  labs(
    y = "Norm. Max Intensity per Cell (a.u.)",
    x = "",
    color = "Replicate",
    shape = "Replicate"
  ) +
  scale_y_continuous(
    limits = c(0, YPos)
  ) +
  facet_wrap(
    ~ LIFETIME_CAT,
    nrow = 1,
    scales = "free_y"
  ) +
  theme_classic() +
  theme(
    legend.position = "none",
    strip.background = element_blank()
  ) +
  ggsave(
    file = paste("Mean_MaxInt Cat_Lifetime ", DATE_TODAY, ".pdf", sep = ""),
    width = 6,
    height = 3
  ) +
  ggsave(
    file = paste("Mean_MaxInt Cat_Lifetime ", DATE_TODAY, ".svg", sep = ""),
    width = 6,
    height = 3
  )