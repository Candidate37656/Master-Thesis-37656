***************************************************
*Weak-Form Efficiency (Normalised Implied Probabilities)
***************************************************

clear all
use "/Users/tillstange/Desktop/Masterarbeit/Data European football bets/Data-Results/Big_Four_2017-2025_Drop.dta"
gen long match_id = _n


*Development of Variables

* 1) Odds
egen avghome = rowmean(b365h bfh bwh iwh lbh psh vch whh)
egen avgdraw = rowmean(b365d bfd bwd iwd lbd psd vcd whd)
egen avgaway = rowmean(b365a bfa bwa iwa lba psa vca wha)

*2) Market Implied Probabilities
generate p_home = 1/avghome
generate p_draw = 1/avgdraw
generate p_away = 1/avgaway
generate p_sum = p_home + p_draw + p_away

*3) Normalised Implied Probabilities
generate norm_home = p_home/p_sum
generate norm_draw = p_draw/p_sum
generate norm_away = p_away/p_sum

*3) League Dummies
gen div_D1 = div == "D1"
gen div_E0 = div == "E0"
gen div_I1 = div == "I1"
gen div_SP1 = div == "SP1"

*4) Clean Date Format
replace date = substr(date,1,6) + "20" + substr(date,7,2) if season == "2017_18"
gen date_s = daily(date, "DMY")
format date_s %tdDD/NN/CCYY
drop date
rename date_s date
count if missing(date)

*4) Season Dummies
gen season_17_18 = season == "2017_18"
gen season_18_19 = season == "2018_19"
gen season_19_20 = season == "2019_20"
gen season_20_21 = season == "2020_21"
gen season_21_22 = season == "2021_22"
gen season_22_23 = season == "2022_23"
gen season_23_24 = season == "2023_24"
gen season_24_25 = season == "2024_25"

*5) Stacked Format
reshape long norm_, i(match_id) j(side) string
gen home = (side == "home")
gen away = (side == "away")

*6) Main Analysis Variables
gen y = (ftr == "H" & side == "home") | (ftr == "D" & side == "draw") | (ftr == "A" & side == "away")
gen epsilon = y - norm_
gen w = 1/(norm_ * (1-norm_))

save "/Users/tillstange/Desktop/Masterarbeit/Data European football bets/Data-Results/Weak-form-efficiency.dta", replace

***************************************************
*Efficiency Curves for Bundesliga
***************************************************
cd "/Users/tillstange/Desktop/Masterarbeit/Results/Weak-Form Efficience/Bundesliga"


*1) Home Win Bets
use "/Users/tillstange/Desktop/Masterarbeit/Data European football bets/Data-Results/Weak-form-efficiency.dta", clear
keep if div_D1==1

regress epsilon norm_ [aweight=w] if home==1, cluster(match_id)
margins, at(norm_=(0.01(0.01)0.99)) predict(xb)

marginsplot, byopts(none) ///
ci1opts(recast(rarea) color(blue%10)) ///
plot1opts(lpattern(solid) msymbol(none) lwidth(thick) color(navy)) legend(off) ///
xlabel(0.25 0.5 0.75 1, labsize(large)) ///
ylabel(,labsize(large) angle(horizontal)) ///
xtitle("p{sub:e}", size(large)) ///
ytitle("Ê(p{sub:e})", size(vlarge)) ///
yline(0, lpattern(dash) lcolor(black) lwidth(thick))
graph export "Bundesliga_Home_Curve.png", replace

*2) Away Win Bets
use "/Users/tillstange/Desktop/Masterarbeit/Data European football bets/Data-Results/Weak-form-efficiency.dta", clear
keep if div_D1==1

regress epsilon norm_ [aweight=w] if away==1, cluster(match_id)
margins, at(norm_=(0.01(0.01)0.99)) predict(xb)

marginsplot, byopts(none) ///
ci1opts(recast(rarea) color(blue%10)) ///
plot1opts(lpattern(solid) msymbol(none) lwidth(thick) color(navy)) legend(off) ///
xlabel(0.25 0.5 0.75 1, labsize(large)) ///
ylabel(,labsize(large) angle(horizontal)) ///
xtitle("p{sub:e}", size(large)) ///
ytitle("Ê(p{sub:e})", size(vlarge)) ///
yline(0, lpattern(dash) lcolor(black) lwidth(thick))
graph export "Bundesliga_Away_Curve.png", replace

