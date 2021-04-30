setwd(COLOCALIZATION_DIRECTORY)

if(exists("ColocalizationImgs")) {} else {
  filename = "GrandColocalizationComparison"
  ColocalizationImgs <-
    data.table::fread(paste(filename, ".csv.gz", sep = ""), integer64="character")
}

ColocalizationImgs <-
  ColocalizationImgs %>%
  mutate(
    UNIVERSAL_TRACK_ID = paste(UNIVERSAL_TRACK_ID_1, UNIVERSAL_TRACK_ID_2, sep = "")
  ) %>%
  select(-c(
    UNIVERSAL_TRACK_ID_1,
    UNIVERSAL_TRACK_ID_2
  ))

ColocalizationImgsRef <-
  ColocalizationImgs %>%
  filter(
    PROTEIN == REFERENCE_PROTEIN
  ) %>%
  group_by(
    IMAGE,
    CELL,
    COLOCALIZATION_GROUP
  ) %>%
  mutate(
    MIN_TRACK_TEST = ifelse(TRACK_ID == min(TRACK_ID), 1, 0)
  ) %>%
  filter(
    MIN_TRACK_TEST == 1
  ) %>%
  select(-c(
    MIN_TRACK_TEST
  )) %>%
  ungroup() %>%
  filter(
    COLOCALIZATION == 1,
    LIFETIME >= LIFETIME_THRESHOLD,
    STARTING_NORMALIZED_INTENSITY <= STARTING_INTENSITY_THESHOLD
  )

ColocalizationImgsRest <-
  ColocalizationImgs %>%
  filter(
    PROTEIN != REFERENCE_PROTEIN
  ) %>%
  group_by(
    IMAGE,
    CELL,
    COLOCALIZATION_GROUP
  ) %>%
  mutate(
    MIN_TRACK_TEST = ifelse(TRACK_ID == min(TRACK_ID), 1, 0)
  ) %>%
  filter(
    MIN_TRACK_TEST == 1
  ) %>%
  select(-c(
    MIN_TRACK_TEST
  )) %>%
  ungroup() %>%
  filter(
    COLOCALIZATION == 1,
    LIFETIME >= LIFETIME_THRESHOLD
  )

ColocalizationImgs <- rbind(ColocalizationImgsRef, ColocalizationImgsRest)

remove(ColocalizationImgsRef, ColocalizationImgsRest)

ColocalizationWaitTracks <-
  ColocalizationImgs %>%
  arrange(
    IMAGE,
    CELL,
    COLOCALIZATION_GROUP,
    FRAME
  ) %>%
  select(
    LIGAND_DENSITY_CAT,
    LIGAND_DENSITY,
    COHORT,
    GROUP,
    PROTEIN,
    IMAGE,
    CELL,
    COLOCALIZATION_GROUP,
    PROTEIN,
    UNIVERSAL_TRACK_ID,
    FRAME,
    FPS
  ) %>%
  distinct() %>%
  group_by(
    IMAGE,
    CELL,
    COLOCALIZATION_GROUP
  ) %>%
  group_by(
    IMAGE,
    CELL,
    COLOCALIZATION_GROUP,
    PROTEIN
  ) %>%
  mutate(
    MIN = min(FRAME, na.rm = T)
  ) %>%
  filter(
    FRAME == MIN
  ) %>%
  ungroup() %>%
  group_by(
    IMAGE,
    CELL,
    COLOCALIZATION_GROUP
  ) %>%
  mutate(
    WAIT_TIME = FRAME - lag(FRAME),
  ) %>%
  mutate(
    REFERENCE_TEST = ifelse(lag(PROTEIN) == REFERENCE_PROTEIN, 1, -1),
    WAIT_TIME = WAIT_TIME*REFERENCE_TEST,
    WAIT_TIME = WAIT_TIME/FPS
  ) %>%
  select(-c(
    MIN,
    REFERENCE_TEST,
    FPS
  )) %>%
  drop_na()

setwd(COLOCALIZATION_DIRECTORY)
filename = "ColocalizationWaitTracks"
file.remove(paste(filename, ".csv.gz", sep = ""))
data.table::fwrite(ColocalizationWaitTracks, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")

KeepTracks <- ColocalizationWaitTracks$UNIVERSAL_TRACK_ID

WaitTrackMeans <-
  ColocalizationWaitTracks %>%
  group_by(
    GROUP,
    LIGAND_DENSITY_CAT
  ) %>%
  summarize(
    MEAN = mean(WAIT_TIME, na.rm = T)
  )

ggplot(
  ColocalizationWaitTracks,
) +
  geom_density(
    aes(
      x = WAIT_TIME,
      y = ..density..
    )
  ) +
  geom_vline(
    aes(
      xintercept = 0
    )
  ) +
  geom_vline(
    aes(
      xintercept = mean(WAIT_TIME)
    ),
    color = "red"
  ) +
  facet_wrap(
    ~GROUP+LIGAND_DENSITY_CAT
  ) +
  theme_classic() +
  ggsave(
    "WaitTime.pdf",
    height = 3,
    width = 4
  )