/* 2_1_HHMigrationSteps_may6


Main steps to migration for HH and Respondents. - Drop the intermediate steps and the attrition, as that will be sorted out later. 

/* Respondent, then HH - one table each*/ 

// NOTE: Changes made to pull out the stratification FE and just use individually stratification big dummy variables. 

*/ 

#delimit ;

forval ss = 10/12{;
local SAMP1 "interested";
local SAMP2 "female";
local SAMP3 "_mar_domestic";
local SAMP4 "_anych_age6";
local SAMP5 "_anych_age2";
local SAMP6 "lowinc";
local SAMP7 "hsgrad";
local SAMP8 "somecolplus";
local SAMP9 "colgradplus";
local SAMP10 "anych_age2_gen";
local SAMP11 "anych_age2_fem";
local SAMP12 "anych_age2_mal";

use "$specdata", clear;
$drop1 ;
$samplet ;

if `ss' == 10 {;
keep if _anych_age2 == 1;
};

if `ss' == 11{;
keep if female == 1;
};
if `ss' == 12{;
keep if female == 0;
};


gen anych_age2_gen = female == 1;
gen anych_age2_fem = _anych_age2;

gen anych_age2_mal = _anych_age2;


if `ss' == 7{;
drop hsgrad;
gen hsgrad = hsplus;
};

forval i = 1/14{;
gen bb`i'X`SAMP`ss'' = `SAMP`ss''*bb`i'_;
};

local R "replace";



tab bg_BLONLY_2040 age4145 if treatgroup1 == 1;
tab base_interv_base bench_as if treatgroup1 == 1;

rename end_currpass resp_currpass;

foreach var in resp {;

	local varno = 1;
	foreach x in  ofwstep_1012 web_1012 raapp_1012 other_1012 ofwinvite ofwattendint ofwoffer /*ofwacceptoff*/ ofwmigrate /*phstart_all phstart_SP phstart_outSP*/{;	
	

				qui sum `var'_`x';
					if `r(sum)' > 1 & `r(N)' != `r(sum)'{;
						sum `var'_`x' if $controltype == 1;
						local depavg = `r(mean)';

*xtset $scell		;
* xi: xtreg `var'_`x' $depvars  $cov1 $convars ,fe robust;		
						
					xi: reg `var'_`x' `SAMP`ss'' bb*X`SAMP`ss'' $depvars $cov1 $convars,robust;
						testparm $depvars;
						local pval = `r(p)';	
						testparm bb*X*;
						local pval1 = `r(p)';

				*			$testinfo;		/* Info alone treatments */ 
				*		local pval1 = `r(p)';
				*			$testpass;		/* PA treatments */ 
				*		local pval2 = `r(p)';
					
						outreg2  `SAMP`ss'' $depvars bb*X`SAMP`ss'' using "$output/Table22_MigrationStepsinttreat `SAMP`ss''_`c(current_date)' $ST $DP.xls",
						`R' nonote $outputspec dec(3) 
/*						adds( mean, `depavg', p-value, `pval', p-valinfo,`pval1',pvalpass,`pval2')	;	*/		
				adds( mean, `depavg', p-value, `pval', p-valuint,`pval1')	;			
						local R "append";
						};
};
local varno = `varno' + 1;
*di "variable `varno'";

};


						erase  "$output/Table22_MigrationStepsinttreat `SAMP`ss''_`c(current_date)' $ST $DP.txt";
						
						};
exit;
