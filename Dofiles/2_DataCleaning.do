*do "$dofiles/0_3_Merge_Endline_Aug09.do"		// run every so often


/* 			Clean Endline Survey */
use "$output_dta/merged_data_public2", clear


******************************************
*		Assigned Treatments
******************************************

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
gen benchbasecontrol = benchcontrol == 1  & basecontrol == 1

// Sample types

rename benchmarkrespondent benchmark
gen benchmarkonly = (benchmark == 1)& baseline == 0


// Passport status
gen bench_passreceived = bench_status == 10 | (bench_pp_release != . & bench_pp_release > 2)
replace bench_passreceived = 1 if bench_tt_status_passr != .
replace bench_passreceived = 0 if bench_passreceived == .




		foreach var in rel  sex ed work mnl ofw{
		forval j = 1/9{
		rename end_b_`var'_0`j' end_b_`var'_`j'
		}
		}
				
				
								




// Whether any household_members overseas 

gen base_anyhh = 0
forval i = 1/18{
replace base_b11_ofw`i' = . if base_b11_ofw`i' == 88 | base_b11_ofw`i' == 99
replace base_anyhh = 1 if base_b11_ofw`i' == 1
}


********************************************
*	Clean up ids in the migration tables 
	// Clean up ids. 	
******************************************

// If the pid is missing (88) in table e3 but not in table e1, and there is an offer in table e1 and the country is the same, replace		
//mark the adjustment with 0.1 - 
//1. Compare same places in the roster
		forval i = 1/3{
		local j = `i' + 1
		recode end_e1a_pid_`i' 88 = .
		list end_e1*pid*`i' end_e1e*`i' end_e1h_offer*`i' end_e1*pid*`j' end_e1e*`j' end_e1h_offer*`j'  end_e3*pid*`i' end_e3f_country_`i' if end_e3_pid_`i' == 88 & end_e1a_pid_`i' != . & end_e1h_offer_`i' == 1 & end_e1e_country_`i' == end_e3f_country_`i' & end_e1e_country_`i' != ""
		replace adjust_id = adjust_id + .1 if end_e3_pid_`i' == 88 & end_e1a_pid_`i' != . & end_e1h_offer_`i' == 1 & end_e1e_country_`i' == end_e3f_country_`i' & end_e1e_country_`i' != ""

		replace end_e3_pid_`i' = end_e1a_pid_`i' if end_e3_pid_`i' == 88 & end_e1a_pid_`i' != . & end_e1h_offer_`i' == 1 & end_e1e_country_`i' == end_e3f_country_`i' & end_e1e_country_`i' != ""
				
				}
				
// If the pid is missing (88) in table e3 but not in table e1, and there is an offer in table e1 and the country is the same, replace		
// mark the adjustment with 0.1	
// 2. Compare different places in the roster 

	forval i = 1/3{
		forval j = 1/3{
	di in red "i = `i' j = `j'"
		list end_e1*pid*`i' end_e1e*`i' end_e1h_offer*`i' end_e1*pid*`j' end_e1e*`j' end_e1h_offer*`j'  end_e3*pid*`j' end_e3f_country_`j' if end_e3_pid_`j' == 88 & end_e1a_pid_`i' != . & end_e1h_offer_`i' == 1 & end_e1e_country_`i' == end_e3f_country_`j' & end_e1e_country_`i' != ""
		replace adjust_id = adjust_id + .1 if end_e3_pid_`j' == 88 & end_e1a_pid_`i' != . & end_e1h_offer_`i' == 1 & end_e1e_country_`i' == end_e3f_country_`j' & end_e1e_country_`i' != ""

		replace end_e3_pid_`j' = end_e1a_pid_`i' if end_e3_pid_`j' == 88 & end_e1a_pid_`i' != . & end_e1h_offer_`i' == 1 & end_e1e_country_`i' == end_e3f_country_`j' & end_e1e_country_`i' != ""
			}	
				}		
				
				
				
// Recode invalid values - Add 0.001
		foreach var in e1a_pid e2_pid e3_pid e4a_pid{
		forval i = 1/3{
		replace adjust_id = adjust_id + 0.001 if end_`var'_`i' == 11 | end_`var'_`i' == 22 | end_`var'_`i' == 13
		
		replace end_`var'_`i' = 1 if end_`var'_`i' == 11 & maxid < 11
		replace end_`var'_`i' = 2 if end_`var'_`i' == 22 & maxid < 22
		replace end_`var'_`i' = 3 if end_`var'_`i' == 13 & maxid < 13		// Verified visually

}
}

// Recode an individual value - looks like missing, but wasn't entered - visually confirmed using pdf files. 



// Recode when an an id as missing when it is listed on searching and there is nothing else listed in the search 
// 10 to adj count
forval i = 1/3{

list  end_mun* hhid_pjid end_e1a_pid_`i' end_e1*_`i' if end_e1a_pid_`i' != . & end_e1a_pid_`i' != 88 & (end_e1b_type_`i' == . | end_e1b_type_`i' == 88 ) & (end_e1e_country_`i' == "" | end_e1e_country_`i' == "8888")
replace adjust_id = adjust_id + 10 if end_e1a_pid_`i' != . & end_e1a_pid_`i' != 88 & (end_e1b_type_`i' == . | end_e1b_type_`i' == 88 ) & (end_e1e_country_`i' == "" | end_e1e_country_`i' == "8888")
replace end_e1a_pid_`i' = . if end_e1a_pid_`i' != . & end_e1a_pid_`i' != 88 & (end_e1b_type_`i' == . | end_e1b_type_`i' == 88 ) & (end_e1e_country_`i' == "" | end_e1e_country_`i' == "8888")

list end_mun* hhid_pjid end_e2_pid_`i' end_e2*_`i' if end_e2_pid_`i' != . & end_e2_pid_`i' != 88 & (end_e2b_attendint_`i' == . | end_e2b_attendint_`i' == 88) & (end_e2d_dateint_yyyy_`i' == 8888 | end_e2d_dateint_yyyy_`i' == .) & (end_e2c_whynotcode_`i' == . | end_e2c_whynotcode_`i' == 88)
replace adjust_id = adjust_id + 10 if end_e2_pid_`i' != . & end_e2_pid_`i' != 88 & (end_e2b_attendint_`i' == . | end_e2b_attendint_`i' == 88) & (end_e2d_dateint_yyyy_`i' == 8888 | end_e2d_dateint_yyyy_`i' == .) & (end_e2c_whynotcode_`i' == . | end_e2c_whynotcode_`i' == 88)
replace end_e2_pid_`i' = . if end_e2_pid_`i' != . & end_e2_pid_`i' != 88 & (end_e2b_attendint_`i' == . | end_e2b_attendint_`i' == 88) & (end_e2d_dateint_yyyy_`i' == 8888 | end_e2d_dateint_yyyy_`i' == .) & (end_e2c_whynotcode_`i' == . | end_e2c_whynotcode_`i' == 88)


list  end_mun* hhid_pjid end_e3_pid_`i' end_e3*_`i' if end_e3_pid_`i' != . & end_e3_pid_`i' != 88 & (end_e3b_accept_`i' == . | end_e3b_accept_`i' == 88) & (end_e3g_migrate_`i' == . | end_e3g_migrate_`i' == 88)
replace adjust_id = adjust_id + 10 if end_e3_pid_`i' != . & end_e3_pid_`i' != 88 & (end_e3b_accept_`i' == . | end_e3b_accept_`i' == 88) & (end_e3g_migrate_`i' == . | end_e3g_migrate_`i' == 88)
replace end_e3_pid_`i' = . if end_e3_pid_`i' != . & end_e3_pid_`i' != 88 & (end_e3b_accept_`i' == . | end_e3b_accept_`i' == 88) & (end_e3g_migrate_`i' == . | end_e3g_migrate_`i' == 88)


list  end_mun* hhid_pjid end_e4a_pid_`i' end_e4*_`i' if end_e4a_pid_`i' != . & end_e4a_pid_`i' != 88 & end_e4b_datemig_mm_`i' == . & end_e4c_workcode_`i' == .
replace adjust_id = adjust_id + 10  if end_e4a_pid_`i' != . & end_e4a_pid_`i' != 88 & end_e4b_datemig_mm_`i' == . & end_e4c_workcode_`i' == .
replace end_e4a_pid_`i' = .  if end_e4a_pid_`i' != . & end_e4a_pid_`i' != 88 & end_e4b_datemig_mm_`i' == . & end_e4c_workcode_`i' == .


}





// Identify household ids with potential individual adjustments 
		// 1. ids are not consistent throughout
		



		foreach var in e1a_pid e2_pid e3_pid e4a_pid{
		forval i = 1/3{
		
		
		list hhid_pjid r_pid maxid end_*pid*`i' if end_`var'_`i' > maxid & end_`var'_`i' != . & end_`var'_`i' != 88
		replace prob1 = 1 if end_`var'_`i' > maxid & end_`var'_`i' != . & end_`var'_`i' != 88

		}
		}
		
	
// Listed and corrected individually:, 99995230, 99996113,, N0090_BL9999, N0096_CA9999 99996236, 99996386, 99996285

// Listed and not corrected: 99994658	// Person 5 listed as enrolling in PJ, but no way to confirm who that is


// Identify household ids with potential individual adjustments 
		// 2. ids are missing for only some tables 

forval i = 1/3{
local j = `i' + 1
di in red "test 1 v 2, i = `i'"
list hhid_pjid r_pid maxid end_*pid*`i'  if end_e1a_pid_`i' != . & end_e1g_int_`i' == 1 & end_e2_pid_`i' != . & end_e2_pid_`i' != 88 & end_e2_pid_`i' != end_e1a_pid_`i' & end_e2_pid_`i' != end_e1a_pid_`j'
di in red "test 1 v3, i = `i'"
list hhid_pjid r_pid maxid end_*pid*`i'  if end_e1a_pid_`i' != . & end_e1h_offer_`i' == 1 & end_e3_pid_`i' != . & end_e3_pid_`i' != 88 & end_e3_pid_`i' != end_e1a_pid_`i' & end_e3_pid_`i' != end_e1a_pid_`j'
di in red "test 3 v 4, i = `i'"
list hhid_pjid r_pid maxid end_*pid*`i'  if end_e3_pid_`i' != . & end_e3g_migrate_`i'== 1 & end_e4a_pid_`i' != . & end_e4a_pid_`i' != 88 & end_e3_pid_`i' != end_e4a_pid_`i' & end_e4a_pid_`i' != end_e3_pid_`j'

}

// Listed and corrected individually: 99992867 99991496 99998961 N0064_CN9999 N0020_PI9999





// Generate indicators for individual level adjustments 




#delimit ;
foreach var in 99995230 99996113 N0090_BL9999 N0096_CA9999 99996236 99996386 99996285
				99992867 99991496 99998961 N0064_CN9999 N0020_PI9999 N0069_MA9999 N0239_BL9999 N0031_SN9999 99994604{;
		replace adjust_id = adjust_id + .01 if hhid_pjid == "`var'" ;
		};
		
#delimit cr
			
	// Make individual level adjustments (confirmed visually in pdf files)
	
		replace end_e2_pid_1 = 2 if end_e2_pid_1 == 1 & hhid_pjid == "99994604" // Visually confirmed - only 1 entry in e1, footnote in e2 says "my respondent"

		replace end_e2_pid_1 = 2 if end_e2_pid_1 == 1 & hhid_pjid == "N0031_SN9999" // Visually confirmed - only 1 entry in e1, same date in e1 and e2, DH position
		
		replace end_e2_pid_1 = 2 if end_e2_pid_1 == 3 & hhid_pjid == "N0239_BL9999" // Visually confirmed - enumeraotr manually chaned from 2/3 in all but this entry
		
		replace end_e4a_pid_1 = 6 if end_e4a_pid_1 == 1 & hhid_pjid == "N0069_MA9999" //Visually confirmed (not corrected in roster)
		replace end_e2_pid_1 = 6 if end_e2_pid_1 == 88 & hhid_pjid == "N0069_MA9999" //Visually confirmed (not corrected in roster)
			
		replace end_e3_pid_1 = 2 if end_e3_pid_1 == 1 & hhid_pjid == "99991496"		// corrected in 0_4
		replace end_e3_pid_1 = 2 if end_e3_pid_1 == 1 & hhid_pjid == "N0064_CN9999"
				
		replace end_e2_pid_1 = 2 if end_e2_pid_1 == 1 & hhid_pjid == "99992867"		// equal to 2 in section 1, but not others. occupation is caregiver, and #2 is female
		replace end_e3_pid_1 = 2 if end_e3_pid_1 == 1 & hhid_pjid == "99992867"
		replace end_e4a_pid_1 = 2 if end_e4a_pid_1 == 88 & hhid_pjid == "99992867"


		replace end_e1a_pid_1 = 2 if end_e1a_pid_1 == 3 & hhid_pjid == "99995230" // Verified visually - enumerator accidentally skipped al ine in the roster, so #3 became #2
		replace end_d1a_pid_1 = 2 if end_d1a_pid_1 == 3 & hhid_pjid == "99995230" // Verified visually - enumerator accidentally skipped al ine in the roster, so #3 became #2
		replace end_e1a_pid_2 = 7 if end_e1a_pid_2 == 8 & hhid_pjid == "99996386" // Verified visually - enumerator accidentally skipped al ine in the roster, so #8 became #7
		replace end_e1a_pid_1 = 4 if end_e1a_pid_1 == 5 & hhid_pjid == "N0096_CA9999" // Verified visually - enumerator accidentally skipped al ine in the roster, so #5 became #4
		replace end_d1a_pid_01 = 4 if end_d1a_pid_01 == 5 & hhid_pjid == "N0096_CA9999" // Verified visually - enumerator accidentally skipped al ine in the roster, so #5 became #4
		replace end_e1a_pid_2 = 2 if end_e1a_pid_2 == 4 & hhid_pjid == "99996236" // Verified visually  - 2nd line accidentally entered 4 despite being same type of job as 1st line. 

		replace end_e2_pid_1 = 7 if end_e2_pid_1 == 6 & hhid_pjid == "99996285"
		replace end_e3_pid_1 = 7 if end_e3_pid_1 == 6 & hhid_pjid == "99996285"
		replace end_e4a_pid_1 = 7 if end_e4a_pid_1 == 8 & hhid_pjid == "99996285" // Verified visually  -PErson who migrated in section e3 is #7, there is no #8 
		
		replace end_e3_pid_1 = 1 if end_e3_pid_1 == 88 & hhid_pjid == "99998961" // Verified visually - enumerator accidentally left blank, but is in line with 5 applications for overseas work
		replace end_e4a_pid_1 = 1 if end_e4a_pid_1 == 88 & hhid_pjid == "99998961" // Verified visually - enumerator accidentally left blank, but is in line with 5 applications for overseas work

		foreach var in e1a_pid e2_pid e3_pid e4a_pid {
		replace end_`var'_1 = 3 if end_`var'_1 == . & hhid_pjid == "N0020_PI9999" // Verified visually - enumerator accidentally wrote 99 instead of 3, but has to be 3
		}

		
		foreach var in e1a_pid e2_pid e3_pid {
		replace end_`var'_1 = 5 if end_`var'_1 == 6 & hhid_pjid == "N0090_BL9999" // Verified visually - enumerator accidentally skipped al ine in the roster, so #6 became #5
		}
		replace end_d1a_pid_01 = 5 if end_d1a_pid_01 == 6 & hhid_pjid == "N0090_BL9999" // Verified visually - enumerator accidentally skipped al ine in the roster, so #6 became #5
		
		foreach var in e1a_pid {
		forval i = 1/2{
		replace end_`var'_`i' = 2 if end_`var'_`i' == 3 & hhid_pjid == "99996113" // Verified visually - there is no #3, but ony #2 has a job, which she lists as accepting in section D
		}
		}
		replace end_d1a_pid_01 = 2 if end_d1a_pid_01 == 3 & hhid_pjid == "99996113" // Verified visually - enumerator accidentally skipped al ine in the roster, so #6 became #5
		replace end_d1a_pid_02 = 2 if end_d1a_pid_02 == 3 & hhid_pjid == "99996113" // Verified visually - enumerator accidentally skipped al ine in the roster, so #6 became #5
		

forval i = 1/3{
local j = `i' + 1
di in red "test 1 v 2, i = `i'"
list  end_mun* hhid_pjid r_pid maxid end_e1a_pid* end_e2_pid*  if end_e1a_pid_`i' != . & end_e1g_int_`i' == 1 & end_e2_pid_`i' != . & end_e2_pid_`i' != 88 & end_e2_pid_`i' != end_e1a_pid_`i' & end_e2_pid_`i' != end_e1a_pid_`j'
di in red "test 1 v3, i = `i'"
list  end_mun*  hhid_pjid r_pid maxid end_e1a_pid* end_e3_pid*  if end_e1a_pid_`i' != . & end_e1h_offer_`i' == 1 & end_e3_pid_`i' != . & end_e3_pid_`i' != 88 & end_e3_pid_`i' != end_e1a_pid_`i' & end_e3_pid_`i' != end_e1a_pid_`j'
di in red "test 3 v 4, i = `i'"
list  end_mun* hhid_pjid r_pid maxid end_e3_pid* end_e4a_pid*  if end_e3_pid_`i' != . & end_e3g_migrate_`i'== 1 & end_e4a_pid_`i' != . & end_e4a_pid_`i' != 88 & end_e3_pid_`i' != end_e4a_pid_`i' & end_e4a_pid_`i' != end_e3_pid_`j'

}


		forval i = 1/3{
		decode end_e2e_intloc_`i',gen(end_e2eintloc`i')
		
		list end_e1h_offer_`i' end_e2*`i' if end_e2eintloc`i' == "THRU PHONE"
		list end_e1h_offer_`i' end_e2*`i' if (end_e2b_attendint_`i' == 88 ) & end_e2d_dateint_yyyy_1 >=2010 & end_e2d_dateint_yyyy_1 <=2012

			replace end_e2b_attendint_`i' = 1 if end_e2b_attendint_`i' == 2 & end_e2eintloc`i' == "THRU PHONE"

			replace end_e2b_attendint_`i' = 1 if end_e2b_attendint_`i' == 88 & end_e2d_dateint_yyyy_1 >=2010 & end_e2d_dateint_yyyy_1 <=2012				
				
				}
				
/* Potentially problematic, not changed: N0158_SJ - confirmed to be okay 
							99991666 - cannot confirm whether it is 4 or 5
							99998962  - ok
							99998931 - ok
							99995170 - ok
							99998958  - ok
							*/ 

							 

			


******************************************
*		Outcome Variables
******************************************



// Outcome variables - Endline


		// end_s10_wherestay - why so many missing values in end_s9_where? 
		
		gen end_outsidesor = end_s9_sorsogon == 2
			replace end_outsidesor = . if end_s9_sorsogon == 8 | end_s9_sorsogon == -2
		gen end_manila = end_s10_wherestay == 1 | end_s10_whereliving == 1
		gen end_otherph = end_s10_wherestay == 2 | end_s10_whereliving == 2
		
		gen end_ofw = end_s10_wherestay == 3 | end_s10_whereliving == 3
		foreach var in manila otherph ofw{
		replace end_`var' = . if end_outsidesor == . & (end_s10_wherestay == . | end_s10_wherestay == 88)
		}
		
		// working overseas 
		decode end_s10_specify,gen(s10spec)
		decode end_s10_wherespec,gen(s10_wherespec)

		gen end_ofwwork = 0 if end_s9 == 1 | (end_s10_wherestay == 1 | end_s10_whereliving == 1 | end_s10_wherestay == 2 | end_s10_whereliving == 2)
		replace end_ofwwork = 0 if end_stype == "FULL"
		replace end_ofwwork = 0 if end_s8a_unableint  == 3 | end_s8a_unableint == 7	// Working in sorsogon or temporarily away
		replace end_ofwwork = 1 if end_s11_whyleftsor == 1 & (end_s10_wherestay == 3 | end_s10_whereliving == 3)
		replace end_ofwwork = 1 if end_s11_reasonmoved_1 == 1 & (end_s10_wherestay == 3 | end_s10_whereliving == 3)
		replace end_ofwwork = 1 if end_s11_whyleftsor == 1 & (end_s10_wherestay == 3 | end_s10_whereliving == 3)
		replace end_ofwwork = 0 if end_s11_whyleftsor  == 4 	// Moved for family
		replace end_ofwwork = 1 if end_s11_whyleftsor == 1 & (s10_wherespec == "ISRAEL" | s10_wherespec == "SAUDI ARABIA (JEDDAH)" | s10_wherespec == "JEDDAH KSA")
		replace end_ofwwork = 0 if s10spec  == "MARINDUQUE" | s10spec == "ILOILO CITY"

		
		

		
		
// Outcome variable - Anyone in the household currently working overseas (full + proxy survey)

gen end_hhofw = 0
gen end_hhofwnum = 0
	forval i = 1/9{
		replace end_hhofw = 1 if end_b_ofw_`i' == 1
		replace end_hhofwnum = end_hhofwnum + 1 if end_b_ofw_`i' == 1
		}
		
	tab end_hhofwnum
		
gen base_hhofw = 0
gen base_hhofwnum = 0
	forval i = 1/18{
	replace base_hhofw = 1 if base_b11_ofw`i' == 1
	replace base_hhofwnum = base_hhofwnum + 1 if base_b11_ofw`i' == 1
	}
	tab base_hhofwnum
	tab base_hhofwnum end_hhofwnum
		
		
		
		tab end_hhofw end_ofw if end_stype != "LOG" 		// 4 inconsistencies out of 116, reasonable (but correct)
		replace end_hhofw = . if end_stype == "LOG"
		replace end_hhofwnum = . if end_stype == "LOG"

		replace base_hhofwnum = . if baseline == 0
		replace base_hhofw = . if baseline == 0
		
gen end_changehhofw = end_hhofwnum - base_hhofwnum

// Anyone in the household left to migrate abroad from 2010-2012

gen end_hhmigrate = 0
	replace end_hhmigrate = 1 if end_c4_stepsofw_8 == 1
	replace end_hhmigrate = . if end_c4_stepsofw_8 == . | end_c4_stepsofw_8 == 8 | end_c4_stepsofw_8 == -2
			

/* Plan to apply abroad */

gen _respplan = end_c5_planapply
	recode _respplan 2 = 0
	recode _respplan -2 = 0
	recode _respplan -1 = .
	recode _respplan 88 = .

	// Migration Steps


			* _endc4stepsofw
			destring end_c4_stepsofw_1,replace force
			gen _endc4stepsofw_0 = 0
		forval i = 1/8{
			gen _endc4stepsofw_`i' = end_c4_stepsofw_`i' == 1
			replace _endc4stepsofw_`i' = . if end_c4_stepsofw_`i' == . 	| end_stype == "LOG" | end_stype == ""	// code -2 and 8 as 0
			replace _endc4stepsofw_0 = 1 if _endc4stepsofw_`i' == 1
			
				}
			replace _endc4stepsofw_0 = . if _endc4stepsofw_1 == . 
				
				tabstat _endc4steps*
			
sum _endc4steps*

			replace end_d1b_typespc_05 = end_d1b_typespc_5 if end_d1b_typespc_5 != "" & end_d1b_typespc_05 == ""
			drop end_d1b_typespc_5
	// Local Steps in Philippines or outside Philippines
			forval i = 1/9{

			
			foreach y in c1_stepsphil d1a_pid d1b_type d1b_typespc d1c_code d1c_posname d1d_wherecode d1d_wherename d1e_datesub_mm d1e_datesub_yyyy d1f_interview d1g_offer d1h_startjob{
		
			cap	rename end_`y'_0`i' end_`y'_`i'
				}
				}

		forval i = 1/12{
			gen _endc1stepsphil_`i' = end_c1_stepsphil_`i' == 1
				replace _endc1stepsphil_`i' = . if end_c1_stepsphil_`i' < 1 | end_c1_stepsphil_`i' > 2
				}
				
				tabstat _endc1stepsphil_*
				
				forval i = 1/7{
				decode end_e1b_typespec_`i',gen(end_e1bspec_`i')
				list end_e1b_type_`i' end_e1bspec_`i' if (end_e1b_type_`i' == -2 | end_e1b_type_`i' == 88 | end_e1b_type_`i' == . ) & end_e1bspec_`i' != "" & end_e1bspec_`i' != "8888"
						
						replace end_e1b_type_`i' = 2 if (end_e1b_type_`i' == 88) & end_e1bspec_`i' == "WEBSITE"

						replace end_e1b_type_`i' = 4 if (end_e1b_type_`i' == 88) & end_e1bspec_`i' != "" & end_e1bspec_`i' != "8888"
						  
						
						}
						
	
		// How did HH look for work abroad?
		// Did respondent look for work abroad steps? 
			foreach x in ofwstep_1012 raapp_1012 web_1012 jobfair_1012 other_1012 ofwinvite ofwlooknoinvite ofwoffer{		
			gen resp_`x' = 0
			gen hh_`x' = 0
			gen notresp_`x' = 0
						}
		gen resplookcount = 0

		gen respinvitecount = 0
		gen respoffercount = 0
			local oo = 1
			foreach var in hh resp notresp{
				forval i = 1/7{
					forval j = 1/10{
			local O1 ""
			local O2 "& end_e1a_pid_`i' == `j' & r_pid == `j'"
			local O3 "& end_e1a_pid_`i' != r_pid == `j'"


					if "`var'" == "resp"{
					replace respinvitecount = respinvitecount + 1 if end_e1g_int_`i' == 1 `O`oo'' 
					replace respoffercount = respoffercount + 1 if end_e1h_offer_`i' == 1 `O`oo'' 
					replace resplookcount = resplookcount + 1 if end_e1b_type_`i' >= 1 & end_e1b_type_`i' <=4 `O`oo''

					}
					
					
					replace `var'_raapp_1012 = 1 if end_e1b_type_`i' == 1 `O`oo''
					replace `var'_web_1012 = 1 if end_e1b_type_`i' == 2 `O`oo''
					replace `var'_jobfair_1012 = 1 if end_e1b_type_`i' == 3 `O`oo''
					replace `var'_other_1012 = 1 if (end_e1b_type_`i' == 3 | end_e1b_type_`i' == 4) `O`oo''
					

					replace `var'_ofwlooknoinvite = 1 if (end_e1a_pid_`i' !=. | (end_e1b_type_`i' >=1 & end_e1b_type_`i' <=4)) & (end_e1g_int_`i' == 2 | end_e1g_int_`i' == 3) `O`oo''	

					replace `var'_ofwinvite = 1 if end_e1g_int_`i' == 1 `O`oo''		// was interview_1012
					replace `var'_ofwoffer = 1 if end_e1h_offer_`i' == 1 `O`oo''	// was offer_1012
					}
					
					}
					
					replace `var'_ofwstep_1012 = 1 if `var'_raapp_1012 == 1 | `var'_web_1012 == 1 | `var'_jobfair_1012 == 1 | `var'_other_1012 == 1

					local oo = `oo' + 1
					
					
					}
					

										
			foreach x in ofwstep_1012 raapp_1012 web_1012 jobfair_1012 other_1012 ofwinvite ofwlooknoinvite ofwoffer{		
			replace resp_`x' = . if end_stype == "LOG" | r_pid == .
			replace hh_`x' = . if end_stype == "LOG" 
			replace notresp_`x' = . if end_stype == "LOG" 

			}
											
			tabstat resp*1012
			tabstat hh*1012
			
			
					
	/* Check attend interview vs. offer interview discrepancies */ 				
		// Was anyone in the household 	offered a job abroad? Did they accept? 
		// Was respondent	offered a job abroad? Did they accept? 

		foreach x in  ofwinvitenotattend ofwattendint ofwnotacceptoff ofwacceptoff ofwmigrate ofwacc_offernomig ofwacc_offerpendmig ofwacc_off_nopend ofwoffer_nopend{
		gen hh_`x' = 0 		
		gen resp_`x' = 0
		}
	
	
		forval i = 4/6{
		gen end_e2c_whynotspec_`i' = .
	}
		forval j = 1/10{

		forval i = 1/6{
		replace hh_ofwattendint = 1 if 	end_e2b_attendint_`i' == 1
		replace hh_ofwinvitenotattend = 1 if 	end_e2b_attendint_`i' == 2 & (end_e2c_whynotcode_`i' != 88 | end_e2c_whynotspec_`i' != .) 
		replace resp_ofwattendint = 1 if end_e2b_attendint_`i' == 1 & r_pid == `j' &  end_e2_pid_`i' == `j'
		replace resp_ofwinvitenotattend = 1 if 	end_e2b_attendint_`i' == 2 & r_pid == `j' &  end_e2_pid_`i' == `j' & (end_e2c_whynotcode_`i' != 88 | end_e2c_whynotspec_`i' != .) 


		}
		forval i = 1/3{
		
		replace hh_ofwacceptoff = 1 if end_e3b_accept_`i' == 1
		replace hh_ofwnotacceptoff = 1 if end_e3b_accept_`i' == 2 & hh_ofwoffer == 1

		replace hh_ofwmigrate = 1 if end_e3g_migrate_`i' == 1
		replace hh_ofwacc_offernomig = 1 if end_e3g_migrate_`i' == 2 & end_e3b_accept_`i' == 1
		replace hh_ofwacc_offerpendmig = 1 if end_e3g_migrate_`i' == 3 & end_e3b_accept_`i' == 1
		replace hh_ofwoffer_nopend = 1 if ((end_e3g_migrate_`i' == 2 | end_e3g_migrate_`i' == 3) & end_e3b_accept_`i' == 1) | end_e3b_accept_`i' == 2
		replace hh_ofwacc_off_nopend = 1 if end_e3b_accept_`i' == 1 & (end_e3g_migrate_`i' == 2 | end_e3g_migrate_`i' == 3)

		replace resp_ofwacceptoff = 1 if end_e3b_accept_`i' == 1 & r_pid == `j' &  end_e3_pid_`i' == `j'
		replace resp_ofwnotacceptoff = 1 if end_e3b_accept_`i' == 2 & r_pid == `j' &  end_e3_pid_`i' == `j' & resp_ofwoffer == 1




		replace resp_ofwmigrate = 1 if end_e3g_migrate_`i' == 1 & r_pid == `j' &  end_e3_pid_`i' == `j'
		replace resp_ofwacc_offernomig = 1 if end_e3g_migrate_`i' == 2 & r_pid == `j' &  end_e3_pid_`i' == `j' &  end_e3b_accept_`i' == 1
		replace resp_ofwacc_offerpendmig = 1 if end_e3g_migrate_`i' == 3 & r_pid == `j' &  end_e3_pid_`i' == `j' & end_e3b_accept_`i' == 1
		replace resp_ofwoffer_nopend = 1 if r_pid == `j' &  end_e3_pid_`i' == `j' & ( ( (end_e3g_migrate_`i' == 2 | end_e3g_migrate_`i' == 3) & end_e3b_accept_`i' == 1) | end_e3b_accept_`i' == 2)
		replace resp_ofwacc_off_nopend = 1 if end_e3b_accept_`i' == 1 & (end_e3g_migrate_`i' == 2 | end_e3g_migrate_`i' == 3) & r_pid == `j' &  end_e3_pid_`i' == `j' 




		}
		
		}
		
		/* General to make sure those accepting or rejecting invitiations to interview are marked as interviewing */
		
		foreach var in hh resp {
		list hhid_pjid if (`var'_ofwattendint == 1 ) & `var'_ofwinvite == 0
		replace `var'_ofwinvite = 1 if `var'_ofwattendint == 1 
		}
	
		
		
		forval i = 1/3{
		decode end_e3h_whynotspec_`i',gen(end_e3h_whynot`i')
		list hhid_pjid end_e2_pid_`i' end_e2b_attendint_`i' end_e2c_whynotcode_`i' end_e2c_whynotspec_`i' if end_e2b_attendint_`i' == 2 & (end_e2c_whynotcode_`i' != 88 | end_e2c_whynotspec_`i' != .) & hh_ofwinvite == 0
		list hhid_pjid end_e3*`i' if hh_ofwaccept == 1 & hh_ofwoffer == 0

		replace hh_ofwoffer = 1 if hh_ofwaccept == 1 & end_e3b_accept_`i' == 1 & end_e3h_whynot`i' != "WASNT CONTACTED" & end_e3h_whynot`i' != "OVER AGE" 
		replace hh_ofwinvite = 1 if end_e2b_attendint_`i' == 2 & (end_e2c_whynotcode_`i' != 88 | end_e2c_whynotspec_`i' != .)

		forval j = 1/7{
		replace resp_ofwinvite = 1 if end_e2b_attendint_`i' == 2 & (end_e2c_whynotcode_`i' != 88 | end_e2c_whynotspec_`i' != .) &  end_e1a_pid_`i' == `j' & r_pid == `j'
		replace resp_ofwoffer = 1 if resp_ofwaccept == 1 & end_e3b_accept_`i' == 1 & end_e3h_whynot`i' != "WASNT CONTACTED" & end_e3h_whynot`i' != "OVER AGE"  &  end_e1a_pid_`i' == `j' & r_pid == `j'

		

		
		}
		
				}
				
				
		
				
		foreach x in  ofwinvitenotattend ofwattendint ofwnotacceptoff ofwacceptoff ofwmigrate ofwacc_offernomig ofwacc_offerpendmig ofwacc_off_nopend ofwoffer_nopend{
			replace resp_`x' = . if end_stype == "LOG" | r_pid == .
			replace hh_`x' = . if end_stype == "LOG" 

		}
		tab hh_ofwinvite hh_ofwinviten								// none that are 1 in hh_ofwinviten and 0 in hh_ofwinvite
		tab hh_ofwinvite hh_ofwattend								// none that are 1 in hh_ofwattend and 0 in hh_ofwinvite
		tab hh_ofwinvite hh_ofwattend  if hh_ofwinviten == 0		// want none that are 0 in hh_ofwattend and 1 in ofwinvite, but okay (bc some ommissions)
		
		
		// Note that I code that to not accept offer, you have to have been ffered a job in section e2. 
		
		tab hh_ofwoffer hh_ofwaccept								// none that are accept and 0 in offer (2) - Just going to ignore it. 
		tab hh_ofwoffer hh_ofwnotacceptoff							// none that are not accept and 0 in offer (0) 
		
		list hhid_pjid if hh_ofwoffer == 0 & (hh_ofwaccept == 1 | hh_ofwnotaccept == 1)
		
		
		
		// Characteristics of Applicant 

		qui tostring end_b_*,replace
		*foreach var in first middle last suffix rel age sex ed work mnl ofw{
		foreach var in rel age sex ed work mnl ofw{
		gen end_resp_`var' = ""
		forval i = 1/3{
		gen end_mig_`var'`i' = ""
		forval j = 1/11{
		replace end_mig_`var'`i' =  end_b_`var'_`j' if end_e3_pid_`i' == `j'
		if `i' == 1{
		replace end_resp_`var' = end_b_`var'_`j' if r_pid == `j'
		}
		}
		}
		tostring end_mig_`var'*,replace
		}
		
		forval i = 1/3{

list hhid_pjid r_pid maxid end_e1a_pid_1 end_e2_pid_1 end_e3*   end_b_age_* if  r_pid != end_e3_pid_`i' & end_e3g_migrate_`i' == 1 & ( end_e3_pid_`i' == . | end_e3_pid_`i' == 88)
list hhid_pjid end*mun* if  r_pid != end_e3_pid_`i' & end_e3g_migrate_`i' == 1 & ( end_e3_pid_`i' == . | end_e3_pid_`i' == 88)

		}
	

		
		// How did HH look for work in the Philippines (including sorsogon) - Respondent? 
		// Did respondent look for work abroad stesps? 
		forval i = 1/9{
		decode end_d1d_wherename_`i',gen(end_d1dname_`i')
		
		local muncount = 1
		qui{
		foreach munname in BARCELONA JUBAN BULAN CASIGURAN CASTILLA DONSOL GUBAT IROSIN MAGALLANES MATNOG PILAR PRIETO MAGDALENA{
			*	di in red "replacing in other section `munname' with `muncount'"
				list end_d1dname_`i' if  regexm(end_d1dname_`i',"`munname'") & end_d1d_wherecode_`i' > 14
				replace end_d1d_wherecode_`i' = `muncount' if regexm(end_d1dname_`i',"`munname'")
				replace end_d1dname_`i' = "" if regexm(end_d1dname_`i',"`munname'")
				local muncount = `muncount' + 1
				}

		replace end_d1d_wherecode_`i' = 14 if regexm(end_d1dname_`i',"BACON")
		replace end_d1dname_`i' = "" if regexm(end_d1dname_`i',"BACON")
		
		replace end_d1d_wherecode_`i' = 14 if regexm(end_d1dname_`i',"SOR.*CITY")
		replace end_d1dname_`i' = "" if regexm(end_d1dname_`i',"SOR.*CITY")
		
		replace end_d1d_wherecode_`i' = 14 if regexm(end_d1dname_`i',"SORSOGON") | end_d1dname_`i' == "SOR" | end_d1dname_`i' == "SOR." 
		replace end_d1dname_`i' = "" if regexm(end_d1dname_`i',"SORSOGON")
		
		replace end_d1d_wherecode_`i' = 15 if regexm(end_d1dname_`i',"BULUSAN")
		replace end_d1dname_`i' = "" if regexm(end_d1dname_`i',"BULUSAN")
		
		replace end_d1d_wherecode_`i' = 16 if regexm(end_d1dname_`i',"LOCAL")
		replace end_d1dname_`i' = "" if regexm(end_d1dname_`i',"LOCAL")
		
		replace end_d1d_wherecode_`i' = 17 if regexm(end_d1dname_`i',"LEG") | regexm(end_d1dname_`i',"ALBAY") | regexm(end_d1dname_`i',"DARAGA") | regexm(end_d1dname_`i',"TABACO")
		replace end_d1dname_`i' = "" if regexm(end_d1dname_`i',"LEG") | regexm(end_d1dname_`i',"ALBAY") | regexm(end_d1dname_`i',"DARAGA") | regexm(end_d1dname_`i',"TABACO")
		
		}
		replace end_d1dname_`i' = "" if end_d1dname_`i' == "8888"
		replace end_d1dname_`i' = "" if end_d1dname_`i' == "-2"
		replace end_d1d_wherecode_`i' = 99 if end_d1d_wherecode_`i' == 88 & end_d1dname_`i' != ""
		replace end_d1d_wherecode_`i' = 88 if end_d1d_wherecode_`i' == 99 & end_d1dname_`i' == ""
		replace end_d1d_wherecode_`i' = 99 if end_d1d_wherecode_`i' == . & end_d1dname_`i' != ""

		replace end_d1d_wherecode_`i' = 99 if end_d1d_wherecode_`i' == 9 & end_d1dname_`i' != "" & regexm(end_d1dname_`i',"MAGELLANES") != 1
		replace end_d1d_wherecode_`i' = 99 if end_d1d_wherecode_`i' == 100
		
		tab end_d1dname_`i' if end_d1d_wherecode_`i' ==99 & end_d1dname_`i' != ""
		}
		
	foreach x in phlook phfriendfam phcvapp phother phinterview  phoffer phstart {	
		
		foreach suffix in all SP outSP MNL{
			gen resp_`x'_`suffix' = 0
			gen hh_`x'_`suffix' = 0
						}
						}

			local oo = 1
			
			gen end_d1bspec_5 = end_d1b_typespc_5
			forval i = 1/6{
			cap decode end_d1b_typespc_`i',gen(end_d1bspec_`i')
			
			list end_d1b_type_`i' end_d1bspec_`i' if (end_d1b_type_`i' == -2 | end_d1b_type_`i' == 88 | end_d1b_type_`i' == . ) & end_d1bspec_`i' != "" & end_d1bspec_`i' != "8888"
			replace end_d1b_type_`i' = 3 if end_d1b_type_`i' == 88 & (end_d1bspec_`i' == "DIRECT HIRE" | end_d1bspec_`i' == "JOB FAIR")
			replace end_d1b_type_`i' = 3 if end_d1b_type_`i' == -2 & end_d1c_code_`i' != . & end_d1c_code_`i' != -2

			}
			
			
	foreach var in hh resp{
				local suff = 1

		foreach suffix in all SP outSP MNL{
					di in red "replacing `var' and `suffix' with codes `oo' and `suff' `SUF`suff'' `O`oo''"

				forval i = 1/7{
					forval j = 1/10{
			
						local O1 ""
						local O2 "& end_d1a_pid_`i' == `j' & r_pid == `j'"

						local SUF1 ""
						local SUF2 "& end_d1d_wherecode_`i' <= 16 & end_d1d_wherecode_`i' >=0"
						local SUF3 "& (end_d1d_wherecode_`i' == 17 | end_d1d_wherecode_`i' == 99)"
						local SUF4 "& (end_d1d_wherecode_`i' == 99)"
			
														
						replace `var'_phfriendfam_`suffix' = 1 if end_d1b_type_`i' == 1 `SUF`suff'' `O`oo''	
						replace `var'_phcvapp_`suffix' = 1 if end_d1b_type_`i' == 2 `SUF`suff'' `O`oo''	
						replace `var'_phother_`suffix' = 1 if end_d1b_type_`i' == 3 `SUF`suff'' `O`oo''	

					
						replace `var'_phinterview_`suffix' = 1 if end_d1f_interview_`i' == 1 `SUF`suff'' `O`oo''	
						replace `var'_phoffer_`suffix' = 1 if end_d1g_offer_`i' == 1 `SUF`suff'' `O`oo''	
						replace `var'_phstart_`suffix' = 1 if end_d1h_startjob_`i' == 1 `SUF`suff'' `O`oo''	
										
									}	// j loop
								}		// i loop
					local suff = `suff' + 1		
					replace `var'_phlook_`suffix' = 1 if `var'_phfriendfam_`suffix' == 1 | `var'_phcvapp_`suffix' == 1 | `var'_phother_`suffix' == 1

			}				

					local oo = `oo' + 1

		}

										
foreach x in phlook phfriendfam phcvapp phother phinterview  phoffer phstart {	
		
		foreach suffix in all SP outSP MNL{
			replace resp_`x'_`suffix' = . if end_stype == "LOG" | r_pid == .
			replace hh_`x'_`suffix' = . if end_stype == "LOG" 

			}
				}						
		tabstat hh_ph* resp_ph*
		
		
				
