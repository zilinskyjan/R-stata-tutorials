# Only uncomment if you need to install the package
# install.packages("tidyverse")

library(tidyverse)

# Read about the density index
# - Methodology: https://github.com/theatlantic/citylab-data/blob/master/citylab-congress/methodology.md
# - https://www.bloomberg.com/news/articles/2018-11-20/citylab-s-congressional-density-index
# - https://www.bloomberg.com/news/articles/2018-10-05/the-suburbs-are-the-midterm-election-battleground


# Load the data

CD <- readr::read_csv("https://raw.githubusercontent.com/zilinskyjan/citylab-data/master/citylab-congress/citylab_cdi_extended.csv")

# What does each row mean?
# How many variables (columns) are contained in the dataset?
# What variables (columns) are present?
# Which variables contain missing data?
  
names(CD)

head(CD)

# For manual inspection, run:
# View(CD)

# How are the district classified?
table(CD$Cluster)

count(CD, Cluster)

summarize(CD, number_of_districts = n())

summarize(CD, number_of_rows = n())

# Re-do the above with pipes

CD %>% count(Cluster)

CD %>% summarise(number_of_districts = n())


# Inspect individual rows and cells
## a) How well did Clinton do in 2016 in NY-14?
## b) How well did she do in New York state?
## c) What can we do if a variable STATE is not included?

## Approach 1 [Base R]

CD[row_number,column_number]

# Keeping all 25 columns
CD[1,]

CD[CD$CD=="NY-14","Clinton16"]

## Approach 2 [Tidyverse]

CD %>% filter(CD=="NY-14")

CD %>% filter(CD=="NY-14") %>% select(Clinton16) # this may clash with pkg: MASS

CD %>% filter(CD=="NY-14") %>% dplyr::select(Clinton16)


CD %>% filter(CD=="NY-14") %>% dplyr::select(Clinton16)



