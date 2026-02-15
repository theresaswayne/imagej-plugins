# shuffle_labels.R
# R script to randomize object labels and recalculate distances 

# ---- Parameters ----
distCriterion = 1.2 # center-center distance in MICRONS to define association
trials = 1000 # number of shuffles to do

# ---- Setup ----
require(tidyverse)
require(spatstat) # maybe in future because it is more sophisticated
require(RANN) # for nearest neighbor analysis
require(ggplot2) # for plot


# prompt for a file
origFile = file.choose()
inputFolder <- dirname(origFile) # the input is the parent of the selected file

# Read the data from the file
origData <- read_csv(origFile,
                       locale = locale())

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

##nn2 nearest neighbor
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
  
  # append to resuts
  results[i] <- shufColoc
}

# rank the actual results vs the shuffled
results_plus_expt <- c(results, totalColoc)
expt_rank_pct <- percent_rank(results_plus_expt)[match(totalColoc, results_plus_expt)]
confInts <- quantile(results_plus_expt, probs = c(0.05, 0.95))

# visualize results
#hist(results)
#hist(results, breaks = seq(0:nupCount+1), right=FALSE) # shows counts of 1 between 1 and 2, etc.

#  histogram
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
nupNearErgDF <- data.frame("NeighborIndex" = nn2_idx, "Distance" = nn2_dists)

outputNearest = paste0("nearest",crit,".csv")
write_csv(nupNearErgDF,file.path(inputFolder, outputNearest))
outputTrials = paste0("simulations",crit,".csv")
write_csv(as.data.frame(results),file.path(inputFolder, outputTrials))
outputHisto = paste0("simulations_plot",crit,".png")
ggsave(file.path(inputFolder, outputHisto))
