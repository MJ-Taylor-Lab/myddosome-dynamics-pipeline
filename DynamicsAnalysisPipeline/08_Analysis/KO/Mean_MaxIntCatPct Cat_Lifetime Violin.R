setwd(FOLDER)

#Exclude combined data
PlotCellTracksSummary <- CellTracksSummary %>% filter(LIFETIME_CAT != "All")
PlotCellTracksImgSummary <- CellTracksImgSummary %>% filter(LIFETIME_CAT != "All")
PlotCellTracksGrandSummary <- CellTracksGrandSummary %>% filter(LIFETIME_CAT != "All")

#T Test
Test <-
  PlotCellTracksSummary %>%
  group_by(
    LIFETIME_CAT,
    GROUP,
    IMAGENUMBER,
  ) %>%
  summarize(
    MEAN = mean(MEAN)
  )


stat.test <- compare_means(
  MEAN ~ GROUP, group.by = "LIFETIME_CAT", data = Test,
  method = "t.test" #for non-parametric, use wilcox.test
)

stat.test <-
  stat.test %>%
  filter(
    group1 == "WT" |
      group2 == "WT"
  )

YPos <- max(PlotCellTracksSummary$MEAN)*100
YPos <- YPos + YPos*.15*(1:(NROW(stat.test)/2))
YPos <- c(YPos, YPos)

ggplot(
  PlotCellTracksSummary
) +
  geom_violin(
    aes(
      x = GROUP,
      y = MEAN*100
    ),
    size = 2,
    fill = "darkgrey",
    color = "darkgrey"
  ) +
  geom_crossbar(
    data = PlotCellTracksGrandSummary,
    aes(
      x = GROUP,
      ymin = MEAN*100,
      y = MEAN*100,
      ymax = MEAN*100
    ),
    color = "black",
    width = 0.75
  ) +
  geom_errorbar(
    data = PlotCellTracksGrandSummary,
    aes(
      x = GROUP,
      ymin = (MEAN - SE)*100,
      ymax = (MEAN + SE)*100,
    ),
    color = "black",
    width = 0.5
  ) +
  geom_jitter(
    data = PlotCellTracksImgSummary,
    aes(
      x = GROUP,
      y = MEAN*100,
      group = IMAGENUMBER,
      fill = GROUP
    ),
    color = "black",
    size = 3,
    shape = 21,
  ) +
  stat_pvalue_manual(
    stat.test,
    y.position = YPos,
    label = paste("p = {p.format}", " ({p.signif})")
  ) +
  scale_fill_manual(
    values = Colors
  ) +
  scale_color_manual(
    values = Colors
  ) +
  labs(
    y = paste("% ", lp.PROTEIN_FLUOROPHORE," Puncta per Cell\n(≥",
              lp.MAX_INTENSITY_THRESHOLD, "x",lp.FLUOROPHORE, ")", sep =""),
    x = "",
    color = "Replicate",
    shape = "Replicate"
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
    file = paste("Mean_MaxIntCatPct Cat_Lifetime ", DATE_TODAY, ".svg", sep = ""),
    width = 6,
    height = 3
  ) +
  ggsave(
    file = paste("Mean_MaxIntCatPct Cat_Lifetime ", DATE_TODAY, ".pdf", sep = ""),
    width = 6,
    height = 3
  )