library(tidyverse)
library(haven)
library(ggridges)

CD <- readr::read_csv("https://raw.githubusercontent.com/zilinskyjan/citylab-data/master/citylab-congress/citylab_cdi_extended.csv")
# Change variable name "CD" to "District"
CD <- rename(CD, `District` = `CD`)
CD$state <- substr(CD$District,1,2) 

####################
# VISUALIZING DATA
####################

library(RColorBrewer)
library(ggpubr)

jzc <- brewer.pal(9, "PuBu")[7]
ss1 <- brewer.pal(9, "Set1")

CD$DemShareGrowth2016 <- CD$Clinton16 - CD$Obama12
CD$ClintonWon <- CD$Clinton16 > CD$Trump16

CD %>% group_by(Cluster) %>%
  summarise(avg_HRC_vote_share = mean(Clinton16)) %>%
  arrange(desc(avg_HRC_vote_share)) %>%
  ggpubr::ggdotchart(y="avg_HRC_vote_share",x="Cluster",rotate = T)


CD %>%
  ggpubr::ggdotchart(y="DemShareGrowth2016",x="Cluster",color="ClintonWon",
             sorting = "descending",
             xlab = "",
             palette = ss1,
             add = "segment",
             rotate = T) # +coord_flip()


CD %>%
ggplot(aes(x=Clinton16,y=Cluster)) +
  geom_density_ridges(aes(fill = Cluster),
                      rel_min_height = .005,
                      alpha=.8) +
  scale_fill_manual(values=brewer.pal(6,"BuPu"),na.value="grey90")


CD %>% group_by(Cluster) %>%
  summarise(avg_HRC_vote_share = mean(Clinton16)) %>%
  arrange(desc(avg_HRC_vote_share))


CD %>% 
  mutate(newly_ordered_type = factor(Cluster,levels = 
                                          c("Pure urban",
                                            "Urban-suburban mix",
                                            "Dense suburban",
                                            "Sparse suburban",
                                            "Rural-suburban mix",
                                            "Pure rural"
                                          ))) %>%
  rename(`District type` = newly_ordered_type) %>%
  ggplot(aes(x=Clinton16,y=`District type`)) +
  geom_density_ridges(aes(fill = Cluster),
                      rel_min_height = .005,
                      alpha=.8) +
  scale_fill_manual(values=brewer.pal(6,"BuPu"),na.value="grey90") +
  xlim(c(0,1)) +
  scale_x_continuous(labels = scales::percent) +
  labs(x="Clinton 2016 vote share", title="Clinton's performance in Congressional districts ") +
  theme_minimal()


CD %>% 
  mutate(newly_ordered_type = factor(Cluster,levels = 
                                       c("Pure urban",
                                         "Urban-suburban mix",
                                         "Dense suburban",
                                         "Sparse suburban",
                                         "Rural-suburban mix",
                                         "Pure rural"
                                       ))) %>%
  rename(`District type` = newly_ordered_type) %>%
  ggplot(aes(x=DemShareGrowth2016,y=`District type`)) +
  geom_density_ridges(aes(fill = Cluster),
                      rel_min_height = .005,
                      alpha=.8) +
  scale_fill_manual(values=brewer.pal(6,"BuPu"),na.value="grey90") +
  xlim(c(0,1)) +
  scale_x_continuous(labels = scales::percent) +
  labs(x="Clinton 2016 minus Obama 2012 margin", title="Clinton's performance in Congressional districts ") +
  theme_minimal()
