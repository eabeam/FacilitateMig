
/****************************
A5-A8_JobOfferCharacteristics.do 
Unilateral Facilitation Does Not Increase Migration 
Emily A. Beam, David McKenzie, and Dean Yang 

Last updated 05 June 2018 by Emily Beam (emily.beam@uvm.edu) 

This file generates Appendix Tables A5-A8.

Note that the following swapspec command should be run first:  
swapspec  attritfull baselineno4145 ascending15 nopval 

Additionally, the following data cleaning programs should be run first 

do "$table/countryreg.do"
do "$table/position_74joboffer.do"
do "$table/whynot_74joboffer.do"

****************************/


use "$specdata",clear

$drop1
$samplet

*Drop unused variables
drop base* bench* pili* end_c* end_a* end_d* end_f* end_b* end_g* end_h* end_i* end_j* end_k* bg* a* c* d*  yy* qq* b* f* _b* i* _end*
keep if end_stype != "LOG" & end_stype != ""


tab hh_ofwoffer hh_ofwoffer_nopend

*keep if hh_ofwoffer == 1
keep if hh_ofwoffer == 1 | hh_ofwoffer_nopend == 1	// Keep any offer (includgin some that are listed as "pending" at the time of the endline
						
							

cap label drop notaccept
cap label drop notattend
cap label drop migoutcome
#delimit ;

label define notaccept 	1 "Not interested in type of work" 2 "Not interested country" 
						3 "No longer interested in/want to work abroad" 4 "Salary too low" 5 "Could not afford expenses" 
						6 "Did not pass medical exam/health problems" 7 "Training not completed" 8 "Family obligations" 
						9 "Other" 10 "Pending" 11 "Documentation Problem" 12 "Prob. with offer" 13 "Prob. with qual." 88 "Missing";
						
label define notattend 1 "Not interested in type of work" 2 "Not interested country" 
						3 "Not interested working abroad" 4 "Insufficient funds" 
						5 "Family obligations" 6 "Other" 88 "Missing";

/* Note that if not accept, then not pending */ ;
label define migoutcome 1 "Migrate"  2 "Accept, pending"  3 "Accept, not migrate" 4 "Not accept, not migrate" 5 "Missing e3" 6 "Missing, e1only";
 /* Define blank variables */ 

forval i = 1/3{;
recode end_e3_pid_`i' 88 = .;				// recode this one.; 
gen _JO_whynotaccept_`i' 	=  	end_e3c_whynotcode_`i';
gen _JO_whynotmig_`i' 		= 	end_e3h_why_`i';
	
decode end_e3c_whynotspec_`i',gen(_JO_whynotaccept_spec_`i');

gen _JO_whynotmig_spec_`i' = end_e3h_whynot`i';

decode end_e3e_posname_`i',gen(_JO_posname`i');

gen _JOrespoffer_whynot_`i' = 0;
gen _JOhhoffer_whynot_`i' = 0;

gen _JOrespoffer_anyoff_`i' = 0;
	replace _JOrespoffer_anyoff_`i' = 1 if r_pid == end_e3_pid_`i';

gen _JOoffer_outcome`i' = .;
	replace _JOoffer_outcome`i' = 1 if end_e3g_migrate_`i' == 1 &  end_e3b_accept_`i' == 1;
	replace _JOoffer_outcome`i' = 2 if end_e3g_migrate_`i' == 3 &  end_e3b_accept_`i' == 1;
	replace _JOoffer_outcome`i' = 3 if end_e3g_migrate_`i' == 2 &  end_e3b_accept_`i' == 1;
	replace _JOoffer_outcome`i' = 4 if end_e3b_accept_`i' == 2								;
	replace _JOoffer_outcome`i' = 5 if end_e3_pid_`i' != .  & _JOoffer_outcome`i' == .;
	replace _JOoffer_outcome`i' = 6 if end_e1h_offer_`i' == 1 & _JOoffer_outcome`i' == .;
gen _JOoffer_no_or_pending_`i' = ((end_e3g_migrate_`i' == 2 | end_e3g_migrate_`i' == 3) & end_e3b_accept_`i' == 1) | end_e3b_accept_`i' == 2;
 tab  _JOoffer_outcome`i' hh_ofwoffer_nopend,mi;
 tab  _JOoffer_outcome`i' end_e3_pid_`i',mi;
 
 *pause;

};

