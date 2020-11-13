
# Repo with the dta:   https://github.com/favstats/USElection2020-NYT-Results

V <- read_csv("https://raw.githubusercontent.com/favstats/USElection2020-NYT-Results/master/data/latest/presidential.csv")

V <-  V %>% rename(county_fips = fips)

V %>% 
  filter(state %in% c("florida","illinois","michigan","pennsylvania","ohio","wisconsin","arizona","minnesota","georgia")) %>%
  ggplot(aes(x=margin2016,y=margin2020)) + 
  geom_point(size=.6) + 
  facet_wrap(~state)


cty_age_data <- read_csv("https://raw.githubusercontent.com/zilinskyjan/elections-and-voting/master/data-election-comparison/US-county-age-profiles-ACS2018.csv")

# A01001B_001 "Total Population:"
# A01001B_002 "Total Population: More than 5 Years"
# A01001B_003 "Total Population: More than 10 Years"
# A01001B_004 "Total Population: More than 15 Years"
# A01001B_005 "Total Population: More than 18 Years"
# A01001B_006 "Total Population: More than 25 Years"
# A01001B_007 "Total Population: More than 35 Years"
# A01001B_008 "Total Population: More than 45 Years"
# A01001B_009 "Total Population: More than 55 Years"
# A01001B_010 "Total Population: More than 65 Years"
# A01001B_011 "Total Population: More than 75 Years"
# A01001B_012 "Total Population: More than 85 Years"


cty_age_data <- cty_age_data %>% rename(county_fips = FIPS)

data <- left_join(cty_age_data,V,by="county_fips")


data <- data %>%
  mutate(perc_35plus = A01001B_007 / A01001B_001 * 100,
         perc_45plus = A01001B_008 / A01001B_001 * 100,
         perc_55plus = A01001B_009 / A01001B_001 * 100,
         perc_65plus = A01001B_010 / A01001B_001 * 100,
         perc_75plus = A01001B_011 / A01001B_001 * 100)


data <- data  %>% 
  filter(state != "alaska") %>% 
  mutate(trump_perc = results_trumpd/votes*100,
         biden_perc = results_bidenj/votes*100,
         biden_2P_voteshare = biden_perc / (biden_perc+trump_perc) * 100)


data %>% 
  filter(state %in% c("florida","illinois","michigan","pennsylvania","ohio","wisconsin","arizona","minnesota","georgia")) %>%
  ggplot(aes(x=perc_55plus,y=biden_2P_voteshare)) + 
  labs(x = "Population over 55 (%)", y = "Biden two-party vote share (%)") +
  geom_point(size=.6) + 
  facet_wrap(~state) 

data %>% 
  filter(state %in% c("florida","illinois","michigan","pennsylvania","ohio","wisconsin","arizona","minnesota","georgia")) %>%
  ggplot(aes(x=perc_65plus,y=biden_2P_voteshare)) + 
  labs(x = "Population over 65 (%)", y = "Biden two-party vote share (%)") +
  geom_point(size=.6) + 
  facet_wrap(~state) 

data %>% 
  filter(state %in% c("florida","illinois","michigan","pennsylvania","ohio","wisconsin","arizona","minnesota","georgia")) %>%
  ggplot(aes(x=margin2016,y=margin2020,color=perc_65plus)) + 
  geom_point(size=.6) + 
  facet_wrap(~state)


# Generate categories:

elex <- data %>% 
  mutate(margin2020_cat = case_when(
    margin2020 >= 20 ~ "Trump +20%",
    margin2020 < 20 & margin2020 >= 10 ~ "Trump +10-20%",
    margin2020 < 10 & margin2020 >= 0 ~ "Trump +0-10%",
    margin2020 < 0 & margin2020 >= -10 ~ "Biden +0-10%",
    margin2020 < -10 & margin2020 >= -20 ~ "Biden +10-20%",
    margin2020 <= -20 ~ "Biden +20%"
  ),
  cat65 = case_when(
    perc_65plus <=10 ~ "Less than 10% of pop. aged 65+",
    perc_65plus > 10 & perc_65plus <= 20 ~ "10-20%",
    perc_65plus > 20 & perc_65plus <= 25 ~ "20-25%",
    perc_65plus > 25 & perc_65plus < 30 ~ "25-30%",
    perc_65plus >= 30  ~ "Over 30% of pop 65+"
  ),
  winner_comp = case_when(
    margin2020 > 0 & margin2016 > 0 ~ "Trump won twice",
    margin2020 < 0 & margin2016 > 0 ~ "Biden flipped a Trump county",
    margin2020 > 0 & margin2016 < 0 ~ "Trump flipped a Clinton county",
    margin2020 < 0 & margin2016 < 0 ~ "Clinton and Biden won",
  )) 

elex %>% count(margin2020_cat) %>% arrange(margin2020_cat) # %>% pull(margin2020_cat) %>% dput()
# Create a vector of categories
elex %>% count(margin2020_cat) %>% arrange(margin2020_cat) %>% pull(margin2020_cat) %>% dput()


elex %>% count(cat65)

elex %>% count(winner_comp)

# Prepare tables

elex %>% group_by(winner_comp) %>%
  summarise(average_biden_2P_voteshare = weighted.mean(biden_2P_voteshare,w = votes))

elex %>% group_by(cat65) %>%
  summarise(average_biden_2P_voteshare = weighted.mean(biden_2P_voteshare,w = votes))

# And some different cuts:

elex %>% group_by(margin2020_cat) %>%
  filter(!is.na(margin2020_cat)) %>%
  summarise(average_prop_65plus = weighted.mean(perc_65plus,w = votes))

tab <- elex %>% group_by(margin2020_cat) %>%
  filter(!is.na(margin2020_cat)) %>%
  summarise(average_prop_65plus = weighted.mean(perc_65plus,w = votes)) %>%
  arrange(average_prop_65plus) 
  
plot(x=tab$average_prop_65plus,
     pch=16,
     xaxt = "n" , 
     xlab = "2020 Election results",
     ylab = "Average % of population aged 65+")
axis(1,at=1:6,labels=tab$margin2020_cat)
  


elex %>% filter(!is.na(winner_comp)) %>%
  ggplot(aes(x=perc_65plus,y=biden_2P_voteshare)) + 
  labs(x = "Population over 65 (%)", y = "Biden two-party vote share (%)") +
  geom_point(size=.6) + 
  facet_wrap(~winner_comp) 

