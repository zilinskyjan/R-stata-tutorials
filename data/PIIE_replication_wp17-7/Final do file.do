*************************************************************************************************

*MANUFACTURING AND THE 2016 PRESIDENTIAL ELECTION: AN ANALYSIS OF US PRESIDENTIAL ELECTION DATA*

*CAROLINE FREUND & DARIO SIDHU*

*APRIL 28, 2017*

*************************************************************************************************

cd "\local directory"
use "Election Data.dta", clear
set more off
xtset fips year

*Generate variables on voting patterns for the analysis*

bys fips: gen lagtotalvote = totalvote[_n-1]
bys fips: gen longlagtotalvote = totalvote[_n-4]

gen relrep = (repvote/(repvote+demvote))*100
gen reldem = (demvote/(repvote+demvote))*100

gen lnrep = ln(repvote)
gen lndem = ln(demvote)

by fips: gen lnrepgrowth = (lnrep - lnrep[_n-1])
by fips: gen lndemgrowth = (lndem - lndem[_n-1])

by fips: gen relrepgrowth = (relrep - relrep[_n-1])
by fips: gen longrelrepgrowth = (relrep-relrep[_n-4])
by fips: gen reldemgrowth = (reldem - reldem[_n-1])

by fips: gen demgrowthpct=(demvote-demvote[_n-1])/demvote[_n-1]*100
by fips: gen repgrowthpct=(repvote-repvote[_n-1])/repvote[_n-1]*100

*Generate variables on economic indicators for counties*

xtset fips year

gen lnwage=ln(medianwage)
gen lnmalewage=ln(malewage)

gen lnpop = ln(totalpopulation)
by fips: gen laglnpop = lnpop[_n-4]

by fips: gen manufacturingempshare = (manufacturingemps/totalemps)*100
by fips: gen constructionempshare = (constructionemps/totalemps)*100

*Generate change variables, from 2000-2016*

by fips: gen longmanchange = manufacturingempshare-manufacturingempshare[_n-4]
by fips: gen longconchange = constructionempshare-constructionempshare[_n-4]
by fips: gen longlfpchange = lfp-lfp[_n-4]
by fips: gen longunempchange = unemployment-unemployment[_n-4]
by fips: gen longwagechange = lnmalewage-lnmalewage[_n-4]

*Generate lagged values (year 2000)*

by fips: gen lagwage= lnmalewage[_n-4]
by fips: gen lagunemp= unemployment[_n-4]
by fips: gen laglfp = lfp[_n-4]
by fips: gen lagman = manufacturingempshare[_n-4]

*Generate demographic variables*

gen shareover50 = upto55share + upto60share + upto65share + upto70share + upto75share + upto80share + upto85share + over85share

*The 2000 Census has one additional age group (over 85 share)*

replace shareover50 = upto55share + upto60share + upto65share + upto70share + upto75share + upto80share + upto85share + upto90share + over90share if year==2000

gen millenialshare =  upto20share + upto25share +upto30share + upto35share

*Generate variable indicating swing states*

gen swingstate=1 if state=="Michigan"|state=="Colorado"|state=="Florida"|state=="Iowa"|state=="Michigan"|state=="Minnesota"|state=="Ohio"|state=="Nevada"|state=="New Hampshire"|state=="North Carolina"|state=="Pennsylvania"|state=="Virginia"|state=="Wisconsin"
replace swingstate=0 if swingstate==.

*Generate variable indicating Northern United States (Northeast, Mid-Atlantic, Midwest)*

gen north = 0
replace north = 1 if state=="Illinois"|state=="Indiana"|state=="Iowa"|state=="Kansas"|state=="Michigan"|state=="Minnesota"|state=="Missouri"|state=="Nebraska"|state=="North Dakota"|state=="Ohio"|state=="South Dakota"|state=="Wisconsin"|state=="Rhode Island"|state=="Massachusetts"|state=="Connecticut"|state=="New Hampshire"|state=="Vermont"|state=="Maine"|state=="New Jersey"|state=="New York"|state=="Pennsylvania"

