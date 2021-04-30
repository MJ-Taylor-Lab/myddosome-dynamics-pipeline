setwd(TABLES_DIRECTORY)

Measurements <-
  Measurements %>%
  mutate(
  ) %>%
  filter(
    FilterCell == F
  ) %>%
  mutate(
    Remove = ifelse(Date == "20201005" & MarkerName == "p-p38" & CellLine == "EL4-WT", T, F),
    Remove = ifelse(Date == "20201021" & MarkerName == "RelA" & CellLine == "EL4-WT" & Stimulation == F, T, Remove)
  ) %>%
  filter(
    Remove == F
  ) %>%
  select(-c(
    Remove
  )) %>%
  group_by(
    Date,
    CellLine,
    CellLineName,
    CellLineNumber,
    Marker,
    MarkerName,
    Stimulation,
    Well,
    WellNumber
  ) %>%
  mutate(
    Cells_N = n()
  ) %>%
  filter(
    Cells_N >= 25
  ) %>%
  mutate(
    Stimulation = ifelse(Stimulation, "Stimulated", "Unstimulated"),
    Stimulation = factor(Stimulation, levels = c("Unstimulated", "Stimulated"))
  )

Thresholds <-
  Measurements %>%
  filter(
    Stimulation == "Unstimulated"
  ) %>%
  group_by(
    Date,
    CellLine,
    CellLineName,
    CellLineNumber,
    Marker,
    MarkerName,
    Stimulation,
    Well,
    WellNumber
  ) %>%
  summarize(
    Mean = mean(Mean, na.rm = T),
    Nucleus2Cytosol_Means = mean(Nucleus2Cytosol_Means, na.rm = T)
  ) %>%
  group_by(
    Date,
    MarkerName
  ) %>%
  summarize(
    Threshold = ifelse(MarkerName == "p-p38", median(Mean, na.rm = T), as.numeric(quantile(Nucleus2Cytosol_Means, .66)))
  ) %>%
  distinct()

Measurements <- merge(Measurements, Thresholds, by = c("Date", "MarkerName"))

Measurements <-
  Measurements %>%
  group_by(
    Date,
    Marker,
    MarkerName,
    Stimulation,
    Well,
    WellNumber
  ) %>%
  mutate(
    MeanAdjusted = Mean/Threshold*100,
    Nucleus2Cytosol_Activation = ifelse(Nucleus2Cytosol_Means >= Threshold, 1, 0)
  ) %>%
  ungroup()
  
WellSummary <-
  Measurements %>%
  group_by(
    Date,
    CellLine,
    CellLineName,
    CellLineNumber,
    Marker,
    MarkerName,
    Stimulation,
    Well,
    WellNumber,
    Threshold
  ) %>%
  summarize(
    Nucleus2Cytosol_Totals = mean(Nucleus2Cytosol_Totals, na.rm = T),
    Nucleus2Cytosol_Means = mean(Nucleus2Cytosol_Means, na.rm = T),
    Nucleus2Cytosol_Activation = mean(Nucleus2Cytosol_Activation, na.rm = T),
    Mean = mean(Mean, na.rm = T),
    MeanAdjusted = mean(MeanAdjusted, na.rm = T),
    TotalIntensity = mean(TotalIntensity, na.rm = T),
    Cytosol_Mean = mean(Cytosol_Mean, na.rm = T),
    Cells_N = n()
  ) %>%
  distinct()

FinalSummary <-
  WellSummary %>%
  group_by(
    CellLine,
    CellLineName,
    CellLineNumber,
    Marker,
    MarkerName,
    Stimulation
  ) %>%
  summarize(
    Mean_SEM = sd(Mean, na.rm = T)/sqrt(n()),
    Nucleus2Cytosol_Means_SEM = sd(Nucleus2Cytosol_Means, na.rm = T)/sqrt(n()),
    Nucleus2Cytosol_Activation_SEM = sd(Nucleus2Cytosol_Activation, na.rm = T)/sqrt(n()),
    MeanAdjusted_SD = sd(MeanAdjusted, na.rm = T),
    MeanAdjusted_SEM = sd(MeanAdjusted, na.rm = T)/sqrt(n()),
    MeanAdjusted = mean(MeanAdjusted, na.rm = T),
    Nucleus2Cytosol_Totals = mean(Nucleus2Cytosol_Totals, na.rm = T),
    Nucleus2Cytosol_Means = mean(Nucleus2Cytosol_Means, na.rm = T),
    Nucleus2Cytosol_Activation = mean(Nucleus2Cytosol_Activation, na.rm = T),
    Mean = mean(Mean, na.rm = T),
    TotalIntensity = mean(TotalIntensity, na.rm = T),
    Cytosol_Mean = mean(Cytosol_Mean, na.rm = T),
    Cells_N = sum(Cells_N)
  )

