**=================================================================================
*
*** CO2 decay analysis
*
**=================================================================================

* This .do file will provide estimates of ventilation in a single space under a 
///single set of conditions

* Suggest, put the six .csv files containing the decay curves for each room under
///each set of conditions into a unique folder

* Having to change both the working directory and the file names for the script to run 
///should prevent errors with selection of the wrong .csv files

* Code prepared by Kathy Baisley (LSHTM) and Tom Yates (UCL)

* Please direct any queries to Tom Yates, email t.yates@ucl.ac.uk

**=================================================================================

clear
capture log close
set more off

**=====================
* Set working directory, start log
cd "**********"

log using **********.log, replace

**=====================
* Import data

* In the second line here, will need to alter the file name to match the naming of 
///the files in the folder

* For experiments where the experiment numbers are 4/6 rather than 1/3, the forval 
///bits will need to be amended, also the final loop will need amended to start with
///ex4a$ and ex4b$ and to then state e.g. forval i=5/6

forval i=1/3 {
import delimited "clinic_room_Exp`i'_mont.csv", clear
	drop v7 v8
	gen experiment=`i'
	gen room=1
	gen monitor=1
	rename v1 seconds
	label var seconds "Seconds"
save ex`i'a$, replace

import delimited "clinic_room_Exp`i'_mont.csv",  clear
	drop v7 v8
	gen experiment=`i'
	gen room=1
	gen monitor=2
	rename v1 seconds
	label var seconds "Seconds"	
save ex`i'b$, replace
}

use ex1a$, clear
	append using ex1b$
forval i=2/3 {
	append using ex`i'a$
	append using ex`i'b$
}

**save dataset
save "**********_merged.dta", replace

**=============================================================================
**=============================================================================

**=====================
* Prepare data for analysis

use "**********_merged.dta", clear

**create a unique experiment-monitor ID to allow us to treat as time-series data
	egen exp_mon=group(experiment monitor)
	tab exp_mon

**define time-series data
	tsset exp_mon seconds

**smooth using a moving average of 60 seconds (30 before/30 after)
	tsegen smoothco2 = rowmean(L(0/30).co2 F(1/30).co2)
	graph twoway scatter smoothco2 seconds, by(exp_mon)

**log-transform smoothed values
	gen lnco2 = ln(smoothco2)
	graph twoway scatter lnco2 seconds, by(exp_mon)

* Trim curves so they start 30 seconds after doors/windows opened and finish when CO2 
///dips within 200ppm of baseline (or below 800ppm if no clear baseline)

* Baseline CO2 values can be obtained from the input data

* For each experiment, times when doors/windows were opened has been uploaded
///in a separate spreadsheet
	
	gen baseline = x
	
	drop if (seconds< | seconds> | co2<baseline) & exp_mon==1
	drop if (seconds< | seconds> | co2<baseline) & exp_mon==2
	drop if (seconds< | seconds> | co2<baseline) & exp_mon==3
	drop if (seconds< | seconds> | co2<baseline) & exp_mon==4
	drop if (seconds< | seconds> | co2<baseline) & exp_mon==5
	drop if (seconds< | seconds> | co2<baseline) & exp_mon==6
	
**recode seconds so starts from 0 so that all will have same x axis

	sort exp_mon seconds
	by exp_mon:egen _fs=min(seconds)
		gen secR=(seconds-_fs)+1

**to demonstrate difference - all data plotted on same graph		
	graph twoway scatter lnco2 seconds
	graph twoway scatter lnco2 secR	

**set time in hours	
	gen hours = secR/3600

**save the truncated dataset
save "**********_truncated.dta", replace

*** Simple linear regression, each experiment separately

regress lnco2 hours if exp_mon==1
regress lnco2 hours if exp_mon==2
regress lnco2 hours if exp_mon==3
regress lnco2 hours if exp_mon==4
regress lnco2 hours if exp_mon==5
regress lnco2 hours if exp_mon==6
	
**plot this
#delimit ;
	graph twoway (scatter lnco2 secR) (lfit lnco2 secR, sort lp(solid)), 
	by(exp_mon, compact legend(off) col(2))
	xtitle(Seconds) ytitle(ln CO2);
#delimit cr

**the data together
sort exp_mon secR
	graph twoway (line lnco2 secR, connect(asc)), xtitle(Seconds) ytitle(ln CO2)
	
	
**==============================================================
**==============================================================
* Combine regression estimates using metan

use "**********_truncated.dta", clear
**get slope & CI from a regression of each experiment and write to a new file
qui {	
tempfile res1
cap postclose p1
postfile p1 experiment slope lci uci n_obs  using res1, replace
forval i=1/6 {
	regress lnco2 hours if exp_mon==`i'
	local ct=e(N)
	mat def b=e(b)
	mat def v=e(V) 
		local slope=(b[1,1])
		local sU=sqrt(v[1,1])
		local lb= `slope'-invttail(e(df_r), 0.025)*`sU'
		local ub= `slope'+invttail(e(df_r), 0.025)*`sU'
post p1 (`i')  (`slope') (`lb') (`ub')  (`ct')
}
postclose p1
}

**now we have a dataset with the results of the 6 regressions

use res1, clear

**combine with random effects

**random effect -weights are calculated from b/w & w/in study variance
**weights will be distributed more equally if there is a lot of heterogeneity
#delimit ;
metan slope lci uci, random
xlabel(-30, -20, -10 , 10, 20, 30) force
label(namevar=experiment) effect(slope)
textsize(120) astext(60)  nulloff;
        

**combine with fixed effects - if no evidence of heterogeneity
**weights will be based on sample size (calculated from CI)
#delimit ;
metan slope lci uci, fixed
xlabel(-30, -20, -10 , 10, 20, 30) force
label(namevar=experiment) effect(slope)
textsize(120) astext(60) nulloff;
        
** Note, the xlabel values need to be adjusted to get good quality forest plots        
		
**===================================================	
log close

forval i=1/3 {
erase ex`i'a$.dta
erase ex`i'b$.dta
}


