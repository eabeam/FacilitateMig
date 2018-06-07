/* Table 1: Attrition: 


Check for Attrition - 

1. Merge roster with merged file to get assignment data
2. Clean and keep only the necessary varaibles
3. Merge roster with assignment data on top of $specdata
4. Those that don't match have attrit

Last Updated: December 19, 2012
*/ 

do "$dofiles/baseline_swap_generate.do"
tempfile big1

	
use "$work/mergedfile_june15_12", clear
tostring pj_id,replace
gen hhid_pjid = hhid+pj_id
// Keep if in baseline or benchmark (or pilot) 
*keep if baseline == 1 | _bench == 3 | pilot == 1
keep if baseline == 1 | _bench != . | pilot == 1
*replace hhid="N0048_BH" if hhid=="9999" & pj_id=="1344"
sort hhid pj_id

baselinegen
intensiveprep

recode pilotsample . =  0
recode baseline . = 0
recode benchmarkr . = 0
rename benchmarkrespondent benchmark
gen benchmarkassign = bench_s_cell != .
gen benchmarkonly = (benchmark == 1) & baseline == 0
assert "$cov1" != ""

keep hhid_pjid lastname female $cov0 $cov1 age41 bench_group base_interv_base bench__assignment benchmarkassign pilotsample _mpilot mflag* base_scell_base baseline benchmarkonly benchmark bench_status  bench_pp_release bench_tt_status_passr base_a1_marital base_b6_sex1 base_b10_emp1 base_d10_how base_c3_internet base_b8_highed1 base_d1_* base_d7* base_f1_* base_f2* base_f3* pili_gender base_s2_age bench__age bench_age bench_s_cell

save `big1',replace




use "$work/files_25 May 2012",clear	// This is the list of all respondents from the roster!
drop if household_id == "N0105_PU" & id_PJ == 281		// This is a duplicate
rename resp_age  bigage
pjcorrect household_id id_PJ

hhidcorrect household_id id_PJ
tostring id_PJ, replace

tostring id_PJ, replace

gen hhid_pjid = household_id  + id_PJ
gen lastname = last_fup
lastnamecorrect

duplicates tag hhid_pjid lastname,gen(dup1)
drop if dup1 >= 1 & bgy == ""
drop if bgy == "" & (household_id == "N0058_PI" | household_id == "N0083_MA" | household_id == "N0125_SJ")
merge m:m barangay_base using "$work/intensivedata_23 Feb 2013",gen(_mintensive)
drop _mintensive

merge 1:1 hhid_pjid lastname using `big1',gen(_mb)

/* Drop duplicates */ 
drop if household_id=="9999" & id_PJ=="1303"
drop if household_id=="9999" & id_PJ=="1341"
drop if household_id=="9999" & id_PJ=="1349"
drop if household_id=="9999" & id_PJ=="1367"
drop if household_id=="9999" & id_PJ=="1387"
drop if household_id=="9999" & id_PJ=="1454"
drop if household_id=="9999" & id_PJ=="1476"
drop if household_id=="9999" & id_PJ=="1525"
drop if household_id=="9999" & id_PJ=="1532"
drop if household_id=="9999" & id_PJ=="1675"
drop if household_id=="9999" & id_PJ=="1690"
drop if household_id=="9999" & id_PJ=="1712"
drop if household_id=="9999" & id_PJ=="2884"
drop if household_id=="9999" & id_PJ=="3867"
drop if household_id=="9999" & id_PJ=="6109"
drop if household_id=="9999" & id_PJ=="7913"
drop if household_id=="9999" & id_PJ=="8436"

drop if hhid_pjid == "N0005_PN9999"				// Don't know why this is here!


assert _mb == 3
drop _merge

