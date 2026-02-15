# shuffle_labels.R
# R script to randomize object labels and recalculate distances 

# ---- Parameters ----
distCriterion = 10 # center-center distance in PIXELS to define association
# TODO: Add columns for um coords in Fiji macro and then do this in um
trials = 100 # number of shuffles to do

# ---- Setup ----
require(tidyverse)
require(spatstat) # maybe in future because it is more sophisticated
require(RANN) # for nearest neighbor analysis


# prompt for a file
origFile = file.choose()
inputFolder <- dirname(selectedFile) # the input is the parent of the selected file

# Read the data from the file
origData <- read_csv(objectFile,
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
nups <- dataWithGroups %>% filter(Group == "Nup") %>% select(c("CX (pix)", "CY (pix)", "CZ (pix)"))
ergs <- dataWithGroups %>% filter(Group == "Erg") %>% select(c("CX (pix)", "CY (pix)", "CZ (pix)"))

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
  shufNups <- dataWithGroups %>% filter(shuffledGroups == "Nup") %>% select(c("CX (pix)", "CY (pix)", "CZ (pix)"))
  shufErgs <- dataWithGroups %>% filter(shuffledGroups == "Erg") %>% select(c("CX (pix)", "CY (pix)", "CZ (pix)"))
  
  ##nn2 nearest neighbor
  shufNupNearErg <- nn2(shufErgs, query=shufNups, k=1, searchtype = "radius", radius = distCriterion) # this is what we want, n(nup) evaluations
  
  # If there are no neighbours then nn.idx will contain 0 and nn.dists will contain 1.340781e+154 for that point.
  shufColoc <- sum(shufNupNearErg[[1]] != 0) # looks at the nn.idx showing the index of the rows that are closest
  
  # append to resuts
  results[i] <- shufColoc
}

# visualize results
hist(results)
#hist(results, breaks = seq(0:nupCount+1), right=FALSE) # shows counts of 1 between 1 and 2, etc.

#ones <- sum(results == 1)
#twos <- sum(results == 2)

# rank the actual results vs the shuffled
results_plus_expt <- c(results, totalColoc)
expt_rank_pct <- percent_rank(results_plus_expt)[match(totalColoc, results_plus_expt)]
confInts <- quantile(results_plus_expt, probs = c(0.05, 0.95))
