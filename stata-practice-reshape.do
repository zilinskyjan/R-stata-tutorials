* Tasks:
* 1. Download the data from: https://github.com/zilinskyjan/R-stata-tutorials/tree/master/data
* 2. Read in wide state-level personal income growth data
* 3. Tidy the dataset (reshape it from wide to long)


clear

cd "~/Downloads"

import excel "real_personal_income_growth_sapri_BEA.xls", sheet("Sheet0") firstrow


drop if state_name == "United States"

gen state_fips = substr(GeoFips,1,2)

destring state_fips, replace

drop if state_fips==0

drop GeoFips



reshape long y, i(state_fips) j(year)

rename y personal_income_growth_STATE

label var personal_income_growth_STATE "Real per capita personal income"

save "real_personal_income_growth_sapri_BEA.dta", replace


* Then merge:

* Change the variable (ID) name to make it consistent across datasets
rename state_name state

merge m:1 state using "2020_results_Friday_morning.dta"

* Dropping 5 district-level observations
drop if _merge == 2 



* Declare: we have a panel dataset: 

tsset state_fips year

gen previous_growth = l.personal_income_growth_STATE

twoway (tsline personal_income_growth_STATE if state_name=="California")

* Then label the chart:
