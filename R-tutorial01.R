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
CD %>% group_by(Cluster) %>%
  summarise(avg_HRC_vote_share = mean(Clinton16)) %>%
  arrange(-avg_HRC_vote_share)

##########################
# GENERATING NEW VARIABLES (as a function of what we already have)
##########################
# Task: How did HRC do relative to the national average
CD %>% mutate(avg_HRC_vote_share = mean(Clinton16))

# To see what happened, run:
CD %>% mutate(avg_HRC_vote_share = mean(Clinton16)) %>%
  select(1,2,Clinton16,26)


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



