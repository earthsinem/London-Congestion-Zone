*log using "/Users/mac/Desktop/log file.smcl", replace

*============================================================================
*Applied Econometrics Project
*Sinem Demir 

*============================================================================
**Initial commands to load  data
*============================================================================
set more off, permanently
clear all

use "/Users/mac/Desktop/Accident Data (8.7m).dta"

*============================================================================
* Data Analysis -- initial commands to reorganize the dataset
*============================================================================
ssc install coefplot
ssc install asdoc
ssc install outreg2, replace

rename accident_year year

keep if year>=1997 & year<=2008 
keep if ("E09000001"<=local_authority_ons_district & local_authority_ons_district<= "E09000033")

drop latitude longitude
drop local_authority_district local_authority_highway
drop junction_detail junction_control second_road_class second_road_number pedestrian_crossing_human_contro pedestrian_crossing_physical_fac light_conditions special_conditions_at_site carriageway_hazards urban_or_rural_area did_police_officer_attend_scene_ trunk_road_flag lsoa_of_accident_location

**# IMPORTANT- To be able to compress three files, I run the commands before here.

encode local_authority_ons_district, generate(borough)

replace borough= 1 if borough== 294
replace borough= 2 if borough== 295
replace borough= 3 if borough== 296
replace borough= 4 if borough== 297
replace borough= 5 if borough== 298
replace borough= 6 if borough== 299
replace borough= 7 if borough== 300
replace borough= 8 if borough== 301 
replace borough= 9 if borough== 302
replace borough= 10 if borough== 303
replace borough= 11 if borough== 304
replace borough= 12 if borough== 305
replace borough= 13 if borough== 306
replace borough= 14 if borough== 307
replace borough= 15 if borough== 308
replace borough= 16 if borough== 309
replace borough= 17 if borough== 310
replace borough= 18 if borough== 311
replace borough= 19 if borough== 312
replace borough= 20 if borough== 313
replace borough= 21 if borough== 314
replace borough= 22 if borough== 315
replace borough= 23 if borough== 316
replace borough= 24 if borough== 317
replace borough= 25 if borough== 318
replace borough= 26 if borough== 319
replace borough= 27 if borough== 320
replace borough= 28 if borough== 321
replace borough= 29 if borough== 322
replace borough= 30 if borough== 323
replace borough= 31 if borough== 324
replace borough= 32 if borough== 325
replace borough= 33 if borough== 326

gen month=substr(date,4,2)
gen day=substr(date,1,2)
gen hour=substr(time,1,2)
destring day month hour, replace

gen tm=ym(year,month)
format tm %tm

destring speed_limit, replace

asdoc sum , replace

*============================================================================
* Trunction -- adjusting the treatment group according to the congestion time
*============================================================================
gen kept=0
replace kept=1 if day_of_week>=1 & day_of_week<=5 & hour>= 7 & hour<18
replace kept=1 if day_of_week>=6 & day_of_week<=7 & hour>= 12 & hour<18
keep if kept==1

*============================================================================
* Calculation of the total number of the accidents 
*============================================================================
gen x1=1
bysort tm borough: egen acc=total(x1)

*============================================================================
* Policy (T): 0 (pre-policy) 1 (post-policy) --- year-month
*============================================================================
gen policy=0
replace policy=1 if tm>=ym(2003,2)

*============================================================================
* Treatment (D): 0 control / 1 treated --- boroughs
*============================================================================
gen CCZ=0
replace CCZ=1 if borough==6 | borough==7 | borough==12 | borough==19 | borough==20 | borough==22 | borough==28 | borough==30 | borough==32 | borough==33

*============================================================================
* Regressions
*============================================================================
* Generate panel data
tab year, gen(yr)

* Declare data to be panel data
duplicates drop tm borough, force
xtset borough tm
xtdes

gen treated_after= policy*CCZ

local n_years = 12

forval i = 2/`n_years' {
    gen tr_yr`i' = yr`i' * CCZ
}

