/****************************
A3_BalanceTests.do 
Unilateral Facilitation Does Not Increase Migration 
Emily A. Beam, David McKenzie, and Dean Yang 

Last updated 05 June 2018 by Emily Beam (emily.beam@uvm.edu) 

This file generates Appendix Table A3, testing for balance across treatment arms. 

Note that the following swapspec command should be run first:  
swapspec  attritfull baselineno4145 ascending15 nopval 

****************************/ 
/* Balance Tests


2. Estimate Means by treatment - information
3. Estimate menas by treatment, passport

*/ 
tempfile tempdata
#delimit ;
use "$specdata", clear;
$drop1;
$samplet;

keep if baseline == 1;
keep if mflag_hsgrad == 0;		// 1 deleted;
keep if mflag_immab == 0;		// 1 deleted;

replace hhincome = hhincome/1000;
replace hhsavings = hhsavings/1000;

gen mflag_female = 0;
gen mflag_resp_age = 0;
foreach nvar in hhsize r_employed applyabroad receiveremit internet{;
gen mflag_`nvar' = `nvar' == .;
};
tabstat mflag*;
tab base_interv_base	;								/* Baseline counts*/ 
tab benchpassassist benchpassinfo if benchmarka == 1; /* Passport counts */ 
save tempdata,replace;



local O1 "keep if base_interv_b == 1";	
local O2 "keep if base_interv_b == 2"; 
local O3 "keep if base_interv_b == 3";
local O4 "keep if base_interv_b == 4";
local O5 "keep if base_interv_b == 5";
local O6 "keep if benchmarka == 1 & benchpassassist == 0 & benchpassinfo == 0";
local O7 "keep if benchmarka == 1 & benchpassassist == 0 & benchpassinfo == 1";
local O8 "keep if benchmarka == 1 & benchpassassist == 1 & benchpassinfo == 0";


local P1 "infocontrol";
local P2 "appinfo";
local P3 "fininfo";
local P4 "appfininfo";
local P5 "webassist";
local P6 "passcontrol";
local P7 "passinfo";
local P8 "passassist";

forval i = 1/8{;
foreach var in female $cov0{;

use tempdata,clear;
`O`i'';
keep if mflag_`var' == 0;		// NEW!;

collapse (mean) mean`P`i'' = `var'  $pweight ;
gen str15 var = "`var'";


save temp`var', replace ;
};

use tempfemale, clear;
for any 
$cov0:
append using tempX;
order var;
list;
egen id = seq();
save  "$output_dta/means_`P`i''", replace;

for any 
 $cov0
: 
erase tempX.dta 
;
};

use "$output_dta/means_infocontrol.dta";
forval i = 2/8{;
di "merging with `P`i''";
merge 1:1 id using "$output_dta/means_`P`i''";
assert _merge == 3;
drop _merge;
};


drop id; 
outsheet using "$output_tables/A3_BalanceTests.xls",replace;
************************************************************
// Compute p-values for various tests - Compare each treatment against control group.
************************************************************;
 #delimit ;
local OO2 "infotreat2";
local OO3 "infotreat3";
local OO4 "infotreat4";
local OO5 "infotreat5";
local OO6 "benchpassinfo";
local OO7 "benchpassassist";

forval j = 2/5{;
local res`j' "if (infotreat1 == 1 | infotreat`j' == 1)";
local sfe`j' "i.bgyp";

};

local res6 "if (bench_assignment  == 1 | bench_assignment == 3)";
local res7 "if (bench_assignment  == 1 | bench_assignment == 2)";


local sfe6 "i.bgyp";
local sfe7 "i.bgyp";
/* Put in barangayp FE only for the baseline stpecification, not for the passport. For the passport, put in the other b_group variables */ ;

forval j = 2/7{;

use tempdata,clear   ;
cd "$output_dta";
cap log close;
*log using "regoutput $ST $RES $MM.log",replace;
foreach var in female $cov0{;
local mflag "& mflag_`var' == 0";

reg `var' `OO`j'' `sfe`j'' `res`j'' `mflag',robust;

testparm `OO`j'';
*gen Fstat_`var' = `r(F)';
gen pval_`var' = `r(p)';
};


*collapse (mean) pval* Fstat*;
collapse (mean) pval*;

xpose,varname clear ;
rename v1 `OO`j'';

save fpvalues_`OO`j'',replace;
};

use fpvalues_infotreat2,clear;
egen id = seq();
forval j = 2/7{;
append using fpvalues_`OO`j'';
};

collapse (max) `OO2' `OO3' `OO4' `OO5' `OO6' `OO7' id ,by(_varname);
sort id;
outsheet  using "$output_tables/A3_Balance_fvalues_ind.xls",replace;


