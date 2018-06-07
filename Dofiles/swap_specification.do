#delimit ;
************************************
* Specification Set-Up

*	Sets up specifications to select data files, weighting, etc. 
************************************;


capture program drop swapspec;
program define swapspec;
	args datafile sampletype depvars  pp;

	#delimit ;

global specdata = "$work/`datafile'";
global depvars "";
global depinteract "";
global outinteract "";
global samplet "";
global keepstatement "";
global controltype "";
global runprog "";
global ST "`sampletype'";
global DP "`depvars'";
global testinfo "";
global testpass "";

global drop1 "drop if (base_interv_base == . & baseline == 1)";


global outputspec "";
if "`pp'" == "nopval"{;
global outputspec "stat(coef se) bracket(se) nocons";	
};
if "`pp'" == "pval"{;
global outputspec "stat(coef se pval) bracket(se) paren(pval) nocons";	
};

global convars "";




**************************************************************************************************************
*	Three main sample specifications for paper: 
*			Pooled sample: union of passport sample and information web sample 
*			Passport sample: benchmark - all in midline survey, including those in baseline + benchmark, benchmark only, and passport pilot
*			Infomration/web sample: baseline - all in baseline survey
**************************************************************************************************************;


if "`sampletype'" == "benchmark"{;
global samplet  "keep if benchmarka == 1 | pilotsample == 1";
global convars "bg_BL1 bg_BL2 bg_BL3 bg_BL4 bg_BL5 bg_BLJF bg_PJMT bg_PJOT bg_PJSC bg_PILOT";	

};

if "`sampletype'" == "baseline"{;
global samplet "keep if baseline == 1";
global convars "i.bgypalfsi age4145 bg_BLONLY_2040";
};

if "`sampletype'" == "all"{;
global samplet "";
global convars " i.bgypalfsi age4145 bg_BLONLY_2040";
};

if "`sampletype'" == "allno4145"{;
global samplet "keep if age4145 == 0";
global convars "i.bgypalfsi bg_BLONLY_2040";
};

if "`sampletype'" == "baselineno4145"{;
global samplet "keep if baseline == 1 & age4145 == 0";
global convars "i.bgypalfsi bg_BLONLY_2040";
};

*********
* Treatment specifications 
**********;

if "`depvars'" == "infodummy"{;
global depvars "infotreat2 infotreat3 infotreat4 infotreat5";
global controltype "infotreat1";


};

if "`depvars'" == "infotreat"{;
global depvars  "appinfo fininfo pilijobs ";
global controltype "basecontrol";

};

if "`depvars'" == "passtreat"{;
global depvars  "benchpassassist benchpassinfo ";

global controltype "benchcontrol";


};

if "`depvars'" == "ascending"{;
global depvars "aa*_*";
global testinfo "testparm q1_ q2 q4";
global testpass "testparm q7 q8 q10";
global controltype "benchbasecontrol";
};

if "`depvars'" == "ascending15"{;
global depvars "bb*_*";

global controltype "benchbasecontrol";
};


if "`depvars'" == "passinfotreat"{;
global testpass "testparm benchpassassist benchpassinfo";

global depvars "infotreat2 infotreat3 infotreat4 infotreat5  benchpassassist benchpassinfo";
global testinfo "testparm infotreat2 infotreat3 infotreat4 infotreat5";

global controltype "benchbasecontrol";


};



global keepstatement "Data: $specdata - Samp: $samplet - Treatment: $depvars ";


di "$keepstatement";
	
	
	
	
end;
