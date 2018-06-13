
/****************************
A2_Attrition.do 
Unilateral Facilitation Does Not Increase Migration 
Emily A. Beam, David McKenzie, and Dean Yang 

Last updated 05 June 2018 by Emily Beam (emily.beam@uvm.edu) 

This file generates Appendix Table A2, testing for additional attrition. 

Note that the following swapspec command should be run first:  
swapspec  attritfull baselineno4145 ascending15 nopval 

****************************/

use "$output_dta/attritfull.dta",clear



$drop1
$samplet

#delimit ;

local R "replace";


foreach var in  logattrit attrit2 {;
/*
xi: reg `var' $depvars $convars ,robust;	

	
			
			
	testparm $depvars;
		local pval = `r(p)';

outreg2  $depvars using "$output_tables/A2_Attrition $ST $DP.xls",
		`R' nonote $outputspec dec(3) adds( mean, `depavg', p-value,`pval')	;			
*/;

xi: reg `var' $depvars $convars $cov1 ,robust;	
		sum `var' if $controltype == 1;
		local depavg = `r(mean)';
	testparm $depvars;
		local pval = `r(p)';

outreg2  $depvars using "$output_tables/A2_Attrition $ST $DP.xls",
		`R' nonote $outputspec dec(3) adds( mean, `depavg', p-value,`pval')	;			
	
	local R "append";

	};

