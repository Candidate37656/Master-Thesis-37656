***************************************************
*Semi-Strong-Form Efficiency (Raw Implied Probabilities)
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

*7) Variables
gen y = (ftr == "H" & side == "home") | (ftr == "D" & side == "draw") | (ftr == "A" & side == "away")
gen epsilon = y - p_
gen w = 1/(p_ * (1-p_))

*8) Set Environment
cd "/Users/tillstange/Desktop/Masterarbeit/Results/Main_Analysis (with intercept)/Diagnostics"

***************************************************
*Covid-19 Analysis
***************************************************

*1) Define Covid-19 Restriction Phases

*Germany
gen phase_D1 = .
replace phase_D1 = 1 if div_D1==1 & date < td(11mar2020)

replace phase_D1 = 2 if div_D1==1 & (inrange(date,td(11mar2020), td(17sep2020))| inrange(date, td(27oct2020), td(21may2021)))

replace phase_D1 = 3 if div_D1==1 & (inrange(date, td(18sep2020), td(26oct2020)) | inrange(date, td(22may2021), td(31mar2022)))

replace phase_D1 = 4 if div_D1==1 & date > td(31mar2022)

*UK
gen phase_E0 = .
replace phase_E0 = 1 if div_E0==1 & date < td(13mar2020)

replace phase_E0 = 2 if div_E0==1 & inrange(date, td(13mar2020), td(16may2021))

replace phase_E0 = 3 if div_E0==1 & inrange(date, td(17may2021),td(12aug2021))

replace phase_E0 = 4 if div_E0==1 & date > td(12aug2021)

*Spain
gen phase_SP1 = .

replace phase_SP1 = 1 if div_SP1==1 & date < td(09mar2020)

replace phase_SP1 = 2 if div_SP1==1 & inrange(date, td(09mar2020), td(12aug2021))

replace phase_SP1 = 3 if div_SP1==1 & inrange(date, td(13aug2021), td(04mar2022))

replace phase_SP1 = 4 if div_SP1==1 & date > td(04mar2022)

*Italy
gen phase_I1 = .

replace phase_I1 = 1 if div_I1==1 & date < td(02mar2020)

replace phase_I1 = 2 if div_I1==1 & (inrange(date,td(02mar2020), td(18sep2020))| inrange(date, td(26oct2020), td(19aug2021)))

replace phase_I1 = 3 if div_I1==1 & (inrange(date,td(19sep2020), td(25oct2020))| inrange(date, td(20aug2021), td(31mar2022)))

replace phase_I1 = 4 if div_I1==1 & date > td(31mar2022)

*2) Regressions

*Germany

regress epsilon c.home##i.phase_D1 away p_ [aweight=w] if div_D1==1, cluster(match_id)
estat ovtest
estat vif
testparm i.phase_D1
testparm c.home#i.phase_D1

outreg2 using WLS_Covid_final.doc, replace ctitle("Bundesliga")

regress epsilon home c.away##i.phase_D1 p_ [aweight=w] if div_D1==1, cluster(match_id)
estat ovtest
estat vif

regress epsilon home away c.p_##i.phase_D1 [aweight=w] if div_D1==1, cluster(match_id)
estat ovtest
estat vif

*UK

regress epsilon c.home##i.phase_E0 away p_ [aweight=w] if div_E0==1, cluster(match_id)
estat ovtest
estat vif
testparm i.phase_E0
testparm c.home#i.phase_E0
outreg2 using WLS_Covid_final.doc, append ctitle("Premier League")


regress epsilon home c.away##i.phase_E0 p_ [aweight=w] if div_E0==1, cluster(match_id)
estat ovtest
estat vif


regress epsilon home away c.p_##i.phase_E0 [aweight=w] if div_E0==1, cluster(match_id)
estat ovtest
estat vif

*Spain

regress epsilon c.home##i.phase_SP1 away p_ [aweight=w] if div_SP1==1, cluster(match_id)
estat ovtest
estat vif
testparm i.phase_SP1
testparm c.home#i.phase_SP1
outreg2 using WLS_Covid_final.doc, append ctitle("La Liga")

regress epsilon home c.away##i.phase_SP1 p_ [aweight=w] if div_SP1==1, cluster(match_id)
estat ovtest
estat vif

regress epsilon home away c.p_##i.phase_SP1 [aweight=w] if div_SP1==1, cluster(match_id)
estat ovtest
estat vif

*Italy
regress epsilon c.home##i.phase_I1 away p_ [aweight=w] if div_I1==1, cluster(match_id)
estat ovtest
estat vif
testparm i.phase_I1
testparm c.home#i.phase_I1
outreg2 using WLS_Covid_final.doc, append ctitle("Serie A")

regress epsilon home c.away##i.phase_I1 p_ [aweight=w] if div_I1==1, cluster(match_id)
estat ovtest
estat vif

regress epsilon home away c.p_##i.phase_I1 [aweight=w] if div_I1==1, cluster(match_id)
estat ovtest
estat vif



