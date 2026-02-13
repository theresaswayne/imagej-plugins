# commands for processing segmentation results from ImageJ

# assume you've loaded a merged dataset called df
require(tidyverse)
require(stringr)

# add a column for the group based on manual assessment
# prefix of the filename indicates the group (for algorithm testing purposes)
keys <- substr(df$filename, 0, 1)
keys_renamed <- factor(keys,
                       levels = c("a", "b"),
                       labels = c("Few", "Many"))

df_mod <- df %>% mutate(ManualScore = keys_renamed, .after = filename)

# summarize measurements for each image and group
summ <- df_mod %>% 
  group_by(ManualScore, filename) %>% 
  summarise(nPuncta = n(),
            meanDist = mean(`Mean dist. to surf. (micron)`))
avg <- summ %>% 
  group_by(ManualScore) %>% 
  summarise(avgPuncta = mean(nPuncta), 
            sdPuncta = sd(nPuncta), 
            meanDist = mean(meanDist))



# save in R working directory
write_csv(avg, "erg6_700_avg.csv")
write_csv(summ, "erg6_700_summ.csv")