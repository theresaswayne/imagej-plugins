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
dataName = "Nup159"
geno <- substr(df$filename, 0, 6)
treat <- substr(df$filename, 8, 10)

# how many observations per group?
# count number of rows; detects NAs ONLY if they are in the geno and treat columns
table(geno, treat, useNA = "ifany") 

# how many NAs?
# count fraction of NAs anywhere in the dataset (including columns we are not analyzing)
df <- df %>% select(-`...19`)
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

# ---- Determine average counts per cell by group ----

# count particles per cell across all groups
counts <- df_mod %>% 
  group_by(filename, Genotype, Treatment) %>% 
  summarise(ObjectsInCell = n())

# check for missing data
# use drop_na(columnName) if any are found
fxnNAcounts <- sum(is.na(counts$ObjectsInCell))/(sum(is.na(counts$ObjectsInCell)) + sum(!is.na(counts$ObjectsInCell)))

# find average particles per cell in different groups, to 2 decimal places
counts_summ <- counts %>% group_by(Genotype, Treatment) %>%
  summarise(ObjectsInCell = round(mean(ObjectsInCell), 2), 
            nCells = n())

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

q <- ggplot(counts, aes(x=Treatment,y=ObjectsInCell, fill = Treatment, na.rm = TRUE)) +
  geom_boxplot() +
  scale_fill_manual(values = c("white", "grey")) +
  theme_minimal(base_size = 24) +
  facet_wrap(~Genotype) +
  stat_summary(fun=mean, geom="point", shape=18,
                 size=3, color="red") +
  theme(legend.position="none") +
  labs(y = "Puncta Per Cell")

ggsave(paste0(dataName,"_count_boxplot.png"), width=5, height = 5)


# basic hypothesis testing

wt_con <- counts %>% filter(Genotype == "WT" & Treatment == "control")
wt_dtt <- counts %>% filter(Genotype == "WT" & Treatment == "DTT")
cue5_con <- counts %>% filter(Genotype == "cue5∆" & Treatment == "control")
cue5_dtt <- counts %>% filter(Genotype == "cue5∆" & Treatment == "DTT")

#are variances equal? NO
v <- var.test(ObjectsInCell ~ Genotype, data = counts)
v[[3]]

# check for normality (repeat for all interesting variables or groups)
hist(wt_con$ObjectsInCell)
qqnorm(wt_con$ObjectsInCell)
hist(wt_dtt$ObjectsInCell)
qqnorm(wt_dtt$ObjectsInCell)
hist(cue5_con$ObjectsInCell)
qqnorm(cue5_con$ObjectsInCell)
hist(cue5_dtt$ObjectsInCell)
qqnorm(cue5_dtt$ObjectsInCell)

# compare means: wt DTT vs wt control
w <- wilcox.test(wt_dtt$ObjectsInCell, wt_con$ObjectsInCell, exact = FALSE) 
w[[3]] # p-value

# compare cue5 DTT vs cue5 control
w <- wilcox.test(cue5_dtt$ObjectsInCell, cue5_con$ObjectsInCell, exact = FALSE) 
w[[3]] # p-value

# compare wt control vs cue5 control
w <- wilcox.test(wt_con$ObjectsInCell, cue5_con$ObjectsInCell, exact = FALSE) 
w[[3]] # p-value

# compare wt DTT vs cue5 DTT
w <- wilcox.test(wt_dtt$ObjectsInCell, cue5_dtt$ObjectsInCell, exact = FALSE) 
w[[3]] # p-value

# Analysis of Variance (ANOVA)
res<- lm(ObjectsInCell ~ Genotype, data = counts)
anova(res)

# Checking model assumptions 
# Constant variance,
# Normality of residuals,
# Outliers and influential points.
# par(mfrow = c(2, 2)) # set up a 2x2 plot
# plot(res)
# 
# par(mfrow = c(2, 2))
# plot(aov(AssociatedNup~factor(Genotype), data=df_mod))
# 
# k <- kruskal.test(AssociatedNup ~ Genotype, data = df_mod)
# k[[3]] # p value
# 
# k <- kruskal.test((AssociatedNup/TotalNup) ~ Genotype, data = df_mod)
# k[[3]] # p value
# 
# k <- kruskal.test(AssociatedNup ~ Treatment, data = df_mod)
# k[[3]] # p value
# 
# k <- kruskal.test((AssociatedNup/TotalNup) ~ Treatment, data = df_mod)
# k[[3]] # p value


# save in R working directory
# write_csv(avg, "iso_erg_700_avg.csv")
#write_csv(summ, "assoc0x4.csv")