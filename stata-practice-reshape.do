* Tasks:
* 1. Read in wide state-level personal income growth data
* 2. Tidy the dataset (reshape it from wide to long)

import excel "real_personal_income_growth_sapri_BEA.xls", sheet("Sheet0") firstrow

gen state_fips = substr(GeoFips,1,2)
destring state_fips, replace
drop if state_fips==0
drop GeoFips

reshape long y, i(state_fips) j(year)

rename y personal_income_growth_STATE
label var personal_income_growth_STATE "Real per capita personal income"

save "real_personal_income_growth_sapri_BEA.dta"