egen end_bar_g = group(bench_group)
	replace end_bar_g = 11 if end_bar_g == .
	
gen endbar2 = end_bar_g
	replace endbar2 = 12 if end_bar_g >=1 & end_bar_g <=5
	
	
	
recode end_i2 -2 = .
recode end_i2 88 = .
recode end_i3 -2 = .
recode end_i3 88 = .

gen _i2passever = end_i2_passever
recode _i2passever 2 = 0
replace end_i2_passever = 1 if end_i3_currpass == 1 // 1 error


gen _i3currpass = end_i3_currpass
	recode _i3currpass 2 = 0
	recode _i3currpass 3 = 0	// Expired
	replace _i3currpass = 0 if _i2passever == 0
	
	tab _i2 _i3 	// 33 where I2 passever == 1 & I3 currpass == missing	12 where full proxy completed but no outcome 
	tab end_i2 end_i3 if _i2 == 1 & _i3currpass == .,mi
	
	
gen end_currpass = 0 if _i3 != . 		// exclude the 33 missing current pass ones. 
	replace end_currpass = 1 if end_i3 == 1
	
gen end_everpass = 0 if _i2 != .
	replace end_everpass = 1 if _i2 == 1
	
	
	list hhid_pjid end_mun*  end_stype if _i2 == 1 & _i3 == .
	
	
	
	
