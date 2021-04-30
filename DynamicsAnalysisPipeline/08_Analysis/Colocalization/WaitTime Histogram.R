#Import manually curated table
WaitTime <- read.csv(file.path(COLOCALIZATION_DIRECTORY, WAIT_TIME_TABLE))
setwd(COLOCALIZATION_DIRECTORY)

#Obtain means
WaitTime <-
  WaitTime %>%
  mutate(
    CATEGORY = factor(WaitTime$PROTEIN2_NAME, levels=PROTEIN_ORDER),
    CATEGORY = as.factor(CATEGORY)
  )

#Obtain means
WaitTimeMean <-
  WaitTime %>%
  group_by(
    CATEGORY
  ) %>%
  summarise(
    MEAN_T = mean(CURATED_DELTA_T),
    N = NROW(CURATED_DELTA_T),
    SD = sd(CURATED_DELTA_T)
  ) 

PROTEIN_ORDER
#Save file
filename = "WaitTimeMean"
data.table::fwrite(WaitTimeMean, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")

#Recruitment time histogram and density plot
ggplot(
) +
  geom_histogram(
    data = WaitTime,
    mapping = aes(
      x = CURATED_DELTA_T,
      y = ..count..,
      color = CATEGORY,
      fill = CATEGORY
    ),
    alpha = .25,
    position = "identity",
    binwidth = 1
  ) +
  geom_density(
    data = WaitTime,
    mapping = aes(
      x = CURATED_DELTA_T,
      y = ..count..,
      fill = CATEGORY,
    ),
    alpha = .25
  ) +
  geom_vline(
    data = WaitTimeMean,
    mapping = aes(
      xintercept = MEAN_T,
    ),
    color = "black",
    linetype = "solid",
    size = .5
  ) +
  scale_color_brewer(palette="Set2") +
  scale_fill_brewer(palette="Set2") +
  scale_x_continuous(limits = c(0,100)) +
  labs(
    x = "Recruitment Time (s)",
    y = "Puncta (Count)",
    color = "Protein",
    fill = "Protein"
  ) +
  theme_classic() +
  facet_wrap(
    ~ CATEGORY,
    scales = "free_y",
    ncol = 1
  ) +
  theme(
    legend.position = "none",
    strip.background = element_blank(),
    strip.text.y = element_blank()
  ) +
  ggsave(
    file = paste("WaitTime Histogram ", DATE_TODAY, ".svg", sep=""),
    width = 4,
    height = 3
  ) +
  ggsave(
    file = paste("WaitTime Histogram ", DATE_TODAY, ".pdf", sep=""),
    width = 4,
    height = 3
  )