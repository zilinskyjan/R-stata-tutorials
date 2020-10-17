library(tidyverse)
library(haven)
library(ggridges)

# Congressional districts [including data on density]
CD <- readr::read_csv("https://raw.githubusercontent.com/zilinskyjan/citylab-data/master/citylab-congress/citylab_cdi_extended.csv")
# Change variable name "CD" to "District"
CD <- rename(CD, `District` = `CD`)
CD$state <- substr(CD$District,1,2) 

addtional_data <- read_dta("https://github.com/zilinskyjan/R-stata-tutorials/blob/master/data/CD_voteshares_demos_2016_18.dta?raw=true")
CD <- left_join(CD,addtional_data,by="District")

####################
# VISUALIZING DATA
####################

library(RColorBrewer)
library(ggpubr)

jzc <- brewer.pal(9, "PuBu")[7]
ss1 <- brewer.pal(9, "Set1")


##############
# Scatterplots
##############

ggplot(CD,aes(x=prop_white_acs201418,y=Clinton16))

ggplot(CD,aes(x=prop_white_acs201418,y=Clinton16)) + geom_point()



CD %>% group_by(Cluster) %>% summarise(HRC = mean(Clinton16),
                                        DJT = mean(Trump16),
                                        college_grad = mean(prop_college_acs201418,na.rm=T)) %>%
  ggplot(aes(y=HRC,x=college_grad)) +
  geom_point()


CD %>% group_by(Cluster) %>% summarise(HRC = mean(Clinton16),
                                        DJT = mean(Trump16),
                                        college_grad = mean(prop_college_acs201418,na.rm=T)) %>%
  ggplot(aes(y=HRC,x=college_grad,label=Cluster)) +
  geom_point() + 
  geom_text(aes(),hjust=0, vjust=0) # or try hjust=0=.5


# Position the labels better:

library(ggrepel)

scatterplot <- CD %>% group_by(Cluster) %>% summarise(HRC = mean(Clinton16),
                                                       DJT = mean(Trump16),
                                                       college_grad = mean(prop_college_acs201418,na.rm=T)) %>%
  ggplot(aes(y=HRC,x=college_grad,label=Cluster)) +
  geom_point() +
  geom_text_repel() 

scatterplot

library(ggedit)
ggedit(scatterplot)

# Bar chart
###########

CD %>% group_by(Cluster) %>% summarise(HRC = mean(Clinton16),
                                        DJT = mean(Trump16),
                                        college_grad = mean(prop_college_acs201418,na.rm=T)) %>%
  ggplot(aes(x=Cluster,y=HRC)) +
  geom_bar(stat="identity") 

CD %>% group_by(Cluster) %>% summarise(HRC = mean(Clinton16),
                                        DJT = mean(Trump16),
                                        college_grad = mean(prop_college_acs201418,na.rm=T)) %>%
  ggplot(aes(x=Cluster,y=HRC)) +
  geom_bar(stat="identity",width=.3,fill="steelblue") +
  theme_minimal()





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
