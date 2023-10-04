global dirpath = "/Users/cassturk/Downloads/Walker-ProblemSet1-Data"
global dirpath_data = "$dirpath/Data"

use "$dirpath_data/poll7080.dta", clear

local covars "dwhite dhs durban dpoverty dplumb dincome downer dmnfcg"

*2.1

*no weights
reg dlhouse dgtsp 
eststo reg1

reg dlhouse dgtsp `covars'
eststo reg2

*weighted by pop
reg dlhouse dgtsp [aweight=pop7080]
eststo reg_3

reg dlhouse dgtsp `covars' [aweight=pop7080]
eststo reg4

*esttab reg1 reg2 reg_3 reg4 using $dirpath/table3.tex , se(4) b(a3) label mtitles("OLS" "OLS 2" "OLS weighted" "OLS 2 weighted")

*2.2
*need exclusion and relevance

*relevance
reg dgtsp tsp7576 
eststo rel1

reg dgtsp tsp7576 `covars'
eststo rel2

*tsp7576 predicts the change in dgtsp well

*exclusion test
reg tsp7576 `covars'
eststo exc1

*esttab rel1 rel2 using $dirpath/table4.tex , se(4) b(a3) label mtitles("Relevance" "Relevance 2" )
*esttab exc1 using $dirpath/table5.tex , se(4) b(a3) label mtitles("Exclusion")


*2.3

reg dgtsp tsp7576 
eststo first1

reg dgtsp tsp7576 `covars'
eststo first2

reg dlhouse tsp7576
eststo second1

reg dlhouse tsp7576 `covars'
eststo second2

*esttab first1 first2 second1 second2 using $dirpath/table6.tex , se(4) b(a3) label mtitles("First Stage" "First Stage 2" "Reduced Form" "Reduced Form 2")


*iv coefficient is betadirecteffect/betafirststage

ivregress 2sls dlhouse `covars' (dgtsp = tsp7576)
eststo tsls1

*esttab tsls1 using $dirpath/table7.tex , se(4) b(a3) label mtitles("2SLS")


*2.4

reg dgtsp mtspgm74
eststo first1_2

reg dgtsp  mtspgm74 `covars'
eststo first2_2

reg dlhouse  mtspgm74
eststo second1_2

reg dlhouse  mtspgm74 `covars'
eststo second2_2

*esttab first1_2 first2_2 second1_2 second2_2 using $dirpath/table8.tex , se(4) b(a3) label mtitles("First Stage" "First Stage 2" "Reduced Form" "Reduced Form 2")

*iv coefficient is betadirecteffect/betafirststage

ivregress 2sls dlhouse `covars' (dgtsp =  mtspgm74)
eststo tsls1_2


*esttab tsls1_2 using $dirpath/table9.tex , se(4) b(a3) label mtitles("2SLS")

*2.5


twoway (lowess dlhouse mtspgm74 if tsp7576 ==1, bwidth(.4)) ||(lowess dlhouse mtspgm74 if tsp7576 ==0, bwidth(.4)), ytitle("Log House Price")  xtitle("Particulates") title("Discontinuity in Housing Prices and Particulates by Regulation") legend(label(1 "Regulated") label(2 "Unregulated"))
graph export $dirpath/lowess1.pdf, replace

twoway (lowess dgtsp mtspgm74 if tsp7576 ==1, bwidth(.2)) ||(lowess dgtsp mtspgm74 if tsp7576 ==0, bwidth(.2)), ytitle("Change in Particulates")  xtitle("Particulates") title("Discontinuity in Particulate Change and Particulates by Regulation") legend(label(1 "Regulated") label(2 "Unregulated"))
graph export $dirpath/lowess2.pdf, replace
*twoway (lowess dlhouse dgtsp if shouldbetsp ==1, bwidth(.2)) ||(lowess dlhouse dgtsp if shouldbetsp ==0, bwidth(.2))


*2.6

reg dlhouse `covars' [aweight = pop7080]
predict dlhouse_covars_predict

twoway (lowess dlhouse_covars_predict mtspgm74, bwidth(.4)) ||(lowess dlhouse mtspgm74 if tsp7576 ==1, bwidth(.4)) ||(lowess dlhouse mtspgm74 if tsp7576 ==0, bwidth(.4)), ytitle("Log House Price")  xtitle("Lowess House on Particulates") title("Discontinuity in Housing Prices and Particulates by Regulation") legend(label(1 "Predicted") label(2 "Regulated") label(3 "Unregulated"))
graph export $dirpath/lowess3.pdf, replace

*2.7

twoway (lowess dgtsp mtspgm74 if (tsp7576 ==1) & (mtspgm74<75) & (mtspgm74 >50), bwidth(1) ) ||(lowess dgtsp mtspgm74 if (tsp7576 ==0) & (mtspgm74<75)& (mtspgm74 >50), bwidth(1) ), ytitle("Change in Particulates")  xtitle("Particulates") title("Discontinuity in Particulate Change and Particulates by Regulation") legend(label(1 "Regulated") label(2 "Unregulated"))
graph export $dirpath/lowess4.pdf, replace

twoway (lowess dlhouse mtspgm74 if (tsp7576 ==1) & (mtspgm74<75) & (mtspgm74 >50), bwidth(1) ) ||(lowess dlhouse mtspgm74 if (tsp7576 ==0) & (mtspgm74<75)& (mtspgm74 >50), bwidth(1) ), ytitle("Log House Price")  xtitle("Particulates") title("Discontinuity in Housing Prices and Particulates by Regulation") legend(label(1 "Regulated") label(2 "Unregulated"))
graph export $dirpath/lowess5.pdf, replace