// Savings Goals

gen _hhsavingofw = end_h4_save_ofw
recode _hhsaving 2 = 0	
recode _hhsaving -2 = .	
recode _hhsaving -1 = .	
recode _hhsaving 8 = .	
recode _hhsaving 88 = .	
	
gen _hhsavinggoal = end_h4a_save_g
recode _hhsavinggoal -2 = .
recode _hhsavinggoal -1 = .
recode _hhsavinggoal 2 = .
recode _hhsavinggoal 8888 = .

gen _hhsavinggoal_wzero = _hhsavinggoal
replace _hhsavinggoal_wzero = 0 if _hhsavingofw == 0 

gen _hhsavingaccomplished = end_h4b
recode _hhsavingaccomplished -2 = .
recode _hhsavingaccomplished -1 = .
recode _hhsavingaccomplished 8888 = .
recode _hhsavingaccomplished 88 = .

gen _hhsavingaccomplished_wzero = _hhsavingaccomplished
replace _hhsavingaccomplished_wzero = 0 if _hhsavingofw == 0

gen _hhborrow_ofw = end_h5_borrow_ofw
recode _hhborrow_ofw -2 = .
recode _hhborrow_ofw -1 = .
recode _hhborrow_ofw 8 = .
recode _hhborrow_ofw 88 = .
recode _hhborrow_ofw 2 = 0