*basic DD
reg acc CCZ policy treated_after, robust
outreg2 using diff.doc, replace ctitle(Basic DD)

*including panel fixed effects
xtreg acc policy treated_after, fe cluster (borough)
outreg2 using diff.doc, append ctitle(PANEL FE)

*including panel fixed effects and time fixed effects
xtreg acc treated_after yr2-yr12, fe cluster (borough)
outreg2 using diff.doc, append ctitle(Panel FE with time FE)

*============================================================================
* Parallel Trend Assumption
*============================================================================

* Parallel trend for year-month
bysort tm: egen avg_acc_tm=mean(acc) if CCZ== 1
bysort tm: egen avg_acc_tm_control=mean(acc) if CCZ== 0

tw (tsline avg_acc_tm if CCZ==1, sort) (tsline avg_acc_tm_control if CCZ==0, sort), xtitle("Year-month") ytitle("Accidents") xline(`=tm(2003m2)')

xtreg acc tr_yr2-tr_yr12 yr2-yr12,fe cluster (borough)

coefplot, keep(tr_yr1 tr_yr2 tr_yr3 tr_yr4 tr_yr5 tr_yr6 tr_yr7 tr_yr8 tr_yr9 tr_yr10 tr_yr11 tr_yr12) vertical

margins, dydx(tr_yr1 tr_yr2 tr_yr3 tr_yr4 tr_yr5 tr_yr6 tr_yr7 tr_yr8 tr_yr9 tr_yr10 tr_yr11 tr_yr12)
marginsplot

* Paralel trend for year
bysort year: egen avg_acc_year=mean(acc) if CCZ== 1
bysort year: egen avg_acc_year_control=mean(acc) if CCZ== 0

tw (tsline avg_acc_year if CCZ==1, sort) (tsline avg_acc_year_control if CCZ==0, sort), xtitle("Year") ytitle("Accidents") xline(`=tm(2003m2)')

xtreg acc tr_yr2-tr_yr12 yr2-yr12,fe cluster (borough)

coefplot, keep(tr_yr2 tr_yr3 tr_yr4 tr_yr5 tr_yr6 tr_yr7 tr_yr8 tr_yr9 tr_yr10 tr_yr11 tr_yr12) vertical

margins, dydx(tr_yr2 tr_yr3 tr_yr4 tr_yr5 tr_yr6 tr_yr7 tr_yr8 tr_yr9 tr_yr10 tr_yr11 tr_yr12)
marginsplot

*============================================================================
* Spillover Effects
*============================================================================

** The classification of the neighboring boroughs:

*Camden: Islington, Haringey, Barnet,Brent,Westminster, City of london

*City of London: Islington, Camden, Westminster, Lambeth, Soutwark, Tower Hamlets

*Hackney: Haringey,Islington, City of London, Tower Hamlets, Newham, Waltham Forest

*Islington: Haringey, Hackney, City of London, Westminster

*Kensington and Chelsea: Brent, Hammersmith and Fulham, Westminster, Wandsworth

*Lambeth: Westminster, Wandsworth, Merton,Croydon, Soutwark, City of London 

*Southwark: City of London, Lambeth, Bromley, Lewisham, Tower Hamlets

*Tower Hamlets: City of London, Hackney, Newham, Greenwhich, Lewisham, Southwark

*Wandsworth:Hammersmith and Fulham, Kensington and Chelsea, Richmond upon Thames, Kingston upon Thames, Merton, Lambeth, Westminster

*Westminster: Kensington and Chelsea, Brent, Camden, City of London, Lambeth, Wandsworth 


** Neigboring Boroughs:

*Brent
*Barnet
*Haringey
*Newham
*Waltham Forest
*Hackney
*Merton
*Croydon
*Bromley
*Lewisham
*Greenwhich
*Kingston upon Thames
*Hammersmith and Fulham
*Richmond upon Thames

* Regenerating the variables to be able to check the spillover effects for boroughs
gen CCZ_spill=0

replace CCZ_spil=1 if borough==6 | borough==7 | borough==12 | borough==19 | borough==20 | borough==22 | borough==28 | borough==30 | borough==32 | borough==33

replace CCZ=. if borough== 3 | borough== 5 | borough== 14 | borough== 25 | borough== 31 | borough == 12 | borough ==24 | borough ==8 | borough ==6 | borough ==23 | borough ==11 | borough ==21 | borough ==13 | borough ==27

gen treated_after_s= policy*CCZ_spill

xtset borough tm

local n_years = 12

forval i = 2/`n_years' {
    gen tr_s_yr`i' = yr`i' * CCZ_spill
}

