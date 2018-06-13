/****************************
1_DescriptiveStatistics.do
Unilateral Facilitation Does Not Increase Migration 
Emily A. Beam, David McKenzie, and Dean Yang 

Last updated 13 June 2018 by Emily Beam (emily.beam@uvm.edu) 

This file generates Table 1.


Note that the following swapspec command should be run first:  
swapspec  attritfull baselineno4145 ascending15 nopval 
****************************/

* Balance Tests


*1. Estimate Means, SD, and F-tests

tempfile tempdata


#delimit ;
use "$specdata", clear;
$drop1;
$samplet;


keep if baseline == 1;
keep if mflag_hsgrad == 0;
keep if mflag_immab == 0;

gen mflag_female = 0;
gen mflag_resp_age = 0;
replace hhincome = hhincome/1000;
replace hhsavings = hhsavings/1000;
foreach nvar in hhsize r_employed applyabroad receiveremit internet{;
gen mflag_`nvar' = `nvar' == .;
};


save `tempdata',replace;

foreach var in female $cov0{;
use `tempdata', clear;
local nomissing "keep if mflag_`var' == 0";

`nomissing';

collapse (mean) mean`P`i'' = `var' (sd) sd`P`i'' = `var' (count) count`P`i'' = `var'  ;
gen str15 var = "`var'";


save "$output_dta/temp`var'", replace ;
};

cd "$output_dta";
use "$output_dta/tempfemale.dta", clear;
for any 
$cov0:
append using tempX;
order var;
list;
egen id = seq();
save "$output_dta/means_`P`i''", replace;

for any 
 $cov0
: 
erase tempX.dta 
;



drop id; 
outsheet using "$output_tables/Table1_DescriptiveStatistics.xls",replace;
		
		
		// Compute F-stat and p-values for various tests. */ 


local OO1 "infotreat2 infotreat3 infotreat4 infotreat5";
local OO2 "benchpassassist benchpassinfo";
local oo1 "infoweb";
local oo2 "passport";

local res1 "if benchmarka != .";
local res2 "if benchmarka == 1";

local sfe1 "i.bgyp";
local sfe2 "i.bgyp";

forval j = 1/2{;

use `tempdata',clear   ;
cd "$output";

foreach var in female $cov0{;

local nomissing "& mflag_`var' == 0";

xi: reg `var' `OO`j'' `sfe`j'' `res`j''  `nomissing',robust;		

testparm `OO`j'';
gen Fstat_`var' = `r(F)';
gen pval_`var' = `r(p)';
};


collapse (mean) pval* Fstat*;

xpose,varname clear ;
rename v1 `oo`j'';

save "$output_dta/fpvalues_`oo`j''",replace;
};

use "$output_dta/fpvalues_infoweb.dta",clear;
egen id = seq();
append using "$output_dta/fpvalues_passport.dta";

collapse (max) infoweb passport id,by(_varname);
sort id;
outsheet  using "$output_tables/fvalues_descriptivevars.xls",replace;


