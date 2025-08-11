***************************************************
*Draw Analysis (Raw Probabilities)
***************************************************
clear all
use "/Users/placeholder/Desktop/Masterarbeit/Data European football bets/Data-Results/Big_Four_2017-2025_Drop.dta"


*Development of Variables

* 1) Odds
egen avghome = rowmean(b365h bfh bwh iwh lbh psh vch whh)
egen avgdraw = rowmean(b365d bfd bwd iwd lbd psd vcd whd)
egen avgaway = rowmean(b365a bfa bwa iwa lba psa vca wha)

*2) Market Implied Probabilities
generate p_home_avg = 1/avghome
generate p_draw_avg = 1/avgdraw
generate p_away_avg = 1/avgaway

*3) League Dummies
gen div_D1 = div == "D1"
gen div_E0 = div == "E0"
gen div_I1 = div == "I1"
gen div_SP1 = div == "SP1"

*4) Draw Result and WLS Weights
gen y_draw = 0
replace y_draw = 1 if ftr == "D"
gen double weight_draw = 1/(p_draw_avg*(1-p_draw_avg))

*5) Set folder
cd "/Users/User/Desktop/Masterarbeit/Results/Draw_Analysis"

***************************************************
*Linear Diagnostics
***************************************************

*1) Homoscedasticity: Breusch Pagan and White Test
regress y_draw p_draw_avg p_home_avg p_away_avg div_I1 div_E0 div_SP1
estat hettest p_draw_avg p_home_avg p_away_avg div_I1 div_E0 div_SP1, iid rhs
estat imtest, white

*2) Correctness of Normality Assumption
regress y_draw p_draw_avg p_home_avg p_away_avg div_I1 div_E0 div_SP1 [aweight=weight_draw]
predict double u, residual
predict double h, hat
scalar MSE = e(rss)/e(df_r)
gen double rstd = u/sqrt((MSE*(1-h))/weight_draw)

qnorm rstd, ytitle("Standardised Residuals")
graph export "qqplot_draw.png", replace

*3) Ramsey Test: Omitted non-linear relation?
regress y_draw p_draw_avg p_home_avg p_away_avg div_I1 div_E0 div_SP1 [aweight=weight_draw]
estat ovtest

*4) Multicollinearity: VIFs
estat vif

***************************************************
*Final WLS Regression (Clustered)
***************************************************
regress y_draw p_draw_avg p_home_avg p_away_avg div_I1 div_E0 div_SP1 [aweight=weight_draw], cluster(hometeam)
outreg2 using "WLS_final.doc", replace








