/****************************
_01_Figure.do 
Unilateral Facilitation Does Not Increase Migration 
Emily A. Beam, David McKenzie, and Dean Yang 

Last updated 05 June 2018 by Emily Beam (emily.beam@uvm.edu) 

This file determines the distribution of treatments and generates Figure 1. 

Note that the following swapspec command should be run first:  
swapspec  attritfull baselineno4145 ascending15 nopval 

****************************/

#delimit;

use "$specdata", clear;
$drop1;
$samplet;

*Row 1;
tab base_interv_base;


tab aa_assign;

