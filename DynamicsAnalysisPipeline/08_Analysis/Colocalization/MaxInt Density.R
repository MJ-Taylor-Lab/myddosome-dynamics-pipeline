setwd(FOLDER)

PlotData <-
  ProteinData %>%
  mutate(
    CATEGORY = ifelse(COLOCALIZATION == 1, "+ve", "-ve"),
    COLOCALIZATION = as.factor(COLOCALIZATION)
  )

ggplot(
  PlotData
) +
  geom_density(
    data = PlotData %>% filter(COLOCALIZATION==0),
    aes(
      y = ..density..,
      x = MAX_NORMALIZED_INTENSITY,
      color = CATEGORY,
      fill = CATEGORY
    ),
    alpha = 0
  ) +
  geom_density(
    data = PlotData %>% filter(COLOCALIZATION==1),
    aes(
      y = ..density..,
      x = MAX_NORMALIZED_INTENSITY,
      color = CATEGORY,
      fill = CATEGORY
    ),
    alpha = 0.5
  ) +
  scale_color_manual(values = c("black", PROTEIN_FILL)) +
  scale_fill_manual(values = c("white", PROTEIN_FILL)) +
  geom_vline(
    aes(
      xintercept = lp.MAX_INTENSITY_THRESHOLD
    ),
    color = "grey",
    linetype = "dashed",
  ) +
  scale_x_continuous(limits = c(0, MAX_INT_LIMIT)) +
  scale_y_continuous( 
    label = mult_format
  ) +
  labs(
    title = paste(lp.PROTEIN, " Puncta Size -/+ for ", lp.OTHERPROTEIN, sep =""),
    y = "Density (%)",
    x = paste(lp.PROTEIN_FLUOROPHORE, " puncta size (# of ",lp.PROTEIN_FLUOROPHORE, ")", sep = ""),
    fill = lp.OTHERPROTEIN,
    color = lp.OTHERPROTEIN
  ) +
  theme_classic(
    base_size = 12
  ) +
  theme(
    legend.position = c(0.8, 0.8),
    strip.text.y = element_blank(),
    strip.background = element_blank()
  ) +
  ggsave(
    file = paste(lp.PROTEIN, " MaxInt Density ", DATE_TODAY, ".svg", sep=""),
    width =5,
    height = 2.5
  ) +
  ggsave(
    file = paste(lp.PROTEIN, " MaxInt Density ", DATE_TODAY, ".pdf", sep=""),
    width = 5,
    height = 2.5
  )