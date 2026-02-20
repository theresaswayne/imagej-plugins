# shuffle_labels_batch.R

# Theresa Swayne, Columbia University, 2026
# -------- Suggested text for acknowledgement -----------
#   "These studies used the Confocal and Specialized Microscopy Shared Resource 
#   of the Herbert Irving Comprehensive Cancer Center at Columbia University, 
#   funded in part through the NIH/NCI Cancer Center Support Grant P30CA013696."

# --------- About this script ------------
# R script to randomize object labels and recalculate distances for all files in a folder

# Input: A folder of csv files from find_object_associations.ijm (table of positions of all objects). 
# The parameter filenameString is used to select files
# Remove the M_ from the filename for nicer output.

# ---- Parameters ----
distCriterion = 0.4 # center-center distance in MICRONS to define association
trials = 1000 # number of shuffles to do
filenameString = "*_allMeas.csv"

# ---- Setup and load data ----

require(tidyverse) # for data processing
require(stringr) # for string harvesting
require(tools) # for file name processing
require(spatstat) # maybe in future because it is more sophisticated
require(RANN) # for nearest neighbor analysis
require(ggplot2) # for plot
require(stringr) # for string manipulations

# ---- Input and output setup ----

# Prompt for a file. No message will be displayed. Choose one of the files in the folder.
selectedFile <- file.choose()
inputFolder <- dirname(selectedFile) # the input is the parent of the selected file

# Create an output folder with time-date stamp

thisTime = format(Sys.time(),"%Y-%m-%d_%H%M")
outputFolder <- file.path(inputFolder,paste0("Output_",thisTime))
dir.create(outputFolder) # creates within the input folder if it does not already exist

# Get names of CSV files in the folder
# change the pattern if needed to match other file types

files <- list.files(inputFolder, pattern = filenameString)
files <- sort(files)

# ----- Function to process a single file ------

process_file_func <- function(f, out) {
  
  # read the file
  origData <- read_csv(file.path(inputFolder, f),locale = locale())

  # Retrieve the file name
  substringLength <- nchar(basename(f))-12
  imageName <- substring(basename(f), 1,substringLength)
  
  # Parse the object names
  type <- substr(origData$Name, 0, 3)
  
  dataWithGroups <- origData %>% mutate(Group = type, .after = Name)
  
  # ---- Find how many in each population ----
  
  nupCount <- sum(dataWithGroups$Group == "Nup")
  ergCount <- sum(dataWithGroups$Group == "Erg")
  
  # ---- Calculate distances based on the original data
  
  origGroups <- dataWithGroups$Group
  
  # generate datasets
  nups <- dataWithGroups %>% filter(Group == "Nup") %>% select(c("CX (unit)", "CY (unit)", "CZ (unit)"))
  ergs <- dataWithGroups %>% filter(Group == "Erg") %>% select(c("CX (unit)", "CY (unit)", "CZ (unit)"))
  
  ##nn2 nearest neighbor -- do only if there are objects in both sets
  
  if (nupCount != 0 & ergCount != 0) {
    #ergNearNup <- nn2(nups, query=ergs, k=1, searchtype = "radius", radius = distCriterion) # produces an output with n(erg) evaluations
    nupNearErg <- nn2(ergs, query=nups, k=1, searchtype = "radius", radius = distCriterion) # this is what we want, n(nup) evaluations
    
    # If there are no neighbours then nn.idx will contain 0 and nn.dists will contain 1.340781e+154 for that point.
    totalColoc <- sum(nupNearErg[[1]] != 0) # looks at the nn.idx showing the index of the rows that are closest
    
    # Monte Carlo simulation
    
    # vector to store results
    results = numeric(trials)
    
    for (i in 1:trials) {
      
      # resample randomly without replacement
      shuffledGroups <-sample(origGroups)
      
      # check count
      #nupShuf <- sum(shuffledGroups == "Nup")
      
      # generate datasets
      shufNups <- dataWithGroups %>% filter(shuffledGroups == "Nup") %>% select(c("CX (unit)", "CY (unit)", "CZ (unit)"))
      shufErgs <- dataWithGroups %>% filter(shuffledGroups == "Erg") %>% select(c("CX (unit)", "CY (unit)", "CZ (unit)"))
      
      ##nn2 nearest neighbor
      shufNupNearErg <- nn2(shufErgs, query=shufNups, k=1, searchtype = "radius", radius = distCriterion) # this is what we want, n(nup) evaluations
      
      # If there are no neighbours then nn.idx will contain 0 and nn.dists will contain 1.340781e+154 for that point.
      shufColoc <- sum(shufNupNearErg[[1]] != 0) # looks at the nn.idx showing the index of the rows that are closest
      
      # append to results
      results[i] <- shufColoc
    }
    
    # rank the actual results vs the shuffled
    results_plus_expt <- c(results, totalColoc)
    expt_rank_pct <- percent_rank(results_plus_expt)[match(totalColoc, results_plus_expt)]
    confInts <- quantile(results_plus_expt, probs = c(0.05, 0.95))
    
    # create an output table comparing experimental to shuffled
    summary <- data.frame(Filename = imageName)
    summary <- summary %>% 
      mutate(NupCount = nupCount) %>%
      mutate(ErgCount = ergCount)
    
    summary <- summary %>%
      mutate(NupColoc = totalColoc) %>%
      mutate(FxnNupColoc = totalColoc/nupCount) %>%
      mutate(SimColoc = mean(results)) %>%
      mutate(FxnSimColoc = mean(results)/nupCount) %>% 
      
    
    
    # visualize results as histogram
    p <- ggplot(as.data.frame(results), aes(x=results)) + 
      geom_histogram(binwidth=1) +
      geom_vline(xintercept = confInts[1], color = "red", alpha = 0.5, linetype = "dashed", linewidth = 2) +
      geom_vline(xintercept = confInts[2], color = "red", alpha = 0.5, linetype = "dashed", linewidth = 2) +
      geom_vline(xintercept = totalColoc, color = "blue", alpha = 0.5)
    
    # save results
    
    # remove any dot from criterion
    crit <- paste0(c("_within_"),str_replace(as.character(distCriterion), "\\.","x"))
    
    # unnest the nn2 results
    nn2_idx <- nupNearErg[[1]]
    nn2_dists <- nupNearErg[[2]]
    nupNearErgDF <- data.frame("NupIndex" = seq(1:nupCount), "NeighborIndex" = nn2_idx, "Distance" = nn2_dists)
    
    outputSumm = paste0(imageName,"_summary", crit, ".csv")
    write_csv(summary, file.path(out, outputSumm))
    outputNearest = paste0(imageName,"_nearest",crit,".csv")
    write_csv(nupNearErgDF,file.path(out, outputNearest))
    outputTrials = paste0(imageName,"_simulations",crit,".csv")
    write_csv(as.data.frame(results),file.path(out, outputTrials))
    outputHisto = paste0(imageName,"_simulations_plot",crit,".png")
    ggsave(file.path(out, outputHisto))
  } # end NN routine
  
  else {
    print(paste0("Image ",imageName, " contains one or more empty object sets and was not processed."))
  }
  
  
  return()
} # end of process file function


# ---- Run the function on each file ----

for (file in files){
  process_file_func(file, outputFolder)
}

