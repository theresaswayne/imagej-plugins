# commands for processing count results from ImageJ, e.g. 
#  a merged dataset of the measurement results from ImageJ "Erg meas spot 700 3doc merged.csv"
#  or "Nup meas mser 2400 3doc merged.csv"

require(tidyverse)
require(stringr)
require(skimr)
require(ggplot2)
require(ggpubr)
require(ggbeeswarm)

# **** Before running these commands, update parameters and load dataset as df ****

# ---- Gather information on dataset and groups ---- 

# parse image filename to get genotype (1st 6 chars) 
#    and treatment (search for CON or 6hr)

# **** change data name and levels as needed here!! ****
dataName = "LD"
geno <- substr(df$filename, 0, 6)
treat <- substr(df$filename, 8, 10)

# how many observations per group?
# count number of rows; detects NAs ONLY if they are in the geno and treat columns
table(geno, treat, useNA = "ifany") 

# how many NAs?
# count fraction of NAs anywhere in the dataset (including columns we are not analyzing)
df <- df %>% select(-`...19`) # this column is all NAs
fxnNA <- sum(is.na(df))/(sum(is.na(df)) + sum(!is.na(df)))

# convert groups of interest to factors with human-readable labels
geno_factor <- factor(geno,
                       levels = c("CTY132", "CTY212"),
                       labels = c("WT", "cue5∆"))

treat_factor <- factor(treat,
                       levels = c("CON", "6hr"),
                       labels = c("control", "DTT"))

df_mod <- df %>% mutate(Genotype = geno_factor, .after = filename)
df_mod <- df_mod %>% mutate(Treatment = treat_factor, .after = Genotype)

# determine size as DC Mean (unit) = mean distance to center in um

# check for missing data
# NAs in the column
radii <- df_mod$`DCMean (unit)`
fxnNAradii <- sum(is.na(radii))/(sum(is.na(radii)) + sum(!is.na(radii)))

# option 1: get average values per cell
radii_by_cell <- df_mod %>% 
  group_by(filename, Genotype, Treatment) %>% 
  drop_na(`DCMean (unit)`) %>%
  summarise(`Mean Distance to Surface µm` = mean(`DCMean (unit)`),
            nCells = n())

# option 2: ignore individual cells and get average values per condition
radii_by_group <- df_mod |> drop_na(`DCMean (unit)`) |>
  summarise(`Mean Distance to Surface µm` = mean(`DCMean (unit)`),
            nObjects = n(),
            .by = c(Genotype, Treatment))

# save count tables in R working directory
write_csv(counts, paste0(dataName,"_particle_counts.csv"))
write_csv(counts_summ, paste0(dataName,"_particle_counts_summary.csv"))
            
# visualize in a box plot

# alternative: dot plot or beeswarm (nicer looking dot plot)
# 
# p <- ggplot(data = counts, aes(x = Treatment, y = ObjectsInCell)) +
#   geom_dotplot(binaxis='y', stackdir='center',
#                binpositions = 'all',
#                fill = "blue", alpha = 0.5) +
#   theme_minimal() +
#   facet_wrap(~ Genotype) +
#   stat_summary(fun=mean, geom="point", shape=18,
#                size=3, color="red")
# q <- ggplot(counts, aes(x=Treatment,y=ObjectsInCell, color = Treatment)) +
#   geom_beeswarm(cex = 3, method = "center") +
#   scale_colour_brewer(palette = "Set1") +
#   theme_minimal() +
#   geom_beeswarm(data=counts_summ, size=5, shape = 15, color = "black", alpha = 0.75) +
#   facet_wrap(~Genotype) +
#   theme(legend.position="none")

q <- ggplot(df_mod, aes(x=Treatment,y=`DCMean (unit)`, fill = Treatment, na.rm = TRUE)) +
  geom_boxplot() +
  scale_fill_manual(values = c("white", "grey")) +
  theme_minimal(base_size = 24) +
  facet_wrap(~Genotype) +
  stat_summary(fun=mean, geom="point", shape=18,
                 size=3, color="red") +
  theme(legend.position="none") +
  labs(y = "Mean Particle Radius")
  

ggsave(paste0(dataName,"_size_boxplot.png"), width=5, height = 5)
