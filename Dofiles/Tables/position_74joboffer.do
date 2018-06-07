


#delimit ;
cap program drop position_74joboffer;

program define position_74joboffer;
	args _posname i;


replace `_posname'`i' = "DH" if `_posname'`i' == "DOMESTIC HELPER" | regexm(`_posname'`i',"BABY");

replace `_posname'`i' = "COOK" if regexm(`_posname'`i',"COOK");
replace `_posname'`i' = "DH" if regexm(`_posname'`i',"HOUSEKEEP");

replace `_posname'`i' = "FACTORY WORKER" if regexm(`_posname'`i',"FACTORY");
replace `_posname'`i' = "TECHNICIAN" if regexm(`_posname'`i',"TECHNICIAN") | regexm(`_posname'`i',"ELECTRICIAN");

replace `_posname'`i' = "SEAMAN" if regexm(`_posname'`i',"SEAMAN");
replace `_posname'`i' = "LABOR/	CONSTRUCTION" if regexm(`_posname'`i',"LABORER") | regexm(`_posname'`i',"CONSTRUCTION");

replace `_posname'`i' = "LABOR/CONSTRUCTION" if regexm(`_posname'`i',"LABORER") | regexm(`_posname'`i',"CONSTRUCTION") | regexm(`_posname'`i',"PAINTER");
replace `_posname'`i' = "SKILLED TRADE" if regexm(`_posname'`i',"MASON") | regexm(`_posname'`i',"WELDER") | regexm(`_posname'`i',"PLUMB") 
					|  regexm(`_posname'`i',"PIPE") |regexm(`_posname'`i',"CARPENTER") ;

replace `_posname'`i' = "MECHANIC" if regexm(`_posname'`i',"MECHANIC") | regexm(`_posname'`i',"AUTOMOTIVE");

replace `_posname'`i' = "OFFICE WORKER" if regexm(`_posname'`i',"OFFICE") | regexm(`_posname'`i',"CLERK") ;

replace `_posname'`i' = "NURSE/NURSING ASST." if regexm(`_posname'`i',"NURS");
replace `_posname'`i' = "SERVICE" if regexm(`_posname'`i',"FOOD") | regexm(`_posname'`i',"SERVICE CREW") | 
			regexm(`_posname'`i',"WAITRESS") | regexm(`_posname'`i',"BAGGER") | regexm(`_posname'`i',"ENTERTAINER") 
				| regexm(`_posname'`i',"HOTEL CREW")| regexm(`_posname'`i',"MERCHANDIZER");
				
replace `_posname'`i' = "DK/MISSING" if regexm(`_posname'`i',"88") | regexm(`_posname'`i',"99") | regexm(`_posname'`i',"-2");

end;