*rename base_bgy bgy
/*
gen municip_base = bench_municipality
	replace municip_base = bench_municip_base if bench_municip_base != "" & municip_base == ""
	foreach var in SL CA BC BL SJ CC BH TA MA SA PI{	
replace municip_base = "SORSOGON" if bgy == "`var'"
}

foreach var in SY CD SI DG SV UN PB{
replace municip_base = "CASTILLA" if bgy == "`var'"
}
foreach var in PO DR BA BI DA MR PU{
replace municip_base = "PILAR" if bgy== "`var'"
}

foreach var in AR CO PA BD CN LC PN {
replace municip_base = "GUBAT" if bgy == "`var'"
}

foreach var in SO BT SG SN SP{
replace municip_base = "IROSIN" if bgy == "`var'"
}

foreach var in RI BO SC TU CP{
replace municip_base = "CASIGURAN" if bgy== "`var'"
}

replace municip_base = "SORSOGON" if municip_base == "SORSOGON CITY"
*/
tab municip_base,mi
	rename municip_base end_municip_base
	rename bgy base_bgy

	// Information treatments dummies
forval i = 1/5{
gen infotreat`i' = base_interv_base == `i'
}

// Specific information treatments

gen appinfo = base_interv_base == 2 | base_interv_base == 4 | base_interv_base == 5
gen fininfo = base_interv_base == 3 | base_interv_base == 4 | base_interv_base == 5
gen pilijobs = base_interv_base == 5
gen basecontrol = base_interv_base == 1 | base_interv_base == .


// Passport information treatments


gen benchpassassist = bench__assignment == "Full Passport"
gen benchpassinfo = bench__assignment == "Info Passport"
gen benchpasscontrol = bench__assignment == "Control"


gen benchcontrol = bench__assignment == "Control" | bench__assignment == ""

gen benchbasecontrol = benchcontrol == 1 & basecontrol == 1

save `big1',replace


use "$work/endline1_w2013fup", clear

merge 1:1 hhid_pjid lastname using `big1',gen(_mall)

assert _mall != 1
gen attrit = _mall == 2
drop _mall
gen attrit2 = attrit
	replace attrit2 = 1 if end_ofwwork == . 
	
*keep if baseline == 1 | _bench !=. | pilot == 1
recode baseline . = 0
sort hhid pj_id
	/*

replace firstname = first_fup if firstname == ""

assert lastname != ""
assert firstname != ""
/*rename hhid household_id
rename pj_id id_PJ
destring id_PJ,replace
*/
*/
replace resp_age = bigage if resp_age == .

	
	assert resp_age != .

replace end_first_fup = firstname


assert female != . 


*merge 1:1 hhid pj_id lastname using "$specdata"


/*
use "/Volumes/FUPDATA/filesfull_25 May 2012.dta",clear
rename barangay_base end_barangay_base
rename municip_base end_municip_base
rename household_id hhid 
rename id_PJ pj_id
tostring pj_id,replace
merge 1:1 hhid pj_id using "$specdata"
*/

tabstat attrit,by(end_municip)
tabstat attrit,by(end_barangay)
*keep if end_municip == "SORSOGON" | end_municip == "CASTILLA" | end_municip == "MATNOG" | end_municip == "BULAN"

gen fullsurvey = end_stype == "FULL"
gen proxysurvey = end_stype == "PROXY"
gen logsurvey = end_stype == "LOG"
gen logattrit = fullsurvey == 0 & proxysurvey == 0
gen fullproxy = fullsurvey == 1 | proxysurvey == 1
gen proxylogattrit = end_stype != "FULL"

gen hh_fullproxy = fullproxy if fullproxy != . 
gen hh_fullproxy2013 = fullproxy == 1 & (rosterfup2013 == 0 | fup2013 == 1) 
gen resp_fullproxy = fullproxy if fullproxy != . & _m_rpid == 0
gen resp_fullproxy2013 = fullproxy == 1 & (rosterfup2013 == 0 | fup2013 == 1) & _m_rpid == 0


replace bench_group = "PILOT" if pilots == 1

replace bench_group = "BLONLY_2040" if bench_group == "" & base_interv_base != . & resp_age >=20 & resp_age <=42
replace bench_group = "BLONLY_4145" if bench_group == "" & base_interv_base != . & resp_age >42
	
				tab bench_group,gen(bgroup)
				
		foreach var in BLONLY_2040 BLONLY_4145 BL1 BL2 BL3 BL4 BL5 PJBL BLJF PJMT PJOT PJSC PILOT{
		gen bg_`var' = bench_group == "`var'"
		}		
			replace base_bgy = "99" if base_bgy == ""
			gen palfsi = base_palfsi_m == 1		// Non-missing
		
