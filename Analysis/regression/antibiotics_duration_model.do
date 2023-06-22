cd "C:/Users/ajwalker/Documents/GitHub/Rx-Quantity-for-Long-Term-Conditions/Analysis/regression"
import delimited "data_for_stata.csv",clear


*misstable summ,all

encode supplier,gen(ehr)
recode dispensing_patients 1/max=1
xtile over_65 = value_over_65,nq(5)
xtile long_term_health = value_long_term_health,nq(5)

tabstat value_over_65,by(over_65) s(min max)
tabstat value_long_term_health,by(long_term_health) s(min max)


foreach indepvar in over_65 long_term_health ehr dispensing_patients {
	tabstat rate,by(`indepvar') s(median)
	poisson rate i.`indepvar', irr
}
meqrpoisson rate i.over_65 i.long_term_health i.ehr i.dispensing_patients ///
		|| pct:, irr

predict predictions
qui corr rate predictions
di "R-squared - fixed effects (%): " round(r(rho)^2*100,.1)

qui predict predictionsr, reffects
qui corr rate predictionsr
di "R-squared - random effects (%): " round(r(rho)^2*100,.1)


