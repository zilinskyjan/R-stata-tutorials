clear

use "https://github.com/zilinskyjan/R-stata-tutorials/blob/master/data/PIIE_replication_wp17-7/Election%20Data.dta?raw=true"

* use "PIIE_wp17-7/Election Data.dta", clear

summ repvote

gen rep_vs = repvote / totalvote
gen dem_vs = demvote / totalvote

label var rep_vs "Trump vote share in 2016"
label var urbanshare "Urban share"
label var pctwhite "Percent white"
label var lfp "Labor force participation rate (%)"

tab year 

keep if year == 2016

drop if year <= 2012

summ pctminbachelor25to34

reg rep_vs pctminbachelor25to34
margins, at(pctminbachelor25to34=(0(10)90))

marginsplot

marginsplot, title("Predicted Trump vote share in 2016") name(fig1)

scatter rep_vs pctminbachelor25to34, name(fig2)

gr combine fig1 fig2

* Subsetting the observations to be displayed
summ urbanshare, det

scatter rep_vs pctminbachelor25to34 if  urbanshare <= 10.97, title("25% least urbanized counties")

* Overlaying two scatterplots
twoway /// 
	(scatter rep_vs pctminbachelor25to34 if statecode=="PA", mcol(purple)) ///
	(scatter rep_vs pctminbachelor25to34 if statecode=="FL")

	
	
* Create a categorical variable
xtile lfp_Q5 = lfp, n(5)

tab lfp_Q5

graph bar (mean) rep_vs, over(lfp_Q5)

recode lfp_Q5 (1=1 "Lowest LFP") (2=2 "2nd quintile") (3=3 "Middle quintile") ///
	(4=4 "4th quintile") (5=5 "Top quintile"), gen (lfp_Q5_labelled)

graph bar (mean) rep_vs, over(lfp_Q5_labelled)

* Extending the regression
reg rep_vs pctminbachelor25to34 ib3.lfp_Q5_labelled

coefplot, drop(_cons)



scatter rep_vs d_tradeusch_pw if year==2016

scatter rep_vs d_tradeusch_pw if year==2016, mcol(*.3) msize(*.6) ///
note("Each point is a U.S. county.") ///
ylabel(0 "0" .25 "25%" .5 "50%" .75 "75%" 1 "100%")

scatter rep_vs urbanshare [w=totalpopulation] if year==2016, mcol(*.3) msize(*.6) ///
note("Each point is a U.S. county, scaled by total population.") ///
ylabel(0 "0" .25 "25%" .5 "50%" .75 "75%" 1 "100%")

scatter rep_vs pctwhite [w=totalpopulation] if year==2016, mcol(*.3) msize(*.6) ///
title("County racial composition and 2016 presidential vote") ///
note("Each point is a U.S. county, scaled by total population.") ///
ylabel(0 "0" .25 "25%" .5 "50%" .75 "75%" 1 "100%")

scatter rep_vs pcthispanic [w=totalpopulation] if year==2016, mcol(*.3) msize(*.6) ///
title("County racial composition and 2016 presidential vote") ///
note("Each point is a U.S. county, scaled by total population.") ///
ylabel(0 "0" .25 "25%" .5 "50%" .75 "75%" 1 "100%")

scatter rep_vs mprtrate if year==2016, mcol(*.3) msize(*.6) ///
title("Religion and 2016 presidential vote") ///
note("Each point is a U.S. county.") ///
ylabel(0 "0" .25 "25%" .5 "50%" .75 "75%" 1 "100%")

scatter rep_vs lfp if year==2016, mcol(*.3) msize(*.6) ///
title("Participation in the labor market and 2016 presidential vote choice") ///
note("Each point is a U.S. county.") ///
ylabel(0 "0" .25 "25%" .5 "50%" .75 "75%" 1 "100%")

scatter rep_vs pctbachelorplus if year==2016, mcol(*.3) msize(*.6) ///
title("Education 2016 and presidential vote choice") ///
note("Each point is a U.S. county.") ///
ylabel(0 "0" .25 "25%" .5 "50%" .75 "75%" 1 "100%")


  

