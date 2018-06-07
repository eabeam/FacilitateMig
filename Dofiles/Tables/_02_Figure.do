
/****************************
_02_Figure.do 
Unilateral Facilitation Does Not Increase Migration 
Emily A. Beam, David McKenzie, and Dean Yang 

Last updated 05 June 2018 by Emily Beam (emily.beam@uvm.edu) 

This file generates Figure 2. 

Note that the following swapspec command should be run first:  
swapspec  attritfull baselineno4145 ascending15 nopval 

****************************/
use "$specdata", clear
$drop1
$samplet

gen treat2 = 0
forval i = 1/14{
replace treat2 = `i' if bb`i'_ == 1
}
tab treat2

tab bench__assign if base_interv_ == 2,mi
tab bench__assign if base_interv_ == 3,mi
tab bench__assign if base_interv_ == 4,mi
collapse (mean) mean_interest = interest (sd) sd_interest = interest (count) n = interest 

gen cihigh = invttail(n-1,0.025)*(sd_ / sqrt(n))
gen cilow = invttail(n-1,0.025)*(sd_ / sqrt(n))


use "$specdata", clear
$drop1
$samplet
gen treat2 = 0
gen treat3 = 0
forval i = 1/14{
replace treat2 = `i' if bb`i'_ == 1
}
forval i = 1/12{
replace treat3 = `i' if yy`i'_ == 1
}

/* Treat2  -NEW
Control = 0
All Information = 1
All Informaiton + Website = 2
Full assistance == 5
*/

foreach var in resp_ofwstep_1012 resp_ofwmigrate{
foreach x in 1 2 5{
ttest `var' if treat2 == 0 | treat2 == `x',by(treat3)
}
}

foreach x in 0 1 2 5 {
tab interested
tab resp_ofwstep_1012 if treat2 == `x'
tab resp_ofwmigrate if treat2 == `x'
}


collapse  (mean) mean_interested = interested (sd) sd_interested = interested  (mean) mean_step= resp_ofwstep_1012 (sd) sd_step=resp_ofwstep_1012 (mean) mean_mig = resp_ofwmigrate (sd) sd_mig = resp_ofwmigrate (count) n=resp_ofwstep_1012, by(treat2)

reshape long mean_ sd_,i(treat2) j(var) string

gen cihigh99 =  invttail(n-1,0.005)*(sd_ / sqrt(n))
gen cihigh95 =  invttail(n-1,0.025)*(sd_ / sqrt(n))
gen cihigh90 =  invttail(n-1,0.050)*(sd_ / sqrt(n))

keep if treat2 == 0 | treat2 == 1 | treat2 == 2 | treat2 == 5
gsort -var treat2
browse

outsheet using "$output_tables/Figure2_Impacts.xls",replace




exit