egen bgypalfsi = group(base_bgy palfsi) ,lab


#delimit ;

/* 11 groups */ 
/*
gen aa1_appinfo_only = base_interv_base == 2 & (benchmarka == 0 | benchpasscontrol == 1);	
gen aa2_fininfo_only = base_interv_base == 3 & (benchmarka == 0 | benchpasscontrol == 1);	
gen aa3_passinfo_only = benchpassinfo == 1 & base_interv_base == 1;	
gen aa4_appfininfo_only = base_interv_base == 4 & (benchmarka == 0 | benchpasscontrol == 1);	
gen aa5_appfininfo_passinfo = (base_interv_base >=2 & base_interv_base <=4) & benchpassinfo == 1; 
gen aa6_webassist_only  = base_interv_base == 5 & (benchmarka == 0 | benchpasscontrol == 1);	
gen aa7_webpassinfo = base_interv_base ==5  & benchpassinfo == 1;	
gen aa8_passassist = base_interv_base == 1 & benchpassassist == 1;	
gen aa9_passassistinfo = (base_interv_base >=2 & base_interv_base <=4) & benchpassassist == 1;	
gen aa10_webpassassist = base_interv_base ==5  & benchpassassist == 1;		
*/



/* All 15 individual groups  - OLD ORDER*/ 

/* Report */ 

gen aa1_appinfo_only = base_interv_base == 2 & (benchmarka == 0 | benchpasscontrol == 1);	/* App. only */
gen aa2_fininfo_only = base_interv_base == 3 & (benchmarka == 0 | benchpasscontrol == 1);	/* Fin. only */
gen aa3_passinfo_only = benchpassinfo == 1 & base_interv_base == 1;	/* PI. only */
gen aa4_appfininfo_only = base_interv_base == 4 & (benchmarka == 0 | benchpasscontrol == 1);	/* App. and Fin. only */
gen aa5_appinfo_passinfo = base_interv_base == 2 & benchpassinfo == 1; /* App/Fin/App+Fin & PI*/
gen aa6_fininfo_passinfo = base_interv_base == 3 & benchpassinfo == 1; /* App/Fin/App+Fin & PI*/


gen aa7_appfininfo_passinfo = base_interv_base == 4 & benchpassinfo == 1; /* App/Fin/App+Fin & PI - ALL INFO*/
gen aa8_webassist_only  = base_interv_base == 5 & (benchmarka == 0 | benchpasscontrol == 1);	/* Web. only */

gen aa9_webpassinfo = base_interv_base == 5  & benchpassinfo == 1;		/* PI + Web - ALL INFO + Website  */
gen aa10_passassist = base_interv_base == 1 & benchpassassist == 1;		/* PA only - Passport Assistance */


gen aa11_passassist_appinfo = base_interv_base == 2 & benchpassassist == 1;		/* PA w App/Fin/A+Fin  */
gen aa12_passassist_fininfo = base_interv_base == 3 & benchpassassist == 1;		/* PA w App/Fin/A+Fin  */

gen aa13_passassist_appfininfo = base_interv_base == 4 & benchpassassist == 1;		/* PA w App/Fin/A+Fin  - ALL INFO + Pass */
gen aa14_webpassassist = base_interv_base ==5  & benchpassassist == 1;		/* PA + Web  */

gen aa_assign = 0;
forval i = 1/14{;
replace aa_assign = `i' if aa`i'_ == 1;
};


/* All 15 individual groups  - NEW ORDER*/ 

/* Report */ 