*3) Draw Bets
use "/Users/tillstange/Desktop/Masterarbeit/Data European football bets/Data-Results/Weak-form-efficiency.dta", clear
keep if div_D1==1

regress epsilon norm_ [aweight=w] if home==0 & away==0, cluster(match_id)
margins, at(norm_=(0.01(0.01)0.99)) predict(xb)

marginsplot, byopts(none) ///
ci1opts(recast(rarea) color(blue%10)) ///
plot1opts(lpattern(solid) msymbol(none) lwidth(thick) color(navy)) legend(off) ///
xlabel(0.25 0.5 0.75 1, labsize(large)) ///
ylabel(,labsize(large) angle(horizontal)) ///
xtitle("p{sub:e}", size(large)) ///
ytitle("Ê(p{sub:e})", size(vlarge)) ///
yline(0, lpattern(dash) lcolor(black) lwidth(thick))
graph export "Bundesliga_Draw_Curve.png", replace

***************************************************
*Efficiency Curves for Premier League
***************************************************
cd "/Users/tillstange/Desktop/Masterarbeit/Results/Weak-Form Efficience/Premier League"


*1) Home Win Bets
use "/Users/tillstange/Desktop/Masterarbeit/Data European football bets/Data-Results/Weak-form-efficiency.dta", clear
keep if div_E0==1

regress epsilon norm_ [aweight=w] if home==1, cluster(match_id)
margins, at(norm_=(0.01(0.01)0.99)) predict(xb)

marginsplot, byopts(none) ///
ci1opts(recast(rarea) color(blue%10)) ///
plot1opts(lpattern(solid) msymbol(none) lwidth(thick) color(navy)) legend(off) ///
xlabel(0.25 0.5 0.75 1, labsize(large)) ///
ylabel(,labsize(large) angle(horizontal)) ///
xtitle("p{sub:e}", size(large)) ///
ytitle("Ê(p{sub:e})", size(vlarge)) ///
yline(0, lpattern(dash) lcolor(black) lwidth(thick))
graph export "Home_Curve.png", replace

*2) Away Win Bets
use "/Users/tillstange/Desktop/Masterarbeit/Data European football bets/Data-Results/Weak-form-efficiency.dta", clear
keep if div_E0==1

regress epsilon norm_ [aweight=w] if away==1, cluster(match_id)
margins, at(norm_=(0.01(0.01)0.99)) predict(xb)

marginsplot, byopts(none) ///
ci1opts(recast(rarea) color(blue%10)) ///
plot1opts(lpattern(solid) msymbol(none) lwidth(thick) color(navy)) legend(off) ///
xlabel(0.25 0.5 0.75 1, labsize(large)) ///
ylabel(,labsize(large) angle(horizontal)) ///
xtitle("p{sub:e}", size(large)) ///
ytitle("Ê(p{sub:e})", size(vlarge)) ///
yline(0, lpattern(dash) lcolor(black) lwidth(thick))
graph export "Away_Curve.png", replace

*3) Draw Bets
use "/Users/tillstange/Desktop/Masterarbeit/Data European football bets/Data-Results/Weak-form-efficiency.dta", clear
keep if div_E0==1

regress epsilon norm_ [aweight=w] if home==0 & away==0, cluster(match_id)
margins, at(norm_=(0.01(0.01)0.99)) predict(xb)

marginsplot, byopts(none) ///
ci1opts(recast(rarea) color(blue%10)) ///
plot1opts(lpattern(solid) msymbol(none) lwidth(thick) color(navy)) legend(off) ///
xlabel(0.25 0.5 0.75 1, labsize(large)) ///
ylabel(,labsize(large) angle(horizontal)) ///
xtitle("p{sub:e}", size(large)) ///
ytitle("Ê(p{sub:e})", size(vlarge)) ///
yline(0, lpattern(dash) lcolor(black) lwidth(thick))
graph export "Draw_Curve.png", replace

***************************************************
*Efficiency Curves for La Liga
***************************************************
cd "/Users/tillstange/Desktop/Masterarbeit/Results/Weak-Form Efficience/La Liga"


*1) Home Win Bets
use "/Users/tillstange/Desktop/Masterarbeit/Data European football bets/Data-Results/Weak-form-efficiency.dta", clear
keep if div_SP1==1

