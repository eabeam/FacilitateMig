#delimit ;
cap program drop countryreg;

program define countryreg;
	args country i newcountry newreg;



gen `newcountry'`i' = `country'`i';
gen `newreg'`i' = "";
replace `newcountry'`i' = "DK/MISSING" if `country'`i' == "-2" | `country'`i' == "8888" | `country'`i' == "DOMESTIC HELPER"  | `country'`i' == "14";
replace `newcountry'`i' = "REGION/INTERNATIONAL" if regexm(`country'`i',"ASIA") | `country'`i' == "MIDDLE EAST"| `country'`i' == "EUROPE"
											| regexm(`country'`i',"INTERNATIONAL") ;
replace `newcountry'`i' = "BAHRAIN" if regexm(`country'`i',"BHARAIN");

replace `newcountry'`i' = "UAE" if regexm(`country'`i',"ABU DHABI") | regexm(`country'`i',"DUBAI") 
									| regexm(`country'`i',"UNITED ARAB") | regexm(`country'`i',"DHUBAI")| regexm(`country'`i',"DUABI");
replace `newcountry'`i' = "QATAR" if regexm(`country'`i',"QUATAR");
replace `newcountry'`i' = "KSA" if regexm(`country'`i',"KSA") | regexm(`country'`i',"JEDDAH")  | regexm(`country'`i',"JEDAH");
replace `newcountry'`i' = "KSA" if regexm(`country'`i',"RIYADH") | regexm(`country'`i',"SAUDI") |regexm(`country'`i',"JUBAIL") ;
replace `newcountry'`i' = "MACAU" if regexm(`country'`i',"MACAU") ;

replace `newcountry'`i' = "UK" if regexm(`country'`i',"U.K") | regexm(`country'`i',"LONDON") ;
replace `newcountry'`i' = "USA" if regexm(`country'`i',"UNITED STATES") | regexm(`country'`i',"FLORIDA")| regexm(`country'`i',"HAWAI") ;
replace `newcountry'`i' = "TAIWAN" if regexm(`country'`i',"TAIWAN");	/* One is "TAIWAN SINGAPORE" Code as "TAIWAN"*/;

replace `newcountry'`i' = "SINGAPORE" if regexm(`country'`i',"SINGAPORE");	/* One is "SINGAPORE/CANADA" Code as "SINGAPORE"*/;
replace `newcountry'`i' = "HONGKONG" if regexm(`country'`i',"HONGKONG");	/* One is "HONGKONG/KUWAIT" Code as "HONGKONG"*/;
replace `newcountry'`i' = "GERMANY" if regexm(`country'`i',"GERMAN");

replace `newcountry'`i' = "NETHERLANDS" if regexm(`country'`i',"AMSTERDAM");

replace `newcountry'`i' = trim(`newcountry'`i');

replace `newreg'`i' = "MIDDLE EAST" if `country'`i' == "MIDDLE EAST";
replace `newreg'`i' = "EUROPE" if `country'`i' == "EUROPE";
replace `newreg'`i' = "ASIA" if regexm(`country'`i',"ASIA");

foreach place in UAE QATAR KSA ISRAEL LEBANON KUWAIT IRAN BAHRAIN OMAN LIBYA{;
replace `newreg'`i' = "MIDDLE EAST" if `newcountry'`i' == "`place'";
};

foreach place in CANADA USA{;
replace `newreg'`i' = "NORTH AMERICA" if `newcountry'`i' == "`place'";
};
foreach place in UK ITALY CYPRUS GERMANY NETHERLANDS {;
replace `newreg'`i' = "EUROPE" if `newcountry'`i' == "`place'";
};
foreach place in MACAU THAILAND TAIWAN SINGAPORE KOREA CHINA HONGKONG MALAYSIA CAMBODIA JAPAN{;
replace `newreg'`i' = "ASIA" if `newcountry'`i' == "`place'";
};
foreach place in AUSTRALIA "PAPUA NEW GUINEA" GUAM{;
replace `newreg'`i' = "AUSTRALIA/PACIFIC" if `newcountry'`i' == "`place'";
};
replace `newreg'`i' = "DK/MISSING/INTERNATIONAL" if `newcountry'`i' == "DK/MISSING" | regexm(`newcountry'`i',"INTERNATIONAL");

tab `newcountry'`i' if `newreg'`i' == "";

end;
