# commands for processing association results from ImageJ, e.g. the summary file 2026-1-20-0-16_results.csv

require(tidyverse)
require(stringr)
require(skimr)
require(ggplot2)
require(ggpubr)
require(ggbeeswarm)

# **** Before running these commands, update parameters and load dataset as df ****

# ---- Gather information on dataset and groups ---- 

# **** change data name and levels as needed here!! ****
# parse image filename to get genotype (1st 6 chars) 
#    and treatment (search for CON or 6hr)
dataName = "Nup159-LD"
crit = "0x4"
geno <- substr(df$ImageName, 0, 6)
treat <- substr(df$ImageName, 8, 10)

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

df_mod <- df %>% mutate(Genotype = geno_factor, .after = ImageName)
df_mod <- df_mod %>% mutate(Treatment = treat_factor, .after = Genotype)

# summarize measurements for each image and group
# note this only includes cells with associations
summ <- df_mod %>% 
  group_by(Genotype, Treatment) %>% 
  summarise(Avg_Nup159Assoc_PerCell = round(mean(AssociatedNup),2),
            AvgFxn_Nup159Assoc = round(mean(AssociatedNup/TotalNup), 2),
            nCells = n())

# hypothesis testing

wt_con <- df_mod %>% filter(Genotype == "WT" & Treatment == "control")
wt_dtt <- df_mod %>% filter(Genotype == "WT" & Treatment == "DTT")
cue5_con <- df_mod %>% filter(Genotype == "cue5∆" & Treatment == "control")
cue5_dtt <- df_mod %>% filter(Genotype == "cue5∆" & Treatment == "DTT")

#are variances equal?
v <- var.test(AssociatedNup ~ Genotype, data = df_mod)
v[[3]]

#are data normally distrib?
hist(wt_con$TotalNup)
hist(wt_con$AssociatedNup)
qqnorm(wt_con$TotalNup)
qqnorm(wt_con$AssociatedNup)
hist(cue5_dtt$AssociatedNup)

# non-parametric tests (for not-necessarily-normally distributed data)

# compare number of Assoc Nup particles: wt DTT vs wt control
w <- wilcox.test(wt_dtt$AssociatedNup, wt_con$AssociatedNup)
w[[3]] # p-value

# compare number of Assoc Nup particles: wt DTT vs cue5 DTT
w <- wilcox.test(wt_dtt$AssociatedNup, cue5_dtt$AssociatedNup)
w[[3]] # p-value

# compare number of Assoc Nup particles: wt control vs cue5 control
w <- wilcox.test(wt_con$AssociatedNup, cue5_con$AssociatedNup)
w[[3]] # p-value

# compare number of Assoc Nup particles: cue5 DTT vs cue5 control
w <- wilcox.test(cue5_dtt$AssociatedNup, cue5_con$AssociatedNup)
w[[3]] # p-value

# compare fraction of Assoc Nup particles: wt DTT vs wt control
w <- wilcox.test(wt_dtt$AssociatedNup/wt_dtt$TotalNup, wt_con$AssociatedNup/wt_con$TotalNup)
w[[3]] # p-value

# compare fraction of Assoc Nup particles: cue5∆ DTT vs wt DTT 
w <- wilcox.test(cue5_dtt$AssociatedNup/cue5_dtt$TotalNup, wt_dtt$AssociatedNup/wt_dtt$TotalNup)
w[[3]] # p-value

# compare fraction of Assoc Nup particles: wt control vs cue5 control
w <- wilcox.test(wt_con$AssociatedNup/wt_con$TotalNup, cue5_con$AssociatedNup/cue5_con$TotalNup)
w[[3]] # p-value

# compare fraction of Assoc Nup particles: cue5 DTT vs cue5 control
w <- wilcox.test(cue5_dtt$AssociatedNup/cue5_dtt$TotalNup, cue5_con$AssociatedNup/cue5_con$TotalNup)
w[[3]] # p-value

# save summary in R working directory
# write_csv(avg, "iso_erg_700_avg.csv")
write_csv(summ, paste0(dataName, "_assoc_",crit,".csv"))

# visualize in a box plot

q <- ggplot(df_mod, aes(x=Treatment,y=AssociatedNup, fill = Treatment, na.rm = TRUE)) +
  geom_boxplot() +
  scale_fill_manual(values = c("white", "grey")) +
  theme_minimal(base_size = 24) +
  facet_wrap(~Genotype) +
  stat_summary(fun=mean, geom="point", shape=18,
               size=3, color="red") +
  theme(legend.position="none",
        axis.title.y = element_text(size = 20)) +
  labs(y = "LD-Associated Nup159 Puncta / Cell")

ggsave(paste0(dataName,"_assoc_",crit,"_boxplot.png"), width=7, height = 7)


q <- ggplot(df_mod, aes(x=Treatment,y=AssociatedNup/TotalNup, fill = Treatment, na.rm = TRUE)) +
  geom_boxplot() +
  scale_fill_manual(values = c("white", "grey")) +
  theme_minimal(base_size = 20) +
  facet_wrap(~Genotype) +
  stat_summary(fun=mean, geom="point", shape=18,
               size=3, color="red") +
  theme(legend.position="none",
        axis.title.y = element_text(size = 18)) +
  labs(y = "Fraction of LD-Associated Nup159 Puncta / Cell")

ggsave(paste0(dataName,"_fxn_assoc_",crit,"_boxplot.png"), width=7, height = 7)