gen bb1_appfininfo_passinfo = base_interv_base == 4 & benchpassinfo == 1; /* App/Fin/App+Fin & PI - ALL INFO*/
gen bb2_webpassinfo = base_interv_base == 5  & benchpassinfo == 1;		/* PI + Web - ALL INFO + Website  */
gen bb3_passassist = base_interv_base == 1 & benchpassassist == 1;		/* PA only - Passport Assistance */
gen bb4_passassist_appfininfo = base_interv_base == 4 & benchpassassist == 1;		/* PA w App/Fin/A+Fin  - ALL INFO + Pass */
gen bb5_webpassassist = base_interv_base ==5  & benchpassassist == 1;		/* PA + Web  */

gen bb6_appinfo_only = base_interv_base == 2 & (benchmarka == 0 | benchpasscontrol == 1);	/* App. only */
gen bb7_fininfo_only = base_interv_base == 3 & (benchmarka == 0 | benchpasscontrol == 1);	/* Fin. only */
gen bb8_passinfo_only = benchpassinfo == 1 & base_interv_base == 1;	/* PI. only */
gen bb9_appfininfo_only = base_interv_base == 4 & (benchmarka == 0 | benchpasscontrol == 1);	/* App. and Fin. only */

gen bb10_appinfo_passinfo = base_interv_base == 2 & benchpassinfo == 1; /* App/Fin/App+Fin & PI*/
gen bb11_fininfo_passinfo = base_interv_base == 3 & benchpassinfo == 1; /* App/Fin/App+Fin & PI*/

gen bb12_webassist_only  = base_interv_base == 5 & (benchmarka == 0 | benchpasscontrol == 1);	/* Web. only */
gen bb13_passassist_appinfo = base_interv_base == 2 & benchpassassist == 1;		/* PA w App/Fin/A+Fin  */
gen bb14_passassist_fininfo = base_interv_base == 3 & benchpassassist == 1;		/* PA w App/Fin/A+Fin  */


/* June 20 proposal for groups */ 
/* Include and report */ 
gen yy1_appinfo_only = base_interv_base == 2 & (benchmarka == 0 | benchpasscontrol == 1);	/* App. only */
gen yy2_fininfo_only = base_interv_base == 3 & (benchmarka == 0 | benchpasscontrol == 1);	/* Fin. only */
gen yy3_passinfo_only = benchpassinfo == 1 & base_interv_base == 1;							/* PI. only */
gen yy4_allinfo = base_interv_base == 4 & (benchmarka == 0 | benchpasscontrol == 1 | benchpassinfo == 1);	/* All Info: App + fin + PI, app + fin */
/* All Info + Website : App + Fin + Web, App + Fin + Web + PI */ 
gen yy5_allinfoweb = base_interv_base == 5 & (benchmarka == 0 | benchpasscontrol == 1 | benchpassinfo == 1);
/* All Info + Website + Passport:*/
gen yy6_webpassassist = base_interv_base ==5  & benchpassassist == 1;		/* PA + Web  */

/* Include but do not report */ 

gen yy7_appinfo_passinfo = base_interv_base == 2 & benchpassinfo == 1; /* App/Fin/App+Fin & PI*/
gen yy8_fininfo_passinfo = base_interv_base == 3 & benchpassinfo == 1; /* App/Fin/App+Fin & PI*/
gen yy9_passassist = base_interv_base == 1 & benchpassassist == 1;		/* PA only */
gen yy10_passassist_appinfo = base_interv_base == 2 & benchpassassist == 1;		/* PA w App/Fin/A+Fin  */
gen yy11_passassist_fininfo = base_interv_base == 3 & benchpassassist == 1;		/* PA w App/Fin/A+Fin  */
gen yy12_passassist_appfininfo = base_interv_base == 4 & benchpassassist == 1;		/* PA w App/Fin/A+Fin  */

/* June 22 proposal for groups - Proposal 2 */ 
/* Include and report */ 
gen qq1_appinfo_only = base_interv_base == 2 & (benchmarka == 0 | benchpasscontrol == 1);	/* App. only [1] */
gen qq2_fininfo_only = base_interv_base == 3 & (benchmarka == 0 | benchpasscontrol == 1);	/* Fin. only [2] */
gen qq3_passinfo_only = benchpassinfo == 1 & base_interv_base == 1;							/* PI. only  [3] */
gen qq4_allinfo = base_interv_base == 4 & (benchmarka == 0 | benchpasscontrol == 1 | benchpassinfo == 1);	/* All Info: App + fin + PI, app + fin [1] + [2] + [3], [1] + [2] */