forval i = 1/3{;

* Clean country/region name;
qui countryreg end_e3f_country_ `i' _JO_poscountry _JO_posregion;		

replace _JO_poscountry`i' = "SINGAPORE" if _JO_posname`i' == "SINGAPORE";
replace _JO_posname`i' = "DH" if _JO_posname`i' == "SINGAPORE";

tab _JO_poscountry`i';
tab _JO_posregion`i';

*Clean position name;
qui position_74joboffer _JO_posname `i';     	

* Clean reasons why not migrated/accept;
qui whynot_74joboffer _JO_whynotmig_ `i';				
qui whynot_74joboffer _JO_whynotaccept_ `i';			


* Generate merged why not accept or migrate;
gen _JO_whynot_acceptmig_`i' = _JO_whynotmig_`i';
	replace _JO_whynot_acceptmig_`i' = _JO_whynotaccept_`i' if _JO_whynotmig_`i' == . | _JO_whynotmig_`i' == 88;


tab _JO_whynot_acceptmig_`i';
list _JO_whynotmig_*`i' _JO_whynotaccept_*`i' if _JO_whynotmig_spec_`i' != "" | _JO_whynotaccept_spec_`i' != "" ;

* Generate indicators for whether it was respondent's offer or household's offer that was not accepted;
replace _JOrespoffer_whynot_`i' = 1 if _JO_whynot_acceptmig_`i' != . & r_pid == end_e3_pid_`i';
replace _JOhhoffer_whynot_`i' = 1 if _JO_whynot_acceptmig_`i' != .;

};
;

/* Reshape offers into universe of individual-offers */ 

reshape long _JO_whynot_acceptmig_ 	_JOhhoffer_whynot_ 		_JOrespoffer_whynot_ 	_JOrespoffer_anyoff_ 	_JO_whynotaccept_ 		
			_JO_whynotaccept_spec_	_JO_whynotmig_ 			_JO_whynotmig_spec_		_JOoffer_outcome 		 
				_JO_poscountry 			_JO_posregion 			_JO_posname			_JOoffer_no_or_pending_,
		
		i(hhid_pjid) j(offerno);
		
foreach var in 	_JO_whynot_acceptmig 	_JOrespoffer_anyoff 	_JOrespoffer_whynot 	_JOhhoffer_whynot 		_JO_whynotaccept_spec	_JO_whynotmig_spec
				_JO_whynotaccept 		_JO_whynotmig 			_JOoffer_no_or_pending		 		{;
rename `var'_ `var';
};



label values _JO_whynotmig notaccept;
label values _JO_whynotaccept notaccept;
label values _JO_whynot_acceptmig notaccept;
label values _JOoffer_outcome migoutcome;

 keep _JO*;


 ***********************************
*	Appendix Table 5
*	Jobs offered abroad, by type of job
***********************************;

 tab _JO_posname if _JOrespoffer_anyoff,sort;
 
***********************************
*	Appendix Table 6
*	Jobs offered abroad, by location of position 
***********************************;

tab _JO_poscountry if _JOrespoffer_anyoff,sort;


**********************************
*	Appendix Table 7
*	Migration outcomes of all job offers as of 2012, by region
***********************************;

tab   _JO_posregion _JOoffer_outcome if _JOoffer_outcome < 5 & _JOrespoffer_anyoff;
tab   _JO_posregion _JOoffer_outcome if _JOoffer_outcome < 5 & _JOrespoffer_anyoff;


**********************************
*	Appendix Table 8
*	Reported reasons for not migrating, conditional on receiving an overseas job offer
***********************************;

*Restrict to just those values for which we have a ``why not'' response;
keep if  _JOhhoffer_whynot == 1 & _JOoffer_no_or_pending == 1;

* Generate column 1 - total;
tab _JO_whynot_acceptmig if _JOrespoffer_whynot == 1,sort;


* Generate columns 2 - 4 by region;
tab _JO_whynot_acceptmig _JO_posregion if _JOrespoffer_whynot == 1;


exit;




