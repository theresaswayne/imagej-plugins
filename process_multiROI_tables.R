# process_multiROI_tables.R
# calculate data from multimeasure tables

# Assumptions:
# 4 measurements (area, mean, intden, raw intden)
# Measure all slices, One row per slice
# Save row numbers (same as slice number)

# ---- Setup ----

require(tidyverse) # for data processing
require(stringr) # for string harvesting
require(tcltk) # for directory choosing


# ---- User opens a single results file ----

datafile <- tk_choose.files(default = "", caption = "Select the Results file",
                             multi = FALSE, filters = NULL, index = 1)
datadir <- dirname(datafile)

# read the data into a file
meas <- read_csv(file.path(datafile)) # errors result, but seems ok

# ---- Get data info ----


# based on our data assumptions, the number of ROIs is (cols - 2)/4
numROIs <- (ncol(meas) - 2)/4
print(numROIs)

# ---- Calculate sums through the stack ----

# get the sums of all the ROI columns
# for the "newer" macro we can assume the updated ROI names
# for more flexibility, just sum all numeric columns (including row numbers but who cares)

# meas_sums <- meas %>%
#   summarise(across(contains("ROI"), 
#                    list(sum = sum), na.rm=TRUE))

meas_sums <- meas %>%
  summarise(across(where(is.numeric), 
                   list(sum = sum), na.rm=TRUE))

# ---- Build a tidier table where each region is a row ----
# Cols: Label, ROI, Area sum, IntDen sum

# Label is a char vector with the label from the 1st row of original table
Label <- meas$Label[1]

# ROI is a numeric sequence vector of integers from 1 to the number of ROIs
Roi <- seq(1:numROIs)

# Measurements will be numeric vectors containing the data from each ROI in order
# We need to make sure these are in order before plucking them out
# Therefore we first make a table of each type of measurement.
# Then we extract the ROI number and link it to the data.
# Finally we merge the tables by ROI number.
# Later we might use some kind of list function to do this across all ROIs

# Area_sum contains the areas from each ROI
meas_areas <- meas_sums %>% 
  select(contains("Area"))
Area_cols <- colnames(meas_areas)

# get ROI names -- for new style ROI names (Area(ROI_1)_sum)
Area_rois <- str_replace(Area_cols, "Area\\(ROI_([0-9]{1,2})\\)_sum", "\\1") %>%
  as.numeric()

# get ROI names -- for old style ROI names (IJ default, Area1_sum)
# Area_rois <- str_replace(Area_cols, "Area([0-9]{1,2})_sum", "\\1") %>%
#   as.numeric()

# values are in the 1st row, all columns
Area_vals <- meas_areas[1,] %>% as.numeric()
Area_table <- bind_cols(ROI = Area_rois, Area = Area_vals)

# IntDen_sum contains IntDen, excluding RawIntDen, from each ROI
meas_intdens <- meas_sums %>% 
  select(contains("IntDen") & !contains("Raw"))
IntDen_cols <- colnames(meas_intdens)

# get ROI names -- for new style ROI names (IntDen(ROI_1)_sum)
IntDen_rois <- str_replace(IntDen_cols, "IntDen\\(ROI_([0-9]{1,2})\\)_sum", "\\1") %>%
  as.numeric()

# IntDen_rois <- str_replace(IntDen_cols, "IntDen([0-9]{1,2})_sum", "\\1") %>%
#   as.numeric()
IntDen_vals <- meas_intdens[1,] %>% as.numeric()
IntDen_table <- bind_cols(ROI = IntDen_rois, IntDen = IntDen_vals)

# merge the columns by the only common column, ROI
meas_tidy <- inner_join(Area_table, IntDen_table, by=NULL)

# Then compute a new column with the ratio, 
# and add the image name at the beginning
meas_tidy <- meas_tidy %>%
  mutate(Ratio = IntDen/Area) %>%
  mutate(Label = Label) %>%
  relocate(Label, .before=ROI)

# Then save the new table
# User selects the output directory

# ---- User chooses the output folder ----
outputDir <- tk_choose.dir(default = "", caption = "Please OPEN the output folder") # prompt user
nameLength <- nchar(basename(datafile)) - 4
outputFile = paste(substring(basename(datafile),1,nameLength),"tidied.csv")
write_csv(meas_tidy,file.path(outputDir, outputFile))



