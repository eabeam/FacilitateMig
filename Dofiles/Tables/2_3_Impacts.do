/****************************
2_3_Impacts.do
Unilateral Facilitation Does Not Increase Migration 
Emily A. Beam, David McKenzie, and Dean Yang 

Last updated 05 June 2018 by Emily Beam (emily.beam@uvm.edu) 

This file generates Tables 2, 3, A12, and A13. Note that the swapspec determines which file is created: 

swapspec  attritfull baselineno4145 ascending15 nopval 
	Generates Table 2 and Table 3. 
	Reporting full set of coeffecients generates Appendix Table A10 and Appendix Table A11
	
swapspec  attritfull baseline ascending15 nopval 
	Generates Appendix Table A12 and Appendix Table A13 

****************************/

#delimit ;

forval ss = 1/2{;
* Full sample (Table 2/A12);
local SAMP1 "";

*Highly interested (Table 3/A13);
local SAMP2 "keep if interested == 1";



local svar1 "Table2_all";
local svar2 "Table3_interest1";


use "$specdata", clear;
$drop1 ;
$samplet ;

drop aa_assign;

`SAMP`ss'';



local R "replace";


tab bg_BLONLY_2040 age4145 if treatgroup1 == 1;
tab base_interv_base bench_as if treatgroup1 == 1;

rename end_currpass resp_currpass;

foreach var in resp {;

	local varno = 1;
	foreach x in  ofwstep_1012 web_1012 raapp_1012 other_1012 ofwinvite ofwattendint ofwoffer  ofwmigrate {;	
	


				qui sum `var'_`x';
					if `r(sum)' > 1 & `r(N)' != `r(sum)'{;
						sum `var'_`x' if $controltype == 1;
						local depavg = `r(mean)';

						
					xi: reg `var'_`x' $depvars $cov1 $convars,robust;
						testparm $depvars;
					
						local pval = `r(p)';		

					
						outreg2  $depvars using "$output_tables/`svar`ss'' $ST $DP.xls",
						`R' nonote $outputspec dec(3) 
				adds( mean, `depavg', p-value, `pval')	;			
						local R "append";
						};
};
local varno = `varno' + 1;

};



						erase  "$output_tables/`svar`ss'' $ST $DP.txt";
						
						};
exit;