gen _hhborrow_ofw_formal = 0 if _hhborrow_ofw != .
	replace _hhborrow_ofw_formal = 1 if end_h5a_borrowhere_6 == 1 | end_h5a_borrowhere_7 == 1

gen _hhborrow_amt = end_h5b_borrow_a
	replace _hhborrow_amt = 0 if _hhborrow_ofw == 0
	recode _hhborrow_amt -2 = .
	recode _hhborrow_amt 8888 = .

gen _hhborrow_out = end_h5c
	replace _hhborrow_out = 0 if _hhborrow_ofw == 0
	recode _hhborrow_out -2 = .
	recode _hhborrow_out -1 = .
	recode _hhborrow_out 8888 = .

foreach var in _hhsavinggoal_wzero _hhsavinggoal _hhsavingaccomplished _hhsavingaccomplished_wzero _hhborrow_amt _hhborrow_out{
replace `var' = `var'/1000
}


/* Information outcomes */ 


	// Clean/Code information outcomes 
	
	/* Fix the others for the internet and for the website */ 
	/* end_b1_wherinfo_7 = Other */ 
forval i = 1/9{
recode end_b1_whereinfo_9 8 = .				// Missing
recode end_b1_whereinfo_9 2 = 0				// Missing

}


// Clean the whereinfospec variable 	
replace end_b1_whereinfo_7 = 0 if end_b1_whereinfospec == "88" | end_b1_whereinfospec == "8888"
replace end_b1_whereinfospec = "" if end_b1_whereinfospec == "88" | end_b1_whereinfospec == "8888"

