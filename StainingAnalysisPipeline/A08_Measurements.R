cat(
  "To cite this work, please use:

  Deliz-Aguirre, Cao, et al. (2021) MyD88 oligomer size functions as a
       physical threshold to trigger IL1R Myddosome signaling.
       J. Cell Biol. https://doi.org/10.1083/jcb.202012071"
)


# Copyright 2020-21 (c) Rafael Deliz-Aguirre
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the 'Software'), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#Makes a list of all cells, recording their path, area and initial intensity (i.e., "background")
#Uses data exported from 01_TIFF-Subtract.ijm

# Adapt scripts----
TABLES_DIRECTORY = file.path(IMAGES_PATH, "Tables")
dir.create(TABLES_DIRECTORY)
SCRIPTS_DIRECTORY =
  ifelse(
    basename(SCRIPTS_DIRECTORY) == "08_Measurements",
    SCRIPTS_DIRECTORY,
    file.path(SCRIPTS_DIRECTORY, "08_Measurements")
  )

# Libraries----
pacman::p_unload(pacman::p_loaded(), character.only = TRUE)

#Install libraries if not installed and load them
if("dplyr" %in% rownames(installed.packages()) == FALSE) {install.packages("dplyr")}
library(dplyr)
if("tidyr" %in% rownames(installed.packages()) == FALSE) {install.packages("tidyr")}
if("parallel" %in% rownames(installed.packages()) == FALSE) {install.packages("parallel")}
library(parallel)
if("rlist" %in% rownames(installed.packages()) == FALSE) {install.packages("rlist")}
library(rlist)
if("ggplot2" %in% rownames(installed.packages()) == FALSE) {install.packages("ggplot2")}
library(ggplot2)
if("ggpubr" %in% rownames(installed.packages()) == FALSE) {install.packages("ggpubr")}
library(ggpubr)
if("stringr" %in% rownames(installed.packages()) == FALSE) {install.packages("stringr")}
library(stringr)
if("data.table" %in% rownames(installed.packages()) == FALSE) {install.packages("data.table")}
if("zoo" %in% rownames(installed.packages()) == FALSE) {install.packages("zoo")}

#For getting characters left of 
substrLeft = function(text, num_char) {
  substr(text, 1, num_char)
}
#For getting characters right of 
substrRight <- function(word, n.characters){
  substr(word, nchar(word)-n.characters+1, nchar(word))
}
#For getting the file extension type
getType <- function (file)
{
  pos <- regexpr("\\.([[:alnum:]]+)$", file)
  ifelse(pos > -1L, substring(file, pos + 1L), "")
}

my.localminima <- function(x) {
  # Use -Inf instead if x is numeric (non-integer)
  y <- diff(c(.Machine$integer.max, x)) > 0L
  rle(y)$lengths
  y <- cumsum(rle(y)$lengths)
  y <- y[seq.int(1L, length(y), 2L)]
  if (x[[1]] == x[[2]]) {
    y <- y[-1]
  }
  y
}

#Calculate nucleus min area
MIN_NUCLEUS_AREA = pi*(MIN_NUCLEUS_DIAMETER/2)^2

#Scientific notation
options(scipen = 9)

# Scripts ----
if(RUN_TABLE_MEASUREMENTS==TRUE){
  setwd(SCRIPTS_DIRECTORY)
  print("Running script 01_Measurements.R")
  source("01_Measurements.R", local = T)
} else{
  Measurements <-
    data.table::fread(
      file.path(TABLES_DIRECTORY, "Measurements.csv.gz")
    )
  # Give cell line order
  Measurements$WellNumber <- as.factor(Measurements$WellNumber)
  Measurements$CellLine <- factor(Measurements$CellLine, levels = CELL_LINE_ORDER)
  CELL_LINE_NAME_ORDER = unique(word(CELL_LINE_ORDER, 1))
  Measurements$CellLineName <- factor(Measurements$CellLineName, levels = CELL_LINE_NAME_ORDER)
  CELL_LINE_NUMBER_ORDER = c("", word(CELL_LINE_ORDER, 2)[2:NROW(CELL_LINE_ORDER)])
  Measurements$CellLineNumber <- factor(Measurements$CellLineNumber, levels = CELL_LINE_NUMBER_ORDER)
}

setwd(SCRIPTS_DIRECTORY)
print("Running script 02_Summaries.R")
source("02_Summaries.R", local = T)

if(RUN_GRAPHS==TRUE){
  
  GRAPHS_DIRECTORY = file.path(IMAGES_PATH, "Graphs")
  dir.create(GRAPHS_DIRECTORY)
  
  tryCatch({
    setwd(SCRIPTS_DIRECTORY)
    print('Running 03_p-p38.R')
    source('03_p-p38.R', local = T)
  }, error = function(e){print("     ERROR with 03_p-p38.R")})
  
  tryCatch({
    setwd(SCRIPTS_DIRECTORY)
    print('Running 03_p-p38.R')
    source('03_p-p38.R', local = T)
  }, error = function(e){print("     ERROR with 03_p-p38.R")})
  
}
