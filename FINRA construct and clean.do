***For FINRA May2008-May2019 Employment Arbitration Data Collection***
***Weihao and Aibak dessertation use***
***Aug. 2019***


***Import data***
use "C:\Users\lwh_v\Box Sync\LER\Projects\FINRA Data Collection\Stata FINRA 2008_2019\FINRA_may2008_may2019.dta", clear


***Generate variables***

**MotionSummaryJudgement**

*remove line breaks in complete text*
gen ct=subinstr(CompleteText,char(10)," ",.)
*look for 'summary judgment' and 'summary judgement' using 'complete text'
label variable MotionSummaryJudgement "fromgsheet_ToBeDeleted"
generate summaryjudgement = 0 
replace summaryjudgement = 1 if strpos(lower(ct), "summary judgment") != 0  //ignore case, 43 real changes made
replace summaryjudgement = 1 if strpos(lower(ct), "summary judegment") != 0  //ignore case, 0 real changes made

**CClaimedComp ($) (compensatory, income/wage, combined)
generate cccompensatflag = (strpos(lower(ReliefRequestedText), "compensat") != 0 ) //1394 cases: ccompensatflag ==1

**remove line breaks**
gen rrt=subinstr(ReliefRequestedText,char(10)," ",.)

*extract compenstation phrase
*gen compenphrase = regexs(0) if(regexm(lower(rrt), "compensat[a-zA-Z ]+[$]?[0-9,.]+[;.,]?"))
gen compenphrase2 = regexs(0) if(regexm(lower(rrt), "[$]?[0-9,.]*[a-zA-Z ]*compensat[a-zA-Z ]*[$]?[ ]?[0-9,.]*[;.,]?")) //401 missing (=1975-1394)

*extract amount in compenphrase
gen cccompenamt = regexs(0) if(regexm(lower(compenphrase2), "[$][ ]?[0-9,.]+"))
split cccompenamt, parse("$") gen (cccompenamtpart)
drop cccompenamtpart1
replace cccompenamtpart2 = subinstr(cccompenamtpart2, ",","",.)
split cccompenamtpart2, parse(".") gen (cccompenamtpart2part)

destring cccompenamtpart2part1 cccompenamtpart2part2 cccompenamtpart2part3,replace
*fix wrong cases where cccompensmtpart2part3!=.
replace cccompenamtpart2part1=11952120 if AwardID=="09-01814"
replace cccompenamtpart2part1=1000000  if AwardID=="09-01561"
replace cccompenamtpart2part1=2719267  if AwardID=="08-04976"
replace cccompenamtpart2part1=2175000  if AwardID=="08-01287"
replace cccompenamtpart2part1=1000     if AwardID=="09-04000"

replace cccompenamtpart2part1=1500000  if AwardID=="09-00618"
replace cccompenamtpart2part1=1161000  if AwardID=="06-02076"
replace cccompenamtpart2part1=1250000  if AwardID=="07-03502"
replace cccompenamtpart2part1=182291   if AwardID=="08-00660"
replace cccompenamtpart2part1=1600000  if AwardID=="08-00921"

replace cccompenamtpart2part1=100000   if AwardID=="07-01322"
replace cccompenamtpart2part1=1000001  if AwardID=="07-01835"
replace cccompenamtpart2part1=1000000  if AwardID=="07-00130"
replace cccompenamtpart2part1=1000000  if AwardID=="07-02377"
replace cccompenamtpart2part1=1000000  if AwardID=="07-02546"

replace cccompenamtpart2part1=841941  if AwardID=="07-03357"
replace cccompenamtpart2part1=1500    if AwardID=="09-01276"

replace cccompenamtpart2part2=cccompenamtpart2part3 if cccompenamtpart2part3!=.
drop cccompenamtpart2part3

*check cases where cccompenamtpart2part1<=10 if there are cases use phrase like "3.4 million"
replace cccompenamtpart2part1=3400000 if AwardID=="16-02323"
replace cccompenamtpart2part1=3600000 if AwardID=="17-00057"

*combine integer part with decimal part
rename cccompenamtpart2part1 cccompenamtinteger
gen cccompenamtdecimal=cccompenamtpart2part2/100
gen cccompenamtnum=cccompenamtinteger+cccompenamtdecimal


*******************************************************************

generate ccincomeflag = 1 if strpos(lower(rrt), "income") != 0

generate ccwageflag = 1 if strpos(lower(rrt), "wage") != 0

generate cccomissionflag = 1 if strpos(lower(rrt), "commission") != 0

generate ccprofitflag = 1 if strpos(lower(rrt), "profit") != 0



**************************************************************************************************************************************

gen cclaimcombined=cccompenamtnum+ccincome+ccwageflag+ccprofitflag

**deal with unspecified**

**CAwardedComp ($) (compensatory, income/wage, combined)
gen cawardcompdam=.
gen cawardincomeloss=.
gen cawardcombined=.





**Respondent counterclaim awarded amount: RespCounterClaimGranted ($)
****************************************************************************************************************************************
*list data
display compenphrase[8]
display ReliefRequestedText[1]
display rrt[12]
list AwardID cccompenamtpart1 if cccompenamtpart1!=""
list AwardID cccompenamt cccompenamtpart2part1 cccompenamtpart2part2 if cccompenamtpart2part1<=10
