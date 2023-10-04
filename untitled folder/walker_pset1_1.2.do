global dirpath = "/Users/cassturk/Downloads/Walker-ProblemSet1-Data"
global dirpath_data = "$dirpath/Data"

*use "$dirpath_data/CountyAnnualTemperature1950to2012", clear

use "$dirpath_data/reis_combine.dta", clear

destring fips, replace

merge 1:1 year fips using "$dirpath_data/CountyAnnualTemperature1950to2012", keep(3)


*1.2.1
gen log_emp_farm = log(emp_farm)

local bins "temp0to4 temp4to8 temp8to12 temp12to16 temp16to20 temp20to24 temp24to28 temp28to32 tempA32"

*regressing without fixed effects, only temp vars


reg log_emp_farm `bins'

eststo reg_1

*adding fixed effects

*year only
reghdfe log_emp_farm `bins', absorb(year)

*county only
reghdfe log_emp_farm `bins', absorb(fips)

*year and county
reghdfe log_emp_farm `bins', absorb(year fips) 
eststo reg_2


*1.2.2
gen log_inc_farm_prop_income = log(inc_farm_prop_income)

local sp_cub "splineC1 splineC2 splineC3 splineC4"

*no fe
reg log_inc_farm_prop_income `sp_cub'
eststo reged1

*year/county fe
reghdfe log_inc_farm_prop_income `sp_cub', absorb(year fips) 
eststo reged2
coefplot, vertical drop(_cons) yline(0)
graph export $dirpath/coef1.pdf, replace


*1.2.3

local binList temp0to4 temp4to8 temp8to12 temp12to16 temp16to20 temp20to24 temp24to28 temp28to32 tempA32


foreach bin of local binList {
	gen temp_interact_32_`bin' = c.`bin'#c.tempA32
	foreach i of numlist 0(4)28{
		local max = `i' + 4
		gen temp_int_`i'to`max'_`bin' = c.`bin'#c.temp`i'to`max'
	}
}

reg log_emp_farm `bins' temp_interact_32_*
eststo reg_3

reghdfe log_emp_farm `bins' temp_interact_32_*, absorb(year fips)
eststo reg_4


*esttab reged1 reged2 using $dirpath/table1.tex , se(4) b(a3) label mtitles("OLS" "FE"), replace

*esttab reg_1 reg_2 reg_3 reg_4 using $dirpath/table2.tex , se(4) b(a3) label mtitles("OLS" "FE" "interacted" "interacted FE"), replace
