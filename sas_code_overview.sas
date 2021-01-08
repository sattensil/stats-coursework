
***Step 1: Put in the location of the data;

run;

**libname local 'C:\UC Berkley\Logistic Reg & Survival Analysis\For Students\Hazard Model\overview';
libname local 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Logistic Reg & Survival Analysis\For Students\Hazard Model\Overview';



** Step 2: Create a data set called heart attack;

data heart_attack;
  set local.whas500;

  run;

  proc freq data=heart_attack; 
   table fstat / missing; 
   title 'fstat'; 

   run; 

   proc univariate data=heart_attack; 
    var lenfol; 

	run; 


*** Step 3: Save Heart Attack Data into Excel Spreadsheet for Further Review;
%macro skipit; 

PROC EXPORT DATA= WORK.HEART_ATTACK
            OUTFILE= "C:\UC Berkley\Logistic Reg & Survival Analysis\For
 Students\Hazard Model\overview\heart_attack.xls"
            DBMS=EXCEL REPLACE;
     SHEET="hearat_attack";
RUN;
%mend skipit; 

*** Step 4: Distribution of deaths by time since admission;

run;

proc options option=jreoptions;

proc javainfo; run;

run;

** Step 4a: Results for those who died;

proc univariate data = heart_attack(where=(fstat=1));
var lenfol;
histogram lenfol / kernel;
run;


** Step 4b: Overall results those who lived and died;

proc univariate data = heart_attack;
var lenfol;
histogram lenfol / kernel;
run;


*** Step 5 Cumulative probablity distribution;


  proc univariate data = heart_attack(where=(fstat=1));
var lenfol;
cdfplot lenfol;

run;

 proc univariate data=heart_attack;
 var bmi;

run;


** Step 5 Cumulative Distribution Function;

run;

 ** Step 5.1: Just for those who died;

proc lifetest data=heart_attack(where=(fstat=1)) plots=survival(atrisk);
time lenfol*fstat(0);
run;



 ** Step 5.2: Everyone;

proc lifetest data=heart_attack plots=survival(atrisk);
time lenfol*fstat(0);
run;



**Step 6: Hazard Function for Heart Attack Example;
** bw is associated with the band width of the kernal use to draw the diagram;
** This has to do with how we smooth the data. Will be reviewed in more detail later;


run;

** Step 6.1: Results for just those who die;

      proc lifetest data=heart_attack(where=(fstat=1)) plots=hazard(bw=200);
       time lenfol*fstat(0);

 run;

 ** Step 6.2: Results for everyone;

      proc lifetest data=heart_attack plots=hazard(bw=200);
       time lenfol*fstat(0);

 run;


**Step 7:Graph of Cumulative Hazard Function;

run;

data whas500; 
 set heart_attack; 

ods output ProductLimitEstimates = ple;
proc lifetest data=whas500(where=(fstat=1))  nelson outs=outwhas500;
time lenfol*fstat(0);

run;

ods output ProductLimitEstimates = ple;
proc lifetest data=heart_attack(where=(fstat=1))  nelson outs=outwhas500;
time lenfol*fstat(0);

run;

proc print data=ple; 
 title 'here is ple'; 

 run; 

proc sgplot data = ple;
series x = lenfol y = CumHaz;
Title 'Cumulative Hazard Curve'; 

run;



** Step 8: Proc Univariate on variables in Model;

run;
   Proc univariate data=heart_attack;
 var gender age bmi hr lenfol;

run;


** Step 9: Proc Corr;

proc corr data = heart_attack plots(maxpoints=none)=matrix(histogram);
var lenfol gender age bmi hr;

run;


** Step 10: Kelman-Mier Estimation;


proc lifetest data=heart_attack atrisk outs=outwhas500;
time lenfol*fstat(0);


run;


** Step 11: Add confidence intervals to surival probablities;


run;
**ods html path="C:\UC Berkley\Logistic Reg & Survival Analysis\For Students\Hazard Model\overview\"
         gpath="C:\UC Berkley\Logistic Reg & Survival Analysis\For Students\Hazard Model\overview"
         ;
