#delimit ;
cap program drop whynot_74joboffer;

program define whynot_74joboffer;
	args whynot i;

	
	
	* Coding */ ;

/* Not interested in country*/;
replace `whynot'`i' = 2 if `whynot'spec_`i' == "SAUDI ARABIA"; 
replace `whynot'spec_`i' = "" if `whynot'spec_`i' == "SAUDI ARABIA"; 


/* 3 = Not interested in working abroad */; 

replace `whynot'`i' = 3 if regexm(`whynot'spec_`i',"CURRENTLY WORKING") | regexm(`whynot'spec_`i',"ENROLL");
replace `whynot'spec_`i' = "" if regexm(`whynot'spec_`i',"CURRENTLY WORKING") | regexm(`whynot'spec_`i',"ENROLL");


/* Afaid/companaions back out*/;
replace `whynot'`i' = 3 if regexm(`whynot'spec_`i',"AFRAID") | regexm(`whynot'spec_`i',"COMPANIONS");
replace `whynot'spec_`i' = "" if regexm(`whynot'spec_`i',"AFRAID") | regexm(`whynot'spec_`i',"COMPANIONS");


/* 5 =  Financies */;
replace `whynot'`i' = 5 if regexm(`whynot'spec_`i',"FINAN") | regexm(`whynot'spec_`i',"PLACEMENT FEE");
replace `whynot'spec_`i' = "" if regexm(`whynot'spec_`i',"FINAN") | regexm(`whynot'spec_`i',"PLACEMENT FEE");


/* 6 = Health*/; 

replace `whynot'`i' = 6 if regexm(`whynot'spec_`i',"SICK") | regexm(`whynot'spec_`i',"DENGUE") 
							| `whynot'spec_`i' == "PREGNANT" | `whynot'spec_`i' == "HEALTH PROBLEM";
replace `whynot'spec_`i' = "" if regexm(`whynot'spec_`i',"SICK") | regexm(`whynot'spec_`i', "DENGUE") 
							| `whynot'spec_`i' == "PREGNANT" | `whynot'spec_`i' == "HEALTH PROBLEM";

/* 8 = Family*/;

replace `whynot'`i' = 8 if regexm(`whynot'spec_`i',"HUSBAND") |  regexm(`whynot'spec_`i',"WIFE");
replace `whynot'spec_`i' = "" if regexm(`whynot'spec_`i',"HUSBAND") |  regexm(`whynot'spec_`i',"WIFE");


/* 10 = Pending*/ ;

replace `whynot'`i' = 10 if regexm(`whynot'spec_`i',"WAIT") | regexm(`whynot'spec_`i',"PEND") | regexm(`whynot'spec_`i',"NAGHIHIN");;
replace `whynot'spec_`i' = "" if regexm(`whynot'spec_`i',"WAIT") | regexm(`whynot'spec_`i',"PEND") | regexm(`whynot'spec_`i',"NAGHIHIN");;

replace `whynot'`i' = 10 if  `whynot'spec_`i' == "PASSPORT ALREADY SUBMITTED" 
	| `whynot'spec_`i' ==  "PROCESS MEDICAL EXAM" |  word(`whynot'spec_`i',1) == "INTERVIEWED";

replace `whynot'spec_`i' = "" if `whynot'spec_`i' == "PASSPORT ALREADY SUBMITTED" 
	| `whynot'spec_`i' ==  "PROCESS MEDICAL EXAM" |  word(`whynot'spec_`i',1) == "INTERVIEWED";


/* 11 = Documentation Problems */;

replace `whynot'`i' = 11 if regexm(`whynot'spec_`i',"BIRTH CER")  
		| `whynot'spec_`i' == "PROBLEMS IN HER DOCUMENTS"  | `whynot'spec_`i' == "NO PASSPORT" | `whynot'spec_`i' == "9 REQUIREMETS";
replace `whynot'spec_`i' = "" if regexm(`whynot'spec_`i',"BIRTH CER") 
		| `whynot'spec_`i' == "PROBLEMS IN HER DOCUMENTS"  | `whynot'spec_`i' == "NO PASSPORT" | `whynot'spec_`i' == "9 REQUIREMETS";;

/* 12 = Problem with offer (conflict, banned, fell through, etc.)  */;
replace `whynot'`i' = 12 if `whynot'spec_`i' == "BANNED" | regexm(`whynot'spec_`i',"TERMS IN CONTRACT IS DIFFERENT") 
								| regexm(`whynot'spec_`i',"CONFLICT")  | regexm(`whynot'spec_`i',"FLIGHT")
							| regexm(`whynot'spec_`i',"WAR IN LIBYA") | regexm(`whynot'spec_`i',"TSUNAMI") ;
replace `whynot'spec_`i' = "" if `whynot'spec_`i' == "BANNED" | regexm(`whynot'spec_`i',"TERMS IN CONTRACT IS DIFFERENT") 
								| regexm(`whynot'spec_`i',"CONFLICT")  | regexm(`whynot'spec_`i',"FLIGHT")
							| regexm(`whynot'spec_`i',"WAR IN LIBYA") | regexm(`whynot'spec_`i',"TSUNAMI") ;



/* 13 = Problem with qualifications (age, experience)  */;
replace `whynot'`i' = 13 if `whynot'spec_`i' == "OVER AGE" | `whynot'spec_`i' == "(AGE PROBLEM)" | regexm(`whynot'spec_`i',"AGENCY REFUSED") 
								| `whynot'spec_`i' == "LACK OF EXPERIENCE" |  `whynot'spec_`i' == "VERY YOUNG" | regexm(`whynot'spec_`i',"AGENCY WANT ABLE")
								| `whynot'spec_`i' == "WASNT CONTACTED";
replace  `whynot'spec_`i' = "" if `whynot'spec_`i' == "OVER AGE" | `whynot'spec_`i' == "(AGE PROBLEM)" | regexm(`whynot'spec_`i',"AGENCY REFUSED") 
								| `whynot'spec_`i' == "LACK OF EXPERIENCE" |  `whynot'spec_`i' == "VERY YOUNG" | regexm(`whynot'spec_`i',"AGENCY WANT ABLE")
								| `whynot'spec_`i' == "WASNT CONTACTED";
				

/* Missing*/;
replace `whynot'`i' = 88 if `whynot'`i' == 9 & `whynot'spec_`i' == "8888";
replace `whynot'spec_`i' = "" if `whynot'`i' == 88 & `whynot'spec_`i' == "8888";

replace `whynot'spec_`i' = "" if `whynot'`i' != 9 & `whynot'`i' <=11  & (`whynot'spec_`i' == "8888" | `whynot'spec_`i' == "5");

end;
