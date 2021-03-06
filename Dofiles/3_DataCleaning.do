/****************************
3_DataCleaning.do
Unilateral Facilitation Does Not Increase Migration 
Emily A. Beam, David McKenzie, and Dean Yang 

Last updated 05 June 2018 by Emily Beam (emily.beam@uvm.edu) 

Inputs: endline1_w2013fup, attritiondata
Outputs: attritfull

****************************/
use "$output_dta/endline1_w2013fup", clear

merge 1:1 hhid_pjid  using "$work/attritiondata",gen(_mall) 

assert _mall != 1
gen attrit = _mall == 2
drop _mall
gen attrit2 = attrit
	replace attrit2 = 1 if end_ofwwork == . 
	
recode baseline . = 0
sort hhid pj_id

replace resp_age = bigage if resp_age == .

	
	assert resp_age != .



assert female != . 



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




/* Ommitted */ 
#delimit ;
egen treatgroup1 = group(aa1_ aa2_ aa3_ aa4_ aa5 aa6 aa7 aa8 aa9 aa10),label;
tab treatgroup1;

egen treatgroup2 = group(bb1_ bb2 bb3 bb4 bb5 bb6 bb7 bb8 bb9 bb10 bb11 bb12 bb13 bb14),label;
tab treatgroup2;

egen treatgroup3 = group(yy1_ yy2 yy3 yy4 yy5 yy6 yy7 yy8 yy9 yy10 yy11 yy12),label;
tab treatgroup3;





tab bg_BLONLY_2040 age4145 if treatgroup1 == 1;
tab base_interv_base bench_as if treatgroup1 == 1;


/* Gen attrition for midline */ 

gen midlineattrit = benchmark == 0 & bench__assignment != "";
replace midlineattrit = . if bench__assignment == "";


				
save "$output_dta/attritfull",replace;