/* All Info + Website : App + Fin + Web, App + Fin + Web + PI [1] + [2] + [4], [1] + [2] + [3] + [4]*/ 
gen qq5_allinfoweb = base_interv_base == 5 & (benchmarka == 0 | benchpasscontrol == 1 | benchpassinfo == 1);

/* Passport assistance [1] + [3] + [5], [2] + [3] + [5], [3] + [5]*/ 
gen qq6_passassist = (base_interv_base >= 1 & base_interv_base <=3) & benchpassassist == 1;		/* PA only */

/* All info + Passport */
gen qq7_passassistallinfo = base_interv_base == 4 & benchpassassist == 1;		/* PA only */

/* All Info + Website + Passport:*/
gen qq8_webpassassist = base_interv_base ==5  & benchpassassist == 1;		/* PA + Web  */


/* Include but do not report */ 
gen qq9_appinfo_passinfo = base_interv_base == 2 & benchpassinfo == 1; /* App/Fin/App+Fin & PI*/
gen qq10_fininfo_passinfo = base_interv_base == 3 & benchpassinfo == 1; /* App/Fin/App+Fin & PI*/





/* Ommitted */ 
#delimit ;
egen treatgroup1 = group(aa1_ aa2_ aa3_ aa4_ aa5 aa6 aa7 aa8 aa9 aa10),label;
tab treatgroup1;

egen treatgroup2 = group(bb1_ bb2 bb3 bb4 bb5 bb6 bb7 bb8 bb9 bb10 bb11 bb12 bb13 bb14),label;
tab treatgroup2;

egen treatgroup3 = group(yy1_ yy2 yy3 yy4 yy5 yy6 yy7 yy8 yy9 yy10 yy11 yy12),label;
tab treatgroup3;

egen treatgroup4 = group(qq1_ qq2_ qq3_ qq4_ qq5 qq6 qq7 qq8 qq9 qq10),label;
tab treatgroup4;




tab bg_BLONLY_2040 age4145 if treatgroup1 == 1;
tab base_interv_base bench_as if treatgroup1 == 1;


/* Gen attrition for midline */ 

gen midlineattrit = benchmark == 0 & bench__assignment != "";
replace midlineattrit = . if bench__assignment == "";

#delimit cr
				
save "$work/attritfull",replace




use "$work/attritfull",clear



$drop1			// Do drop those who were in the roster but not in the benchmark or baseline - selected to be in benchmark but not selected. 


$samplet

*keep if age4145 == 0
#delimit ;

local R "replace";


foreach var in attrit attrit2 logattrit{;

xi: reg `var' $depvars $convars ,robust;	

		sum `var' if $controltype == 1;
		local depavg = `r(mean)';
			
			
	testparm $depvars;
		local pval = `r(p)';
	*$testinfo;
	*	local pval1 = `r(p)';
	*$testpass ;
	*local pval2 = `r(p)';
outreg2  $depvars using "$output/Table31_attrition_`c(current_date)' $ST $DP.xls",
	/*	`R' nonote $outputspec dec(3) adds( mean, `depavg', p-value, `pval', p-valinfo,`pval1',pvalpass,`pval2')	;*/			
		`R' nonote $outputspec dec(3) adds( mean, `depavg', p-value,`pval')	;			

local R "append";

xi: reg `var' $depvars $convars $cov1 ,robust;	


			
	testparm $depvars;
		local pval = `r(p)';
	*$testinfo;
	*	local pval1 = `r(p)';
	*$testpass ;
	*local pval2 = `r(p)';


outreg2  $depvars using "$output/Table31_attrition_`c(current_date)' $ST $DP.xls",
	/*	`R' nonote $outputspec dec(3) adds( mean, `depavg', p-value, `pval', p-valinfo,`pval1',pvalpass,`pval2')	;*/			
		`R' nonote $outputspec dec(3) adds( mean, `depavg', p-value,`pval')	;			
	};

