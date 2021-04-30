GrandTracks <- data.table::fread("/Users/u_deliz/Desktop/SingleMolecule/Low vs High Ligand Density/08_Analysis/GrandTableTracks.csv.gz")

CONVERSION <-
  matrix(
    c(
      "M0L0", "<4.5xGFP\n<50s","<4.5xGFP", "<50s",
      "M0L1", "<4.5xGFP\n≥50s","<4.5xGFP", "≥50s",
      "M1L0", "≥4.5xGFP\n<50s","≥4.5xGFP", "<50s",
      "M1L1", "≥4.5xGFP\n≥50s","≥4.5xGFP", "≥50s"
    ),
    ncol = 4
  )
CONVERSION <- t(CONVERSION)
CONVERSION <- as_tibble(CONVERSION)
names(CONVERSION) <- c("STACK", "Combined", "MAX_INTENSITY_CAT", "LIFETIME_CAT")

# GrandTracks <- data.table::fread("/Users/u_deliz/Desktop/SingleMolecule/08_Analysis/GrandTableTracks.csv.gz")

CellSummary <-
  GrandTracks %>%
  group_by(
    LIGAND_DENSITY_CAT,
    IMAGE,
    CELL
  ) %>%
  mutate(
    LIGAND_DENSITY_CAT = paste(LIGAND_DENSITY_CAT, "mol. µm^-2"),
    STACK = paste0(MAX_INTENSITY_CAT, LIFETIME_CAT),
    M0L0 = ifelse(STACK == "00", 1, 0),
    M0L1 = ifelse(STACK == "01", 1, 0),
    M1L0 = ifelse(STACK == "10", 1, 0),
    M1L1 = ifelse(STACK == "11", 1, 0),
    LIFETIME_CAT = ifelse(LIFETIME_CAT == 0, "<50s", "≥50s"),
    MAX_INTENSITY_CAT = ifelse(MAX_INTENSITY_CAT == 0, "<4.5x GFP", "≥4.5x GFP")
  ) %>%
  summarize(
    M0L0 = sum(M0L0),
    M0L1 = sum(M0L1),
    M1L0 = sum(M1L0),
    M1L1 = sum(M1L1)
  ) %>%
  gather(
    STACK,
    COUNT,
    M0L0:M1L1
  ) %>%
  filter(
    STACK != "M0L0",
    STACK != "M0L1"
  ) %>%
  mutate(
    LIFETIME_CAT = ifelse(STACK == "M1L0", "<50s", "≥50s"),
  ) %>%
  arrange(
    LIGAND_DENSITY_CAT,
    IMAGE,
    CELL,
    LIFETIME_CAT
  ) %>%
  select(-c(
    STACK
  ))

CellSummaryAll <-
  CellSummary %>%
  group_by(
    LIGAND_DENSITY_CAT,
    IMAGE,
    CELL
  ) %>%
  summarize(
    COUNT = sum(COUNT),
    LIFETIME_CAT = "All"
  )

CellSummary <- bind_rows(CellSummaryAll, CellSummary)

CellSummary <-
  CellSummary %>%
  arrange(
    LIGAND_DENSITY_CAT,
    IMAGE,
    CELL,
    LIFETIME_CAT
  )

ImageSummary <-
  CellSummary %>%
  group_by(
    LIGAND_DENSITY_CAT,
    IMAGE,
    LIFETIME_CAT
  ) %>%
  summarize(
    MEAN = mean(COUNT),
    N = sum(COUNT)
  )

FinalSummary <-
  ImageSummary %>%
  group_by(
    LIGAND_DENSITY_CAT,
    LIFETIME_CAT
  ) %>%
  summarize(
    MEAN_SEM = sd(MEAN, na.rm = T)/sqrt(n()),
    MEAN = mean(MEAN),
    N = sum(N)
  )


ggplot(
) +
  geom_violin(
    data = CellSummary,
    aes(
      y = COUNT,
      x = LIFETIME_CAT,
    ),
    color = "black",
    fill = "lightgray",
    scale = "width"
  ) +
  geom_crossbar(
    data = FinalSummary,
    aes(
      x = LIFETIME_CAT,
      y = MEAN,
      ymin = MEAN,
      ymax = MEAN
    ),
    width = 0.5
  ) +
  geom_errorbar(
    data = FinalSummary,
    aes(
      x =  LIFETIME_CAT,
      ymin = MEAN - MEAN_SEM,
      ymax = MEAN + MEAN_SEM
    ),
    width = 0.25
  ) +
  geom_point(
    data = ImageSummary,
    aes(
      x = LIFETIME_CAT,
      y = MEAN
    ),
    color = "#377eb8",
    position = "jitter",
    size = 3
  ) +
  labs(
    title = "IL-1 Surface Density",
    x = "Lifetime (s)",
    y = "# MyD88-GFP Puncta per cell\n(≥4.5xGFP) "
  ) +
  facet_wrap(
    ~LIGAND_DENSITY_CAT
  ) +
  theme_classic() +
  theme(
    legend.position = "none"
  ) 

SpotsSummary <-
  GrandTracks %>%
  filter(
    MAX_INTENSITY_CAT == 1
  ) %>%
  group_by(
    LIGAND_DENSITY_CAT,
    IMAGE,
    CELL,
    LIFETIME_CAT
  ) %>%
  summarize(
    COUNT = n(),
    STACK = ifelse(LIFETIME_CAT == 0, "<50s", "≥50s"),
    LIGAND_DENSITY_CAT = paste(LIGAND_DENSITY_CAT, "mol. µm^-2")
  ) %>%
  arrange(
    LIGAND_DENSITY_CAT,
    IMAGE,
    CELL,
    LIFETIME_CAT
  ) %>%
  distinct()

SpotsSummary2 <-
  SpotsSummary %>%
  group_by(
    LIGAND_DENSITY_CAT,
    IMAGE,
    CELL
  ) %>%
  summarize(
    STACK = "All",
    COUNT = sum(COUNT)
  )

SpotsSummary <- bind_rows(SpotsSummary, SpotsSummary2)

SpotsSummary$STACK <- factor(SpotsSummary$STACK, levels = c("All", "<50s", "≥50s"))

ImageSummary <-
  SpotsSummary %>%
  group_by(
    LIGAND_DENSITY_CAT,
    STACK,
    IMAGE
  ) %>%
  summarize(
    COUNT = mean(COUNT),
    MEAN = mean(COUNT, na.rm = T)
  )

FinalSummary <-
  ImageSummary %>%
  group_by(
    LIGAND_DENSITY_CAT,
    STACK
  ) %>%
  summarize(
    COUNT = mean(COUNT),
    MEAN_SEM = sd(MEAN, na.rm = T)/sqrt(n()),
    MEAN = mean(MEAN, na.rm = T)
  )

Table <-
  FinalSummary %>%
  select(
    LIGAND_DENSITY_CAT,
    STACK,
    COUNT
  ) %>%
  mutate(
    COUNT = round(COUNT, 1)
  )


write.csv(Table, "3H.csv", row.names = F)