replace end_b1_whereinfospec = subinstr(end_b1_whereinfospec,".","",.)
replace end_b1_whereinfospec = subinstr(end_b1_whereinfospec,",","",.)
replace end_b1_whereinfospec = subinstr(end_b1_whereinfospec,"(","",.)
replace end_b1_whereinfospec = subinstr(end_b1_whereinfospec,")","",.)
replace end_b1_whereinfospec = subinstr(end_b1_whereinfospec,"/"," ",.)
replace end_b1_whereinfospec = subinstr(end_b1_whereinfospec,"'","",.)

replace end_b1_whereinfospec = trim(upper(end_b1_whereinfospec))


replace end_b1_whereinfo_4 = 1 if end_b1_whereinfospec == "PILIJOBS" | end_b1_whereinfospec == "PILIJOBS ORG" | end_b1_whereinfospec == "PILIJOBSORG"
replace end_b1_whereinfo_4 = 1 if end_b1_whereinfospec == "INTERNET" | end_b1_whereinfospec == "INTERNET SEARCHING" | end_b1_whereinfospec == "JOBSTREET" | end_b1_whereinfospec == "THROUGH INTERNET"

replace end_b1_whereinfospec = "" if end_b1_whereinfospec == "PILIJOBS" | end_b1_whereinfospec == "PILIJOBS ORG" | end_b1_whereinfospec == "PILIJOBSORG"
replace end_b1_whereinfospec = "" if end_b1_whereinfospec == "INTERNET" | end_b1_whereinfospec == "INTERNET SEARCHING" | end_b1_whereinfospec == "JOBSTREET" | end_b1_whereinfospec == "THROUGH INTERNET"


 
gen infoanywhere = 0
forval i = 1/7{
replace infoanywhere = 1 if end_b1_whereinfo_`i' == 1
}
replace infoanywhere = . if end_b1_whereinfo_1 == .

replace end_b1_whereinfo_5 = 1 if end_b1_whereinfospec == "MANILA"
replace end_b1_whereinfo_7 = 0  if end_b1_whereinfospec == "MANILA"
replace end_b1_whereinfospec = ""  if end_b1_whereinfospec == "MANILA"


gen end_b1_whereinfo_10 = regex(end_b1_whereinfospec,"RECRUITMENT")
	replace end_b1_whereinfo_10 = 1 if regex(end_b1_whereinfospec,"AGENC") & regex(end_b1_whereinfospec,"TRAVEL") != 1 & regex(end_b1_whereinfospec,"GOV")  != 1
	replace end_b1_whereinfo_10 = 1 if regex(end_b1_whereinfospec,"RECRUITER") | regex(end_b1_whereinfospec, "RAS") | regex(end_b1_whereinfospec,"RA$")
	replace end_b1_whereinfo_10 = 1 if end_b1_whereinfospec == "RA REFERRALS" 
replace end_b1_whereinfo_10 = . if end_b1_whereinfo_1 == .

gen info_rajfint = end_b1_whereinfo_4 == 1 | end_b1_whereinfo_10 == 1 | end_b1_whereinfo_6 == 1		// 4 = Internet = RA, 6 = JF, 10 == RA
	replace info_rajfint = . if end_b1_whereinfo_1 == .


gen infointernet = 0
replace infointernet = 1 if end_b1_whereinfo_4 ==  1	// 401 say "yes!"
replace infointernet = . if infoanywhere == .

/* Visit recruitment agency, visit JR, look on internet */ 



/* Code website information */ 

/* 5 = other 
	6 = DK
	*/ 


forval i = 1/6{
recode end_b1a_webinfo_`i' 8 = .
recode end_b1a_webinfo_`i' 2 = 0

}


/* recode specific website */ 

replace end_b1a_webinfo_3 = 1 if regexm(end_b1a_webspec,"PILIJOB")
replace end_b1a_webinfo_5 = 0 if regexm(end_b1a_webspec,"PILIJOB")
replace end_b1a_webspec = "" if regexm(end_b1a_webspec,"PILIJOB")


replace end_b1a_webinfo_5 = 0 if (end_b1a_webspec == "1" | end_b1a_webspec == "8888" | end_b1a_webspec == "INTERNET") & end_b1a_webinfo_5 == 1
replace end_b1a_webspec = "" if (end_b1a_webspec == "1" | end_b1a_webspec == "8888" | end_b1a_webspec == "INTERNET")



replace end_b1a_webinfo_5 = 2 if substr(end_b1a_webspec,1,4) == "DONT" | substr(end_b1a_webspec,1,3) == "SHE"
replace end_b1a_webspec = ""  if substr(end_b1a_webspec,1,4) == "DONT" | substr(end_b1a_webspec,1,3) == "SHE"

replace end_b1a_webinfo_1 = 1 if regexm(end_b1a_webspec,"WORKABROAD")
	replace end_b1a_webinfo_5 = 0 if end_b1a_webspec == "WWW.WORKABROAD.COM"
	replace end_b1a_webspec = "" if end_b1a_webspec == "WWW.WORKABROAD.COM"

/* Code website variables */ 



gen infowebsite = 0

	forval i = 1/5{
		replace infowebsite = 1 if end_b1a_webinfo_`i' == 1
		}

