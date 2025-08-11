***************************************************
*Strong-Form Efficiency (Raw Implied Probabilities)
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

*5) Season Dummies
gen season_17_18 = season == "2017_18"
gen season_18_19 = season == "2018_19"
gen season_19_20 = season == "2019_20"
gen season_20_21 = season == "2020_21"
gen season_21_22 = season == "2021_22"
gen season_22_23 = season == "2022_23"
gen season_23_24 = season == "2023_24"
gen season_24_25 = season == "2024_25"

*6) Stacked Format
reshape long p_, i(match_id) j(side) string
gen home = (side == "home")
gen away = (side == "away")

*6) Main Analysis Variables
gen y = (ftr == "H" & side == "home") | (ftr == "D" & side == "draw") | (ftr == "A" & side == "away")
gen epsilon = y - p_
gen w = 1/(p_ * (1-p_))

*8) Set Environment
cd "/Users/tillstange/Desktop/Masterarbeit/Results/Main_Analysis (with intercept)/Diagnostics"

***************************************************
*Linear Diagnostics
***************************************************
regress epsilon home away p_ season_18_19-season_24_25 div_E0 div_I1 div_SP1

*1) Homoscedasticity: Breusch Pagan and White Test
estat hettest p_ home away season_18_19-season_24_25 div_E0 div_I1 div_SP1, iid rhs

estat imtest, white

*2) Normality Assumption
regress epsilon home away p_ season_18_19-season_24_25 div_E0 div_I1 div_SP1 [aweight=w]
predict double u, residual
predict double h, hat
scalar MSE = e(rss)/e(df_r)
gen double rstd = u/sqrt((MSE*(1-h))/w)

qnorm rstd, ytitle("Standardised Residuals")
graph export "qqplot_efficiency_raw.png", replace

*3) Ramsey Test: Omitted non-linear Relationship?
regress epsilon home away p_ season_18_19-season_24_25 div_E0 div_I1 div_SP1 [aweight=w],vce(cluster match_id)

estat ovtest

*4) Multicollinearity?: VIFs
estat vif

***************************************************
*Final WLS Regressions
***************************************************

cd "/Users/tillstange/Desktop/Masterarbeit/Results/Main_Analysis (with intercept)/Implied Probabilities"

*1) Pooled Regression
regress epsilon home away p_ season_18_19-season_24_25 div_E0 div_I1 div_SP1 [aweight=w],vce(cluster match_id)
outreg2 using "WLS_final_.doc", replace
test home away p_
test season_18_19 season_19_20 season_20_21 season_21_22 season_22_23 season_23_24 season_24_25
test div_E0 div_I1 div_SP1

*2) Individual Leagues
regress epsilon home away p_ season_18_19-season_24_25 if div_D1==1 [aweight=w], cluster(match_id) 
outreg2 using "WLS_final_leagues.doc", replace ctitle("Bundesliga")
test home away p_
test season_18_19 season_19_20 season_20_21 season_21_22 season_22_23 season_23_24 season_24_25

regress epsilon home away p_ season_18_19-season_24_25 if div_E0==1 [aweight=w], cluster(match_id) 
outreg2 using "WLS_final_leagues.doc", append ctitle("Premier League")
test home away p_
test season_18_19 season_19_20 season_20_21 season_21_22 season_22_23 season_23_24 season_24_25

regress epsilon home away p_ season_18_19-season_24_25 if div_SP1==1 [aweight=w], cluster(match_id) 
outreg2 using "WLS_final_leagues.doc", append ctitle("La Liga")
test home away p_
test season_18_19 season_19_20 season_20_21 season_21_22 season_22_23 season_23_24 season_24_25

regress epsilon home away p_ season_18_19-season_24_25 if div_I1==1 [aweight=w], cluster(match_id) 
outreg2 using "WLS_final_leagues.doc", append ctitle("Serie A")
test home away p_
test season_18_19 season_19_20 season_20_21 season_21_22 season_22_23 season_23_24 season_24_25










