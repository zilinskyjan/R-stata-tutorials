#R-tutorial02-missing-values.R

# BASIC PROBLEM

A <- c(10,20,NA)

mean(A)

# Why did the missing value propagate in mean()?

summary(A)

##############################
# CONGRESSIONAL DISTRICT DATA
##############################

library(tidyverse)

CD <- readr::read_csv("https://raw.githubusercontent.com/zilinskyjan/citylab-data/master/citylab-congress/citylab_cdi_extended.csv")
# Change variable name "CD" to "District"
CD <- rename(CD, `District` = `CD`)


###############################
# 2018 Congressional elections
###############################

# Number of Democratic incumbents by state?

## not piping
count(CD,`Pre-2018 party`)
# with %>%
CD %>% count(`Pre-2018 party`)


# How many Democrats and Republicans were re-elected?
CD %>% count(`Pre-2018 party`,`2018 winner party`)

# Calculate proportions
CD %>% count(`Pre-2018 party`,`2018 winner party`) %>%
  mutate(prop = n / sum(n))

# What about the missing results for one district? Where is it?
CD %>% filter(is.na(`2018 winner party`))

CD %>% filter(is.na(`2018 winner party`)) %>% select(`2018 winner party`)

####################
# THIS IS IMPORTANT
####################

dim(CD)

complete.cases(CD)

sum(complete.cases(CD))

sum(!complete.cases(CD))

# Where are the missing values?
colSums(is.na(CD))

CD %>%
  filter(is.na(`2018 winner party`))


# There were ballot-harvesting problems in NC-09, and a new election had to be called
# ... what happened next, a Republican won

# So, we can update the dataset:
CD_nonmissing <- CD %>% mutate(`2018 winner party` = ifelse(District == "NC-09",
                                      "R",
                                      `2018 winner party`))

# This has been cleaned
CD_nonmissing

# You can save the fixed dataset:
write_csv(CD_nonmissing,"newfile.csv")




# Tidyverse tricks
CD %>% select(where(is.numeric)) 

CD %>% summarise(across(where(is.numeric), is.na)) 


# Useful references
# https://raw.githack.com/uo-ec607/lectures/master/05-tidyverse/05-tidyverse.html#35
# https://dplyr.tidyverse.org/reference/summarise.html
# https://dplyr.tidyverse.org/articles/colwise.html
# https://stackoverflow.com/questions/44290704/dplyr-count-non-na-value-in-group-by