regress epsilon norm_ [aweight=w] if home==1, cluster(match_id)
margins, at(norm_=(0.01(0.01)0.99)) predict(xb)

marginsplot, byopts(none) ///
ci1opts(recast(rarea) color(blue%10)) ///
plot1opts(lpattern(solid) msymbol(none) lwidth(thick) color(navy)) legend(off) ///
xlabel(0.25 0.5 0.75 1, labsize(large)) ///
ylabel(,labsize(large) angle(horizontal)) ///
xtitle("p{sub:e}", size(large)) ///
ytitle("Ê(p{sub:e})", size(vlarge)) ///
yline(0, lpattern(dash) lcolor(black) lwidth(thick))
graph export "Home_Curve.png", replace

*2) Away Win Bets
use "/Users/tillstange/Desktop/Masterarbeit/Data European football bets/Data-Results/Weak-form-efficiency.dta", clear
keep if div_SP1==1

regress epsilon norm_ [aweight=w] if away==1, cluster(match_id)
margins, at(norm_=(0.01(0.01)0.99)) predict(xb)

marginsplot, byopts(none) ///
ci1opts(recast(rarea) color(blue%10)) ///
plot1opts(lpattern(solid) msymbol(none) lwidth(thick) color(navy)) legend(off) ///
xlabel(0.25 0.5 0.75 1, labsize(large)) ///
ylabel(,labsize(large) angle(horizontal)) ///
xtitle("p{sub:e}", size(large)) ///
ytitle("Ê(p{sub:e})", size(vlarge)) ///
yline(0, lpattern(dash) lcolor(black) lwidth(thick))
graph export "Away_Curve.png", replace

*3) Draw Bets
use "/Users/tillstange/Desktop/Masterarbeit/Data European football bets/Data-Results/Weak-form-efficiency.dta", clear
keep if div_SP1==1

regress epsilon norm_ [aweight=w] if home==0 & away==0, cluster(match_id)
margins, at(norm_=(0.01(0.01)0.99)) predict(xb)

marginsplot, byopts(none) ///
ci1opts(recast(rarea) color(blue%10)) ///
plot1opts(lpattern(solid) msymbol(none) lwidth(thick) color(navy)) legend(off) ///
xlabel(0.25 0.5 0.75 1, labsize(large)) ///
ylabel(,labsize(large) angle(horizontal)) ///
xtitle("p{sub:e}", size(large)) ///
ytitle("Ê(p{sub:e})", size(vlarge)) ///
yline(0, lpattern(dash) lcolor(black) lwidth(thick))
graph export "Draw_Curve.png", replace

***************************************************
*Efficiency Curves for Serie A
***************************************************
cd "/Users/tillstange/Desktop/Masterarbeit/Results/Weak-Form Efficience/Serie A"


*1) Home Win Bets
use "/Users/tillstange/Desktop/Masterarbeit/Data European football bets/Data-Results/Weak-form-efficiency.dta", clear
keep if div_I1==1

regress epsilon norm_ [aweight=w] if home==1, cluster(match_id)
margins, at(norm_=(0.01(0.01)0.99)) predict(xb)

marginsplot, byopts(none) ///
ci1opts(recast(rarea) color(blue%10)) ///
plot1opts(lpattern(solid) msymbol(none) lwidth(thick) color(navy)) legend(off) ///
xlabel(0.25 0.5 0.75 1, labsize(large)) ///
ylabel(,labsize(large) angle(horizontal)) ///
xtitle("p{sub:e}", size(large)) ///
ytitle("Ê(p{sub:e})", size(vlarge)) ///
yline(0, lpattern(dash) lcolor(black) lwidth(thick))
graph export "Home_Curve.png", replace

*2) Away Win Bets
use "/Users/tillstange/Desktop/Masterarbeit/Data European football bets/Data-Results/Weak-form-efficiency.dta", clear
keep if div_I1==1

regress epsilon norm_ [aweight=w] if away==1, cluster(match_id)
margins, at(norm_=(0.01(0.01)0.99)) predict(xb)

