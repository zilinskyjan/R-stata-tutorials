#R-tutorial02-missing-values.R

library(tidyverse)

CD <- readr::read_csv("https://raw.githubusercontent.com/zilinskyjan/citylab-data/master/citylab-congress/citylab_cdi_extended.csv")
# Change variable name "CD" to "District"
CD <- rename(CD, `District` = `CD`)

# Looking at state-level observations
#####################################
library(stringr)
CD %>% filter(str_detect(District,"NY"))

CD %>% filter(grepl("NY",District))

# Usually a better choice: generate a new variable
substr(CD$District,1,2) 

CD$state <- substr(CD$District,1,2) 

View(CD)


###############################
# 2018 Congressional elections
###############################

# Number of Democratic incumbents by state?
CD %>% count(`Pre-2018 party`)

# How many Democrats and Republicans were re-elected?
CD %>% count(`Pre-2018 party`,`2018 winner party`)

# Calculate proportions
CD %>% count(`Pre-2018 party`,`2018 winner party`) %>%
  mutate(prop = n / sum(n))

# What about the missing results for one district? Where is it?
CD %>% filter(is.na(`2018 winner party`))

####################
# THIS IS IMPORTANT
####################

dim(CD)

sum(complete.cases(CD))

sum(!complete.cases(CD))

# Where are the missing values?
colSums(is.na(CD))

CD %>%
  filter(is.na(`2018 winner party`))


# There were ballot-harvesting problems in NC-09, and a new election had to be called
# ... what happened next, a Republican won

# So, we can update the dataset:
CD %>% filter(state=="NC") %>% relocate(`2018 winner party`)

CD %>% filter(state=="NC") %>% relocate(`2018 winner party`) %>%
  mutate(`2018 winner party` = ifelse(District=="NC-09","R",`2018 winner party`))


# Tidyverse tricks
CD %>% select(where(is.numeric)) 

CD %>% summarise(across(where(is.numeric), is.na)) 


# Useful references
# https://raw.githack.com/uo-ec607/lectures/master/05-tidyverse/05-tidyverse.html#35
# https://dplyr.tidyverse.org/reference/summarise.html
# https://dplyr.tidyverse.org/articles/colwise.html
# https://stackoverflow.com/questions/44290704/dplyr-count-non-na-value-in-group-by


