/****************************
1_DataCleaning.do
Unilateral Facilitation Does Not Increase Migration 
Emily A. Beam, David McKenzie, and Dean Yang 

Last updated 13 November 2018 by Emily Beam (emily.beam@uvm.edu) 

Inputs: facilmig_public
Outputs: merged_data_public2


****************************/


use "$work/facilmig_public",clear


/* Variable generation */ 



gen resp_ed = base_b8_highed1
replace resp_ed = . if base_b8_highed1 == 19		// Invalid value

forval i = 1/6{
replace resp_ed = bench_f9_high_ed_`i' if resp_ed == . & benchpid == `i'		
}

replace resp_ed = . if resp_ed < 0 | resp_ed > 32
gen edflag = resp_ed != . & base_b8_highed1 == .



gen lesshs = resp_ed < 10 & resp_ed != .
gen hsgrad = resp_ed == 10
gen somevoc = (resp_ed >=11 & resp_ed < 15) | resp_ed == 21 | resp_ed == 22
gen colgradplus = resp_ed >= 15 & resp_ed != 21 & resp_ed != 22 & resp_ed != .
gen somecolplus = somevoc == 1 | colgradplus == 1
gen hsplus = somecolplus == 1 | hsgrad == 1
foreach var in lesshs hsgrad somevoc colgradplus somecolplus hsplus{
replace `var' = . if resp_ed == . | resp_ed < 0
}


/* Interested: interested */
gen interested = base_d10_how == 1 | base_d10_how == 2
	replace interested = . if base_d10_how == . 


/* Risks: risks */
gen risks = base_f18_take if base_f18_take >=0 & base_f18_take <=10



/* Household income: hhincome */ 

gen hhincome = 0
forval i = 1/12{
replace base_e1_income_diff`i' = . if base_e1_income_diff`i' == 88888 | base_e1_income_diff`i' < 0
replace hhincome = hhincome + base_e1_income_diff`i'
}
replace hhincome = hhincome/12

replace hhincome = base_e1_income_same if hhincome == . & hhincome != 88888
replace hhincome = . if hhincome < 0 | hhincome == 88888



/* Household savings */ 

gen hhsavings = base_f1_total 
	replace hhsavings = . if base_f1_total < 0 | base_f1_total == 88888 | base_f1_total == .

gen zerohhsavings = base_f1_total == 0
	replace zerohhsavings = . if base_f1_total < 0 | base_f1_total == 88888 | base_f1_total == .


/* Whether anyone in HH ever taken out loan: hhloan */ 
gen everloan = base_f3_ever_loan == 1
	replace everloan = . if base_f3_ever_loan == .
	
	
/* Asset count code: 
(Implemented prior to finishing merging and dropping of PII) 
gen assetcount = 0
forval i = 1/16{
replace assetcount = assetcount + 1 if base_e16_household_owns`i' == 1
}
replace assetcount = . if base_e16_household_owns1 == .

		/* Normalize asset cont */ 
		
sum assetcount
sum normassetcount 
gen normassetcount = (assetcount - `r(mean)')/`r(sd)'	

*/ 


/* Family migration experience: immabroad, extabroad */ 
gen immabroad = base_d1_imm == 1
gen extabroad = base_d1_ext == 1
	replace immabroad = . if base_d1_imm == . | base_d1_imm == 88
	replace extabroad = . if base_d1_ext == . | base_d1_imm == 88

/* Household size */
gen hhsize = 0 if baseline == 1

forval i = 1/18{
replace base_b1_firstname`i' = "" if base_b1_firstname`i' == "88888"
replace hhsize = hhsize + 1 if base_b1_firstname`i' != ""
}

/* Employment status */
gen r_employed = base_b10_emp1 == 1 | base_b10_emp1 == 2
	replace r_employed = . if base_b10_emp1 == 3 | base_b10_emp1 < 0 | base_b10_emp1 == 9 | base_b10_emp1 == 26 | base_b10_emp1 == .
	
	/* Do you ever use the internet or e-mail Internet*/
		gen internet = base_c3_internet == 1
		replace internet = . if base_c3_internet == . | base_c3_internet == 88

/* Ever apply abroad */
gen applyabroad = base_d7_everapplied == 1
	replace applyabroad = . if base_d7_everapplied == . | base_d7_everapplied == 88

/* Household receives remittances */ 
gen receiveremit = base_d2_anyone_sending_money == 1
	replace receiveremit = . if base_d2_anyone_sending_money == . | base_d2_anyone_sending_money == 88


/* Self-assessed english ability */ 
forval i = 1/4{
gen _a6english`i' = base_a6_english_`i'
recode _a6english`i' 8 = .
recode _a6english`i' 88 = .
}
// Speaking is 1

replace base_scell_base = base_scell_base*10000

/* Generate missing flags */
assert female != .
assert resp_age != .


#delimit ;

gen _mar_domestic = base_a1_m == 1 | base_a1_m == 2;
	replace _mar_domestic = . if base_a1_m == .	;	// 2 missing;
	tab _mar_domestic,mi;
	
sum hhincome if  hhincome != .,d;
gen lowinc = hhincome < `r(p50)' ;
replace lowinc = . if hhincome == .;

*Generate variable for number of children under age X, number of own child under age X ;

*list base_s2_age base_b5_age1 if base_s2_age != . & base_b5_age1 != . & base_s2_age != base_b5_age1;

foreach age in 2 6 10 18{;
gen _ch_num_age`age' = 0;
gen _anych_age`age' = 0;
forval i = 1/18{;
replace _ch_num_age`age' = _ch_num_age`age' + 1 if base_b5_age`i' <= `age';

};
replace _anych_age`age' = 1 if _ch_num_age`age' > 0 ;
};


#delimit cr




* Generate missing data flags 

foreach var in  hsgrad somevoc colgradplus interested risks hhincome hhsavings zerohhsavings everloan normasset immabroad extabroad{


gen mflag_`var' = `var' == . 

replace `var' = 0 if `var' == .
}

* Generate merged stratification cells 
gen scellbasebench = base_scell*10000 + bench_s_cell




save "$output_dta/merged_data_public2", replace
