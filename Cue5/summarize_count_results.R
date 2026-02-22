# commands for processing count results from ImageJ, e.g. 
#  a merged dataset of the measurement results from ImageJ "Erg meas spot 700 3doc merged.csv"
#  or "Nup meas mser 2400 3doc merged.csv"

require(tidyverse)
require(stringr)
require(skimr)
require(ggplot2)
require(ggpubr)
require(ggbeeswarm)

# these commands assume you've loaded a dataset called df

# parse the filename to get genotype (1st 6 chars of ImageName) 
#    and treatment (search for CON or 6hrDTT)
geno <- substr(df$filename, 0, 6)
treat <- substr(df$filename, 8, 10)
table(geno, treat) #gives n(particles)

geno_factor <- factor(geno,
                       levels = c("CTY132", "CTY212"),
                       labels = c("WT", "cue5del"))

treat_factor <- factor(treat,
                       levels = c("CON", "6hr"),
                       labels = c("control", "DTT"))

df_mod <- df %>% mutate(Genotype = geno_factor, .after = filename)
df_mod <- df_mod %>% mutate(Treatment = treat_factor, .after = Genotype)

# count particles per cell
counts <- df_mod %>% 
  group_by(filename, Genotype, Treatment) %>% 
  summarise(ObjectsInCell = n())

# find average particles per cell in different groups
counts_summ <- counts %>% group_by(Genotype, Treatment) %>%
  summarise(ObjectsInCell = round(mean(ObjectsInCell), 2), 
            nCells = n())

# save count tables in R working directory
write_csv(counts, "particle_counts.csv")
write_csv(counts_summ, "particle_counts_summary.csv")
            
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

q <- ggplot(counts, aes(x=Treatment,y=ObjectsInCell, fill = Treatment)) +
  geom_boxplot() +
  scale_fill_manual(values = c("white", "grey")) +
  theme_minimal() +
  facet_wrap(~Genotype) +
  theme(legend.position="none")

ggsave("boxplot.pdf", width=7, height = 7)

# basic hypothesis testing

wt_con <- counts %>% filter(Genotype == "WT" & Treatment == "control")
wt_dtt <- counts %>% filter(Genotype == "WT" & Treatment == "DTT")
cue5_con <- counts %>% filter(Genotype == "cue5del" & Treatment == "control")
cue5_dtt <- counts %>% filter(Genotype == "cue5del" & Treatment == "DTT")

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

# non-parametric test

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