*Generate variables on increases in votes cast, to calculate contribution variables*

xtset fips year

bys fips: gen demgrowth = demvote-demvote[_n-1]
bys fips: gen repgrowth = repvote-repvote[_n-1]

gen absdemgrowth = abs(demgrowth)
gen absrepgrowth = abs(repgrowth)

gen turnout = demvote+repvote
gen logturnout = log(turnout)
drop if turnout==0
bys fips: gen deltalogturnout = logturnout-logturnout[_n-1]

gen demcontribution = absdemgrowth/(absdemgrowth+absrepgrowth)
gen repcontribution = absrepgrowth/(absrepgrowth+absdemgrowth)

*Generate contribution for the entire United States*

preserve

collapse(sum) demvote repvote, by(year)

gen demgrowth = demvote-demvote[_n-1]
gen repgrowth = repvote-repvote[_n-1]

gen absdemgrowth = abs(demgrowth)
gen absrepgrowth = abs(repgrowth)

gen demcontribution = absdemgrowth/(absdemgrowth+absrepgrowth)
gen repcontribution = absrepgrowth/(absrepgrowth+absdemgrowth)

restore

*Create figures 4 % 5, on the Republican contribution by state type, and by manufacturing intensity*

preserve

keep if year==2016

gen statetype="Swing State" if statecode=="CO"|statecode=="FL"|statecode=="IA"|statecode=="MI"|statecode=="MN"|statecode=="OH"|statecode=="NV"|statecode=="NH"|statecode=="NC"|statecode=="PA"|statecode=="VA"|statecode=="WI"
replace statetype="Blue State" if statecode=="WA"|statecode=="OR"|statecode=="CA"|statecode=="HI"|statecode=="NM"|statecode=="IL"|statecode=="ME"|statecode=="NY"|statecode=="VT"|statecode=="MA"|statecode=="CT"|statecode=="RI"|statecode=="NJ"|statecode=="DE"|statecode=="MD"|statecode=="DC"
replace statetype="Red State" if statecode=="AK"|statecode=="UT"|statecode=="ID"|statecode=="MT"|statecode=="WY"|statecode=="TX"|statecode=="OK"|statecode=="KS"|statecode=="NE"|statecode=="SD"|statecode=="ND"|statecode=="MO"|statecode=="AR"|statecode=="LA"|statecode=="MS"|statecode=="AL"|statecode=="TN"|statecode=="KY"|statecode=="WV"|statecode=="IN"|statecode=="AZ"|statecode=="GA"|statecode=="SC"

twoway scatter repcontribution deltalogturnout if statetype=="Blue State" & deltalogturnout>-0.6 || scatter repcontribution deltalogturnout if statetype=="Red State" || scatter repcontribution deltalogturnout if statetype=="Swing State", graphregion(lcolor(white)) xtitle("Change in major party votes, 2012-16 (log)") ytitle("Republican contribution") title("Figure 4: Republican contribution by county, 2016") note("Source: Dave Leip's US Election Atlas; authors' calculations") legend(label(1 "Blue states") label(2 "Red states") label(3 "Swing states")) graphregion(color(white))
graph save figure4, replace

summarize manufacturingempshare, detail
return list
local top25man=r(p75)
twoway scatter repcontribution deltalogturnout if manufacturingempshare<`top25man' & deltalogturnout>-0.6 || scatter repcontribution deltalogturnout if manufacturingempshare>`top25man', legend(label(1 "Low manufacturing") label(2 "High manufacturing")) graphregion(color(white)) xtitle("Change in major party votes, 2012-16 (log)") ytitle("Republican contribution") title("Figure 5: Republican contribution by manufacturing intensity, 2016") note("Source: Dave Leip's US Election Atlas, US Census; authors' calculations")
graph save figure5, replace

restore

*Generate variables for analysis*

