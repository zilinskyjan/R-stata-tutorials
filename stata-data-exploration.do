clear

* Options for importing the data

* If the dta file is on your computer:
use "citylab-districts-density-2018.dta"

* If you don't have the file ready:
import delimited "https://raw.githubusercontent.com/zilinskyjan/citylab-data/master/citylab-congress/citylab_cdi_extended.csv"


* 1. What does each row mean?

browse

rename cd district

* 2. How many variables (columns) are contained in the dataset?
* 3. What variables (columns) are present?
* 4. Which variables contain missing data?


summarize

* Why is the reported number of observations sometimes "0"?


* How are the district classified and how many districts of each type do we have in the data?
tab cluster

browse district cluster


***********************************
* GENERATING DESCRIPTIVE STATISTIC
* BY CATEGORY
***********************************

* TASK: Calculate average Democratic vote share in the state of New York:

* Can / shoudl you do this?  [Please don't do this]
tabstat clinton16 if district == "NY-01" | district == "NY-02" | district == "NY-03" | district=="NY=04" .......

* We want to simplify our life

* We already have information about "which state the district is in"
* even if THERE IS NO VARIABLE called "state"

* Let's generate a state indicator:
generate state = substr(district,1,2)

browse district state cluster

* SOLUTION
tabstat clinton16 if stat == "NY"

* Distribution of district types in Arizona:

tab cluster if state=="AZ"

* Summarizing vote shares
tabstat clinton16

tabstat clinton16, stat(min mean median max)

tabstat clinton16, by(state)

tabstat clinton16, by(state) stat(min mean median max)

* Calculate Democratic averages over time
tabstat obama08 obama12 clinton16, by(state)

* Q: If polarization increased... there will be larger between district-level results

* TASK: Did the standard deviation increase?

* SOLUTION
tabstat obama08 obama12 clinton16, s(sd)
tabstat obama08 obama12 clinton16, by(state) s(sd)

* TASK: Generate a dummy variable for "solid blue"

* Making a new variable as a function of what we already have

gen solid_victory_HRC = (clinton16 >. 6)

tabstat clinton16, by(solid_victory_HRC)

* Sorting observations

sort clinton16
