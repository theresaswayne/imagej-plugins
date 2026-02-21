# commands for processing association results from ImageJ, e.g. the summary file 2026-1-20-0-16_results.csv

# these commnds assume you've loaded a dataset called df
require(tidyverse)
require(stringr)
require(skimr)

# parse the filename to get genotype (1st 6 chars of ImageName) 
#    and treatment (search for CON or 6hrDTT)
geno <- substr(df$ImageName, 0, 6)
treat <- substr(df$ImageName, 8, 10)
table(geno, treat)

geno_factor <- factor(geno,
                       levels = c("CTY132", "CTY212"),
                       labels = c("WT", "cue5∆"))

treat_factor <- factor(treat,
                       levels = c("CON", "6hr"),
                       labels = c("control", "DTT"))

df_mod <- df %>% mutate(Genotype = geno_factor, .after = ImageName)
df_mod <- df_mod %>% mutate(Treatment = treat_factor, .after = Genotype)

# summarize measurements for each image and group
summ <- df_mod %>% 
  group_by(Genotype, Treatment) %>% 
  summarise(nCells = n(),
            Avg_Nup159Puncta_PerCell = round(mean(TotalNup), 2),
            Avg_LDs_PerCell = round(mean(TotalErg), 2),
            Avg_Nup159Assoc_PerCell = round(mean(AssociatedNup),2),
            Fxn_Nup159Assoc = round(mean(AssociatedNup/TotalNup), 2))

# basic hypothesis testing

wt_con <- df_mod %>% filter(Genotype == "WT" & Treatment == "control")
wt_dtt <- df_mod %>% filter(Genotype == "WT" & Treatment == "DTT")
cue5_con <- df_mod %>% filter(Genotype == "cue5∆" & Treatment == "control")
cue5_dtt <- df_mod %>% filter(Genotype == "cue5∆" & Treatment == "DTT")

#are variances equal? NO
v <- var.test(AssociatedNup ~ Genotype, data = df_mod)
v[[3]]

# compare Total Nup: wt DTT vs the mean for wt control
t <- t.test(wt_dtt$TotalNup, mu=2.4) 
t[[3]] # p-value

# compare Assoc Nup: wt DTT vs the mean for wt control
t <- t.test(wt_dtt$AssociatedNup, mu=1.0)
t[[3]] # p-value

# compare Assoc Nup: cue5∆ DTT vs wt DTT mean ()
t <- t.test(cue5_dtt$AssociatedNup, mu=1.56)
t[[3]] # p-value

# this is valid only if data is norm distrib
hist(wt_con$TotalNup)
hist(wt_con$AssociatedNup)
qqnorm(wt_con$TotalNup)
qqnorm(wt_con$AssociatedNup)
hist(cue5_dtt$AssociatedNup) # def not normal

# non-parametric test

# compare Total Nup: wt DTT vs the mean for wt control
w <- wilcox.test(wt_dtt$TotalNup, mu=2.47) 
w[[3]] # p-value

# compare Total Nup: cue5∆ DTT vs the mean for wt DTT
w <- wilcox.test(cue5_dtt$TotalNup, mu=4.36) 
w[[3]] # p-value

# compare Total Erg: wt DTT vs the mean for wt control
w <- wilcox.test(wt_dtt$TotalErg, mu=5.29) 
w[[3]] # p-value

# compare Total Erg: cue5∆ DTT vs the mean for wt DTT
w <- wilcox.test(cue5_dtt$TotalErg, mu=14.1) 
w[[3]] # p-value

# compare Assoc Nup: wt DTT vs the mean for wt control
w <- wilcox.test(wt_dtt$AssociatedNup, mu=1.06)
w[[3]] # p-value

# compare Assoc Nup: cue5∆ DTT vs wt DTT mean
w <- wilcox.test(cue5_dtt$AssociatedNup, mu=2.34)
w[[3]] # p-value

# compare Fxn Assoc Nup: wt DTT vs the mean for wt control
w <- wilcox.test(wt_dtt$AssociatedNup/wt_dtt$TotalNup, mu=0.37)
w[[3]] # p-value

# compare Fxn Assoc Nup: cue5∆ DTT vs wt DTT mean
w <- wilcox.test(cue5_dtt$AssociatedNup/cue5_dtt$TotalNup, mu=0.35)
w[[3]] # p-value

# compare Fxn Assoc Nup: wt DTT vs the mean for wt control
w <- wilcox.test(wt_dtt$AssociatedNup/wt_dtt$TotalNup, mu=0.4)
w[[3]] # p-value

# compare Fxn Assoc Nup: cue5∆ DTT vs wt DTT mean
w <- wilcox.test(cue5_dtt$AssociatedNup/cue5_dtt$TotalNup, mu=0.53)
w[[3]] # p-value

# Analysis of Variance (ANOVA)
# Does Assoc Nup significantly differ by genotype?
res<- lm(AssociatedNup ~ Genotype, data = df_mod)
anova(res)

# Checking model assumptions 
# Constant variance,
# Normality of residuals,
# Outliers and influential points.
par(mfrow = c(2, 2)) # set up a 2x2 plot
plot(res)

par(mfrow = c(2, 2))
plot(aov(AssociatedNup~factor(Genotype), data=df_mod))

k <- kruskal.test(AssociatedNup ~ Genotype, data = df_mod)
k[[3]] # p value

k <- kruskal.test((AssociatedNup/TotalNup) ~ Genotype, data = df_mod)
k[[3]] # p value

k <- kruskal.test(AssociatedNup ~ Treatment, data = df_mod)
k[[3]] # p value

k <- kruskal.test((AssociatedNup/TotalNup) ~ Treatment, data = df_mod)
k[[3]] # p value


# save in R working directory
# write_csv(avg, "iso_erg_700_avg.csv")
write_csv(summ, "assoc0x4.csv")