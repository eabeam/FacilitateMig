swapspec attritfull baselineno4145 passinfotreat none nopval	


use "$specdata", clear
$drop1
$samplet

gen treat2 = 0
forval i = 1/14{
replace treat2 = `i' if aa`i'_ == 1
}
tab treat2
