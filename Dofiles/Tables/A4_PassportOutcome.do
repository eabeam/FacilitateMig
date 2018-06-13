
/****************************
A4_Passport Outcomes.do 
Unilateral Facilitation Does Not Increase Migration 
Emily A. Beam, David McKenzie, and Dean Yang 

Last updated 05 June 2018 by Emily Beam (emily.beam@uvm.edu) 

This file generates Appendix Table A4, passport outcomes

Note that the following swapspec command should be run first:  
swapspec  attritfull baselineno4145 ascending15 nopval 

****************************/

#delimit ;
use "$specdata", clear;
$drop1;
$samplet;

local R "replace";

		qui sum end_currpass;
			sum end_currpass if $controltype == 1;
			local depavg = `r(mean)';


			
		xi: reg end_currpass $depvars $cov1 $convars ,robust;
			testparm $depvars;
		
			local pval = `r(p)';

			
			outreg2  $depvars using "$output_tables/A4_PassportOutcome $ST $DP.xls",
			`R' nonote $outputspec dec(3) 
			adds( mean, `depavg', p-value, `pval')	;			

			local R "append";
			


			erase  "$output_tables/A4_PassportOutcome $ST $DP.txt";


