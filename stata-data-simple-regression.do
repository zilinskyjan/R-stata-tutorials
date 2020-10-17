clear

* Options for importing the data

* If the dta file is on your computer:
* use "citylab-districts-density-2018.dta"

* If you don't have the file ready:
import delimited "https://raw.githubusercontent.com/zilinskyjan/citylab-data/master/citylab-congress/citylab_cdi_extended.csv"

* Merge in additional covariates:

rename cd congress_district 
merge 1:1 congress_district using "https://github.com/zilinskyjan/R-stata-tutorials/blob/master/data/CD_voteshares_demos_2016_18.dta?raw=true"

tab cluster

gen pure_urban = (cluster == "Pure urban")
gen pure_rural = (cluster == "Pure rural")

reg clinton16 pure_urban

* Or generate a set of binary variables this way:
tab cluster, gen(density_type)

reg clinton16 density_type3

* Add a continuous variable to the the regression:
reg clinton16 highdensity

* Generate above/below median indicator
xtile dem2016_median = clinton16, n(2)

tab dem2016_median

tabstat clinton16, by(dem2016_median)

* New binary variable

gen dem2016_winner = (clinton16 > trump16)
