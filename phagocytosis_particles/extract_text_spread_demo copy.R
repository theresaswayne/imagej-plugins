# extract_text_demo.R
# extract text using regular expressions and stringr
# e.g. pull information from a text column in a results table
# TCS 2019

require(stringr)
require(tidyverse)

# sample names containing info, e.g. labels from ImageJ analysis

label <- c("C1-synuclein phago test2_syn mono 1 - Aligned-MaxIP-1-t1",
             "synuclein phago test2_syn mono 1 - Aligned-MaxIP-1-t1-Particles inside",
             "synuclein phago test2_syn mono 1 - Aligned-MaxIP-1-t1-Total particles",
             "C1-synuclein phago test2_syn mono 1 - Aligned-MaxIP-1-t2",
             "synuclein phago test2_syn mono 1 - Aligned-MaxIP-1-t2-Particles inside",
             "synuclein phago test2_syn mono 1 - Aligned-MaxIP-1-t2-Total particles")

# sample data that we ultimately want to associate with times
count <- c(85,71,102,85,75,115)

# str_match returns the matching text in column 1 and the capture group (in parens) in column 2
# we only want column 2 here.

time <- str_match(label, "-t([0-9]*)")[,2]

# extract the info telling us which type of measurement it is
type_in <- str_match(label, "Particles inside")[,1]
type_total <- str_match(label, "Total particles")[,1]
type_cells <- str_match(label, "[0-9]$")[,1]

# transform all non-NA values in type_cells to "Total cells"
type_cells <- replace(type_cells,!is.na(type_cells), "Total cells")

# merge the measurement types into a single column (inelegantly)
types <- cbind(type_in, type_total, type_cells)
merged_types <- ifelse(!is.na(type_in), type_in, type_total)
merged_types <- ifelse(!is.na(type_cells), type_cells, merged_types)

# make the extracted times and measurement types into new columns
df <- data.frame(label, time, merged_types, count)

# make a column consistently identifying the filename
df$label <- gsub("-t[0-9]*", "", df$label)
df$label <- gsub("-Particles inside", "", df$label)
df$label <- gsub("-Total particles", "", df$label)
df$label <- gsub("C1-", "", df$label)

# Reshape the table so that each timepoint is a row and the types become variables

df_spread <- spread(df, merged_types, count)
