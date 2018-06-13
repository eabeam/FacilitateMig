/*Master Analysis File 

	Data for Unilateral Facilitation Does Not Increase Migration 
	Emily A. Beam, David McKenzie, Dean Yang
			
			
	Last updated: 
	13 June 2018
	
	Code created by Emily Beam and Karl Rubio.
*/

			
set more off
version 13
****************************************
*	Install necessary packages 
****************************************
*ssc install outreg2

****************************************
*	Set global pathways 
****************************************

global path "~/Dropbox/FacilitatingMigration_replication_June2018"

* Dependent paths		
global work "$path/Data"
global dofiles "$path/Dofiles"
global output_tables "$path/Output/Tables"
global output_dta "$path/Output/IntermediateData"
global table "$path/Dofiles/Tables"

****************************************
*	Start replication log
****************************************
capture log close
log using "$path/replication", text replace

****************************************
*	Set main specifications
****************************************

global mainspec " attritfull baselineno4145 ascending15 nopval"
do "$path/Dofiles/swap_specification.do"



****************************************
*	Set covariates
****************************************

#delimit;

global covfull "female resp_age hsgrad somevoc colgradplus interested risks hhincome hhsavings zerohhsavings 
				everloan normasset immabroad extabroad edflag 
				mflag_*";
				
global cov1 "$covfull";

global cov0 "resp_age hsgrad somevoc colgradplus interested risks hhincome hhsavings zerohhsavings 
			everloan normasset immabroad extabroad hhsize r_employed applyabroad receiveremit internet";





**************************************************
*	Data Creation
**************************************************;

#delimit;
do "$path/Dofiles/1_DataCleaning";		// use merged_data_public  ** Share
										//save merged_data_public2
										
do "$path/Dofiles/2_DataCleaning";		//use merged_data_public2
										// use roster2013fup	** Share
										// use FUP2013			** Share
										// save endline1_w2013fup
										
do "$path/Dofiles/3_DataCleaning"; 		//use "$work/endline1_w2013fup",replace
										//use attritiondata		** Share
										// save attritfull



										
										
**************************************************
*	Data Analysis 
*	Uses $work/attritfull for most files 
* 	See $mainspec at top
* 	Run swap_specification prior to running analysis files
*************************************************;



#delimit;

*Figure 1;
swapspec $mainspec;
do "$table/_01_Figure.do";	

*Figure 2;
swapspec $mainspec;
do "$table/_02_Figure.do"; 	

*Table 1: Descriptive Statistics;
swapspec $mainspec;
do "$table/1_DescriptiveStatistics.do";

* Main impacts
	* Table 2 / A10: Main impacts - all
	* Table 3 / A11: Main impacts - interested only;

swapspec $mainspec;
do "$table/2_3_Impacts.do";		


********************************
*Appendix Tables
********************************;
#delimit;

*A1 Project Timeline (No Stata) ;

*A2 Sample attrition  ;
swapspec $mainspec;
swapspec attritfull baselineno4145 ascending15 nopval;
do "$table/A2_Attrition.do";

*A3 Balancing tests
swapspec $mainspec;

do "$table/A3_BalanceTests.do";


*A4 Impact of unilateral facilitation on passport acquisition

swapspec $mainspec;
do "$table/A4_PassportOutcome.do";

* Descriptive tables;
	*A5 Jobs offered, by position type
	*A6 Jobs offered, by country
	*A7 Migration outcomes of all jobs offered as of 2012, by region
	*A8 Reported reasons for not migrating, conditional on job offer, by region;

	* Run Programs 
	
	* Clean country names;
		do "$table/countryreg.do";
	* Clean position name;
		do "$table/position_74joboffer.do";
	* Clean why people do not accept jobs;
		do "$table/whynot_74joboffer.do";

swapspec $mainspec
do "$table/A5-A8_JobOfferCharacteristics.do";


*A9 Alternative migration measures
	*1_1: Column 5 - respondent working abroad
	*7_2: Column 5 - original offers for respondent

	swapspec  attritfull baselineno4145 ascending  nopval;
		do "$table/A9_AltMigration";		



*A10 Full set of coefficients from T2
*A11 Full set of coefficients from T3
	* See Tables 2/3 output

*A12 Full set of coefficients from T2, INCLUDING AGE 41-45
*A13 Full set of coefficients from T3, INCLUDING AGE 41-45;

	swapspec attritfull baseline ascending15  nopval;
		do "$table/2_3_Impacts.do";


log close;
