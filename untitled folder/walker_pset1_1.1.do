global dirpath = "/Users/cassturk/Downloads/Walker-ProblemSet1-Data"
global dirpath_data = "$dirpath/Data"


use "$dirpath_data/fips1001", clear

foreach var of varlist * {
	assert !missing(`var')
}

*using code from degreeDays.do, taken from Schlenker's website
*http://www.columbia.edu/~ws2162/links.html

*1:temperature variables
*A: sinusodal degree days
gen tAvg = (tMin+tMax) / 2
label var tAvg "average of min and max temp by day"

gen year = year(dateNum)

local boundList 30 32 34
foreach b of local boundList {
	
	// create label for negative bounds by adding Minus
	if (`b' < 0) {
		local b2 = abs(`b')
		local bLabel Minus`b2'
	} 
	else {
		local bLabel `b'
	}

	// default case 1: tMax <= bound
	qui gen dday`bLabel'Ce = 0

	// case 2: bound <= tMin
	qui replace dday`bLabel'Ce = tAvg - `b' if (`b' <= tMin)

	// case 3: tMin < bound < tMax
	qui gen tempSave = acos( (2 * `b'- tMax - tMin) / (tMax - tMin) )
	qui replace dday`bLabel'Ce = ///
		((tAvg - `b') * tempSave + (tMax - tMin) * sin(tempSave)/2) / _pi if ///
		((tMin < `b') & (`b' < tMax))
	drop tempSave
}
      
*B: temperature bins



	
gen tAvg0 = (tAvg < 0)
foreach bin of numlist 0(4)28 {
	local min = `bin'
	local max = `bin' + 4
	gen tAvg`min'to`max' = (tAvg >= `min' & tAvg < `max')
}
gen tAvg32 = (tAvg >= 32)

*C: cubic spline

local knotList 0 8 16 24 32

mkspline tAvgsp = tAvg , cubic knots(`knotList')


*D: linear spline


mkspline tAvg1 28 tAvg2 32 tAvg3 = tAvg , marginal



*2: averaging and summing

collapse (sum) tMin* tMax* tAvg* dday*, by(year gridNum)
collapse (mean) tMin* tMax* tAvg* dday*, by(year)

*3: check county 01001

gen fips = 1001

save "$dirpath_data\intermediate\Autauga_County_temperature_aggregation.dta", replace


*merge 1:1 fips year using "$dirpath_data/CountyAnnualTemperature1950to2012", keep(3) nogen

use "$dirpath_data/CountyAnnualTemperature1950to2012", clear
drop if fips != 1001

merge 1:1 year fips using "$dirpath_data\intermediate\Autauga_County_temperature_aggregation.dta", keep(3)

*only gives output if assertion is incorrect--no output is good output

foreach bin of numlist 0(4)28 {
		local max = `bin'+4
		assert round(tAvg`bin'to`max', .1) == round(temp`bin'to`max', .1)
}

foreach bin of numlist 1 2 3 4{
	assert round(tAvgsp`bin', .1) == round(splineC`bin', .1)
	
}

foreach bin of numlist 30 32 34{
	assert round(dday`bin'Ce, .1) == round(dday`bin'C, .1)
}

assert round(tAvg2, .1) == round(piece28, .1)
assert round(tAvg3, .1) == round(piece32, .1)
