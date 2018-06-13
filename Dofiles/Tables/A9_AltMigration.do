
/****************************
A9_AltMigration.do 
Unilateral Facilitation Does Not Increase Migration 
Emily A. Beam, David McKenzie, and Dean Yang 

Last updated 05 June 2018 by Emily Beam (emily.beam@uvm.edu) 

This file generates Appendix Table A9, testing forr alternate migration impacts

Note that the following swapspec command should be run first:  
swapspec  attritfull baselineno4145 ascending nopval 

****************************/

#delimit ;
use "$specdata", clear;
$drop1;
$samplet;

gen noattrit = 1 - attrit;


local R "replace";

drop aa_assign;		// 13 June 2018 revision (comment out to replicate original table)

	sum end_ofww if $controltype == 1;
	local depavg = `r(mean)';
			
* Column 1;

xi: reg end_ofww $depvars $convars $covfull `outcomecontrol', robust;		

testparm $depvars;

local pval = `r(p)';

outreg2  $depvars using "$output_tables/A9_AlternateMigration $ST $DP.xls",
		`R' nonote $outputspec dec(3) adds( mean, `depavg', p-value,`pval')	;			
local R "append";


* Column 2; 

sum resp_anymig_orig if $controltype == 1;
	local depavg = `r(mean)';
			
xi: reg resp_anymig_orig $depvars $convars $covfull `outcomecontrol', robust;		

testparm $depvars;

local pval = `r(p)';

outreg2  $depvars using "$output_tables/A9_AlternateMigration $ST $DP.xls",
		`R' nonote $outputspec dec(3) adds( mean, `depavg', p-value,`pval')	;			


