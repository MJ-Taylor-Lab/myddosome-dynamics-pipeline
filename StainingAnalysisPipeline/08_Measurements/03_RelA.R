setwd(GRAPHS_DIRECTORY)

PlotMarker = "RelA"

Group1 <- NULL
Group1$CellLine <- MODIFIED_CELL_LINE_ORDER[1:4]
Group1 <- as_tibble(Group1)
Group1$Group <- "MyD88"

Group2 <- NULL
Group2$CellLine <- c(MODIFIED_CELL_LINE_ORDER[1], MODIFIED_CELL_LINE_ORDER[4:6])
Group2 <- as_tibble(Group2)
Group2$Group <- "IRAKs"

Group3 <- NULL
Group3$CellLine <- c(MODIFIED_CELL_LINE_ORDER[4], MODIFIED_CELL_LINE_ORDER[7:8])
Group3 <- as_tibble(Group3)
Group3$Group <- "KO"

Categories <- rbind(Group1, Group2, Group3)
remove(Group1, Group2, Group3)

Groups <- unique(Categories$Group)

Colors <- NULL
Colors$Color <- RColorBrewer::brewer.pal(NROW(MODIFIED_CELL_LINE_ORDER), "Set2")
Colors <- as_tibble(Colors)
Colors <- t(Colors)
Colors <- as_tibble(Colors)
names(Colors) <- MODIFIED_CELL_LINE_ORDER

# New tables
GroupsFx <- function(GroupX) {
  
  CellLineX <-
    Categories%>%
    filter(
      Group == GroupX
    )
  
  CellLineX <- CellLineX$CellLine
  
  PlotImageSummary <-
    Measurements %>%
    filter(
      MarkerName == PlotMarker,
      CellLine %in% CellLineX
    )
  
  PlotWellSummary <-
    WellSummary %>%
    filter(
      MarkerName == PlotMarker,
      CellLine %in% CellLineX
    )
  
  PlotFinalSummary <-
    FinalSummary %>%
    filter(
      MarkerName == PlotMarker,
      CellLine %in% CellLineX
    )
  
  #Calculate p-values
  stat.test <- ggpubr::compare_means(
    Nucleus2Cytosol_Means ~ CellLine, group.by = "Stimulation",  paired = F, data = PlotWellSummary,# %>%mutate(Nucleus2Cytosol_Means = log(Nucleus2Cytosol_Means)),
    method = "t.test" #for non-parametric, use wilcox.test
  )
  
  stat.test <-
    stat.test %>%
    filter(
      group1 == MODIFIED_CELL_LINE_ORDER[1] |
      group2 == MODIFIED_CELL_LINE_ORDER[1] |
      group1 == MODIFIED_CELL_LINE_ORDER[4] |
      group2 == MODIFIED_CELL_LINE_ORDER[4]
    )
  
  stat.test$Marker = PlotMarker
  YPos <- max(PlotImageSummary$Nucleus2Cytosol_Means)
  YPos <- YPos + YPos*.15*(1:(NROW(stat.test)/2))
  YPos <- c(YPos, YPos)
  #Plot
  ggplot() +
    geom_violin(
      data = PlotImageSummary %>%filter(Nucleus2Cytosol_Means <= 30),
      aes(
        x = CellLine,
        y = Nucleus2Cytosol_Means
      ),
      fill = "grey",
      color = "grey",
      scale = "width"
    ) +
    geom_point(
      data = PlotWellSummary,
      aes(
        x = CellLine,
        y = Nucleus2Cytosol_Means,
        fill = CellLine
      ),
      position = "jitter",
      color = "black",
      size = 3,
      shape = 21
    ) +
    geom_crossbar(
      data = PlotFinalSummary,
      aes(
        x = CellLine,
        y = Nucleus2Cytosol_Means,
        ymin = Nucleus2Cytosol_Means,
        ymax = Nucleus2Cytosol_Means
      ),
      width = 0.5
    ) +
    geom_errorbar(
      data = PlotFinalSummary,
      aes(
        x = CellLine,
        ymin = Nucleus2Cytosol_Means-Nucleus2Cytosol_Means_SEM,
        ymax = Nucleus2Cytosol_Means+Nucleus2Cytosol_Means_SEM
      ),
      width = 0.25
    ) + 
    # ggpubr::stat_pvalue_manual(
    #   stat.test,
    #   y.position = YPos,
    #   label = paste("p = {p.format}", " ({p.signif})")
    # ) +
    scale_fill_manual(
      values = Colors
    ) +
    labs(
      x = "Cell Line",
      y = "Nucleus:Cytosol Means Ratio"
    ) +
    facet_wrap(
      ~ Stimulation
    ) +
    theme_classic() +
    theme(
      axis.title.x = element_blank(),
      legend.position = "none",
      axis.text.x = element_text(angle = 45, hjust = 1),
      strip.background = element_blank()
    ) +
    ggsave(
      paste(PlotMarker, GroupX, "Nucleus2Cytosol_Means Violin.pdf"),
      height = 4,
      width = NROW(CellLineX)
    )
}
mclapply(Groups, GroupsFx)

