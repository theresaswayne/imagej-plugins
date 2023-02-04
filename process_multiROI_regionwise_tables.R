# process_multiROI_regionwise_tables.R
# calculate data from multimeasure tables

# Assumptions:
# There are 2 files, numerator and denominator, with Num and Denom in their names
# The files are in the same subdirectory
# 4 measurements (area, mean, intden, raw intden)
# Measure all slices, One row per slice
# Save row numbers (same as slice number)

# ---- Setup ----

require(tidyverse) # for data processing
require(stringr) # for string harvesting
require(tcltk) # for directory choosing

# ---- User opens the two results files ----

datafiles <- tk_choose.files(default = "", caption = "Use Ctrl-click to select BOTH the numerator and denominator files",
                multi = TRUE, filters = NULL, index = 1)
datadir <- dirname(datafiles)[1] # IMPORTANT select just one of the directories (they are the same)
# note if datadir was not reduced to 1 element, it would read the table multiple times into the same dataframe!

datanames <- basename(file.path(datafiles)) # file names without directory names


# read the numerator and denominator files
numfile <- datanames[grepl("Num", datanames)]
nummeas <- read_csv(file.path(datadir,numfile)) 

denomfile <- datanames[grepl("Denom", datanames)]
denommeas <- read_csv(file.path(datadir,denomfile)) 

# ---- Get data info ----

# based on our data assumptions, the number of ROIs is (cols - 2)/4
numROIs <- (ncol(nummeas) - 2)/4

# ---- Calculate sums through the stack ----

# get the sums of all the ROI columns
# for the "newer" macro we can assume the updated ROI names
# for more flexibility, just sum all numeric columns (including row numbers but who cares)

# num_sums <- nummeas %>%
#   summarise(across(contains("ROI"),
#                    list(sum = sum), na.rm=TRUE))
# 
# denom_sums <- denommeas %>%
#   summarise(across(contains("ROI"),
#                    list(sum = sum), na.rm=TRUE))

num_sums <- nummeas %>%
  summarise(across(where(is.numeric),
                   list(sum = sum), na.rm=TRUE))

denom_sums <- denommeas %>%
  summarise(across(where(is.numeric),
                   list(sum = sum), na.rm=TRUE))

# ---- Build a tidier table where each region is a row ----
# Cols: Label, ROI, Area sum, IntDen sum

# Label is a char vector with the label from the 1st row of original table
Label <- nummeas$Label[1]

# ROI is a numeric sequence vector of integers from 1 to the number of ROIs
Roi <- seq(1:numROIs)

# Measurements will be numeric vectors containing the data from each ROI in order
# We need to make sure these are in order before plucking them out
# Therefore we first make a table of each type of measurement.
# Then we extract the ROI number and link it to the data.
# Finally we merge the tables by ROI number.
# Later we might use some kind of list function to do this across all ROIs

# Area_sum contains the areas from each ROI
num_areas <- num_sums %>% 
  select(contains("Area"))
numArea_cols <- colnames(num_areas)
denom_areas <- denom_sums %>% 
  select(contains("Area"))
denomArea_cols <- colnames(denom_areas)

# get ROI names -- for new style ROI names (Area(ROI_1)_sum)
numArea_rois <- str_replace(numArea_cols, "Area\\(ROI_([0-9]{1,2})\\)_sum", "\\1") %>%
  as.numeric()
denomArea_rois <- str_replace(denomArea_cols, "Area\\(ROI_([0-9]{1,2})\\)_sum", "\\1") %>%
  as.numeric()

# get ROI names -- for old style ROI names (IJ default, Area1_sum)
# numArea_rois <- str_replace(numArea_cols, "Area([0-9]{1,2})_sum", "\\1") %>%
#   as.numeric()
# denomArea_rois <- str_replace(denomArea_cols, "Area([0-9]{1,2})_sum", "\\1") %>%
  #   as.numeric()

# values are in the 1st row, all columns
numArea_vals <- num_areas[1,] %>% as.numeric()
numArea_table <- bind_cols(ROI = numArea_rois, Num_Area = numArea_vals)
denomArea_vals <- denom_areas[1,] %>% as.numeric()
denomArea_table <- bind_cols(ROI = denomArea_rois, Denom_Area = denomArea_vals)

# IntDen_sum contains IntDen, excluding RawIntDen, from each ROI
num_intdens <- num_sums %>% 
  select(contains("IntDen") & !contains("Raw"))
numIntDen_cols <- colnames(num_intdens)
numIntDen_rois <- str_replace(numIntDen_cols, "IntDen\\(ROI_([0-9]{1,2})\\)_sum", "\\1") %>%
  as.numeric()
# numIntDen_rois <- str_replace(numIntDen_cols, "IntDen([0-9]{1,2})_sum", "\\1") %>%
#   as.numeric()
numIntDen_vals <- num_intdens[1,] %>% as.numeric()
numIntDen_table <- bind_cols(ROI = numIntDen_rois, Num_IntDen = numIntDen_vals)

denom_intdens <- denom_sums %>% 
  select(contains("IntDen") & !contains("Raw"))
denomIntDen_cols <- colnames(denom_intdens)
denomIntDen_rois <- str_replace(denomIntDen_cols, "IntDen\\(ROI_([0-9]{1,2})\\)_sum", "\\1") %>%
  as.numeric()
# denomIntDen_rois <- str_replace(denomIntDen_cols, "IntDen([0-9]{1,2})_sum", "\\1") %>%
#   as.numeric()
denomIntDen_vals <- denom_intdens[1,] %>% as.numeric()
denomIntDen_table <- bind_cols(ROI = denomIntDen_rois, Denom_IntDen = denomIntDen_vals)

# merge the columns by the only common column, ROI
# calculate the weighted mean intensity for num and denom
num_tidy <- inner_join(numArea_table, numIntDen_table, by=NULL) %>%
  mutate(Num_WeightedMean = Num_IntDen/Num_Area)
denom_tidy <- inner_join(denomArea_table, denomIntDen_table, by=NULL) %>%
  mutate(Denom_WeightedMean = Denom_IntDen/Denom_Area)
combined_tidy <- inner_join(num_tidy, denom_tidy)

# Then compute new column with the ratio, 
# and add back the image name at the beginning
combined_tidy <- combined_tidy %>%
  mutate(Ratio = Num_WeightedMean/Denom_WeightedMean) %>%
  mutate(Label = Label) %>%
  relocate(Label, .before=ROI)

# Then save the new table
# User selects the output directory

# ---- User chooses the output folder ----
outputDir <- tk_choose.dir(default = "", caption = "Please OPEN the output folder") # prompt user
nameLength <- nchar(basename(numfile)) - 4
outputFile = paste(substring(basename(numfile),1,nameLength),"tidied.csv")
write_csv(combined_tidy,file.path(outputDir, outputFile))

# TODO: Adapt the same idea to take 2 input files (Num and Denom) and calculate appropriately



