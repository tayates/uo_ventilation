* Generating contour plots

*** About this .do file
* Code written by Tom Yates (UCL)
* Please direct any queries to t.yates@ucl.ac.uk

clear

set obs 10000

*** Generate 100 x 100 datapoints

egen hours = seq(), block(100)
egen vent = seq(), from(1) to(100)

replace hours = hours^1.951545
replace vent = vent^1.849485

*** Assumptions

* These calculations use a Wells Riley Model (see Riley et al, 1978)

* I = 1 (single infector)
* p = 0.6 m3/hr (from Riley and Nardell, 1989)

*** Generate transmission probabilities under various values of q

* Set q = 1.25 (from the second set of Johns Hopkins Pilot Ward experiments - see
///Riley et al, 1962)

gen prob_low = (1 - exp((-0.75*hours)/vent))

* Set q = 8.2 (from Escombe et al, 2008 - average from 97 HIV positive patients 
///hospitalised in Lima)

gen prob_med = 1 - exp((-4.92*hours)/vent)

* Set q = 226 (the most infectious patient from Escombe et al, 2008) 

gen prob_high = 1 - exp((-135.6*hours)/vent)

* The horizontal line gives the median absolute visit duration from Karat et
///al, 2021

* The verical lines give the median ventilation rate in waiting rooms under both
///usual and ideal conditions (from this paper)

* All citations listed below

*** Make contour plots with log scales

twoway (contour prob_low hours vent, ccuts(0.001 0.01 .1 .9)), /// 
	yscale(log) ylab(1 8 40 480 2000 8000) ///
	xtitle("Absolute ventilation rate (m3/hr)") ytitle("Time (hrs)") ///
	zscale(log) ztitle("Transmission probability (1.25 q/hr)") || ///
	scatteri 1 1769 8000 1769, c(l) lc(black) lw(medthick) lp(dash) m(i) legend(off) || ///
    scatteri 1 2950 8000 2950, c(l) lc(black) lw(medthick) lp(dash) m(i) legend(off) || ///
	scatteri 2.6 0 2.6 5000, c(l) lc(black) lw(medthick) lp(dash) m(i) legend(off)

twoway (contour prob_med hours vent, ccuts(0.001 0.01 .1 .9)), /// 
	yscale(log) ylab(1 8 40 480 2000 8000) ///
	xtitle("Absolute ventilation rate (m3/hr)") ytitle("Time (hrs)") ///
	zscale(log) ztitle("Transmission probability (8.2 q/hr)") || ///
	scatteri 1 1769 8000 1769, c(l) lc(black) lw(medthick) lp(dash) m(i) legend(off) || ///
    scatteri 1 2950 8000 2950, c(l) lc(black) lw(medthick) lp(dash) m(i) legend(off) || ///
	scatteri 2.6 0 2.6 5000, c(l) lc(black) lw(medthick) lp(dash) m(i) legend(off)
	
twoway (contour prob_high hours vent, ccuts(0.001 0.01 .1 .9)), /// 
	yscale(log) ylab(1 8 40 480 2000 8000) ///
	xtitle("Absolute ventilation rate (m3/hr)") ytitle("Time (hrs)") ///
	zscale(log) ztitle("Transmission probability (226 q/hr)") || ///
	scatteri 1 1769 8000 1769, c(l) lc(black) lw(medthick) lp(dash) m(i) legend(off) || ///
    scatteri 1 2950 8000 2950, c(l) lc(black) lw(medthick) lp(dash) m(i) legend(off) || ///
	scatteri 2.6 0 2.6 5000, c(l) lc(black) lw(medthick) lp(dash) m(i) legend(off)
	
*** References

* Escombe et al (2008). The infectiousness of tuberculosis patients coinfected 
///with HIV. PLoS Med; 5(9): e188.

* Karat et al (2021). Waiting times, patient flow, and occupancy density in South
///African primary health care clinics: implications for infection prevention
///and control. medRxiv; 2021.07.21.21260806; 
///doi: https://doi.org/10.1101/2021.07.21.21260806 

* Riley et al (1962). Infectiousness of air from a tuberculosis ward. Ultraviolet 
///irradiation of infected air: comparative infectiousness of different patients.
///Am Rev Respir Dis; 85: 511–525.


* Riley et al (1978). Airborne spread of measles in a suburban elementary school.
///Am J Epidemiol; 107(5): 421-32.

* Riley and Nardell (1989). Clearing the air. The theory and application of ultraviolet air disinfection.
///Am Rev Respir Dis; 139(5): 1286-94.