PlotImageSummary <-
  Measurements %>%
  filter(
    MarkerName == PlotMarker
  )

PlotWellSummary <-
  WellSummary %>%
  filter(
    MarkerName == PlotMarker
  )

PlotFinalSummary <-
  FinalSummary %>%
  filter(
    MarkerName == PlotMarker
  )

PValuesFx <- function(StimulationX){
  stat.test <- ggpubr::compare_means(
    Nucleus2Cytosol_Means ~ CellLine, group.by = "Stimulation",  paired = F, data = PlotWellSummary,
    method = "t.test"
  )
  
  stat.test <-
    stat.test %>%
    filter(
      Stimulation == StimulationX
    ) %>%
    ungroup() %>%
    select(
      group1,
      group2,
      p
    )
  
  PList <-
    stat.test %>%
    mutate(
      group = group1,
      group1 = group2,
      group2 = group
    ) %>%
    select(
      group1,
      group2,
      p
    )
  
  PList <- bind_rows(PList, stat.test)
  
  stat.test <- NULL
  stat.test <- bind_cols(MODIFIED_CELL_LINE_ORDER, MODIFIED_CELL_LINE_ORDER, rep(1, NROW(MODIFIED_CELL_LINE_ORDER)))
  names(stat.test) <- c("group1", "group2", "p")
  
  PList <- bind_rows(PList, stat.test)
  
  PList <-
    PList %>%
    mutate(
      group1 = factor(group1, levels = MODIFIED_CELL_LINE_ORDER),
      group2 = factor(group2, levels = MODIFIED_CELL_LINE_ORDER)
    ) %>%
    distinct()
  
  plot.stat.test <-
    PList %>%
    mutate(
      group2 = factor(group2, levels = rev(MODIFIED_CELL_LINE_ORDER))
    )
  
  setwd(GRAPHS_DIRECTORY)
  
  ggplot(
    plot.stat.test,
    aes(
      x = group1,
      y = group2,
      fill = p,
      label = round(p, 3)
    )
  ) +
    geom_tile() +
    geom_text() +
    scale_fill_distiller(
      palette = "RdYlBu",
      limits = c(0, 1)
    ) +
    labs(
      x = "Cell Line",
      y = "Cell Line",
      fill = "p-value",
      title =  paste(PlotMarker, StimulationX)
    ) +
    theme_classic() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
    ) +
    ggsave(
      paste(PlotMarker, StimulationX, "p-values.pdf"),
      height = 4,
      width = 6
    )
  
  setwd(TABLES_DIRECTORY)
  
  PList <- PList[order(PList$group2),]
  PList <- PList[order(PList$group1),]
  PList <- matrix(PList$p, nrow = 8)
  PList <- as_data_frame(PList)
  names(PList) <- CELL_LINE_ORDER
  setwd(TABLES_DIRECTORY)
  write.csv(PList, paste(PlotMarker, StimulationX, "p-values.csv"))
}
lapply(c("Unstimulated", "Stimulated"), PValuesFx)

# stat.test <- ggpubr::compare_means(
#   Nucleus2Cytosol_Means ~ CellLine, group.by = "Stimulation",  paired = F, data = PlotWellSummary,
#   method = "t.test"
# )
# 
# stat.test <-
#   stat.test %>%
#   filter(
#     p <= 0.05
#   )
# 
# stat.test$Marker = PlotMarker
# YPos <- 1100
# YPos <- YPos + YPos*.15*(1:NROW(stat.test)/2)

setwd(GRAPHS_DIRECTORY)

#Plot
ggplot() +
  geom_violin(
    data = PlotImageSummary%>%filter(Nucleus2Cytosol_Means <= 30),
    aes(
      x = CellLine,
      y = Nucleus2Cytosol_Means
    ),
    fill = "grey",
    color = "grey",
    scale = "width"
  ) +
  geom_point(
    data = PlotWellSummary,
    aes(
      x = CellLine,
      y = Nucleus2Cytosol_Means,
      fill = CellLine
    ),
    position = "jitter",
    color = "black",
    size = 3,
    shape = 21
  ) +
  geom_crossbar(
    data = PlotFinalSummary,
    aes(
      x = CellLine,
      y = Nucleus2Cytosol_Means,
      ymin = Nucleus2Cytosol_Means,
      ymax = Nucleus2Cytosol_Means
    ),
    width = 0.5
  ) +
  geom_errorbar(
    data = PlotFinalSummary,
    aes(
      x = CellLine,
      ymin = Nucleus2Cytosol_Means-Nucleus2Cytosol_Means_SEM,
      ymax = Nucleus2Cytosol_Means+Nucleus2Cytosol_Means_SEM
    ),
    width = 0.25
  ) + 
  scale_fill_manual(
    values = Colors
  ) +
  labs(
    x = "Cell Line",
    y = "Nucleus:Cytosol Means Ratio"
  ) +
  facet_wrap(
    ~ Stimulation
  ) +
  theme_classic() +
  theme(
    axis.title.x = element_blank(),
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1),
    strip.background = element_blank()
  ) +
  ggsave(
    paste(PlotMarker, "Nucleus2Cytosol_Means Violin.pdf"),
    height = 4,
    width = 9
  )
