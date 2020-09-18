clear

* Options for importing the data

import delim https://raw.githubusercontent.com/zilinskyjan/citylab-data/master/citylab-congress/citylab_cdi_extended.csv

* OR:
* use "data/citylab-districts-density-2018.dta"

* 1. What does each row mean?
* 2. How many variables (columns) are contained in the dataset?
* 3. What variables (columns) are present?
* 4. Which variables contain missing data?
summarize

* How are the district classified and how many districts of each type do we have in the data?
tab Cluster

* Where was HRC's vote at its minimum?
sort Clinton16


* Inspect individual rows and cells
** a) How well did Clinton do in 2016 in NY-14?
** b) How well did she do in New York state?
** c) What can we do if a variable STATE is not included?