ods html path="H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Logistic Reg & Survival Analysis\For Students\Hazard Model\Overview"
         gpath="H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Logistic Reg & Survival Analysis\For Students\Hazard Model\Overview"
         ;
proc lifetest data=heart_attack atrisk plots=survival(cb) outs=outwhas500;
time lenfol*fstat(0);

Run;


** Step 12: Derive the Cumulative Hazard Function;

run;


ods output ProductLimitEstimates = ple;
proc lifetest data=heart_attack(where=(fstat=1))  nelson outs=outwhas500;
time lenfol*fstat(0);

run;

proc sgplot data = ple;
series x = lenfol y = CumHaz;
Title 'Cumulative Hazard Curve'; 

run;

ods output ProductLimitEstimates = ple;
proc lifetest data=heart_attack nelson outs=outwhas500;
time lenfol*fstat(0);

run;



** Step 13: Derive the statistics on the Surival Function;

   run;

      proc lifetest data=heart_attack atrisk nelson;
      time lenfol*fstat(0);

  run;


** Step 14: Compare men and women surival curves;

run;
proc format;
 value gender
 0 = 'Men'
 1 = 'Women'
;

run;

proc lifetest data=heart_attack atrisk plots=survival(atrisk cb) outs=outwhas500;
strata gender;
time lenfol*fstat(0);
format gender gender.;
run; 

** Step 14a: Check Age; 

run;
proc sort data=heart_attack; 
 by gender; 

proc univariate data=heart_attack; 
 by gender; 
  var age; 
format gender gender.; 
**where age <= 69; 

  run; 

** Step 14b: Constrain everyone to be 69; 

run;

proc lifetest data=heart_attack atrisk plots=survival(atrisk cb) outs=outwhas500;
strata gender;
time lenfol*fstat(0);
format gender gender.;
**where age <= 69; 

run; 

** Step 14c: CHeck afb; 

proc format; 
 value afb
 0 = 'No AFB'
 1 = 'AFB'
 ; 

proc lifetest data=heart_attack atrisk plots=survival(atrisk cb) outs=outwhas500;
strata afb;
time lenfol*fstat(0);
**format gender gender.;
format afb afb.; 
**where age <= 69; 

run; 

** Check Heart Rate; 

 data check_hr; 
  set heart_attack; 
   rank_hr = hr; 

   proc rank data=check_hr group=3 out=ranks; 
      var rank_hr; 

proc format; 
 value hr
  0 = 'low'
  1 = 'med'
  2 = 'high'
  ; 

proc lifetest data=ranks atrisk plots=survival(atrisk cb) outs=outwhas500;
strata rank_hr;
time lenfol*fstat(0);
**format gender gender.;
format rank_hr hr.; 


run; 

** Check BMI; 

 data check_hr; 
  set heart_attack; 
   rank_bmi = bmi; 

   proc rank data=check_hr group=3 out=ranks; 
      var rank_bmi; 

proc format; 
 value bmi
  0 = 'low'
  1 = 'med'
  2 = 'high'
  ; 

proc lifetest data=ranks atrisk plots=survival(atrisk cb) outs=outwhas500;
strata rank_bmi;
time lenfol*fstat(0);
**format gender gender.;
format rank_bmi bmi.; 


run; 



** Step 15: Smoothed hazard function;


proc lifetest data=heart_attack atrisk plots=hazard (bw=10) outs=outwhas500;
**strata bmi(15,18.5,25,30,40);
time lenfol*fstat(0);
where lenfol<=2000;

run;

** Step 16: Stratified Hazard Function by BMI;


proc lifetest data=heart_attack atrisk plots=hazard(bw=200) outs=outwhas500;
strata bmi(15,18.5,25,30,40);
time lenfol*fstat(0);
where lenfol<=2000;
title 'lenfol <=2000';

run;

run;

proc lifetest data=heart_attack atrisk plots=hazard(bw=200) outs=outwhas500;
strata bmi(15,18.5,25,30,40);
time lenfol*fstat(0);
where lenfol<=1750;
title 'lenfol <=1750';


run;

proc lifetest data=heart_attack atrisk plots=hazard(bw=200) outs=outwhas500;
strata bmi(15,18.5,25,30,40);
time lenfol*fstat(0);
where lenfol<=1250;
title 'lenfol <=1250';


