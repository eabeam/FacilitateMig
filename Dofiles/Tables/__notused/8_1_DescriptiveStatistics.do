/* Mean Statistics */ 

#delimit ;


global cov0 "resp_age hsgrad somevoc colgradplus interested risks hhincome hhsavings zerohhsavings everloan normasset immabroad extabroad";


foreach var in female $cov0{;use "$specdata", clear;
$drop1;
$samplet;
keep if baseline == 1;
replace hhincome = hhincome / 1000;
replace hhsavings = . if hhsavings == 0;

collapse (mean) mean = `var' (sd) sd = `var' (count) count = `var'  ;
gen str15 var = "`var'";
save temp`var', replace ;};


use tempfemale, clear;foreach var in $cov0{;append using temp`var';
};order var;list;egen id = seq();save  means, replace;
outsheet using "$output/means_`c(current_date)'.xls",replace;