replace infowebsite = . if end_b1a_webinfo_1 == .

gen info_website_piliwork = end_b1a_webinfo_1 == 1 | end_b1a_webinfo_3 == 1
	replace info_website_piliwork = . if end_b1_whereinfo_1 == .

gen info_website_other = end_b1a_webinfo_2 == 1 | end_b1a_webinfo_4 == 1 | end_b1a_webinfo_5 == 1 | end_b1a_webinfo_1 == 1
	replace info_website_other = . if end_b1_whereinfo_1 == .

gen infopilijobs = end_b1a_webinfo_3 == 1
	replace infopilijobs = . if end_b1_whereinfo_1 == .


/* Contact POEA - end_g10_license_4 = other, end_g10_license_5 = DK*/


forval i = 1/5{
recode end_g10_license_`i' 8 = .
recode end_g10_license_`i' 2 = 0

recode end_g10_poeahow_`i' 8 = .
recode end_g10_poeahow_`i' 2 = 0
}

 
 decode end_g10_license_s,gen(endg10_spec)
 replace end_g10_license_1 = 1 if regexm(endg10_spec,"POEA")
 
 tabstat end_g10_license*

// 5. -	Whether respondent reports “Contact POEA” as a way to check whether a recruitment agency is licensed (follow-up FULL  G10)
// Note that 4 is other, 5 = DK, 1 is POEA
 gen info_contpoea = 0 if end_g10_license_1 != .
 replace info_contpoea = 1 if end_g10_license_1 ==1 
 tab info_contpoea,mi

