use "$specdata",clear

$drop1
$samplet

keep if end_stype != "LOG" & end_stype != ""

// Make sure the pending is coded

/* HH together, and respondents only */ 


*list  end_e3c_*1 end_e3h_*1 if resp_ofwoffer_no == 1		// view things 

keep if hh_ofwoffer_nopend == 1

cap label drop notaccept
#delimit ;

label define notaccept 	1 "Not interested in type of work" 2 "Not interested country" 
						3 "No longer interested in/want to work abroad" 4 "Salary too low" 5 "Could not afford expenses" 
						6 "Did not pass medical exam/health problems" 7 "Training not completed" 8 "Family obligations" 
						9 "Other" 10 "Pending" 11 "Documentation Problem" 12 "Prob. with offer" 13 "Prob. with qual." 88 "Missing";
						
label define notattend 1 "Not interested in type of work" 2 "Not interested country" 
						3 "Not interested working abroad" 4 "Insufficient funds" 
						5 "Family obligations" 6 "Other" 88 "Missing";



forval i = 1/3{;

gen _whynotaccept_`i' =  end_e3c_whynotcode_`i';
gen _whynotmig_`i' = end_e3h_why_`i';
decode end_e3c_whynotspec_`i',gen(_whynotaccept_spec_`i');
gen _whynotmig_spec_`i' = end_e3h_whynot`i';
};


	#delimit ;					
forval i = 1/3{;
foreach type in mig accept{;

list _whynot`type'_spec_`i' _whynot`type'_`i' if regexm(_whynot`type'_spec_`i',"AFRAID") | regexm(_whynot`type'_spec_`i',"COMPANIONS");
};

gen respoffer_`i' = 0;
gen hhoffer_`i' = 0;

};

*exit; 


forval i = 1/3{;


foreach type in mig accept{;
/* Coding */ ;

/* Not interested in country*/;
replace _whynot`type'_`i' = 2 if _whynot`type'_spec_`i' == "SAUDI ARABIA"; 
replace _whynot`type'_spec_`i' = "" if _whynot`type'_spec_`i' == "SAUDI ARABIA"; 


/* 3 = Not interested in working abroad */; 

replace _whynot`type'_`i' = 3 if regexm(_whynot`type'_spec_`i',"CURRENTLY WORKING") | regexm(_whynot`type'_spec_`i',"ENROLL");
replace _whynot`type'_spec_`i' = "" if regexm(_whynot`type'_spec_`i',"CURRENTLY WORKING") | regexm(_whynot`type'_spec_`i',"ENROLL");


/* Afaid/companaions back out*/;
replace _whynot`type'_`i' = 3 if regexm(_whynot`type'_spec_`i',"AFRAID") | regexm(_whynot`type'_spec_`i',"COMPANIONS");
replace _whynot`type'_spec_`i' = "" if regexm(_whynot`type'_spec_`i',"AFRAID") | regexm(_whynot`type'_spec_`i',"COMPANIONS");


/* 5 =  Financies */;
replace _whynot`type'_`i' = 5 if regexm(_whynot`type'_spec_`i',"FINAN") | regexm(_whynot`type'_spec_`i',"PLACEMENT FEE");
replace _whynot`type'_spec_`i' = "" if regexm(_whynot`type'_spec_`i',"FINAN") | regexm(_whynot`type'_spec_`i',"PLACEMENT FEE");


/* 6 = Health*/; 

replace _whynot`type'_`i' = 6 if regexm(_whynot`type'_spec_`i',"SICK") | regexm(_whynot`type'_spec_`i',"DENGUE") 
							| _whynot`type'_spec_`i' == "PREGNANT" | _whynot`type'_spec_`i' == "HEALTH PROBLEM";
replace _whynot`type'_spec_`i' = "" if regexm(_whynot`type'_spec_`i',"SICK") | regexm(_whynot`type'_spec_`i', "DENGUE") 
							| _whynot`type'_spec_`i' == "PREGNANT" | _whynot`type'_spec_`i' == "HEALTH PROBLEM";

/* 8 = Family*/;

replace _whynot`type'_`i' = 8 if regexm(_whynot`type'_spec_`i',"HUSBAND") |  regexm(_whynot`type'_spec_`i',"WIFE");
replace _whynot`type'_spec_`i' = "" if regexm(_whynot`type'_spec_`i',"HUSBAND") |  regexm(_whynot`type'_spec_`i',"WIFE");