marginsplot, byopts(none) ///
ci1opts(recast(rarea) color(blue%10)) ///
plot1opts(lpattern(solid) msymbol(none) lwidth(thick) color(navy)) legend(off) ///
xlabel(0.25 0.5 0.75 1, labsize(large)) ///
ylabel(,labsize(large) angle(horizontal)) ///
xtitle("p{sub:e}", size(large)) ///
ytitle("Ê(p{sub:e})", size(vlarge)) ///
yline(0, lpattern(dash) lcolor(black) lwidth(thick))
graph export "Away_Curve.png", replace

*3) Draw Bets
use "/Users/tillstange/Desktop/Masterarbeit/Data European football bets/Data-Results/Weak-form-efficiency.dta", clear
keep if div_I1==1

regress epsilon norm_ [aweight=w] if home==0 & away==0, cluster(match_id)
margins, at(norm_=(0.01(0.01)0.99)) predict(xb)

marginsplot, byopts(none) ///
ci1opts(recast(rarea) color(blue%10)) ///
plot1opts(lpattern(solid) msymbol(none) lwidth(thick) color(navy)) legend(off) ///
xlabel(0.25 0.5 0.75 1, labsize(large)) ///
ylabel(,labsize(large) angle(horizontal)) ///
xtitle("p{sub:e}", size(large)) ///
ytitle("Ê(p{sub:e})", size(vlarge)) ///
yline(0, lpattern(dash) lcolor(black) lwidth(thick))
graph export "Draw_Curve.png", replace

***************************************************
*Profitability: Strategy Analysis Serie A
***************************************************
use "/Users/tillstange/Desktop/Masterarbeit/Data European football bets/Data-Results/Weak-form-efficiency.dta", clear
keep if div_I1==1

*Break Even Points Efficiency Curves

*Home Wins
regress epsilon norm_ [aweight=w] if home==1, cluster(match_id)
preserve
clear
set obs 99
gen norm_ = 0.01*_n
predict double epsilonhat, xb
predict double epsilonhat_se, stdp
gen lower = epsilonhat - invnormal(0.975)*epsilonhat_se
sort norm_
su norm_ if lower>=0
di as txt "Serie A (Home): p= " r(min)
restore

*Away Wins
regress epsilon norm_ [aweight=w] if away==1, cluster(match_id)
preserve
clear
set obs 99
gen norm_ = 0.01*_n
predict double epsilonhat, xb
predict double epsilonhat_se, stdp
gen lower = epsilonhat - invnormal(0.975)*epsilonhat_se
sort norm_
su norm_ if lower>=0
di as txt "Serie A (Home): p= " r(min)
restore

*Draws
regress epsilon norm_ [aweight=w] if home==0 & away==0, cluster(match_id)
preserve
clear
set obs 99
gen norm_ = 0.01*_n
predict double epsilonhat, xb
predict double epsilonhat_se, stdp
gen lower = epsilonhat - invnormal(0.975)*epsilonhat_se
sort norm_
su norm_ if lower>=0
di as txt "Serie A (Home): p= " r(min)
restore

***************************************************
*Serie A: In Sample Profit Simulation (ex-post) 2017/18 - 2024/25
***************************************************
use "/Users/tillstange/Desktop/Masterarbeit/Data European football bets/Data-Results/Weak-form-efficiency.dta", clear
keep if div_I1==1
gen stake = 1

* Implied Probability Ranges
scalar prob_home = 0.79
scalar prob_away = 0.36
scalar prob_draw = 0.27

*Profitable Odd Threshold
scalar o_home = 1/prob_home
scalar o_away = 1/prob_away
scalar o_draw = 1/prob_draw

* Home Bets
gen bet_home = home==1 & avghome <=o_home
gen profit = .
replace profit = (avghome)*stake-stake if bet_home==1 & ftr=="H"
replace profit = -stake if bet_home==1 & ftr!="H"

* Away Bets
gen bet_away = away==1 & avgaway <=o_away
replace profit = (avgaway)*stake-stake if bet_away==1 & ftr=="A"
replace profit = -stake if bet_away==1 & ftr!="A"

* Draw Bets
gen bet_draw = home==0 & away==0 & avgdraw <=o_draw
replace profit = (avgdraw)*stake-stake if bet_draw==1 & ftr=="D"
replace profit = -stake if bet_draw==1 & ftr!="D"

* Results per Bet Type

