library(tidyverse)

CD <- readr::read_csv("https://raw.githubusercontent.com/zilinskyjan/citylab-data/master/citylab-congress/citylab_cdi_extended.csv")
# Change variable name "CD" to "District"
CD <- rename(CD, `District` = `CD`)


# Inspect individual rows and cells
###############################################
## a) How well did Clinton do in 2016 in NY-14?
## b) How well did she do in New York state?
## c) What can we do if a variable STATE is not included?

######################
## Approach 1 [Base R]
######################

row_number <-1
column_number <-1

CD[row_number,column_number]

# Keeping all 25 columns
CD[1,]

CD[CD$District=="NY-14","Clinton16"]

###########################
## Approach 2 [Tidyverse]
###########################
CD %>% filter(District=="NY-14")

CD %>% filter(District=="NY-14") %>% select(Clinton16) # this may clash with pkg: MASS

CD %>% filter(District=="NY-14") %>% dplyr::select(Clinton16)

CD %>% filter(District=="NC-09") %>% dplyr::select(Clinton16)


# Looking at state-level observations
#####################################
library(stringr)
CD %>% filter(str_detect(District,"NY"))

CD %>% filter(grepl("NY",District))

# Usually a better choice: generate a new variable
substr(CD$District,1,2) 

CD$state <- substr(CD$District,1,2) 

View(CD)

# Average performance by state?
CD %>% group_by(state) %>% summarise(HRC = mean(Clinton16),
                                     DJT = mean(Trump16))
# Typical performance by state?
CD %>% group_by(state) %>% summarise(HRC = median(Clinton16),
                                     DJT = median(Trump16))

# Typical performance by state and by district type
CD %>% group_by(state,Cluster) %>% summarise(HRC = median(Clinton16),
                                             DJT = median(Trump16),
                                             n = n())



# How did HRC do relative to the national average
CD %>% mutate(avg_HRC_vote_share = mean(Clinton16))

# To see what happened, run:
CD %>% mutate(avg_HRC_vote_share = mean(Clinton16)) %>%
  select(1,2,Clinton16,avg_HRC_vote_share)

# Calculate relative performance
CD %>% mutate(avg_HRC_vote_share_national = mean(Clinton16)) %>%
  select(1,2,Clinton16,avg_HRC_vote_share_national)

# What else do we need?
CD %>% mutate(avg_HRC_vote_share_national = mean(Clinton16)) %>%
  select(1,2,Clinton16,avg_HRC_vote_share_national) %>%
  mutate(relative_performance = Clinton16 - avg_HRC_vote_share_national) 

(plot1 <- CD %>% mutate(avg_HRC_vote_share_national = mean(Clinton16)) %>%
    select(1,2,Clinton16,avg_HRC_vote_share_national) %>%
    mutate(relative_performance = Clinton16 - avg_HRC_vote_share_national) %>% 
    select(relative_performance) %>%
    ggplot(aes(x=relative_performance)) +
    geom_histogram(colour = '#CCCCCC',fill = '#3173B0',size = .5,linetype = 1,alpha = 0.6) +
    theme_minimal() +
    labs(y= "Number of districts", x = "Relative Clinton performance compared to the average"))

# library('ggedit')
# ggedit(plot1)


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

# There were ballot-harvesting problems in NC-09, and a new election had to be called
# ... what happened next, a Republican won

# So, we can update the dataset:
CD %>% filter(state=="NC") %>% relocate(`2018 winner party`)

CD %>% filter(state=="NC") %>% relocate(`2018 winner party`) %>%
  mutate(`2018 winner party` = ifelse(District=="NC-09","R",`2018 winner party`))

