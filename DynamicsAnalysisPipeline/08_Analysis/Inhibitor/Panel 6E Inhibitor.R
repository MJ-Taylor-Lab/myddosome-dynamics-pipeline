setwd(INHIBITOR_DIRECTORY)

GrandTracks <-
  GrandTracks %>%
  mutate(
    MAX_INTENSITY_CAT = ifelse(MAX_INTENSITY_CAT == 1, "≥4.5", "<4.5"),
    LIFETIME_CAT = ifelse(LIFETIME_CAT == 1, "MyD88-GFP Puncta Lifetime ≥50s", "MyD88-GFP Puncta Lifetime <50s"),
    COHORT = ifelse(
      grepl(
        "Inhibitor",
        IMAGE,
        fixed = T
      ),
      "IRAK4-Inhibitor",
      "Control"
    ),
    GROUP = ifelse(
      grepl(
        "Inhibitor",
        IMAGE,
        fixed = T
      ),
      "IRAK4-Inhibitor",
      "Control"
    )
  )

ViolinTracks <-
  GrandTracks %>%
  # filter(
  #   LIGAND_DENSITY_CAT == "32 mol. µm^-2"
  # ) %>%
  ungroup() %>%
  mutate(
    IMAGENUMBER = group_indices(., GROUP, IMAGE)
  ) %>%
  group_by(
    GROUP
  ) %>%
  mutate(
    IMAGENUMBER = IMAGENUMBER - min(IMAGENUMBER) + 1,
    IMAGENUMBER = as.factor(IMAGENUMBER)
  )

ViolinCells <-
  ViolinTracks %>%
  ungroup() %>%
  mutate(
    MEAN = ifelse(MAX_INTENSITY_CAT == "≥4.5", 1, 0),
    MEAN = as.numeric(MEAN),
  ) %>%
  group_by(
    GROUP,
    IMAGENUMBER,
    CELL,
    LIFETIME_CAT
  ) %>%
  summarize(
    MEAN = mean(MEAN, na.rm = T)
  )

ViolinImg <-
  ViolinCells %>%
  group_by(
    GROUP,
    IMAGENUMBER,
    LIFETIME_CAT
  ) %>%
  summarize(
    MEAN = mean(MEAN, na.rm = T)
  )

ViolinLigand <-
  ViolinImg %>%
  group_by(
    GROUP,
    LIFETIME_CAT
  ) %>%
  summarize(
    SD = sd(MEAN, na.rm = T),
    SE = SD/sqrt(n()),
    MEAN = mean(MEAN, na.rm = T)
  )

#T Test
TestL <-
  ViolinCells %>%
  filter(
    LIFETIME_CAT == "MyD88-GFP Puncta Lifetime <50s"
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

# stat.test.l <- stat.test.l[1:2,]
stat.test.l$LIFETIME_CAT = "MyD88-GFP Puncta Lifetime <50s"

#T Test
TestH <-
  ViolinCells %>%
  filter(
    LIFETIME_CAT == "MyD88-GFP Puncta Lifetime ≥50s"
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

# stat.test.h <- stat.test.h[1:2,]
stat.test.h$LIFETIME_CAT = "MyD88-GFP Puncta Lifetime ≥50s"

ggplot(
  ViolinCells
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
    data = ViolinLigand,
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
    data = ViolinLigand,
    aes(
      x = GROUP,
      ymin = MEAN*100 - SE*100,
      ymax = MEAN*100 + SE*100,
    ),
    color = "black",
    width = 0.5
  ) +
  geom_jitter(
    data = ViolinImg,
    aes(
      x = GROUP,
      y = MEAN*100,
      group = IMAGENUMBER,
      fill = GROUP
    ),
    color = "black",
    size = 3,
    shape = 21,
    color = "#377eb8"
  ) +
  stat_pvalue_manual(
    stat.test.l,
    y.position = c(105),
    label = paste("p = {p.format}", " ({p.signif})")
  ) +
  stat_pvalue_manual(
    stat.test.h,
    y.position = c(105),
    label = paste("p = {p.format}", " ({p.signif})")
  ) +
  scale_color_brewer(palette = "Set2") +
  scale_fill_brewer(palette = "Set2") +
  scale_y_continuous( 
    limits = c(0,110)
  ) +
  labs(
    y = "%  MyD88-GFP puncta per cell\n(≥4.5xGFP)",
    x = "Cell Line",
    color = "Replicate",
    shape = "Replicate"
  ) +
  facet_wrap(
    ~LIFETIME_CAT,
    scales = "free_y"
  ) +
  theme_classic() +
  theme(
    legend.position = "none",
    strip.background = element_blank()
  ) +
  ggsave(
    file = "Inhibitor Assembled-Violin-Lifetime.svg",
    width = 6,
    height = 3
  ) +
  ggsave(
    file = "Inhibitor Assembled-Violin-Lifetime.pdf",
    width = 6,
    height = 3
  )

Summary <-
  ViolinCells %>%
  ungroup() %>%
  group_by(
    GROUP,
    LIFETIME_CAT,
    IMAGENUMBER
  ) %>%
  summarize(
    MEAN = mean(MEAN),
  ) %>%
  group_by(
    GROUP,
    LIFETIME_CAT
  ) %>%
  summarize(
    N = n(),
    SD = sd(MEAN),
    MEAN = mean(MEAN),
    SE = SD/sqrt(N)
  )

write.csv(Summary, "Summary.csv")