foreach t in home away draw {
	summarize profit if bet_`t'
	local N_bets = r(N)
	local mean_profit = r(mean)
	
	if "`t'"=="home" {
		quietly count if bet_home & ftr=="H"
	}
	else if "`t'"=="away" {
		quietly count if bet_away & ftr=="A"
	}
	else {
		quietly count if bet_draw & ftr=="D"
	}
	local N_corr = r(N)
	local pct_corr = 100*(`N_corr'/`N_bets')
	
	di as txt "`=("`t'")' Bets:"
	di as txt "Number of Bets: " `N_bets'
	di as txt "Average profit: " `mean_profit'
	di as txt "Overall profit: " (`N_bets'*`mean_profit')
	di as txt "% correct Bets: " `pct_corr' "%"
}

*Overall Results
summarize profit
local N_bets = r(N)
local mean_profit = r(mean)
quietly count if profit>0 & !missing(profit)
local N_corr = r(N)
local pct_corr = 100 * (`N_corr'/`N_bets')

di as txt "Number of Bets: " `N_bets'
di as txt "Average profit: " `mean_profit'
di as txt "Overall profit: " (`N_bets'*`mean_profit')
di as txt "% correct Bets: " `pct_corr' "%"

***************************************************
*Serie A: Out of Sample Profit Simulation
***************************************************


*1) Determination of Profitability Thresholds (Seasons 17/18-20/21)

cd "/Users/tillstange/Desktop/Masterarbeit/Results/Weak-Form Efficience/Serie A"
use "/Users/tillstange/Desktop/Masterarbeit/Data European football bets/Data-Results/Weak-form-efficiency.dta", clear
keep if div_I1==1 & (season_17_18==1 | season_18_19==1 | season_19_20==1 | season_20_21==1)

*1.1) Home Win Bets
regress epsilon norm_ [aweight=w] if home==1, cluster(match_id)
margins, at(norm_=(0.01(0.01)0.99)) predict(xb)

*Efficiency Curve
marginsplot, byopts(none) ///
ci1opts(recast(rarea) color(blue%10)) ///
plot1opts(lpattern(solid) msymbol(none) lwidth(thick) color(navy)) legend(off) ///
xlabel(0.25 0.5 0.75 1, labsize(large)) ///
ylabel(,labsize(large) angle(horizontal)) ///
xtitle("p{sub:e}", size(large)) ///
ytitle("Ê(p{sub:e})", size(vlarge)) ///
yline(0, lpattern(dash) lcolor(black) lwidth(thick))
graph export "Home_Curve_implications.png", replace

*Break Even Point
regress epsilon norm_ [aweight=w] if home==1, cluster(match_id)
clear
set obs 99
gen norm_ = 0.01*_n
predict double epsilonhat, xb
predict double epsilonhat_se, stdp
gen lower = epsilonhat - invnormal(0.975)*epsilonhat_se
sort norm_
su norm_ if lower>=0
scalar prob_home2 = r(min)
di as txt "Serie A (Home): p= " r(min)


*1.2) Away Win Bets
use "/Users/tillstange/Desktop/Masterarbeit/Data European football bets/Data-Results/Weak-form-efficiency.dta", clear
keep if div_I1==1 & (season_17_18==1 | season_18_19==1 | season_19_20==1 | season_20_21==1)

regress epsilon norm_ [aweight=w] if away==1, cluster(match_id)
margins, at(norm_=(0.01(0.01)0.99)) predict(xb)

*Efficiency Curve

marginsplot, byopts(none) ///
ci1opts(recast(rarea) color(blue%10)) ///
plot1opts(lpattern(solid) msymbol(none) lwidth(thick) color(navy)) legend(off) ///
xlabel(0.25 0.5 0.75 1, labsize(large)) ///
ylabel(,labsize(large) angle(horizontal)) ///
xtitle("p{sub:e}", size(large)) ///
ytitle("Ê(p{sub:e})", size(vlarge)) ///
yline(0, lpattern(dash) lcolor(black) lwidth(thick))
graph export "Away_Curve_implications.png", replace

*Break Even Point
regress epsilon norm_ [aweight=w] if away==1, cluster(match_id)
clear
set obs 99
gen norm_ = 0.01*_n
predict double epsilonhat, xb
predict double epsilonhat_se, stdp
gen lower = epsilonhat - invnormal(0.975)*epsilonhat_se
sort norm_
su norm_ if lower>=0
scalar prob_away2 = r(min)
di as txt "Serie A (Away): p= " r(min)


*1.3) Draw Bets
use "/Users/tillstange/Desktop/Masterarbeit/Data European football bets/Data-Results/Weak-form-efficiency.dta", clear
keep if div_I1==1 & (season_17_18==1 | season_18_19==1 | season_19_20==1 | season_20_21==1)

regress epsilon norm_ [aweight=w] if home==0 & away==0, cluster(match_id)
margins, at(norm_=(0.01(0.01)0.99)) predict(xb)

*Efficiency Curve

marginsplot, byopts(none) ///
ci1opts(recast(rarea) color(blue%10)) ///
plot1opts(lpattern(solid) msymbol(none) lwidth(thick) color(navy)) legend(off) ///
xlabel(0.25 0.5 0.75 1, labsize(large)) ///
ylabel(,labsize(large) angle(horizontal)) ///
xtitle("p{sub:e}", size(large)) ///
ytitle("Ê(p{sub:e})", size(vlarge)) ///
yline(0, lpattern(dash) lcolor(black) lwidth(thick))
graph export "Away_Curve_implications.png", replace

*Break Even Point
regress epsilon norm_ [aweight=w] if away==0 & home==0, cluster(match_id)
preserve
clear
set obs 99
gen norm_ = 0.01*_n
predict double epsilonhat, xb
predict double epsilonhat_se, stdp
gen lower = epsilonhat - invnormal(0.975)*epsilonhat_se
sort norm_
su norm_ if lower>=0
scalar prob_draw2 = r(min)
di as txt "Serie A (Away): p= " r(min)
restore

*2) Bet Simulations for Seasons 2021 - 2024/25

cd "/Users/tillstange/Desktop/Masterarbeit/Results/Weak-Form Efficience/Serie A"
use "/Users/tillstange/Desktop/Masterarbeit/Data European football bets/Data-Results/Weak-form-efficiency.dta", clear
keep if div_I1==1 & (season_21_22==1 | season_22_23==1 | season_23_24==1 | season_24_25==1)
gen stake = 1

*Profitable Odd Threshold
scalar o_home2 = 1/prob_home2
scalar o_away2 = 1/prob_away2
scalar o_draw2 = 1/prob_draw2

* Home Bets
gen bet_home = home==1 & avghome <=o_home2
gen profit = .
replace profit = (avghome)*stake-stake if bet_home==1 & ftr=="H"
replace profit = -stake if bet_home==1 & ftr!="H"

* Away Bets
gen bet_away = away==1 & avgaway <=o_away2
replace profit = (avgaway)*stake-stake if bet_away==1 & ftr=="A"
replace profit = -stake if bet_away==1 & ftr!="A"

* Draw Bets
gen bet_draw = home==0 & away==0 & avgdraw <=o_draw2
replace profit = (avgdraw)*stake-stake if bet_draw==1 & ftr=="D"
replace profit = -stake if bet_draw==1 & ftr!="D"

* Results per Bet Type

foreach t in home away draw {
	summarize profit if bet_`t'
	local N_bets = r(N)
	local mean_profit = r(mean)
	
	if "`t'"=="home" {
		quietly count if bet_home & ftr=="H"
	}
	else if "`t'"=="away" {
		quietly count if bet_away & ftr=="A"
	}
	else {
		quietly count if bet_draw & ftr=="D"
	}
	local N_corr = r(N)
	local pct_corr = 100*(`N_corr'/`N_bets')
	
	di as txt "`=("`t'")' Bets:"
	di as txt "Number of Bets: " `N_bets'
	di as txt "Average profit: " `mean_profit'
	di as txt "Overall profit: " (`N_bets'*`mean_profit')
	di as txt "% correct Bets: " `pct_corr' "%"
}

*Overall Results
summarize profit
local N_bets = r(N)
local mean_profit = r(mean)
quietly count if profit>0 & !missing(profit)
local N_corr = r(N)
local pct_corr = 100 * (`N_corr'/`N_bets')

di as txt "Number of Bets: " `N_bets'
di as txt "Average profit: " `mean_profit'
di as txt "Overall profit: " (`N_bets'*`mean_profit')
di as txt "% correct Bets: " `pct_corr' "%"



