xtreg acc treated_after_s tr_s_yr2-tr_s_yr12 yr2-yr12,fe cluster (borough)

ssc install coefplot

coefplot, keep(tr_s_yr2 tr_s_yr3 tr_s_yr4 tr_s_yr5 tr_s_yr6 tr_s_yr7 tr_s_yr8 tr_s_yr9 tr_s_yr10 tr_s_yr11 tr_s_yr12) vertical

margins, dydx (tr_s_yr2 tr_s_yr3 tr_s_yr4 tr_s_yr5 tr_s_yr6 tr_s_yr7 tr_s_yr8 tr_s_yr9 tr_s_yr10 tr_s_yr11 tr_s_yr12)
marginsplot

reg acc CCZ policy treated_after, robust
outreg2 using spill.doc, replace ctitle(Basic DD)
reg acc CCZ_spill policy treated_after_s, cluster(borough)
outreg2 using spill.doc, append ctitle(Spillover Effects)


*log close

*============================================================================
* Further Research
*============================================================================

** Control Variables -- Aggregation (grouping & regenerating)

* Speed Limit:
bysort tm borough: egen speed=mean(speed_limit)

* Road type:
gen roadt=0 if road_type==3 | road_type==6
replace roadt=1 if road_type==1
replace roadt=2 if road_type==2 | road_type==7 | road_type==9 | road_type==12

bysort tm borough roadt: egen road111=total(x1) if roadt==1
bysort tm borough: egen road11=max(road111)
drop road111

bysort tm borough roadt: egen road222=total(x1) if roadt==2
bysort tm borough: egen road22=max(road222)
drop road222

gen road1=road11/acc
gen road2=road22/acc

* Weather
gen weat=1
replace weat=0 if weather_conditions==1 | weather_conditions==4

bysort tm borough weat: egen weat111=total(x1) if weat==1
bysort tm borough: egen weat11=max(weat111)
drop weat111

gen weat1=weat11/acc

* Road Surface
gen surface=1
replace surface=0 if road_surface_conditions==1

bysort tm borough surface: egen surf111=total(x1) if surface==1
bysort tm borough: egen surf11=max(surf111)
drop surf111

gen surf1=surf11/acc

duplicates drop tm borough, force


** Additional Regressions for Control Variables

*regression with the control variables
reg acc CCZ policy treated_after road1 road2 surf1 speed weat1, cluster(borough)
outreg2 using myreng1.doc, replace ctitle(With_controls)

*regression without some of the the control variables
reg acc CCZ policy treated_after road2 surf1 speed weat1, cluster(borough)
outreg2 using myreng1.doc, append ctitle((-)road1)

reg acc CCZ policy treated_after road1 surf1 speed weat1, cluster(borough)
outreg2 using myreng1.doc, append ctitle(-)road2)

reg acc CCZ policy treated_after surf1 speed weat1, cluster(borough)
outreg2 using myreng1.doc, append ctitle(-)road)

reg acc CCZ policy treated_after road1 road2 speed weat1, cluster(borough)
outreg2 using myreng1.doc, append ctitle(-)surf1)

reg acc CCZ policy treated_after road1 road2 surf1 weat1, cluster(borough)
outreg2 using myreng1.doc, append ctitle(-)speed)

reg acc CCZ policy treated_after road1 road2 surf1 speed, cluster(borough)
outreg2 using myreng1.doc, append ctitle(-)weat1)