run;



** Step 17: Introduction to Cox Proporitional Hazard Model;

run;

run;
**Results for gender only;
proc phreg data = heart_attack;
class gender/desc;
model lenfol*fstat(0) = gender;
run;


proc phreg data = heart_attack;
class gender / desc;
model lenfol*fstat(0) = gender age;;
run;

** Step 18: Discussion of Age;

run;

proc format;
 value gender
 0 = 'Men'
 1 = 'Women'
;

run;

  proc means data=heart_attack;
  **class gender/desc;
  class gender;
  var age;
  output out=stats mean=;
 format gender gender.;


run;


** Step 19: Introducing Interaction Terms;

** Step 19a: We begin with understanding the difference for men and women when you use the class statement;

** First no class statement;
proc phreg data = heart_attack;
**class gender;
model lenfol*fstat(0) = gender /*age*/;
title 'No Class on Gender';
run;

** Second class statement;
proc phreg data = heart_attack;
class gender;
model lenfol*fstat(0) = gender ;
title 'Class on Gender';
run;

** Third class statement with decending;
proc phreg data = heart_attack;
class gender / desc;
model lenfol*fstat(0) = gender ;
title 'Class on Gender';
run;



 ** Step 19b: We add in interaction terms;
 ** Note: Existence of the class statement with desending menas that 0=Male and 1= FeMale;

proc phreg data = heart_attack;
class gender / desc;
**model lenfol*fstat(0) = gender|age bmi|bmi hr ;
model lenfol*fstat(0) = gender|age bmi hr ;
format gender gender.;
run;

**Compare to no class statement Results Same because we add descend;
proc phreg data = heart_attack;
**class gender / desc;
**model lenfol*fstat(0) = gender|age bmi|bmi hr ;
model lenfol*fstat(0) = gender|age bmi hr ;
format gender gender.;
run;


** Step 20: Help with interpreting Interaction Terms;
** Note we are adding in a bmi term as well;

**Start with No Hazard Ratio;

run;
proc phreg data = heart_attack;
class gender / desc;
model lenfol*fstat(0) = gender|age bmi hr ;
**format gender gender.;

run; 
**Add Hazard Ratio;
proc phreg data = heart_attack;
class gender / desc;
model lenfol*fstat(0) = gender|age bmi hr ;
hazardratio 'Effect of 1-unit change in age by gender' age / at(gender=ALL);
hazardratio 'Effect of gender across ages' gender / at(age=(0 20 40 60 80));
format gender gender.;

run;


** Step 21: Graphical Results for surival curves;

data covs2;
format gender gender.;
input gender age bmi hr;
datalines;
0 40 26.614 23.586
0 60 26.614 23.586
0 80 26.614 23.586
1 40 26.614 23.586
1 60 26.614 23.586
1 80 26.614 23.586
;
run;

**proc phreg data = heart_attack plots(overlay=group)=(survival);
proc phreg data = heart_attack plots=(survival);
class gender / desc;
model lenfol*fstat(0) = gender|age bmi hr ;
baseline covariates=covs2  / rowid=age group=gender;
format gender gender.;
run;


** Step 22 Introducing time varying covariates;


run;

proc phreg data = heart_attack;
class gender / desc;
model lenfol*fstat(0) = gender|age bmi hr in_hosp ;
if lenfol > los then in_hosp = 0;
else in_hosp = 1;

run;


** Step 23 Adjusting the covariate form;


proc phreg data = heart_attack;
class gender / descending;
model lenfol*fstat(0) = gender age bmi hr;

run;


** Step 24 Using Martingale Residuals to get the correct functional form of the data;


run;

proc phreg data = heart_attack;
class gender / desc;
model lenfol*fstat(0) = ;
output out=residuals resmart=martingale;

run;

proc loess data = residuals plots=ResidualsBySmooth(smooth);
**model martingale = bmi / smooth=0.2 0.4 0.6 0.8;
model martingale = bmi / smooth=0.8;

run;

** Step 24a: Try the the residuals against bmi;

run;

proc phreg data = heart_attack;
class gender / desc;
model lenfol*fstat(0) = bmi;
output out=residuals resmart=martingale;

