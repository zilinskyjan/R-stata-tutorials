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

# Change variable name "CD" to "District"
CD <- rename(CD, `District` = `CD`)

# Move the variables you are interested in the left:
CD %>% select(District, Clinton16, everything())

CD %>% relocate(District, Clinton16)

# To see the names of all variables:  
names(CD)

# For manual inspection, run:
# View(CD)

# Reordering rows:
CD %>% arrange(Clinton16) %>% relocate(Clinton16)

CD %>% arrange(-Clinton16) %>% relocate(Clinton16)

# How are the district classified and how many districts of each type do we have in the data?
table(CD$Cluster)

count(CD, Cluster)

summarize(CD, number_of_districts = n())

summarize(CD, number_of_rows = n())

# Re-do the above with pipes

CD %>% count(Cluster)

# Calculate the total number of rows
CD %>% summarise(number_of_districts = n(),
                 average_clinton_performance = mean(Clinton16))

CD %>% tally()

# Any missing values?
sum(complete.cases(CD))

dim(CD)

# Where are the missing values?
colSums(is.na(CD))


# Let's list the KEY VERBS
# 1. filter: Keep only some rows (depending on their particular values).
# 2. select: Keep the specified columns (list their names, without quotation marks).
# 3. mutate: Create new variables.
# 4. summarise: Collapse multiple rows into a single summary value.
# 5. arrange: Order rows based on their values.

# Calculate the average Clinton vote share
CD %>% summarise(avg_HRC_vote_share = mean(Clinton16))

# Where was HRC's vote at its minimum? Would this work?
CD %>% summarise(min_HRC_vote_share = min(Clinton16))

# Prepare summaries by district type
CD %>% 
  group_by(Cluster) %>% 
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
CD %>% mutate(Clinton16_over70 = Clinton16 >= .7) %>% 
  relocate(Clinton16_over70,Clinton16) %>%
  slice_sample(n=10)

# Or make a string variable [not necessarily recommended]
CD %>% mutate(Clinton16_over70_string = ifelse(Clinton16 >= .7,"Safe","Not safe")) %>%
  relocate(District,Clinton16,Clinton16_over70_string) %>%
  slice_sample(n=10) 

# Save a new dataset
CD_new <- CD %>% mutate(Clinton16_over70 = Clinton16 >= .7)

# Check 3 randomly selected district from each group:
CD_new %>% group_by(Clinton16_over70) %>% 
  sample_n(3) %>% 
  select(District,Clinton16_over70,Clinton16)

# How many such (arbitrarily defined) safe districts are there?
CD_new %>% count(Clinton16_over70)

# What is the typical density in these types of districts?
CD_new %>% filter(Clinton16_over70==1) %>%
  count(Cluster) %>%
  arrange(-n)




