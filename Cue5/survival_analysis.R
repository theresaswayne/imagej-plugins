# R script to generate survival curves from cell interaction data
# Assumptions:
# CSV data from multiple timepoints are merged 
# Cols: filename, Label, timepoint and other data (not needed)
# Label column data is of the format objA1_objB7 
# Outputs:
# number of objects in the A class that show interactions
# number of objects in the A class that show persistent interactions 

# To use: 
# 1) Generate a merged colocalization file for one imaging field using combine_csv_files_with_num.R
# 2) Edit Parameters section (object names, time window, interaction threshold) as needed
# 3) Source the script; when prompted, open the merged colocalization file

# ---- Setup ----

require(tidyverse) # for data processing
require(stringr) # for string harvesting
require(RcppRoll) # for scanning interactions
require(xfun) # for filename manipulation
require(survival) # for survival analysis
require(survminer) # for survival analysis
require(ggplot2) # for survival output
require(broom) # for survival output
 
# ---- Parameters ----
# change these as needed 

# object A represents a Treg and object B represents a fibroblast
objAname = "Treg"
objBname = "Fibroblast"

# time window size (units = timepoints) for checking persistence of interactions
# threshold is the number of interactions within that window to be considered consistent
# if time window == threshold, then you must have that many consecutive interactions
# if time window > threshold, then the interactions may be non-consecutive but must occur within the window

timeWindow <- 22
threshold <- 8

# ---- Get the data ----
# no message will be displayed. Choose the file to analyze
selectedFile <- file.choose()
parentFolder <- dirname(selectedFile) # parent of the selected file
df <- read_csv(selectedFile)

# ---- Reformat the data ----

# remove unneeded columns
df <- df %>% 
  select(filename, Label, timepoint) # all rows

# split Label to identify object names
# format: objA1_objB7
df <- df %>%
  separate_wider_delim("Label", delim="_", names=c("ObjA", "ObjB"))

# get the Object A numbers by capturing what's after "objA"
Anums <- str_replace(df$ObjA, "objA(.*)", "\\1")

# get the Object B numbers by capturing what's after "objB"
Bnums <- str_replace(df$ObjB, "objB(.*)", "\\1")

# substitute the cleaned data for the original
df <- df %>% mutate(ObjA = Anums,
                    ObjB = Bnums)

# ---- Count interactions ----

# total interactions per timepoint
intPerTime <- df %>% 
  count(timepoint)

# total interactions per T cell (objA)
intPerA <- df %>%
  count(ObjA) %>% 
  arrange(as.integer(ObjA))

# ---- Generate table of interactions across time ----

timepoints <- min(df$timepoint):max(df$timepoint) # unique row for each timepoint

objA_IDs <- as.character(sort(as.integer(unique(df$ObjA)))) # all the interacting objects across the dataset

# create a logical vector for each objA containing the interacting timepoints for a single object
# and assemble these into a table of interactions over time

intxns <- data.frame("t" = timepoints) # this serves as the 1st col

for (obj in objA_IDs) {
  # objInts and objTimes = temporary variables
  objInts <- df %>% 
    filter(ObjA == obj) # select rows pertaining to one objA
  objTimes <- timepoints %in% objInts$timepoint # boolean: at which timepoints was that object interacting?
  intxns[[paste0("",obj)]] <- objTimes # add a column showing interaction status for that object
}

# check the total calculation (compare to intPerA above)
intPerALogical <- intxns[,-1]  #omit the t column
intPerALogical <- intPerALogical %>% 
  pivot_longer(cols = everything(), names_to = "ObjA", values_to = "val") %>%
  group_by(ObjA) %>%
  summarise(Total = sum(val)) %>% 
  arrange(as.integer(ObjA))

# calculate a rolling sum along the logical vector

# function to return TRUE if any rolling sums 
#  within the time window meet or exceed the threshold 
#  (may be consecutive or non-consecutive contacts)

intxnsWithoutT <- intxns[,-1] # omit the t column
persist <- intxnsWithoutT %>%
  summarise_all(function(x) {
    ifelse(max(roll_sum(x, n = timeWindow, weights = NULL, fill = numeric(0),
                        partial = FALSE, align = "left", normalize = TRUE,
                        na.rm = FALSE)) >= threshold, TRUE, FALSE)
  })