/* Contact POEA - end_g10_poeahow_4 = other, end_g10_poeahow_5 = DK*/
forval i = 1/5{
recode end_g10_poeahow_`i' 8 = .
recode end_g10_poeahow_`i' 88 = .
}
gen poea_callweb = 1 if end_g10_poeahow_1 == 1 | end_g10_poeahow_3 == 1
replace poea_callweb = 0 if info_contpoea == 0 | (info_contpoea == 1 & end_g10_poeahow_1 != 1 & end_g10_poeahow_3 != 1)


/* Knows where to borrok P50k */ 

gen info_borrow = end_g21_b 
recode info_borrow 2 = 0
recode info_borrow -2 = 0
recode info_borrow -1 = 0
recode info_borrow 88 = .


/* Normalized difference between interest rate to borrow P50k and interest rate of 2.5%/month*/


/* Know where to apply for passport */ 
forval i = 1/6{
recode end_i5_wherepass_`i' 2 = 0
recode end_i5_wherepass_`i' 8 = .
}			// 5 is other 


/* Checked in .ent file 
	1 = DOLE/PESO
	2 = POEA
	3 = Travel agency
	4 = DFA - CORRECT
	5 = Other
	6 = DK
	*/ 
decode end_i5_wherepass_spec,gen(end_i5_wherespec)

gen know_passapply = end_i5_wherepass_4 == 1
	replace know_passapply = 1 if regexm(end_i5_wherespec,"DFA") == 1
	replace know_passapply = . if end_stype != "FULL" | end_i5_wherepass_4 == .
*	replace know_passapply = . if end_stype != "FULL" | end_i5_wherepass_4 == 8

gen know_passapply2 = know_passapply
	replace know_passapply2 = 1 if regexm(end_i5_wherespec,"LEGASPI") | regexm(end_i5_wherespec,"LEGAZPI")


/* Know how much a passport costs 
	True: P950 - regular, P1200 expedited 
	*/ 
	
gen know_passcost = end_i6 >=950 & end_i6 <=1200
	replace know_passcost = . if end_stype != "FULL" 
	
	/* Name at least one of many required documents for passport */ 
forval i = 1/9{
rename end_i4_whatdocs_0`i' end_i4_whatdocs_`i'
}

