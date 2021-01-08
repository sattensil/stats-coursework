run;

libname school 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Overview';

**libname school 'C:\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\overview';


run;

**proc print data=school.hsb2;
**title 'here is hsb2';

run;

**Step 1: Create a binary variable you want to predict;

 data model_data;
   set school.hsb2;
   hiwrite = write >=52;

   proc freq data=model_data;
    table hiwrite*female prog / missing;
         title 'here is hiwrite';
         run;

**Step 2: Results of model against gender;

         run;

 proc logistic data =  model_data;
  model hiwrite (event='1') = female ;
  ods output ParameterEstimates = model_female;
run;

** Step 3: Results when we add in the Student's math score;

proc sort data=model_data; 
 by female; 

proc means data=model_data; 
 var math;
output out=stats mean=;  
 by female; 
 format female female.; 

 run;

proc logistic data = model_data;
  model hiwrite (event='1') = female math;
  output out = m2 p = prob xbeta = logit;
run;

proc print data=m2(obs=50); 
 title 'm2'; 

 run; 

** Step 4: Graphical comparison of Males and Females for Math Score Vs. Probablity of being a good writer;

Proc format;
value female
 0 = 'Male'
 1 = 'Female'
 ;

proc sort data = m2;
  by math;
run;

symbol1 i = join v=star l=32  c = red;
symbol2 i = join v=circle l = 1 c=blue;
proc gplot data = m2;
  plot logit*math = female;
  plot prob*math = female;
  format female female.;
run;
quit;

**Just math by itself; 

proc logistic data = model_data;
  model hiwrite (event='1') = math;
  output out = m2 p = prob xbeta = logit;
run;

proc sort data=m2; 
 by math; 
proc print data=m2(obs=50); 
 title 'm2'; 

 run; 

symbol1 i = join v=star l=32  c = red;
symbol2 i = join v=circle l = 1 c=blue;
proc gplot data = m2;
  plot logit*math;
  plot prob*math ;
  format female female.;
run;
quit;


** Step 5: product impact of a 5 unit increase in the score value;

proc logistic data = model_data ;
  model hiwrite (event='1') = female math /clodds=wald;
  units math = 5;
run;


** Step 6: Review the class statement;

 proc logistic data = model_data ;
  class prog (ref='1') /param = ref;
  model hiwrite (event='1') = female read math prog ;
run;

**Step 6.5: Do 5 point unit increase for read and math; 

 proc logistic data = model_data ;
  class prog (ref='1') /param = ref;
  model hiwrite (event='1') = female read math prog / clodds=wald;
  units math=5 read=5; 
run;


** Step 7: Contrast Statement Semiar Way 1 vs 2;

proc logistic data = model_data ;
  class prog /param = glm ;
  model hiwrite (event='1') = female read math prog;
  contrast '1 vs 2 of prog' prog 1 -1 0 / estimate;
run;

** Step 8: Contrast Statement Semiar Way 2 vs 3;

proc logistic data = model_data ;
  class prog /param = glm ;
  model hiwrite (event='1') = female read math prog;
  contrast '2 vs 3 of prog' prog 0 1 -1 / estimate;
run;


**STep 9: Test Statement;

proc logistic data = model_data ;
  class prog(ref='1') /param = ref;
  model hiwrite (event='1') = prog female read math;
  test_read_math: test read, math;
  test_equal: test read = math;


  run;


**Step 10: Regression Diagnositics;

proc logistic data = model_data;
  class prog(ref='1') /param = ref;
  model hiwrite(event='1') = female prog read math / rsq lackfit;
run;


** Step 11: Influential Observations;

proc logistic data = model_data ;
  class prog(ref='1') /param = ref;
  model hiwrite(event='1') = female prog read math ;
  output out=dinf prob=p resdev=dr h=pii reschi=pr difchisq=difchi;
run;

goptions reset = all;
symbol1 pointlabel = ("#id" h=1 )  value=none;
proc gplot data = dinf;
  plot difchi*p;
run;
quit;

proc print data=dinf; 
where id=187; 
 title 'dinf'; 
run; 
** Step 12: Scoring a data set;


proc sql;
  create table gdata as
  select distinct female, (prog=2) as prog2,(prog=3) as prog3,
                  mean(read) as read, mean(math) as math
  from model_data;
quit;

run;

proc print data=gdata;
 title 'here is gdata';

run;


proc logistic data = model_data outest=mg;
  class prog(ref='1') /param = ref;
  model hiwrite(event='1') = female prog read math ;
run;

proc print data=mg; 
 title 'here is mg'; 

 run; 

*Scoring the data set to get the linear predictions;
proc score data=gdata score=mg out=gpred type=parms;
  var female prog2 prog3 read math;
run;

proc print data=gpred; 
 title 'gpred'; 

 run; 

data gpred;
  set gpred;
  odds = exp(hiwrite);
  p_1 = odds /(1+odds);
  p_0 = 1 - p_1;

run;

proc print data=gpred;
title 'here is gpred';

run;