/* 10 = Pending*/ ;

replace _whynot`type'_`i' = 10 if regexm(_whynot`type'_spec_`i',"WAIT") | regexm(_whynot`type'_spec_`i',"PEND") | regexm(_whynot`type'_spec_`i',"NAGHIHIN");;
replace _whynot`type'_spec_`i' = "" if regexm(_whynot`type'_spec_`i',"WAIT") | regexm(_whynot`type'_spec_`i',"PEND") | regexm(_whynot`type'_spec_`i',"NAGHIHIN");;

replace _whynot`type'_`i' = 10 if  _whynot`type'_spec_`i' == "PASSPORT ALREADY SUBMITTED" 
	| _whynot`type'_spec_`i' ==  "PROCESS MEDICAL EXAM" |  word(_whynot`type'_spec_`i',1) == "INTERVIEWED";

replace _whynot`type'_spec_`i' = "" if _whynot`type'_spec_`i' == "PASSPORT ALREADY SUBMITTED" 
	| _whynot`type'_spec_`i' ==  "PROCESS MEDICAL EXAM" |  word(_whynot`type'_spec_`i',1) == "INTERVIEWED";


/* 11 = Documentation Problems */;

replace _whynot`type'_`i' = 11 if regexm(_whynot`type'_spec_`i',"BIRTH CER")  
		| _whynot`type'_spec_`i' == "PROBLEMS IN HER DOCUMENTS"  | _whynot`type'_spec_`i' == "NO PASSPORT";
replace _whynot`type'_spec_`i' = "" if regexm(_whynot`type'_spec_`i',"BIRTH CER") 
		| _whynot`type'_spec_`i' == "PROBLEMS IN HER DOCUMENTS"  | _whynot`type'_spec_`i' == "NO PASSPORT";

/* 12 = Problem with offer (conflict, banned, fell through, etc.)  */;
replace _whynot`type'_`i' = 12 if _whynot`type'_spec_`i' == "BANNED" | regexm(_whynot`type'_spec_`i',"TERMS IN CONTRACT IS DIFFERENT") 
								| regexm(_whynot`type'_spec_`i',"CONFLICT")  | regexm(_whynot`type'_spec_`i',"FLIGHT")
							| regexm(_whynot`type'_spec_`i',"WAR IN LIBYA") | regexm(_whynot`type'_spec_`i',"TSUNAMI") ;
replace _whynot`type'_spec_`i' = "" if _whynot`type'_spec_`i' == "BANNED" | regexm(_whynot`type'_spec_`i',"TERMS IN CONTRACT IS DIFFERENT") 
								| regexm(_whynot`type'_spec_`i',"CONFLICT")  | regexm(_whynot`type'_spec_`i',"FLIGHT")
							| regexm(_whynot`type'_spec_`i',"WAR IN LIBYA") | regexm(_whynot`type'_spec_`i',"TSUNAMI") ;



/* 13 = Problem with qualifications (age, experience)  */;
replace _whynot`type'_`i' = 13 if _whynot`type'_spec_`i' == "OVER AGE" | _whynot`type'_spec_`i' == "(AGE PROBLEM)" | regexm(_whynot`type'_spec_`i',"AGENCY REFUSED") 
								| _whynot`type'_spec_`i' == "LACK OF EXPERIENCE" |  _whynot`type'_spec_`i' == "VERY YOUNG" | regexm(_whynot`type'_spec_`i',"AGENCY WANT ABLE")
								| _whynot`type'_spec_`i' == "WASNT CONTACTED";
replace  _whynot`type'_spec_`i' = "" if _whynot`type'_spec_`i' == "OVER AGE" | _whynot`type'_spec_`i' == "(AGE PROBLEM)" | regexm(_whynot`type'_spec_`i',"AGENCY REFUSED") 
								| _whynot`type'_spec_`i' == "LACK OF EXPERIENCE" |  _whynot`type'_spec_`i' == "VERY YOUNG" | regexm(_whynot`type'_spec_`i',"AGENCY WANT ABLE")
								| _whynot`type'_spec_`i' == "WASNT CONTACTED";
				

/* Missing*/;
replace _whynot`type'_`i' = 88 if _whynot`type'_`i' == 9 & _whynot`type'_spec_`i' == "8888";
replace _whynot`type'_spec_`i' = "" if _whynot`type'_`i' == 88 & _whynot`type'_spec_`i' == "8888";

replace _whynot`type'_spec_`i' = "" if _whynot`type'_`i' != 9 & _whynot`type'_`i' <=11  & (_whynot`type'_spec_`i' == "8888" | _whynot`type'_spec_`i' == "5");
};

gen _whynot_acceptmig_`i' = _whynotmig_`i';
	replace _whynot_acceptmig_`i' = _whynotaccept_`i' if _whynotmig_`i' == . | _whynotmig_`i' == 88;



tab _whynot_acceptmig_`i';
list _whynotmig_*`i' _whynotaccept_*`i' if _whynotmig_spec_`i' != "" | _whynotaccept_spec_`i' != "" ;


replace respoffer_`i' = 1 if _whynot_acceptmig_`i' != . & r_pid == end_e3_pid_`i';
replace hhoffer_`i' = 1 if _whynot_acceptmig_`i' != .;

};

;
/* Reshape respondent offers into universe of respondent offers */ 

reshape long _whynot_acceptmig_ hhoffer_ respoffer_ _whynotaccept_ _whynotmig_ ,i(hhid_pjid) j(offerno);
foreach var in _whynot_acceptmig respoffer hhoffer _whynotaccept _whynotmig{;
rename `var'_ `var';
};

label values _whynotmig notaccept;
label values _whynotaccept notaccept;
label values _whynot_acceptmig notaccept;

keep if hhoffer == 1;


tab _whynot_acceptmig if respoffer == 1;

tab _whynot_acceptmig if hhoffer == 1;

exit;

/* Follow-up survey responses - confirmed offers */ 




#delimit ;
use "$specdata",clear;

keep if fup2013 == 1;



*d7_whynotaccept_1 d7_whynot_spec_1 d9_whynotmigrate_1 d9_whynotmigrate_spec_1;










tab end_e3h_whynotspec_1  if _whynotmig == 9

*******
tab _whynotaccept hh_ofwn,mi
list end_e3c_whynotspec* if _whynotaccept  == 9

tab _whynotmig hh_ofwoffern
tab _whynotmig if hh_ofwoffern == 1,mi

list end_e3h_whynotspec_1  if _whynotmig == 9


exit
******* Why ot attend interview *******


forval i = 1/3{
decode end_e2c_whynotspec_`i',gen(_end_e2c_whynotspec_`i')
gen _whynotattend`i' = end_e2c_whynotcode_`i'
label values _whynotattend`i' notattend
replace _whynotattend`i' = 88 if _end_e2c_whynotspec_`i' == "8888"
replace _whynotattend`i' = 7 if _end_e2c_whynotspec_`i' == "NO PASSPORT" | _end_e2c_whynotspec_`i' == "NO PASSPORT HEALTH PROBLEM"
replace _whynotattend`i' = 3 if _end_e2c_whynotspec_`i' == "NOT INTERESTED GOING ABROAD"
replace _whynotattend`i' = 88 if _end_e2c_whynotspec_`i' == "" & _whynotattend`i' == 6

}
replace _whynotattend1 = _whynotattend2 if _whynotattend1 == .
replace _whynotattend1 = _whynotattend3 if _whynotattend1 == .

tab _whynotattend1 if hh_ofwinviten == 1,mi

list _end_e2c_whynotspec_1 if _whynotattend1 == 6
list 


exit
list end_e3b_accept* if hh_ofwaccept == 1
list end_e3c_whynotcode_* if hh_ofwaccept == 0 & hh_ofwoffer == 1
list hh_ofwaccept end_e3h_why_* if hh_ofwmig == 0 & hh_ofwoffer == 1








************	Average migration income **********


use "$specdata",clear

$drop1
$samplet

keep if end_stype != "LOG" & end_stype != ""
keep end* hhid_pjid resp_* r_pid

keep if resp_ofwmigrate == 1


reshape long end_e4d_migcountry_ end_e4e_midincome_ end_e4f_borrow_ end_e4a_pid_,i(hhid_pjid) j(order)

keep if r_pid == end_e4a_pid_

drop if end_e4e_midincome_ == -2 | end_e4e_midincome_ == -1
egen senum = seq(),by(hhid_pjid)
drop if senum == 2
drop senum

sum end_e4e_midincome,d


foreach var in _whynot_acceptmig respoffer hhoffer _whynotaccept _whynotmig{;
rename `var'_ `var';
};