forval i = 1/24{
recode end_i4_whatdocs_`i' 2 = 0
recode end_i4_whatdocs_`i' 8 = .
recode end_i4_whatdocs_`i' 8888 = .

		}
		
gen know_passdocs =  end_i4_whatdocs_1 == 1 | end_i4_whatdocs_2 == 1 | end_i4_whatdocs_13 == 1 // BC or NBI
	replace know_passdocs = . if end_stype != "FULL" | end_i4_whatdocs_1 == .	



/* How interested - endline: end_howinteret */

gen end_someinterest = 1 if end_g12_howinterest < 5 & end_g12_howinterest != .
	replace end_someinterest = 0 if end_g12_howinterest == 5
gen end_interest = 1 if end_g12_howinterest <=2 & end_g12_howinterest != .
	replace end_someinterest = 0 if end_g12_howinterest >2 & end_g12_howinterest <=5
	
gen end_selfdeploy = end_g18
recode end_selfdeploy -2 = .
recode end_selfdeploy -1 = .
recode end_selfdeploy 888 = .
recode end_selfdeploy 88 = . // confusing, but equals 88 for both g18 and g17

gen end_selfoffer = end_g16
recode end_selfoffer -2 = .
recode end_selfoffer -1 = .
recode end_selfoffer 888 = .
recode end_selfoffer 88 = .
		
		
/* Midline - knowldege */ 

//mid_know_lend50k _rate50k mid_know_norm50k mid_placementfee mid_placement_norm mid_othrplace mid_othrplace_norm mid_dkwage mid_avgwagecountry mid_dkcost mid_avgcostcountry

gen mid_know_lend50k = bench_d13_know_lender == 1
	replace mid_know_lend50k = . if bench_d13 == 9 | bench_d13 == .

gen _rate50k = bench_d15_i if bench_d15_i != . & bench_d15_f == 2
	replace bench_d15_i = . if bench_d15_i == -2 | bench_d15_i == 9999
replace _rate50k = bench_d15_i*2 if bench_d15_i != . & bench_d15_f == 1	/* Bi-monthly */  
replace _rate50k = bench_d15_i/3 if bench_d15_i != . & bench_d15_f == 3	/* Quarterly */  
replace _rate50k = bench_d15_i/6 if bench_d15_i != . & bench_d15_f == 4	/* 2X per year */ 
replace _rate50k = bench_d15_i/12 if bench_d15_i != . & bench_d15_f == 5	/* Annually */ 	
replace _rate50k = bench_d15_i / bench_d15_t if bench_d15_i != . & bench_d15_t != .
gen difrate50k = _rate50k - 2.5
sum difrate50k
local mean_dif = `r(mean)'
local sd_dif = `r(sd)'

gen mid_know_norm50k = (difrate50k - `mean_dif') / `sd_dif'
drop difrate50k


	
gen mid_placementfee = bench_d4_avg_placement
	replace mid_placementfee = . if bench_d4_avg_placement == -2 | bench_d4_avg_placement == 9

gen difplacement = mid_placementfee - 25000
sum difplacement
local mean_dif = `r(mean)'
local sd_dif = `r(sd)'

gen mid_placement_norm = (difplacement - `mean_dif') / `sd_dif'
drop difplacement


gen mid_dkplacementfee = bench_d4_avg_placement == -2
	replace mid_dkplacementfee = . if bench_d4_avg_placement == .
	
gen mid_othrplace = bench_d5_avg_otr_expenses
	replace mid_othrplace = . if bench_d5_avg_otr_expenses == -2	

gen difplacement = mid_othrplace - 14445
sum difplacement
local mean_dif = `r(mean)'
local sd_dif = `r(sd)'

gen mid_othrplace_norm = (difplacement - `mean_dif') / `sd_dif'
drop difplacement



/* Average wage, six countries */ 


foreach type in wage cost{

foreach var in ca sa hk ta uae{
gen _bench`type'_`var' = bench_d3_`type'_`var'

recode _bench`type'_`var' -2 = .
recode _bench`type'_`var' 9 = .
recode _bench`type'_`var' -1 = .
}
gen mid_dk`type' = 0 if bench_d3_`type'_ca != .
	replace mid_dk`type' = 1 if bench_d3_`type'_ca == -2 & bench_d3_`type'_sa == -2 & bench_d3_`type'_hk == -2 & bench_d3_`type'_ta == -2 & bench_d3_`type'_uae == -2

gen mid_avg`type'country = (_bench`type'_ca + _bench`type'_sa + _bench`type'_hk + _bench`type'_ta + _bench`type'_uae)/5

}




#delimit cr


/* Enrollment */

gen end_enroll = end_f6_enroll24
	recode end_enroll 2 = 0
	recode end_enroll 88 = .
				
			*	intensiveprep
			
				
			*		infovariables			/* Make information variables */ 
			
				
#delimit ;
gen _bencheverpass = 0 ;
	replace _bencheverpass = 1 if bench_a1_valid == 1;
gen _mi_bencheverpass = 0;
	replace _mi_bencheverpass = 1 if bench_a1_valid == . | bench_a1_valid == 9;
	
gen _pilicurrpass = 0;
	replace _pilicurrpass = 1 if pili_have_valid == 1;
gen _mi_pilicurrpass = 0;
	replace _mi_pilicurrpass = 1 if pili_have_valid == . | pili_have_valid == -999999;
	
gen _benchcurrpass = 0;
	replace _benchcurrpass = 1 if bench_a2_passport_current == 1;
gen _mi_benchcurrpass = 0;
	replace _mi_benchcurrpass = 1 if bench_a1_valid == . | bench_a1_valid == 9 | (bench_a1_valid == 1 & bench_a2_pass == 9);

gen mi_currpass = 0 if end_stype == "FULL" | end_stype == "PROXY";
	replace mi_currpass = 1 if end_currpass == .	;

				
#delimit cr


/* Merge in intended sample for intensive follow-up  */ 

merge 1:1 hhid_pjid using "$work/roster2013fup",gen(_mergeroster2013)
gen rosterfup2013 = _mergeroster2013 == 3
drop _mergeroster2013
	
	merge 1:1 hhid_pjid using "$work/FUP2013",gen(_merge2013)
		assert _merge2013 != 2
		
		
		gen fup2013 = _merge2013 == 3
		drop _merge2013
		
		
tab adjust_id	if fup2013 == 1	// 21 potential issues, though 10 of them are just replacing a missing value
// Check any where the status changed - could be because offer changed
*list hhid_pjid adjust_id a_status* if adjust_id > 0 & fup2013 == 1		// one is 2 and one is 3
// Check 1st because only 1 enry for these
*list hhid_pjid adjust_id a_status* pid_1_F13 end_e3_pid_1 r_pid if adjust_id > 0 & fup2013 == 1		// one is 2 and one is 3

replace pid_1_F13 = 5 if hhid_pjid == "N0090_BL9999" 		// Adjust pid to match earlier change

assert pid_1_F13 == end_e3_pid_1 if adjust_id > 0 & fup2013 == 1 & hhid_pjid != "N0107_BA9999"
// Only 2 are different - and that' N0107_BA9999 becuase missing at end_e3_pid_1 , because that section is blank
// The main one is N0090_BL! 



//
		
		

// Clean 2013 follow-up data

gen stype_F13 = "FULL" if a1_whoint_F13 == 1
	replace stype_F13 = "PROXY" if a1_whoint_F13 == 2 | a1_whoint_F13 == 3

tab stype_F13
forval i = 1/3{
tab a_status_`i' // Note that 83% of the first offers are good , 3% DK, 10% correct but details wrong 2% error
}

tab c9_offers			// 25% had new offers that were not listed 

assert a1_whoint != . if fup2013 == 1

tab a_status_1 if fup2013 == 1,mi 

list a_status_1 hhid_pjid if fup2013 == 1 & (a_status_1  < 1 | a_status_1 > 3 )

/*Definitions
	resp_anymig_orig = any offer in endline survey that is confirmed as having led to migration
	resp_anymig_rev = equals resp_anymig_orig, then addsany offer that led to migration in the follow-up that wasn't listed in the endline 
	resp_anymig_origbroad = 1 if resp_anymig_orig == 1 or resp_ofwmigrate == 1  (the offer led to migration was confirmed, or was confirmed in the endline)
	
	Use resp_anymig_orig
	*/ 
// Generate new outcome variables  - HOUSEHOLD LEVEL
foreach var in anymig_orig newmig anymig_pending{	
gen hh_`var' = 0 if (end_stype  == "FULL" | end_stype == "PROXY") 
}

forval i = 1/3{
replace hh_anymig_orig = 1 if b4_migrate_`i' == 1
replace hh_newmig = 1 if d8_migrate_`i' == 1		// 10% new mig
replace hh_anymig_pending = 1 if b4_migrate_`i' == 3

}

tab hh_anymig_orig	if fup2013 == 1		// 36% migrated - not super high. 
tab hh_newmig if fup2013 == 1
tab hh_anymig_orig hh_newmig	if fup2013 == 1	// 42% any migratino - with new ones. 


tab hh_ofwmigrate hh_anymig_orig

gen hh_anymig_2013fup = (hh_anymig_orig == 1 | hh_newmig == 1) & (end_stype  == "FULL" | end_stype == "PROXY")
gen hh_anymig_origbroad = (hh_anymig_orig == 1 | hh_ofwmigrate == 1) & (end_stype  == "FULL" | end_stype == "PROXY")


replace hh_anymig_2013fup = . if end_stype == "LOG" 
replace hh_anymig_origbroad = . if end_stype == "LOG" 


tab hh_ofwmigrate hh_anymig_2013fup		// 28 new, 8 missing 

gen hh_anymig_revise = hh_anymig_orig

// Revise HH outcome if there was an offer, but the status was different than anticipate 
gen varX = 0
forval i = 1/3{
forval j= 1/3{
replace varX = 1 if a_status_`i' != 1 & pid_`i'_F13  == dt2_pid_`j'_F13 & d8_migrate_`j' == 1
list a_status* a_position* a_country* a_offerdate* pid*F13 d2*F13 d3*F13 d4*F13 d8_migrate* d1_pid*F13 dt2*F13 hhid_pjid if a_status_`i' != 1 & pid_`i'_F13  == dt2_pid_`j'_F13 & a_offerdate_yyyy_`i' == d2_offerdate_yyyy_`j'& d8_migrate_`j' == 1
replace hh_anymig_revise = 1 if a_status_`i' != 1 & pid_`i'_F13  == dt2_pid_`j'_F13 & a_offerdate_yyyy_`i' == d2_offerdate_yyyy_`j'& d8_migrate_`j' == 1
*list hhid_pjid if a_status_`i' != 1 & pid_`i'_F13  == dt2_pid_`j'_F13 & d8_migrate_`j' == 1
}
}




// Tab migration in E4 vs. E3? 
gen e4mig = 0
forval i = 1/3{
replace e4mig = 1 if end_e4a_pid_`i' != .
}
tab e4mig hh_ofwmig
tab e4mig hh_ofwmig if rosterfup2013 == 0


// Generate new outcome variables  - RESPONDENT

	// Generate pid for offers A, B, C - in lines B1 B2 B3 
	

	gen pid_A_F13 = pid_1_F13
	gen pid_B_F13 = pid_2_F13
	gen pid_C_F13 = pid_3_F13
		forval i = 1/3{
			gen pid_b_`i'_F13 = .
				foreach letter in A B C{
						replace pid_b_`i'_F13 = pid_`letter'_F13 if bofferlet_`i'_F13 == "`letter'"

		}
		}
				
		
foreach var in anymig_orig newmig anymig_pending{	
gen resp_`var' = 0 if (end_stype  == "FULL" | end_stype == "PROXY")  & _m_rpid == 0
}
forval i = 1/3{
replace resp_anymig_orig = 1 if b4_migrate_`i' == 1 & pid_b_`i'_F13 == r_pid
replace resp_newmig = 1 if d8_migrate_`i' == 1	& dt2_pid_`i'_F13  == r_pid	// 10% new mig
replace resp_anymig_pending = 1 if b4_migrate_`i' == 3 & pid_b_`i'_F13 == r_pid

}
	
		
gen resp_anymig_2013fup = (resp_anymig_orig == 1 | resp_newmig == 1) & (end_stype  == "FULL" | end_stype == "PROXY")
gen resp_anymig_origbroad = (resp_anymig_orig == 1 | resp_ofwmigrate == 1) & (end_stype  == "FULL" | end_stype == "PROXY")

replace resp_anymig_origbroad = . if end_stype == "LOG" | _m_rpid == 1
replace resp_anymig_2013fup = . if end_stype == "LOG"  | _m_rpid == 1


gen resp_anymig_revise = resp_anymig_orig

// Revise HH outcome if there was an offer, but the status was different than anticipate 
drop varX
gen varX = 0
forval i = 1/3{
forval j= 1/3{
replace varX = 1 if a_status_`i' != 1 & pid_`i'_F13  == dt2_pid_`j'_F13 & d8_migrate_`j' == 1 & pid_`i'_F13 == r_pid
list hhid_pjid  r_pid a_status* a_position* a_country* a_offerdate* pid*F13 d2*F13 d3*F13 d4*F13 d8_migrate* d1_pid*F13 dt2*F13 if a_status_`i' != 1 & pid_`i'_F13  == dt2_pid_`j'_F13 & a_offerdate_yyyy_`i' == d2_offerdate_yyyy_`j' & pid_`i'_F13 == r_pid & d8_migrate_`j' == 1
replace resp_anymig_revise = 1 if a_status_`i' != 1 & pid_`i'_F13  == dt2_pid_`j'_F13 & a_offerdate_yyyy_`i' == d2_offerdate_yyyy_`j'& d8_migrate_`j' == 1 & r_pid == pid_`i'_F13
}
}




save "$output_dta/endline1_w2013fup",replace





