library(tidyverse)

CD <- readr::read_csv("https://raw.githubusercontent.com/zilinskyjan/citylab-data/master/citylab-congress/citylab_cdi_extended.csv")
# Change variable name "CD" to "District"
CD <- rename(CD, `District` = `CD`)
CD$state <- substr(CD$District,1,2) 

names(CD)

# Distribution of district types

table(CD$Cluster)

# Alternatively

CD %>% dplyr::count(Cluster)

CD %>% count(Cluster) %>% mutate(proportion = n / sum(n))


# Inspect individual rows and cells
###############################################
## a) How well did Clinton do in 2016 in NY-14?
## b) How well did she do in New York state?
## c) What can we do if a variable STATE is not included?

######################
## Approach 1 [Base R]
######################

row_number <-1
column_number <-10

CD[1,10]

# Keeping all 25 columns
CD[1,]

CD[ ,1]

CD[CD$District=="NY-14","Clinton16"]

###########################
## Approach 2 [Tidyverse]
###########################
CD %>% filter(District=="NY-14")

CD %>% filter(District=="NY-14") %>% dplyr::select(Clinton16) # this may clash with pkg: MASS

CD %>% filter(District=="NY-14") %>% dplyr::select(Clinton16)

CD %>% filter(District=="NC-09") %>% dplyr::select(Clinton16)



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

#CD %>% dplyr::count(Cluster)

# How did HRC do relative to the national average
CD %>% mutate(avg_HRC_vote_share = mean(Clinton16))

# To see what happened, run:
CD %>% mutate(avg_HRC_vote_share = mean(Clinton16)) %>%
  select(1,2,Clinton16,avg_HRC_vote_share)

# Calculate relative performance
# CD %>% mutate(avg_HRC_vote_share_national = mean(Clinton16)) %>%
#   select(1,2,Clinton16,avg_HRC_vote_share_national)

# Or you can run
CD %>% mutate(avg_HRC_vote_share_national = mean(Clinton16)) %>%
  relocate(1,2,Clinton16,avg_HRC_vote_share_national)

# What else do we need?
CD %>% mutate(avg_HRC_vote_share_national = mean(Clinton16)) %>%
  select(1,2,Clinton16,avg_HRC_vote_share_national) %>%
  mutate(relative_performance = Clinton16 - avg_HRC_vote_share_national) 

# Prepare data for plotting
toPlot1 <- CD %>% mutate(avg_HRC_vote_share_national = mean(Clinton16)) %>%
    select(1,2,Clinton16,avg_HRC_vote_share_national) %>%
    mutate(relative_performance = Clinton16 - avg_HRC_vote_share_national) %>% 
    select(relative_performance) 

toPlot1
  
p <- toPlot1 %>%
    ggplot(aes(x=relative_performance)) +
    geom_histogram(colour = '#CCCCCC',fill = '#3173B0',
                   size = .5,linetype = 1,alpha = 0.6) +
    theme_minimal() +
    labs(y= "Number of districts", 
         x = "Relative Clinton performance compared to the average")

p

############################
# Let's merge in more data:
############################

# install.packages("haven")
library(haven)
addtional_data <- read_dta("https://github.com/zilinskyjan/R-stata-tutorials/blob/master/data/CD_voteshares_demos_2016_18.dta?raw=true")

names(addtional_data)

# Join by the variable identifying each district
addtional_data <- addtional_data %>% rename(District = congress_district)

names(addtional_data)

addtional_data %>% relocate(District)

# How many rows will NOT be merged?
## (Note: ideally, we want this to be zero)
CD %>% anti_join(addtional_data, "District") 

#NEW DATASET:
CD2 <- left_join(CD,addtional_data,by="District")


names(CD2)

CD2 %>% group_by(Cluster) %>% summarise(HRC = mean(Clinton16),
                                       DJT = mean(Trump16),
                                       college_grad = mean(prop_college_acs201418,na.rm=T))


###################
# Basic Regressions
###################

reg1 <- lm(Clinton16 ~ prop_college_acs201418, data = CD2)

# One numerical independent variables + 1 factor (categorical) variable:

reg2 <- lm(Clinton16 ~ prop_college_acs201418 + 
                          factor(Cluster), data = CD2)

summary(reg1)

summary(reg2)