run;

proc loess data = residuals plots=ResidualsBySmooth(smooth);
**model martingale = bmi / smooth=0.2 0.4 0.6 0.8;
model martingale = bmi / smooth=0.8;
title "BMI Only";



run;

** Step 24b: Try the the residuals against bmi and bmi^2;

proc phreg data = heart_attack;
class gender / desc;
model lenfol*fstat(0) = bmi|bmi ;
output out=residuals resmart=martingale;

run;

proc loess data = residuals plots=ResidualsBySmooth(smooth);
**model martingale = bmi / smooth=0.2 0.4 0.6 0.8;
model martingale = bmi / smooth=0.8;
title "BMI with BMI^2 ";

run;


** Step 25 Try access on Woreschter Heart Attack;


    ods graphics on;
   proc phreg data=heart_attack;
      model lenfol*fstat(0)=gender|age bmi hr;
     assess var=(age bmi hr) / resample;
      run;
   ods graphics off;

run;


**Step 26: Cerious of the Liver example;


run;

%macro skipit;
**C:\UC Berkley\Logistic Reg & Survival Analysis\Fo
r Students\Hazard Model\Chapter 6\cerious_liver.xls; 

run;
PROC IMPORT OUT= WORK.liver
            DATAFILE= "H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Logistic Reg & Survival Analysis\For Students\Hazard Model\Data\Cirhosus.xls"
            DBMS=EXCEL REPLACE;
     RANGE="PBC_DAT";
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;


********************************************************************************;
* Variable meanings;
      N         Case number.
      time      X         The number of days between registration and the earlier of death,
                    liver transplantation, or study  analysis time in July, 1986.
      staus     D         1 if X is time to death, 0 if time to censoring
               Z1        Treatment Code, 1 = D-penicillamine, 2 = placebo.
      age      Z2        Age in years. For the first 312 cases, age was calculated by dividing the number of days between birth

                    and study registration by 365.
      Sex      Z3        Sex, 0 = male, 1 = female.
               Z4        Presence of ascites, 0 = no, 1 = yes.
               Z5        Presence of hepatomegaly, 0 = no, 1 = yes.
               Z6        Presence of spiders 0 = no, 1 = Yes.
    edema      Z7        Presence of edema, 0 = no edema and no diuretic therapy for
                 edema; 0.5 = edema present for which no diuretic therapy was given, or
                 edema resolved with diuretic therapy; 1 = edema despite diuretic therapy
   bilirubin  Z8        Serum bilirubin, in mg/dl.
              Z9        Serum cholesterol, in mg/dl.
   albumin    Z10       Albumin, in gm/dl.
              Z11       Urine copper, in mg/day.
              Z12       Alkaline phosphatase, in U/liter.
              Z13       SGOT, in U/ml.
              Z14       Triglycerides, in mg/dl.
              Z15       Platelet count; coded value is number of platelets
                        per-cubic-milliliter of blood divided by 1000.
 protime      Z16       Prothrombin time, in seconds.
              Z17       Histologic stage of disease, graded 1, 2, 3, or 4.

%mend skipit;


run;
data local.liver;
 set liver;

run;

run;
   data liver2;
   set local.liver;
 time = x;
 status = d;
Bilirubin = z8;
Protime   = z16;
Albumin   = z10;
Age       = z2;
Edema     = z7;

run;

**Step 26a use raw form of Bilirubin;


    ods graphics on;
   proc phreg data=Liver2;
      model Time*Status(0)=Bilirubin logProtime logAlbumin Age Edema;
      logProtime=log(Protime);
      logAlbumin=log(Albumin);
      assess var=(Bilirubin) /  resample seed=7548;
      run;
   ods graphics off;

run;

**Step 26b: Use log of bilirubin;


run;
    ods graphics on;
   proc phreg data=Liver2;
      model Time*Status(0)=logBilirubin logProtime logAlbumin Age Edema;
      logProtime=log(Protime);
      logAlbumin=log(Albumin);
      logbilirubin = log(bilirubin);
      assess var=(logBilirubin) /  resample seed=7548;
      run;
   ods graphics off;

run;