filename = "New Measurements"
file.remove(paste(filename, ".csv.gz", sep = ""))
data.table::fwrite(Measurements, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")

filename = "WellSummary"
file.remove(paste(filename, ".csv.gz", sep = ""))
data.table::fwrite(WellSummary, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")

filename = "FinalSummary"
file.remove(paste(filename, ".csv.gz", sep = ""))
data.table::fwrite(FinalSummary, paste(filename, ".csv.gz", sep = ""), row.names = F, na = "")

# Give cell line order
Measurements$CellLine <- gsub(" ", "\n", Measurements$CellLine)
WellSummary$CellLine <- gsub(" ", "\n", WellSummary$CellLine)
FinalSummary$CellLine <- gsub(" ", "\n", FinalSummary$CellLine)

Measurements$CellLine <- gsub("_", "\n", Measurements$CellLine)
WellSummary$CellLine <- gsub("_", "\n", WellSummary$CellLine)
FinalSummary$CellLine <- gsub("_", "\n", FinalSummary$CellLine)

MODIFIED_CELL_LINE_ORDER = gsub(" ", "\n", CELL_LINE_ORDER)
MODIFIED_CELL_LINE_ORDER = gsub("_", "\n", MODIFIED_CELL_LINE_ORDER)

Measurements$CellLine <- factor(Measurements$CellLine, levels = MODIFIED_CELL_LINE_ORDER)
WellSummary$CellLine <- factor(WellSummary$CellLine, levels = MODIFIED_CELL_LINE_ORDER)
FinalSummary$CellLine <- factor(FinalSummary$CellLine, levels = MODIFIED_CELL_LINE_ORDER)

MODIFIED_CELL_LINE_NAME_ORDER = unique(word(CELL_LINE_ORDER, 1))
MODIFIED_CELL_LINE_NAME_ORDER = gsub(" ", "\n", MODIFIED_CELL_LINE_NAME_ORDER)
MODIFIED_CELL_LINE_NAME_ORDER = gsub("_", "\n", MODIFIED_CELL_LINE_NAME_ORDER)

Measurements$CellLineName <- factor(Measurements$CellLineName, levels = MODIFIED_CELL_LINE_NAME_ORDER)
WellSummary$CellLineName <- factor(WellSummary$CellLineName, levels = MODIFIED_CELL_LINE_NAME_ORDER)
FinalSummary$CellLineName <- factor(FinalSummary$CellLineName, levels = MODIFIED_CELL_LINE_NAME_ORDER)

MODIFIED_CELL_LINE_NUMBER_ORDER = c("", word(CELL_LINE_ORDER, 2)[2:NROW(CELL_LINE_ORDER)])
MODIFIED_CELL_LINE_NUMBER_ORDER = gsub(" ", "\n", MODIFIED_CELL_LINE_NUMBER_ORDER)
MODIFIED_CELL_LINE_NUMBER_ORDER = gsub("_", "\n", MODIFIED_CELL_LINE_NUMBER_ORDER)

Measurements$CellLineNumber <- factor(Measurements$CellLineNumber, levels = MODIFIED_CELL_LINE_NUMBER_ORDER)
WellSummary$CellLineNumber <- factor(WellSummary$CellLineNumber, levels = MODIFIED_CELL_LINE_NUMBER_ORDER)
FinalSummary$CellLineNumber <- factor(FinalSummary$CellLineNumber, levels = MODIFIED_CELL_LINE_NUMBER_ORDER)
