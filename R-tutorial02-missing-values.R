#R-tutorial02-missing-values.R

sum(complete.cases(CD))

sum(!complete.cases(CD))

dim(CD)

# Where are the missing values?
colSums(is.na(CD))

CD %>%
  summarise(count = sum(is.na(CD)))

CD %>%
  select(where(is.numeric)) 

CD %>%
  summarise(across(where(is.numeric), is.na)) 

# Useful references
# https://raw.githack.com/uo-ec607/lectures/master/05-tidyverse/05-tidyverse.html#35
# https://dplyr.tidyverse.org/reference/summarise.html
# https://dplyr.tidyverse.org/articles/colwise.html
# https://stackoverflow.com/questions/44290704/dplyr-count-non-na-value-in-group-by


