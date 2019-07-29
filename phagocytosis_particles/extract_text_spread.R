# extract_text_spread.R
# extract text using regular expressions and stringr
# e.g. pull information from a text column in an ImageJ results or summary table
# TCS 2019

require(stringr)
require(tidyverse)
require(tools) # for file extension identification

# load file
mydatafile <- file.choose()
mydata <- read.csv(mydatafile) # we have the full file path

# sample names containing info, e.g. labels from ImageJ analysis

# labels are first column
label <- mydata[,1]

# counts are second column
count <- mydata[,2]

# str_match returns the matching text in column 1 and the capture group (in parens) in column 2
# we only want column 2 here.

time <- str_match(label, "-t([0-9]*)")[,2]

# extract the info telling us which type of measurement it is
type_in <- str_match(label, "Particles inside")[,1]
type_total <- str_match(label, "Total particles")[,1]
type_cells <- str_match(label, "Nuclei")[,1]

# merge the measurement types into a single column (inelegantly)
types <- cbind(type_in, type_total, type_cells)

# build the "merged types" column:
# if there is a value in the "particles inside" column, take that, otherwise take the value in the "cells" column
merged_types <- ifelse(!is.na(type_in), type_in, type_cells)

# if there is a value in the "total particles" column, take that, otherwise take what is already defined
merged_types <- ifelse(!is.na(type_total), type_total, merged_types)

# make the extracted times and measurement types into new columns
df <- data.frame(label, time, merged_types, count)

# make a column consistently identifying the filename
df$label <- gsub("-t[0-9]*", "", df$label)
df$label <- gsub("-Particles inside", "", df$label)
df$label <- gsub("-Total particles", "", df$label)
df$label <- gsub("-Nuclei", "", df$label)
df$label <- gsub("C1-", "", df$label)

# Reshape the table so that each timepoint is a row and the types become variables
# Not sure what determines the order of the columns 
df_spread <- spread(df, merged_types, count)

# save the table in the same directory
parentDir <- dirname(mydatafile)

fileName <- file_path_sans_ext(basename(mydatafile))

outputFile = paste(fileName, "reformatted.csv") # spaces will be inserted
write_csv(df_spread,file.path(parentDir, outputFile))