gen deltaturnout = ((turnout-turnout[_n-1])/turnout)*100
gen pctminbachelor = (pctbachelor+pctgrad)

replace pctminbachelor=pctbachelorplus if year==2000

*Generate minority share (share of population that is black or hispanic)*

gen pctblackorhispanic = (pctblack + pcthispanic)

*Generate share of population between 35 and 50*

gen middleshare = (100-millenialshare-shareover50)

*Generate figure 1, bivariate correlations between Republican vote growth 2012-16 and main variables of interest*

preserve

keep if year==2016

twoway scatter relrepgrowth pctblackorhispanic, graphregion(color(white)) title("Ethnic diversity") ytitle("") xtitle("Share black or hispanic") ysize(4) ylabel(-20 (15) 30) yline(0) msize(tiny)
graph save scatter1, replace
twoway scatter relrepgrowth pctminbachelor, xlabel(0 (20) 100) graphregion(color(white)) title("Education") ytitle("") xtitle("Share with bachelor's degree or higher") ysize(4) ylabel(-20 (15) 30) yline(0) msize(tiny)
graph save scatter2, replace
replace mprtrate=mprtrate/10
twoway scatter relrepgrowth mprtrate, graphregion(color(white)) title("Religion") ytitle("") xtitle("Adherence per 100") ysize(4) ylabel(-20 (15) 30) yline(0) msize(tiny)
graph save scatter3, replace
twoway scatter relrepgrowth middleshare, graphregion(color(white)) title("Share middle-aged") ytitle("") xtitle("Share middle-aged") ysize(4) ylabel(-20 (15) 30) yline(0) msize(tiny)
graph save scatter4, replace
twoway scatter relrepgrowth unemployment, graphregion(color(white)) title("Unemployment") ytitle("") xtitle("Share unemployment") ysize(4) ylabel(-20 (15) 30) yline(0) msize(tiny)
graph save scatter5, replace
twoway scatter relrepgrowth lfp, graphregion(color(white)) title("Labor force participation") ytitle("") xtitle("Labor force participation rate") ysize(4) ylabel(-20 (15) 30) yline(0) msize(tiny)
graph save scatter6, replace
twoway scatter relrepgrowth medianwage, xscale(log) xlabel(10000 (30000) 80000) graphregion(color(white)) title("Median wage") ytitle("") xtitle("Median wage (log scale)") ysize(4) ylabel(-20 (15) 30) yline(0) msize(tiny)
graph save scatter7, replace
twoway scatter relrepgrowth manufacturingempshare, graphregion(color(white)) title("Manufacturing employment") ytitle("") xtitle("Manufacturing employment share") ysize(4) ylabel(-20 (15) 30) yline(0) msize(tiny)
graph save scatter8, replace

gr combine scatter1.gph scatter2.gph scatter3.gph scatter4.gph scatter5.gph scatter6.gph scatter7.gph scatter8.gph, title("Figure 1: Republican vote share growth, 2012-16", size(medium)) graphregion(color(white)) note("Source: Dave Leip's Election Atlas, US Census, Association of Religion Data Archives; authors' calculations", size(tiny)) col(2) ysize(7)
graph export Figure1.tif, replace width(3900)

restore

*Generate incumbent share for panel analysis*

gen incshare = reldem if year==2016
replace incshare = reldem if year==2012
replace incshare = relrep if year==2008
replace incshare = relrep if year==2004
replace incshare = reldem if year==2000

xtset fips year

*Replace 2004 values by averages of 2000 and 2008, as 2004 Census coverage is limited*

replace pctwhite = (pctwhite[_n-1]+pctwhite[_n+1])/2 if year==2004
replace pctblackorhispanic = (pctblackorhispanic[_n-1]+pctblackorhispanic[_n+1])/2 if year==2004
replace lfp = (lfp[_n-1]+lfp[_n+1])/2 if year==2004
replace unemployment = (unemployment[_n-1]+unemployment[_n+1])/2 if year==2004
replace pctminbachelor = (pctminbachelor[_n-1]+pctminbachelor[_n+1])/2 if year==2004
replace middleshare = (middleshare[_n-1]+middleshare[_n+1])/2 if year==2004
replace lnwage = (lnwage[_n-1]+lnwage[_n+1])/2 if year==2004

