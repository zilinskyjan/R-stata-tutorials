# Only uncomment if you need to install the package
# install.packages("tidyverse")

library(tidyverse)

# Read about the density index
# - Methodology: https://github.com/theatlantic/citylab-data/blob/master/citylab-congress/methodology.md
# - https://www.bloomberg.com/news/articles/2018-11-20/citylab-s-congressional-density-index
# - https://www.bloomberg.com/news/articles/2018-10-05/the-suburbs-are-the-midterm-election-battleground


# Load the data

CD <- readr::read_csv("https://raw.githubusercontent.com/zilinskyjan/citylab-data/master/citylab-congress/citylab_cdi_extended.csv")

# 1. What does each row mean?
# 2. How many variables (columns) are contained in the dataset?
# 3. What variables (columns) are present?
# 4. Which variables contain missing data?

head(CD)

# To see the names of all variables:  
names(CD)

# For manual inspection, run:
# View(CD)

# How are the district classified and how many districts of each type do we have in the data?
table(CD$Cluster)

count(CD, Cluster)

summarize(CD, number_of_districts = n())

summarize(CD, number_of_rows = n())

# Re-do the above with pipes

CD %>% count(Cluster)

# Calculate the total number of rows
CD %>% summarise(number_of_districts = n())

CD %>% tally()



# Let's list the KEY VERBS
# filter: Keep only some rows (depending on their particular values).
# select: Keep the specified columns (list their names, without quotation marks).
# mutate: Create new variables.
# summarise: Collapse multiple rows into a single summary value.
# arrange: Order rows based on their values.


# Calculate the average Clinton vote share
CD %>% summarise(avg_HRC_vote_share = mean(Clinton16))

# Where was HRC's vote at its minimum? Would this work?
CD %>% summarise(min_HRC_vote_share = min(Clinton16))

CD %>% arrange(Clinton16)

# Prepare summaries by district type
CD %>% group_by(Cluster) %>%
  summarise(avg_HRC_vote_share = mean(Clinton16))

# Sort your data:
CD %>% group_by(Cluster) %>%
  summarise(avg_HRC_vote_share = mean(Clinton16)) %>%
  arrange(avg_HRC_vote_share)

# Sort your data from highest to lowest average Clinton vote share
# and show the total number of districts per row:
CD %>% group_by(Cluster) %>%
  summarise(avg_HRC_vote_share = mean(Clinton16),
            n=n()) %>%
  arrange(-avg_HRC_vote_share)

##########################
# GENERATING NEW VARIABLES (as a function of what we already have)
##########################
# Create a binary variable conveying the district is "safe Democratic"
CD %>% mutate(Clinton16_over70 = ifelse(Clinton16 >= .7,1,0))

CD <- CD %>% mutate(Clinton16_over70 = ifelse(Clinton16 >= .7,1,0))

# Check 3 randomly selected district from each group:
CD %>% group_by(Clinton16_over70) %>% 
  sample_n(3) %>% 
  select(CD,Clinton16_over70,Clinton16)

# How many such (arbitrarily defined) safe districts are there?
CD %>% count(Clinton16_over70)

# What is the typical density in these types of districts?
CD %>% filter(Clinton16_over70==1) %>%
  count(Cluster) %>%
  arrange(-n)



# NEW TASK: How did HRC do relative to the national average
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
  geom_histogram(colour = '#CCCCCC',fill = '#3173B0',size = .5,linetype = 1,alpha = 0.6) )

# library('ggedit')
# ggedit(plot1)

# Inspect individual rows and cells
###############################################
## a) How well did Clinton do in 2016 in NY-14?
## b) How well did she do in New York state?
## c) What can we do if a variable STATE is not included?

######################
## Approach 1 [Base R]
######################

CD[row_number,column_number]

# Keeping all 25 columns
CD[1,]

CD[CD$CD=="NY-14","Clinton16"]

###########################
## Approach 2 [Tidyverse]
###########################
CD %>% filter(CD=="NY-14")

CD %>% filter(CD=="NY-14") %>% select(Clinton16) # this may clash with pkg: MASS

CD %>% filter(CD=="NY-14") %>% dplyr::select(Clinton16)

CD %>% filter(CD=="NY-14") %>% dplyr::select(Clinton16)


# Looking at state-level observations
library(stringr)
CD %>% filter(str_detect(CD,"NY"))

CD %>% filter(grepl("NY",CD))

# Usually a better choice: generate a new variable
substr(CD$CD,1,2) 

CD$state <- substr(CD$CD,1,2) 

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

# Number of Democratic incumbents by state?