# ---- Calculate % persistence ----

# pivot the table to get the number and % persistent
persistSummary <- persist %>% 
  pivot_longer(cols = everything(), names_to = "ObjA", values_to = "Persistent")

totalIntxns <- nrow(persistSummary)
totalPersistent <- sum(persistSummary$Persistent == TRUE)
fracPersistent <- totalPersistent/totalIntxns

# ---- Survival analysis ----

# start with the table of interactions
# filter for those objects undergoing persistent interactions
# for each object, we will analyze the first interaction only
# -- assuming that each Treg is unlikely to interact with multiple Fbs
# -- this in turn assumes tracking is accurate (same Fb is always assigned the same object number)

# create an empty table to hold the results
survData <- data.frame(ObjA = character(),
                       Duration = double(),
                       Status = double(),
                       stringsAsFactors = FALSE)

# which objAs have persistent interactions?
persistObjs <- persistSummary$ObjA[persistSummary$Persistent == TRUE]
persistObjs <- as.character(sort(as.integer(unique(persistObjs)))) 

for (obj in persistObjs) {
  # select the object column and find the start time (earliest timepoint of interaction)
  intxnTimes <- intxns %>% 
    filter(intxns[[obj]] == TRUE)
  intxnStart <- min(intxnTimes$t)
  
  # find the end time of that interaction and the total duration
  laterTimes <- intxns %>% filter(t > intxnStart)
  intxnEnd <- min(laterTimes$t[laterTimes[[obj]] == FALSE])
  
  # handle interactions at end of expt
  # set status 1 = event (end of interaction), 0 = censored (still "alive" at end of experiment)
  if(is.infinite(intxnEnd)) {
    status <- 0
    }
  else {
    status <- 1
    }
  intxnDur <- intxnEnd - intxnStart
  # create a new row in the data table 
  survData <- survData %>% add_row(ObjA = obj,
          Duration = intxnDur, 
          Status = status)
  }

# fit and plot the survival curve using Kaplan-Meier method
fit1 <- survfit(Surv(Duration, Status) ~ 1, data=survData)
p <- ggsurvplot(fit1, data = survData, risk.table = FALSE,
                submain = "Kaplan-Meier survival curve",
)
# ---- Create output ----

resultHeaders <- c("Filename", "Window", "Threshold", "Total Interacting",  "Persistent Interacting","Fraction Persistent")
resultValues <- c(basename(selectedFile), timeWindow, threshold, totalIntxns, totalPersistent, fracPersistent)
resultTable <- data.frame(rbind(resultHeaders, resultValues))
names(resultTable) <- resultTable[1,]
resultTable <- resultTable[-1,]

# intxns 
intxnFile = paste(sans_ext(basename(selectedFile)), "_interactions_",timeWindow, "_",threshold,".csv", sep = "")
write_csv(intxns,file.path(parentFolder, intxnFile))

# survival table
survTable = paste(sans_ext(basename(selectedFile)), "_surv_",timeWindow, "_",threshold,".csv", sep = "")
write_csv(survData,file.path(parentFolder, survTable))

# survival fit table
survSumm <- tidy(fit1)
survFit = paste(sans_ext(basename(selectedFile)), "_survFit_",timeWindow, "_",threshold,".csv", sep = "")
write_csv(survSumm,file.path(parentFolder, survFit))

# survival plot
plotFile = paste(sans_ext(basename(selectedFile)), "_plot_",timeWindow, "_",threshold,".png", sep = "")
ggsave(filename = plotFile, path = parentFolder)

# persistSummary (which objects showed persistent interactions)
persistFile = paste(sans_ext(basename(selectedFile)), "_persistence_",timeWindow, "_",threshold,".csv", sep = "")
write_csv(persistSummary,file.path(parentFolder, persistFile))

# summary (final calculations)
resultFile = paste(sans_ext(basename(selectedFile)), "_summary_",timeWindow, "_",threshold,".csv", sep = "")
write_csv(resultTable,file.path(parentFolder, resultFile))

