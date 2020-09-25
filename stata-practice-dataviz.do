use "PIIE_wp17-7/Election Data.dta", clear

gen rep_vs = repvote / totalvote
gen dem_vs = demvote / totalvote

label var rep_vs "Trump vote share in 2016"
label var urbanshare "Urban share"
label var pctwhite "Percent white"
label var lfp "Labor force participation rate (%)"


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


  

