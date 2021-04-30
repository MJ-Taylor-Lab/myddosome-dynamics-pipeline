# Staining pipeline

These scripts analyze multi-channel fluorescent cells from images to measurements. This pipeline has two segments: one for image processesing and another for statistical analysis. They may be used modularly. 

These scripts are for analyzing fluorescent cells acquired using fluorescent microscopy. These scripts take raw 16-bit image acquired using NIKON Elements (ND2) and perform from image processing to statistical analysis. This pipeline has two main steps which run sequentially, but may may also be used modularly. The full pipeline is to be run on multi-color data (e.g., GFP and RFP channel data).

Pipeline described in Deliz-Aguirre, Cao, et al. (2021) MyD88 oligomer size functions as a physical threshold to trigger IL1R Myddosome signaling. J. Cell Biol. https://doi.org/10.1083/jcb.202012071.

## Getting started

### Prerequisites

#### Operating System (OS))

The operating system must be UNIX-based (e.g., Mac, Linux) due to the terminal command prompts. VirutalBox (https://www.virtualbox.org/) may be used to run Ubuntu (Linux) inside a Windows computer.

#### ImageJ
**FIJI is Just Image J** (Schindelin, J.; Arganda-Carreras, I. & Frise, E. et al. (2012), "Fiji: an open-source platform for biological-image analysis", Nature methods 9(7): 676-682, PMID 22743772, doi:10.1038/nmeth.2019)
* MorphoLibJ (Legland, D.; Arganda-Carreras, I. & Andrey, P. (2016), "MorphoLibJ: integrated library and plugins for mathematical morphology with ImageJ", Bioinformatics (Oxford Univ Press) 32(22): 3532-3534, PMID 27412086, doi:10.1093/bioinformatics/btw413)

#### R
**R version 4.0.2 (2020-06-22)** R Core Team (2020). R: A language and environment for statistical computing. R Foundation for Statistical
Computing, Vienna, Austria. URL https://www.R-project.org/.
* parallel (RStudio Team (2020). RStudio: Integrated Development for R. RStudio, PBC, Boston, MA URL http://www.rstudio.com/)
* data.table (Matt Dowle and Arun Srinivasan (2019). data.table: Extension of `data.frame`. R package version 1.12.8. https://CRAN.R-project.org/package=data.table)
* ggnewscale (Elio Campitelli (2020). ggnewscale: Multiple Fill and Colour Scales in 'ggplot2'. R package version 0.4.1. https://CRAN.R-project.org/package=ggnewscale)
* ggplot2 (H. Wickham. ggplot2: Elegant Graphics for Data Analysis. Springer-Verlag New York, 2016.)
* ggpmisc (Pedro J. Aphalo (2019). ggpmisc: Miscellaneous Extensions to 'ggplot2'. R package version 0.3.3. ( https://CRAN.R-project.org/package=ggpmisc)
* scales (Hadley Wickham (2018). scales: Scale Functions for Visualization. R package version 1.0.0. https://CRAN.R-project.org/package=scales)
* tictoc (Sergei Izrailev (2014). tictoc: Functions for timing R scripts, as well as implementations of Stack and ( List structures.. R package version 1.0. https://CRAN.R-project.org/package=tictoc)
* tidyverse (Hadley Wickham (2017). tidyverse: Easily Install and Load the 'Tidyverse'. R package version 1.2.1. https://CRAN.R-project.org/package=tidyverse)
* zoo (Achim Zeileis and Gabor Grothendieck (2005). zoo: S3 Infrastructure for Regular and Irregular Time Series. Journal of Statistical Software, 14(6), 1-27. doi:10.18637/jss.v014.i06)

**RStudio** (RStudio Team (2020). RStudio: Integrated Development for R. RStudio, PBC, Boston, MA URL http://www.rstudio.com/)

**NOTE:** All required packages install themselves automatically on Step 8: UserInput.R during the "Setup" phase 

#### OPTIONAL: Sample Data Set (Both Input and Output)
Download data sets with https://zenodo.org/.

## Pipeline

For this pipeline, we contain the workflow inside a folder called "Staining". The path leading to "Staining" will be referred to in this document as "~". The image names will be refered to as *ImageName*. All images were captured using a confocal microscope.

Because FIJI is GUI-based, we used RStudio to dictate to the terminal which FIJI scripts to run. Since most FIJI functions do not run on parallel ("multi-core"), we executed several instances of the FIJI script. This was based on the number of cores of the comptuer.

Scripts A00-A07 are imaging processing scripts that run back to back. Scripts under A08 are focusd on statistical analysis. Script A09 circles which cells passed the filters of A08.

### Image processing

The image processing is executed by A00_StainingParallelProcessing.R. The input is as it follows:
* FIJI_PATH: Path of ImageJ
* SCRIPTS_DIRECTORY: Path to image procesing scripts
* IMAGES_PATH: Path to images
* RUN_NAME: Instructs computer whether to run a program (TRUE) or not (FALSE)

```
# User Input----
FIJI_PATH = "/Applications/Fiji.app/Contents/MacOS/ImageJ-macosx"
SCRIPTS_DIRECTORY = "~/image-analysis/Staining/00_Automated"
IMAGES_PATH = "~/Colocalization/ColocalizationPipeline/01_Unprocessed"
# Scripts to run ----
RUN_SPLIT_SERIES = FALSE
RUN_SPLIT_CHANNELS_DFRm = FALSE
RUN_FLAT_FIELD_GENERATOR = FALSE
RUN_FF_MEDIAN_REMOVE = FALSE
RUN_SEGMENTATION = FALSE
RUN_LABEL = FALSE
RUN_WELL_STITCH = TRUE
RUN_MEASUREMENTS = FALSE
RUN_NEW_LABELS = FALSE

```

A00_StainingParallelProcessing.R executes the following scripts:
* A01_SplitSeries.R calls A01_SplitSeries.ijm
  * Converts ND2 to TIFF
  * Splits multi-page multi-channel TIFF into single-page multi-channel TIFFs

* A02_SplitChannels-DFRm.R calls A02_SplitChannels-DFRm.ijm
 * Spits multi-channel TIFFs into single-channel TIFFs
 * Removes dark frame (camera noise) from images
 * The parameters are:
    * dir_df: path to dark-frame images
    * df_#: The # is the channel number. It is the dark-field image name
    * LUT_#: The # is the channel number. It is the LUT for the channel
    * numC: Number of channels
    * Marker_Channel: Channel of the marker (e.g., nuclear marker)
    * Mask_Channel: Channel of the mask (e.g., cytosolic marker)
    * Measuring_Channel: Channel to obtain measurements from (e.g., RelA stain)

```
# A02
dir_df = "~/Colocalization/ColocalizationPipeline/DarkFrames/"
LUT_0 = "Magenta"                         # C=0 LUT
df_0 = "AVG_20201026 Darkfield 100ms.tif" # C=0 Dark field name
LUT_1 = "Green"                           # C=1 LUT
df_1 = "AVG_20201026 Darkfield 200ms.tif" # C=1 Dark field name
LUT_2 = "Yellow"                          # C=2 LUT
df_2 = "AVG_20201026 Darkfield 100ms.tif" # C=2 Dark field name
# A03
numC = 3 # Number of channels
#A05
Marker_Channel = 0
Mask_Channel = 2
Measuring_Channel = 1
```

* A03_FlatFieldGenerator.R calls A03a_ImageFlatFieldGenerator.ijm and A03b_DateFlatFieldGenerator.ijm
 * Averages all images captured for each channel
 * The average images are median-blurred to generate the flat-field (illumination function) image. The median was used because it preserves edges
 * The dark-frame removed image is then divided by the flat-field image to flat-field correct the image
* A04_MedRm.R calls A04_MedRm.ijm
 * Generates a median blur of the image
 * Subtracts median blur from the flat-field removed image
* A05_Segmentation.R and A05_Segmentation.ijm
    * Imags are segmented using two channels: DAPI for determining the nucleus region and MyD88 for determining the cytosolic region 
* A06_Label.R and A06_Label.ijm
    * Marks the cytosol and nucleus boundaries in the image
* A07_WellPictureStitch.R
    * Stitches the wells together
    * The parameters are:
        * IMAGE_PIXEL_SIZE: Size of the image
        * IMAGES_PER_ROW: How many images were aquired per row for a well/sample
        * BIN_SIZE: How many pixels are averaged together. 2 would average 4 (2x2) pixels into one and 3 would avereage 9 (3x3) pixels into one. and This is done to reduce memory use so that the computer is not overloaded.
        * C#: Color of channel. Only "r", "g" and "b" allowed
        * FILE_ENDING: Ending of file name whose images are going to be stitched together
    
```
IMAGE_PIXEL_SIZE = 1200
IMAGES_PER_ROW = 13
BIN_SIZE = 2 #4x4
C0 = "b"
C1 = "r"
C2 = "g"
FILE_ENDING = "-DFRm-FFMedRm.tif"
```

* A09_NewLabel.R and A09_NewLabel.ijm
    * Marks the cytosol and nucleus boundaries of select cells (those that pass the filters) in the image
    * NOTE: Must be run after A08_Measurements.R
    

### Statistical analysis 
The statistical analysis is executed by A08_Measurements.R.  This script executes the following scripts:
* 01_Measurements.R
    * Pairs nucleus with cytosol using centroid distance
    * Filters cells: (1) whose nucleus centroid is far from the cytosol centroid, (2) whose cytosolic and nucleic radii are outside a defined range, (3) whose cytosolic and nuclear are too elliptic (i.e., circularity, eccentricity), (4) which are at the image boundary.
* 02_Summaries.R
    * Creates summaries of the statistics (e.g., mean nucleus intensity, mean cytosol intensity) for each cell, image, cell line and conditions
* 03_LowHigh.R
    * Generates plots comparing low to high ligand density
* 03_p-p38.R
    * Generates plots comparing the p-p38 nuclear intensity of unstimulated and stimulated cells
* 03_RelA.R
    * Generates plots comparing the RelA nuclear to cytosolic intensity of unstimulated and stimulated cell

## Versioning
We use GitHub for versioning.

## Author
* Rafael Deliz-Aguirre - All scripts