*TABLE 2 - BASIC AND SWING STATES*

*Create indicator for minority share mean*

summarize pctblackorhispanic if year==2016, detail
return list
local meanminority=r(mean)
gen abovemeanminority = 0
replace abovemeanminority = 1 if pctblackorhispanic > `meanminority'

regress relrepgrowth manufacturingempshare lnwage unemployment lfp pctblackorhispanic middleshare pctminbachelor mprtrate lnpop [iweight=lagtotalvote], robust
outreg2 using table2.doc, replace stats(beta tstat) asterisk(beta) dec(2)
regress relrepgrowth c.manufacturingempshare##c.pctblackorhispanic lnwage unemployment lfp middleshare pctminbachelor mprtrate lnpop [iweight=lagtotalvote], robust
outreg2 using table2.doc, stats(beta tstat) asterisk(beta) dec(2)
regress relrepgrowth c.manufacturingempshare##i.abovemeanminority pctblackorhispanic lnwage unemployment lfp middleshare pctminbachelor mprtrate lnpop [iweight=lagtotalvote], robust
outreg2 using table2.doc, stats(beta tstat) asterisk(beta) dec(2)
regress relrepgrowth manufacturingempshare lnwage unemployment lfp pctblackorhispanic middleshare pctminbachelor mprtrate lnpop if swingstate==1 [iweight=lagtotalvote], robust
outreg2 using table2.doc, stats(beta tstat) asterisk(beta) dec(2)
regress relrepgrowth c.manufacturingempshare##c.pctblackorhispanic lnwage unemployment lfp middleshare pctminbachelor mprtrate lnpop if swingstate==1 [iweight=lagtotalvote], robust
outreg2 using table2.doc, stats(beta tstat) asterisk(beta) dec(2)
regress relrepgrowth c.manufacturingempshare##i.abovemeanminority pctblackorhispanic lnwage unemployment lfp middleshare pctminbachelor mprtrate lnpop if swingstate==1 [iweight=lagtotalvote], robust
outreg2 using table2.doc, stats(beta tstat) asterisk(beta) dec(2)


*TABLE 3 - BASIC AND SWING STATES - LONG CHANGE*

regress relrepgrowth pctblackorhispanic middleshare pctminbachelor mprtrate longwagechange longunempchange longlfpchange longmanchange lnpop [iweight=lagtotalvote], robust
outreg2 using table3.doc, replace stats(beta tstat) asterisk(beta) dec(2)
regress relrepgrowth pctblackorhispanic middleshare pctminbachelor mprtrate longwagechange longunempchange longlfpchange c.longmanchange##c.pctblackorhispanic lnpop [iweight=lagtotalvote], robust
outreg2 using table3.doc, stats(beta tstat) asterisk(beta) dec(2)
regress relrepgrowth pctblackorhispanic middleshare pctminbachelor mprtrate longwagechange longunempchange longlfpchange c.longmanchange##i.abovemeanminority lnpop [iweight=lagtotalvote], robust
outreg2 using table3.doc, stats(beta tstat) asterisk(beta) dec(2)
regress relrepgrowth pctblackorhispanic middleshare pctminbachelor mprtrate longwagechange longunempchange longlfpchange longmanchange lnpop if swingstate==1 [iweight=lagtotalvote], robust
outreg2 using table3.doc, stats(beta tstat) asterisk(beta) dec(2)
regress relrepgrowth pctblackorhispanic middleshare pctminbachelor mprtrate longwagechange longunempchange longlfpchange c.longmanchange##c.pctblackorhispanic lnpop if swingstate==1 [iweight=lagtotalvote], robust
outreg2 using table3.doc, stats(beta tstat) asterisk(beta) dec(2)
regress relrepgrowth pctblackorhispanic middleshare pctminbachelor mprtrate longwagechange longunempchange longlfpchange c.longmanchange##i.abovemeanminority lnpop if swingstate==1 [iweight=lagtotalvote], robust
outreg2 using table3.doc, stats(beta tstat) asterisk(beta) dec(2)

summarize longmanchange, detail
return list
local p75loss=r(p75)
local p25loss=r(p25)

regress relrepgrowth pctblackorhispanic middleshare pctminbachelor mprtrate longwagechange longunempchange longlfpchange c.longmanchange##i.abovemeanminority lnpop [iweight=lagtotalvote], robust
ereturn list
matrix list e(b)
local coeffjobloss=_b[longmanchange]
local coeffinterac=_b[1.abovemeanminority#c.longmanchange]

*25th to 75th percentile, white counties*

local p75outcomewhite = `coeffjobloss' * `p75loss'
local p25outcomewhite = `coeffjobloss' * `p25loss'
local whitecountymagnitude = `p25outcomewhite' - `p75outcomewhite' 
display `whitecountymagnitude'

*Diverse counties*

local p75outcomediverse = `p75outcomewhite' + `coeffinterac'*`p75loss'
local p25outcomediverse = `p25outcomewhite' + `coeffinterac'*`p25loss'
local diversecountymagnitude = `p25outcomediverse' - `p75outcomediverse' 
display `diversecountymagnitude'


*TABLE 4 - ALTERNATIVE INTERACTIONS*

regress relrepgrowth pctblackorhispanic middleshare pctminbachelor mprtrate lnwage unemployment manufacturingempshare lfp c.pctminbachelor##c.pctblackorhispanic  c.manufacturingempshare##c.pctblackorhispanic lnpop [iweight=lagtotalvote], robust
outreg2 using table4.doc, replace stats(beta tstat) asterisk(beta) dec(2) keep(manufacturingempshare pctblackorhispanic c.manufacturingempshare##c.pctblackorhispanic pctminbachelor c.pctminbachelor##c.pctblackorhispanic)
regress relrepgrowth pctblackorhispanic middleshare pctminbachelor mprtrate lnwage unemployment manufacturingempshare lfp c.constructionempshare##c.pctblackorhispanic  c.manufacturingempshare##c.pctblackorhispanic lnpop [iweight=lagtotalvote], robust
outreg2 using table4.doc, stats(beta tstat) asterisk(beta) dec(2) keep(manufacturingempshare pctblackorhispanic c.manufacturingempshare##c.pctblackorhispanic pctminbachelor constructionempshare c.constructionempshare##c.pctblackorhispanic)
regress relrepgrowth pctblackorhispanic middleshare pctminbachelor mprtrate lnwage unemployment lfp c.urbanshare##c.manufacturingempshare  c.manufacturingempshare##c.pctblackorhispanic lnpop [iweight=lagtotalvote], robust
outreg2 using table4.doc, stats(beta tstat) asterisk(beta) dec(2) keep(manufacturingempshare pctblackorhispanic c.manufacturingempshare##c.pctblackorhispanic pctminbachelor urbanshare c.urbanshare##c.manufacturingempshare)
regress relrepgrowth pctblackorhispanic middleshare pctminbachelor mprtrate lnwage unemployment lfp lnpop north##c.manufacturingempshare  c.manufacturingempshare##c.pctblackorhispanic [iweight=lagtotalvote], robust
outreg2 using table4.doc, stats(beta tstat) asterisk(beta) dec(2) keep(manufacturingempshare pctblackorhispanic c.manufacturingempshare##c.pctblackorhispanic pctminbachelor north 1.north##c.pctblackorhispanic)

regress d_tradeusch_pw d_tradeotch_pw_lag c.d_tradeotch_pw_lag##c.pctblackorhispanic c.manufacturingempshare##c.pctblackorhispanic lnwage unemployment lfp pctblackorhispanic middleshare pctminbachelor mprtrate lnpop [iweight=lagtotalvote], robust
predict double csinstrument

regress relrepgrowth csinstrument c.csinstrument##c.pctblackorhispanic c.manufacturingempshare##c.pctblackorhispanic lnwage unemployment lfp pctblackorhispanic middleshare pctminbachelor mprtrate lnpop [iweight=lagtotalvote], robust
outreg2 using table4.doc, stats(beta tstat) asterisk(beta) dec(2) keep(manufacturingempshare pctblackorhispanic c.manufacturingempshare##c.pctblackorhispanic pctminbachelor csinstrument csinstrument##c.pctblackorhispanic)

regress d_tradeusch_pw d_tradeotch_pw_lag c.d_tradeotch_pw_lag##c.pctblackorhispanic pctblackorhispanic middleshare pctminbachelor mprtrate lnwage unemployment lfp north##c.manufacturingempshare c.constructionempshare##c.pctblackorhispanic c.pctminbachelor##c.pctblackorhispanic c.urbanshare##c.manufacturingempshare manufacturingempshare c.manufacturingempshare##c.pctblackorhispanic lnpop [iweight=lagtotalvote], robust
predict double csinstrument2

regress relrepgrowth csinstrument2 c.csinstrument2##c.pctblackorhispanic pctblackorhispanic middleshare pctminbachelor mprtrate lnwage unemployment lfp north##c.manufacturingempshare c.constructionempshare##c.pctblackorhispanic c.pctminbachelor##c.pctblackorhispanic c.urbanshare##c.manufacturingempshare manufacturingempshare c.manufacturingempshare##c.pctblackorhispanic lnpop [iweight=lagtotalvote], robust
outreg2 using table4.doc, stats(beta tstat) asterisk(beta) dec(2)

*TABLES 5 - ALTERNATIVE TIMEFRAMES*

xtreg incshare pctblackorhispanic manufacturingempshare pctminbachelor middleshare lfp unemployment, fe robust
outreg2 using table5.doc, replace stats(beta tstat) asterisk(beta) dec(2) keep(pctblackorhispanic manufacturingempshare)
xtreg incshare c.manufacturingempshare##c.pctblackorhispanic pctminbachelor middleshare lfp unemployment, fe robust
outreg2 using table5.doc, stats(beta tstat) asterisk(beta) dec(2) keep(pctblackorhispanic manufacturingempshare c.manufacturingempshare##c.pctblackorhispanic)
regress longrelrepgrowth pctblackorhispanic middleshare pctminbachelor mprtrate lnwage unemployment lfp manufacturingempshare lnpop [iweight=longlagtotalvote], robust
outreg2 using table5.doc, stats(beta tstat) asterisk(beta) dec(2) keep(pctblackorhispanic manufacturingempshare)
regress longrelrepgrowth pctblackorhispanic middleshare pctminbachelor mprtrate lnwage unemployment lfp c.manufacturingempshare##c.pctblackorhispanic lnpop [iweight=longlagtotalvote], robust
outreg2 using table5.doc, stats(beta tstat) asterisk(beta) dec(2) keep(pctblackorhispanic manufacturingempshare c.manufacturingempshare##c.pctblackorhispanic)
regress relrepgrowth manempshare86 lnwage unemployment lfp pctblackorhispanic middleshare pctminbachelor mprtrate lnpop [iweight=lagtotalvote], robust
outreg2 using table5.doc, stats(beta tstat) asterisk(beta) dec(2) keep(pctblackorhispanic manempshare86)
regress relrepgrowth c.manempshare86##c.pctblackorhispanic lnwage unemployment lfp pctblackorhispanic middleshare pctminbachelor mprtrate lnpop [iweight=lagtotalvote], robust
outreg2 using table5.doc, stats(beta tstat) asterisk(beta) dec(2) keep(pctblackorhispanic manempshare86 c.manempshare86##c.pctblackorhispanic)

*TABLES 6a & 6b - CHANGE IN VOTES CAST*

*Replace percentage points by shares for analysis of votes cast*

replace pctblackorhispanic=pctblackorhispanic/100
replace pctminbachelor=pctminbachelor/100
replace manufacturingempshare=manufacturingempshare/100
replace middleshare=middleshare/100
replace unemployment=unemployment/100
replace lfp=lfp/100

regress deltalogturnout pctblackorhispanic middleshare pctminbachelor mprtrate lnwage unemployment lfp manufacturingempshare lnpop [iweight=lagtotalvote], robust
outreg2 using table6a.doc, replace stats(beta tstat) asterisk(beta) dec(2) keep(pctblackorhispanic manufacturingempshare)
regress deltalogturnout pctblackorhispanic middleshare pctminbachelor mprtrate lnwage unemployment lfp manufacturingempshare c.manufacturingempshare##c.pctblackorhispanic lnpop [iweight=lagtotalvote], robust
outreg2 using table6a.doc, stats(beta tstat) asterisk(beta) dec(2) keep(pctblackorhispanic manufacturingempshare c.manufacturingempshare##c.pctblackorhispanic)
regress lnrepgrowth pctblackorhispanic middleshare pctminbachelor mprtrate lnwage unemployment lfp manufacturingempshare lnpop[iweight=lagtotalvote], robust
outreg2 using table6a.doc, stats(beta tstat) asterisk(beta) dec(2) keep(pctblackorhispanic manufacturingempshare)
regress lnrepgrowth pctblackorhispanic middleshare pctminbachelor mprtrate lnwage unemployment lfp manufacturingempshare c.manufacturingempshare##c.pctblackorhispanic lnpop [iweight=lagtotalvote], robust
outreg2 using table6a.doc, stats(beta tstat) asterisk(beta) dec(2) keep(pctblackorhispanic manufacturingempshare c.manufacturingempshare##c.pctblackorhispanic)
regress lndemgrowth pctblackorhispanic middleshare pctminbachelor mprtrate lnwage unemployment lfp manufacturingempshare lnpop[iweight=lagtotalvote], robust
outreg2 using table6a.doc, stats(beta tstat) asterisk(beta) dec(2) keep(pctblackorhispanic manufacturingempshare)
regress lndemgrowth pctblackorhispanic middleshare pctminbachelor mprtrate lnwage unemployment lfp manufacturingempshare c.manufacturingempshare##c.pctblackorhispanic lnpop [iweight=lagtotalvote], robust
outreg2 using table6a.doc, stats(beta tstat) asterisk(beta) dec(2) keep(pctblackorhispanic manufacturingempshare c.manufacturingempshare##c.pctblackorhispanic)

regress deltalogturnout pctblackorhispanic middleshare pctminbachelor mprtrate lnwage unemployment lfp manufacturingempshare lnpop if swingstate==1 [iweight=lagtotalvote], robust
outreg2 using table6b.doc, replace stats(beta tstat) asterisk(beta) dec(2) keep(pctblackorhispanic manufacturingempshare)
regress deltalogturnout pctblackorhispanic middleshare pctminbachelor mprtrate lnwage unemployment lfp manufacturingempshare c.manufacturingempshare##c.pctblackorhispanic lnpop if swingstate==1 [iweight=lagtotalvote], robust
outreg2 using table6b.doc, stats(beta tstat) asterisk(beta) dec(2) keep(pctblackorhispanic manufacturingempshare c.manufacturingempshare##c.pctblackorhispanic)
regress lnrepgrowth pctblackorhispanic middleshare pctminbachelor mprtrate lnwage unemployment lfp manufacturingempshare lnpop if swingstate==1 [iweight=lagtotalvote], robust
outreg2 using table6b.doc, stats(beta tstat) asterisk(beta) dec(2) keep(pctblackorhispanic manufacturingempshare)
regress lnrepgrowth pctblackorhispanic middleshare pctminbachelor mprtrate lnwage unemployment lfp manufacturingempshare c.manufacturingempshare##c.pctblackorhispanic lnpop if swingstate==1 [iweight=lagtotalvote], robust
outreg2 using table6b.doc, stats(beta tstat) asterisk(beta) dec(2) keep(pctblackorhispanic manufacturingempshare c.manufacturingempshare##c.pctblackorhispanic)
regress lndemgrowth pctblackorhispanic middleshare pctminbachelor mprtrate lnwage unemployment lfp manufacturingempshare lnpop if swingstate==1 [iweight=lagtotalvote], robust
outreg2 using table6b.doc, stats(beta tstat) asterisk(beta) dec(2) keep(pctblackorhispanic manufacturingempshare)
regress lndemgrowth pctblackorhispanic middleshare pctminbachelor mprtrate lnwage unemployment lfp manufacturingempshare c.manufacturingempshare##c.pctblackorhispanic lnpop if swingstate==1 [iweight=lagtotalvote], robust
outreg2 using table6b.doc, stats(beta tstat) asterisk(beta) dec(2) keep(pctblackorhispanic manufacturingempshare c.manufacturingempshare##c.pctblackorhispanic)

*FIGURE 2*

regress relrepgrowth pctblackorhispanic middleshare pctminbachelor mprtrate lnwage unemployment lfp manufacturingempshare c.manufacturingempshare##c.pctblackorhispanic lnpop [iweight=lagtotalvote] if swingstate==1, robust
quietly margins, at(manufacturingempshare=(0(0.10)0.75) pctblackorhispanic=(0(0.20)1))
marginsplot, title("Figure 2: Predicted change in Republican vote share, 2012-16") ytitle("") note("Source: Dave Leip's US Election Atlas, US Census, ARDA; authors' calculations")
graph save figure2, replace

*FIGURES 3a & 3b*

preserve

gen bhgroup=.
replace bhgroup=5 if pctblackorhispanic<1.00
replace bhgroup=4 if pctblackorhispanic<0.80
replace bhgroup=3 if pctblackorhispanic<0.60
replace bhgroup=2 if pctblackorhispanic<0.40
replace bhgroup=1 if pctblackorhispanic<0.20

bys year: egen totvot=total(totalvote)
bys year bhgroup: egen totgroupvote=total(totalvote)
gen groupvoteshare=totgroupvote/totvot

graph bar groupvoteshare if year==2016, over(bhgroup) ylabel(0 (0.1) 0.6) title("Figure 3a: Share of total votes cast, by county % non-white") note("Source: Dave Leip's US Election Atlas, US Census; authors' calculations")
graph save figure3a, replace

restore

preserve

keep if swingstate==1

gen bhgroup=.
replace bhgroup=5 if pctblackorhispanic<1.00
replace bhgroup=4 if pctblackorhispanic<0.80
replace bhgroup=3 if pctblackorhispanic<0.60
replace bhgroup=2 if pctblackorhispanic<0.40
replace bhgroup=1 if pctblackorhispanic<0.20

bys year: egen totvot=total(totalvote)
bys year bhgroup: egen totgroupvote=total(totalvote)
gen groupvoteshare=totgroupvote/totvot

graph bar groupvoteshare if year==2016, over(bhgroup) ylabel(0 (0.1) 0.6) title("Figure 3b: Share of total votes cast, by county % non-white (swing states)") note("Source: Dave Leip's US Election Atlas, US Census; authors' calculations")
graph save figure3b, replace

restore

*FIGURE 6 - CHANGE IN VOTERS' PRIORITIES*

preserve

import excel "R:\Dario\Election\Final\pewissues.xlsx", firstrow clear
gen negx2016=-x2016
graph hbar x2012 x2016, over(issue, sort(negx2016)) graphregion(color(white)) title("Figure 6: Voters' Priorities: 2012-16") note("Source: Pew Research Center") legend(label(1 2012) label(2 2016))

restore
