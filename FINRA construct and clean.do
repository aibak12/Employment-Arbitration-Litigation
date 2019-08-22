***For FINRA May2008-May2019 Employment Arbitration Data Collection***
***Weihao and Aibak dessertation use***
***Aug. 2019***


***Import data***
use "C:\Users\lwh_v\Box Sync\LER\Projects\FINRA Data Collection\Stata FINRA 2008_2019\FINRA_may2008_may2019.dta", clear


***Generate variables***

**MotionSummaryJudgment**

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

gen cclaimcombined=cccompenamtnum+ccincome+ccwageflag+ccprofit

**deal with unspecified**





***************************************************************************************************************************************
**CAwardedComp ($) (compensatory, income/wage, combined)

gen at=subinstr(AwardText,char(10)," ",.)

generate cacompensatflag = (strpos(lower(at), "compensat") != 0 ) //1394 cases: ccompensatflag ==1

generate caincomeflag = 1 if strpos(lower(at), "income") != 0

generate cawageflag = 1 if strpos(lower(at), "wage") != 0

generate cacomissionflag = 1 if strpos(lower(at), "commission") != 0

generate caprofitflag = 1 if strpos(lower(at), "profit") != 0






**Respondent counterclaim awarded amount: RespCounterClaimGranted ($)
****************************************************************************************************************************************
*list data
display compenphrase[8]
display ReliefRequestedText[1]
display rrt[12]
list AwardID cccompenamtpart1 if cccompenamtpart1!=""
list AwardID cccompenamt cccompenamtpart2part1 cccompenamtpart2part2 if cccompenamtpart2part1<=10






***************************************************************************************************************************************
** Allegation variables**
*remove line breaks in complete text*
ssc inst charlist
gen cst = subinstr(CaseSummaryText, char(10), "", .)
split cst, parse(Counterclaim)

gen breachofcontract1= 0
replace breachofcontract = 1 if strpos(lower(cst1), "breach of contract") !=0
replace breachofcontract = 1 if strpos(lower(cst1), "breach of implied contract") !=0
replace breachofcontract = 1 if strpos(lower(cst1), "breach of employment agreement") !=0

gen wrongterm= 0
replace wrongterm = 1 if strpos(lower(cst1), "wrongful termination") !=0
replace wrongterm = 1 if strpos(lower(cst1), "termination of employment") !=0
replace wrongterm = 1 if strpos(lower(cst1), "termination") !=0
replace wrongterm = 1 if strpos(lower(cst1), "unlawful termination") !=0
replace wrongterm = 0 if strpos(lower(cst1), "constructive termination") !=0

gen discrimination= 0
replace discrimination = 1 if strpos(lower(cst1), "discrim") !=0

gen defamation= 0
replace defamation = 1 if strpos(lower(cst1), "defam") !=0

gen compensation= 0
replace compensation= 1 if strpos(lower(cst1), "compensat") !=0

gen fraud= 0
replace fraud= 1 if strpos(lower(cst1), "fraud") !=0

gen raiding= 0
replace raiding= 1 if strpos(lower(cst1), "raid") !=0

gen ERISA= 0
replace ERISA= 1 if strpos(upper(cst1), "ERISA") !=0

gen BreachCovGdFaith = 0
replace ERISA= 1 if strpos(lower(cst1), "covenant of good faith and fair") !=0

gen promissoryestoppel= 0
replace promissoryestoppel= 1 if strpos(lower(cst1), "promissory estoppel") !=0

gen retaliation= 0
replace retaliation= 1 if strpos(lower(cst1), "retaliat") !=0

gen quantummeruit= 0
replace quantummeruit= 1 if strpos(lower(cst1), "quantum meruit") !=0

gen tortiousinterference= 0
replace tortiousinterference= 1 if strpos(lower(cst1), "tortious") !=0

gen harassment= 0
replace harassment= 1 if strpos(lower(cst1), "harass") !=0

gen libel= 0
replace libel= 1 if strpos(lower(cst1), "libel") !=0

gen slander= 0
replace slander= 1 if strpos(lower(cst1), "slander") !=0

gen expunge= 0
replace expunge= 1 if strpos(lower(cst1), "expung") !=0
replace expunge= 1 if strpos(upper(cst1), "U5") !=0
replace expunge= 1 if strpos(upper(cst1), "CRD") !=0

gen disability= 0
replace disability= 1 if strpos(lower(cst1), "disabilit") !=0

gen FMLA= 0
replace FMLA= 1 if strpos(upper(cst1), "FMLA") !=0

gen fiduciaryduty= 0
replace fiduciaryduty= 1 if strpos(lower(cst1), "fiduciary duty") !=0

gen negligence= 0
replace negligence= 1 if strpos(lower(cst1), "negligence") !=0

gen indemnification= 0
replace indemnification= 1 if strpos(lower(cst1), "indemnif") !=0

gen injunctiverelief= 0
replace injunctiverelief= 1 if strpos(lower(cst1), "injunctive relief") !=0

gen legalmalpractice= 0
replace legalmalpractice= 1 if strpos(lower(cst1), "legalmalpractice") !=0

gen misappropriation= 0
replace misappropriation= 1 if strpos(lower(cst1), "misappropriation") !=0

gen misrepresentation= 0
replace misrepresentation= 1 if strpos(lower(cst1), "misrepresentation") !=0

gen derelictionofduty= 0
replace derelictionofduty= 1 if strpos(lower(cst1), "dereliction of duty") !=0

gen commission= 0
replace commission= 1 if strpos(lower(cst1), "commission") !=0

gen unjustenrichment= 0
replace unjustenrichment= 1 if strpos(lower(cst1), "unjust enrichment") !=0

gen BreachSettlemtAgreemt= 0
replace BreachSettlemtAgreemt= 1 if strpos(lower(cst1), "settlement agreement") !=0

gen constructivedischarge= 0
replace constructivedischarge= 1 if strpos(lower(cst1), "constructive discharge") !=0
replace constructivedischarge= 1 if strpos(lower(cst1), "constructive termination") !=0

gen contribution= 0
replace contribution= 1 if strpos(lower(cst1), "contribution") !=0

gen conversion= 0
replace conversion= 1 if strpos(lower(cst1), "conversion") !=0

gen declaratoryjudgement= 0
replace declaratoryjudgement= 1 if strpos(lower(cst1), "declaratory judgment") !=0

gen RICO= 0
replace RICO= 1 if strpos(upper(cst1), "RICO") !=0

gen severance= 0
replace severance= 1 if strpos(lower(cst1), "severance") !=0

gen whistleblowing= 0
replace whistleblowing= 1 if strpos(lower(cst1), "whistle") !=0

gen accounting= 0
replace accounting= 1 if strpos(lower(cst1), "accounting") !=0
