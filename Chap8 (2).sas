
run;

**libname chap8
'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Chapter 8';

libname chap8 'C:\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Chapter 8';



run;

%macro skipit;

run;

data chap8.lowbirth;
    set lowbirth;

  data chap8.placement;
   set placement;

run;

%mend;

 data lowbirth;
   set chap8.lowbirth;

   run;

 data placement;
  set chap8.placement;

  run;

  proc format;
   value place
   0 = 'outpaitent'
   1 = 'Half Way House'
   2 = 'Residential'
   ;

   run;

  **Step 1: Table 8.1;

  proc freq data=placement;
   table place3*VIOL / missing;
   format place3 place. ;
    title 'placement results';

        run;

**Step 2: Table 8.2;

**Step 2a: proc logistic on first place3;

proc logistic data = placement;
  model place3(event='1') = viol;
  output out = m2 p = prob xbeta = logit;
  where place3 in (0,1);
run;

**Step 2b: proc logistic on Second place3;

proc logistic data = placement;
  model place3(event='2') = viol;
  output out = m2 p = prob xbeta = logit;
  where place3 in (0,2);
run;


**Step 2c: Match results using the link functin GLOGIT;


proc logistic data = placement;
  class place3 (ref='0') viol (ref='0');
  model place3 /*(event='0')*/  = viol / link=glogit;
  output out = m2 p = prob xbeta = logit;
run;

****Step 2d: Lets to the Proc Genmod as suggested by Allison to clarify ;
** Why are numbers are different from Hosmer and Lemeshow;

 proc catmod data=placement;
  direct viol;
   model place3  = viol / Noiter;
   response joint;

   run;

**Step 2e Wallet data from  Allison;
** As eventually seen if we use the class statement and include a;
** param=ref then we get results similiar to what is shown in Hosmer and Lemeshow;

%macro skipit;
----------------
WALLET Data Set
----------------

 Data described in Chapter 5 of P.D. Allison, "Logistic Regression
 Using the SAS System: Theory and Application."                 */

 %mend skipit;

 run;

data chap8.wallet;
input wallet male business punish explain;
datalines;
2 0 0 2 0
2 0 0 2 1
3 0 0 1 1
3 0 0 2 0
1 1 0 1 1
3 0 0 1 1
3 0 0 1 1
3 1 0 1 1
3 1 0 1 1
3 0 0 2 1
2 0 1 1 1
3 1 1 1 1
3 1 0 1 1
3 1 0 1 1
3 0 0 1 1
3 0 0 1 0
3 0 0 2 1
2 0 0 3 0
1 1 1 3 0
2 0 0 1 1
2 1 0 2 0
3 0 0 1 1
3 1 0 1 1
3 1 1 1 0
3 1 0 1 1
2 0 0 1 0
2 1 0 3 0
1 1 0 2 0
3 1 0 2 0
3 1 0 1 1
3 0 0 1 1
3 1 0 2 1
1 1 0 1 1
3 0 0 2 0
3 1 0 1 0
3 1 1 2 1
3 0 0 2 0
3 0 0 1 1
3 1 0 1 1
3 0 0 1 1
3 0 0 1 1
3 0 0 1 1
3 0 0 2 0
3 1 1 1 1
3 1 0 1 1
3 0 0 1 1
3 0 0 1 1
3 0 0 1 0
3 0 1 3 0
3 1 0 2 0
2 0 0 2 1
3 0 0 1 1
3 1 0 1 1
3 1 0 1 1
3 1 0 1 0
3 1 1 1 0
3 1 0 1 0
2 1 1 3 1
3 0 0 1 1
3 0 0 3 1
3 0 0 1 1
3 0 0 1 0
3 0 0 1 1
1 0 1 1 1
3 0 0 1 0
3 1 0 1 1
1 1 0 1 0
3 1 0 3 1
2 1 0 3 1
1 1 1 2 1
1 1 0 2 1
3 0 0 1 1
3 0 0 3 0
2 1 0 1 1
2 0 0 1 1
2 1 0 1 1
3 0 0 1 0
3 1 1 1 1
3 1 0 1 1
3 0 0 1 1
3 0 1 1 1
3 0 0 1 1
3 0 0 1 1
3 0 0 2 1
2 1 1 1 0
3 1 0 1 1
3 0 0 1 1
2 1 1 1 1
3 0 0 1 1
3 1 1 1 1
3 0 0 1 1
3 0 0 1 1
3 0 0 1 1
3 0 1 1 1
3 0 0 2 1
1 1 1 1 1
1 1 0 2 0
2 1 0 1 1
1 1 1 1 1
2 1 0 1 1
1 1 1 3 0
2 1 1 1 1
1 1 1 3 1
3 0 0 3 1
3 0 0 1 1
2 0 0 1 1
3 0 0 1 1
1 0 1 3 0
3 0 0 1 1
2 0 0 1 0
3 0 0 1 1
3 0 0 1 1
2 1 0 1 1
3 1 0 1 1
3 0 0 1 1
1 1 0 3 0
2 1 0 1 1
2 0 1 1 1
1 0 0 3 0
1 0 1 2 0
3 0 0 1 1
3 0 0 1 1
3 0 0 1 1
3 1 1 1 1
3 0 0 1 0
3 0 0 1 1
3 1 0 1 1
3 1 1 1 1
3 1 0 1 1
2 1 1 1 1
2 0 0 1 0
3 0 0 1 1
2 1 1 2 0
3 1 0 1 0
2 1 0 1 0
3 0 0 2 1
3 1 1 1 1
1 0 0 3 0
3 0 0 1 1
3 1 1 1 1
3 0 0 1 0
3 0 1 1 0
2 0 0 1 1
3 1 0 1 1
2 1 0 1 0
3 0 0 1 0
2 1 0 1 1
3 1 0 1 1
3 1 0 2 0
3 1 1 2 1
3 1 0 1 1
2 1 0 1 0
3 0 0 1 1
3 1 0 1 1
2 1 1 1 0
3 0 0 1 1
3 1 0 1 1
2 1 0 1 0
3 0 1 2 1
2 1 1 2 1
3 0 0 1 1
1 1 0 1 1
3 1 1 3 1
2 1 0 1 1
1 0 0 1 0
2 1 0 3 0
3 0 0 1 1
2 1 1 1 1
3 0 0 1 1
2 0 0 2 0
2 1 0 1 1
1 1 1 2 0
2 1 0 2 0
2 0 0 1 1
1 0 1 3 0
2 1 0 1 1
2 1 0 1 1
3 1 0 1 1
3 0 0 1 1
2 1 0 1 1
1 1 0 2 0
2 0 1 2 1
3 0 0 2 0
2 1 1 1 1
3 0 1 2 1
1 0 0 3 0
2 1 1 1 0
3 0 0 3 1
2 1 0 2 1
3 0 0 1 1
3 1 0 3 1
3 0 0 1 1
3 1 1 1 1
3 1 0 1 1
2 1 0 1 1
;

run;

**Step 2e1: What does logistic look like;

proc format;
 value wallet
 1 = 'Keep Both'
 2 = 'Keep Money'
 3 = 'Return Both'
;
 value male
  0 = 'Female'
  1 = 'Male'
  ;
  value business
  0 ='Not Bus Major'
  1 = 'Bus Major'
  ;
  value punish
  1 = 'Punished Elementary'
  2 = 'Punished Elem & Middle'
  3 = 'Punihsed All School'
  ;
  Value explain
  0 = 'Not Explained'
  1 = 'Explained'
  ;
  run;

run;


proc freq data=chap8.wallet;
 table wallet*(male business punish explain) / missing;
 format wallet wallet. male male. business business. punish punish. explain explain.;

run;

proc logistic data=chap8.wallet;
 class male (ref='0') business (ref='0') punish (ref='1') explain (ref='0')/param=ref;
 **model wallet(event='3') = male business punish explain;
 model wallet(event='3') = punish;
 where wallet in (1,3);  **and punish in (1,2);

 run;

****Step 2f: Lets return to the original problem;
**   Here we will use a class statement and param=ref;
** That will match what we get in Hosmer and Lemeshow;

 proc freq data=placement;
  table viol / missing;
  title 'viol';

  run;

proc logistic data = placement;
  class place3 (ref='0') viol (ref='0')/param=ref;
  model place3 (event='2')  = viol / link=glogit;
  output out = m2 p = prob xbeta = logit;
run;


**** Step 3: Dervie Table 8.5;

proc format;
 value danger
 0 = 'Unlikely'
 1 = 'Possible'
 2 = 'Probable'
 3 = 'Likely'
;

proc freq data=placement;
 table danger / missing;
 format danger danger.;

 run;

proc logistic data = placement outest=est;
  class place3 (ref='0') viol (ref='0') danger(ref='0')/param=ref;
  **model place3 (event='2')  = viol / link=glogit;
  model place3 (event='2')  = danger / link=glogit ;
  output out = m2 p = prob xbeta = logit;
run;


***Step 4: Derive Table 8.6;

  data new_placement;
    set placement;
         danger_d=0;
          if danger > 0 then danger_d = 1;
          LOS_5 = sqrt(los);
          L_C = los_5*custd;
                  age2 = age**2;
run;
options mprint symbolgen;

%macro skipit;

*); */; /*’*/ /*”*/; %mend;

%mend skipit;

run;

%macro hood(data=,var=,num=,intercept_only=,dof=);

   proc logistic data = &data outest=est;
  class place3 (ref='0') viol (ref='0') danger(ref='0') race(ref='0') neuro(ref='0') emot(ref='0') danger_d(ref='0')
        elope(ref='0') custd(ref='0')  /param=ref;
  **model place3 (event='2')  = viol / link=glogit;
  model place3 (event='2')  = &var / link=glogit ;
  output out = m2 p = prob xbeta = logit;
run;

   %if (&num=1) %then %do;

      data stats;
           set est;
           format var $12.;
           first_term = (-2*_LNLIKE_);
           ratio =  &intercept_only - first_term;
           var="&var";
           p=1-probchi(ratio,&dof);
           dof=&dof;
           **keep var ratio p;

    proc print data=stats;
       var var _lnlike_ first_term ratio p dof;
            title 'here are stats';

  run;

  %end;
  %else %do;

     data temp;
           set est;
           first_term = (-2*_LNLIKE_);
           ratio =  &intercept_only - first_term;
           var="&var";
           p=1-probchi(ratio,&dof);
           dof=&dof;
           keep var ratio p dof;

     data stats;
          set stats temp;
      keep var ratio p dof;

  %end;

%mend hood;

run;

%hood(data=new_placement,var=age,num=1,intercept_only=1048.742,dof=2);
%hood(data=new_placement,var=race,num=2,intercept_only=1048.742,dof=2);

run;

%hood(data=new_placement,var=gender,num=2,intercept_only=1048.742,dof=2);
%hood(data=new_placement,var=neuro,num=2,intercept_only=1048.742,dof=6);
%hood(data=new_placement,var=emot,num=2,intercept_only=1048.742,dof=2);
%hood(data=new_placement,var=danger,num=2,intercept_only=1048.742,dof=6);
%hood(data=new_placement,var=elope,num=2,intercept_only=1048.742,dof=2);
%hood(data=new_placement,var=LOS,num=2,intercept_only=1048.742,dof=2);
%hood(data=new_placement,var=behav,num=2,intercept_only=1048.742,dof=2);
%hood(data=new_placement,var=custd,num=2,intercept_only=1048.742,dof=2);
%hood(data=new_placement,var=viol,num=2,intercept_only=1048.742,dof=2);
%hood(data=new_placement,var=danger_d,num=2,intercept_only=1048.742,dof=2);

run;

proc print data=stats;
var var ratio dof p;
 title 'here is table 8.6';

 run;


 ***Step 5: Derive Table 8.7;
 ** IN all these cases the key is that place3 (ref=0);
 ** This caused the reference, the denominaator of the odds ratio;
 ** to be 0 and you are predicting the numerator which is 1 or 2;

run;
**FIrst we predict without  having a class statement for place3;

   proc logistic data = new_placement outest=est;
  class /*place3 (ref='0')*/ viol (ref='0') danger(ref='0') race(ref='0') neuro(ref='0') emot(ref='0') danger_d(ref='0')
        elope(ref='0') custd(ref='0')  /param=ref;
  **model place3 (event='2')  = viol / link=glogit;
  model place3 (event='0')  =  AGE RACE GENDER EMOT DANGER_D ELOPE LOS BEHAV CUSTD VIOL
/ link=glogit ;
  output out = m2 p = prob xbeta = logit;
  title 'Notice that Event = does not impact the coefficent values';
  title 'But the class statement with place3 ref=- or ref=2 does';


run;

**Now we introduce the class statement with ref=0;

   proc logistic data = new_placement outest=est;
  class place3 (ref='0') viol (ref='0') danger(ref='0') race(ref='0') neuro(ref='0') emot(ref='0') danger_d(ref='0')
        elope(ref='0') custd(ref='0')  /param=ref;
  **model place3 (event='2')  = viol / link=glogit;
  model place3 /*(event='0')*/  =  AGE RACE GENDER EMOT DANGER_D ELOPE LOS BEHAV CUSTD VIOL
/ link=glogit ;
  output out = m2 p = prob xbeta = logit;
  title 'Notice that Event = does not impact the coefficent values';
  title2 'But the class statement with place3 ref=0 or ref=2 does';
  title3 'Our Odds ratios are for 0 on the bottom and 1 or 2 on top';


run;

**Lets verify the value of Danger_d by looking at it alone;

   proc logistic data = new_placement outest=est;
  class place3 (ref='0') viol (ref='0') danger(ref='0') race(ref='0') neuro(ref='0') emot(ref='0') danger_d(ref='0')
        elope(ref='0') custd(ref='0')  /param=ref;
  **model place3 (event='2')  = viol / link=glogit;
  model place3 /*(event='0')*/  =  DANGER_D
/ link=glogit ;
  output out = m2 p = prob xbeta = logit;
  title 'Notice that Event = does not impact the coefficent values';
  title2 'But the class statement with place3 ref=0 or ref=2 does';
  title3 'Our Odds ratios are for 0 on the bottom and 1 or 2 on top';


run;


**Verify with a tabulate statement;

data tabulate;
 set new_placement;
  one = 1;

  proc format;
   value place
   0 = 'outpaitent'
   1 = 'Half Way House'
   2 = 'Residential'
   ;
  value danger
   0 = 'Not Danger'
   1 = 'Mayber Danger'
   ;

proc tabulate data=tabulate noseps;
 class place3 danger_d;
 var one ;
table (place3='' all='Total' )*(
 one =' '*sum=''*f=comma20.0
),(danger_d='' all='total')
 / rts=25 condense
;
format place3 place. danger_d danger.;
title "Results for place3=&place3";

run;




 ***Step 6: Derive Table 8.8;

proc logistic data = new_placement outest=est;
  class place3 (ref='0') viol (ref='0') danger(ref='0') race(ref='0') neuro(ref='0') emot(ref='0') danger_d(ref='0')
        elope(ref='0') custd(ref='0')  /param=ref;
  **model place3 (event='2')  = viol / link=glogit;
  model place3 (event='2')  =  AGE RACE DANGER_D LOS BEHAV CUSTD
/ link=glogit ;
  output out = m2 p = prob xbeta = logit;

run;

***Step 7: Derive Table 8.9;

proc logistic data = new_placement outest=est;
  class place3 (ref='0') viol (ref='0') danger(ref='0') race(ref='0') neuro(ref='0') emot(ref='0') danger_d(ref='0')
        elope(ref='0') custd(ref='0')  /param=ref;
  **model place3 (event='2')  = viol / link=glogit;
  model place3 (event='2')  =  AGE RACE DANGER_D LOS_5 BEHAV CUSTD L_C
/ link=glogit ;
  output out = m2 p = prob xbeta = logit;

run;

***Step 8: Derive Table 8.10;

proc freq data=new_placement;
 table place3 / missing;
 title 'place3';

 run;

**Step 8a: First get the full model as in Sep 7;
proc logistic data = new_placement outest=est;
  class place3 (ref='0') viol (ref='0') danger(ref='0') race(ref='0') neuro(ref='0') emot(ref='0') danger_d(ref='0')
        elope(ref='0') custd(ref='0')  /param=ref;
  **model place3 (event='2')  = viol / link=glogit;
  model place3 (event='2')  =  AGE RACE DANGER_D LOS_5 BEHAV CUSTD L_C
/ link=glogit ;
  output out = m2 p = prob xbeta = logit;

run;

**Step 8b: Seperate Model First Compare Place3=1 to place3=0;
proc logistic data = new_placement outest=est;
  class place3 (ref='0') viol (ref='0') danger(ref='0') race(ref='0') neuro(ref='0') emot(ref='0') danger_d(ref='0')
        elope(ref='0') custd(ref='0')  /param=ref;
  **model place3 (event='2')  = viol / link=glogit;
  model place3 (event='1')  =  AGE RACE DANGER_D LOS_5 BEHAV CUSTD L_C
/ link=glogit ;
  output out = m2 p = prob xbeta = logit;
  where place3 in (0,1);
  title 'Results for Place in (0,1)';

run;

**Step 8c: Seperate Model First Compare Place3=2 to place3=0;
proc logistic data = new_placement outest=est;
  class place3 (ref='0') viol (ref='0') danger(ref='0') race(ref='0') neuro(ref='0') emot(ref='0') danger_d(ref='0')
        elope(ref='0') custd(ref='0')  /param=ref;
  **model place3 (event='2')  = viol / link=glogit;
  model place3 (event='2')  =  AGE RACE DANGER_D LOS_5 BEHAV CUSTD L_C
/ link=glogit ;
  output out = m2 p = prob xbeta = logit;
  where place3 in (0,2);
title 'Results for Place in (0,2)';

run;

**Step 9: Get Hosmer Lemeshow but does not work a/c not a binary response;
** Table 8.11;

**Step 9a: try an duse lackfit but does not work;

proc logistic data = new_placement outest=est;
  class place3 (ref='0') viol (ref='0') danger(ref='0') race(ref='0') neuro(ref='0') emot(ref='0') danger_d(ref='0')
        elope(ref='0') custd(ref='0')  /param=ref;
  **model place3 (event='2')  = viol / link=glogit;
  model place3 (event='2')  =  AGE RACE DANGER_D LOS_5 BEHAV CUSTD L_C
/ link=glogit lackfit;
  output out = m2 p = prob xbeta = logit;
  title 'Trying to get Hosmer Lemeshow Test for Multinominal Logistic Regression';

run;

**Step 9b: Try and find the cuts individually for each place3;

options mpring symbolgen;

%macro hl(data=,group=,place3=);

  data pre_hosmer;
   set &data;
   rank_prob = prob;
   one = 1;
   if place3 in &place3;

   run;
 proc rank data=pre_hosmer out=rank group=&group;
 var rank_prob;

run;

proc tabulate data=rank noseps;
 class rank_prob;
 var one prob;
table (rank_prob='' all='Total' ),(
 one =' '*sum='Tot #'*f=comma20.0
prob =' '*min ='Min Prob'*f=comma20.4
prob =' '*mean='Mn  Prob'*f=comma20.4
prob =' '*max ='Max Prob'*f=comma20.4

)
 / rts=25 condense
;
title "Results for place3=&place3";

run;

%mend hl;

run;

**%hl(data=m2,group=10,place3= (1));
%hl(data=m2,group=10,place3= (0,1,2))

run;

**Step 9c: We need for each person to get their probablity of having Place=0;
**         Then we take 1-Prob(y=0) and use this to get our rank ordering;
** Key is that that the output m2 has 1500 records so you have to take those;
** with level = 0 because they are probablity that the ID = 0;


proc logistic data = new_placement outest=est;
  class place3 (ref='0') viol (ref='0') danger(ref='0') race(ref='0') neuro(ref='0') emot(ref='0') danger_d(ref='0')
        elope(ref='0') custd(ref='0')  /param=ref;
  **model place3 (event='2')  = viol / link=glogit;
  model place3 (event='0')  =  AGE RACE DANGER_D LOS_5 BEHAV CUSTD L_C
/ link=glogit lackfit;
  output out = m2 p = prob xbeta = logit;
  title 'Predict the event 0 as that is what we need to do for Table 8.11';

  run;

  proc print data=m2;
   title 'here is m2';

   run;


%macro hlq(data=,group=,place3=,level=);

  data pre_hosmer;
   set &data;
   if _level_ = &level;
   rank_prob = prob;
   one = 1;
   if place3 in &place3;
   prob_no_zero = 1-prob;
   rank_no_zero = prob_no_zero;


   run;
 proc rank data=pre_hosmer out=rank group=&group;
 var rank_prob rank_no_zero;

run;

proc tabulate data=rank noseps;
 class rank_prob rank_no_zero;
 var one prob prob_no_zero;
table (rank_no_zero='' all='Total' ),(
 one =' '*sum='Tot #'*f=comma20.0
prob_no_zero =' '*min ='Min Prob'*f=comma20.4
prob_no_zero =' '*mean='Mn  Prob'*f=comma20.4
prob_no_zero =' '*max ='Max Prob'*f=comma20.4

)
 / rts=25 condense
;
title "Results for place3=&place3";

run;

%mend hl;

run;

%hlq(data=m2,group=10,place3= (0,1,2),level=0)

run;

**Step 9d: Okay now we have the distribution we use that;
** to get the results formated by what we got above;
** and constrain ourselves to levels 0,1,2 as that will point;
** to the probablities we need to get our results;
run;
options mprint symbolgen;

%macro hlqq(data=,group=,place3=,level=);

proc format;
 value prob
 low - 0.0465='0.0465'
0.0465-<0.0906='0.0906'
0.0906-<0.1386='0.1386'
0.1386-<0.2027='0.2027'
0.2027-<0.428='0.428'
0.428-<0.7746='0.7746'
0.7746-<0.8606='0.8606'
0.8606-<0.9003='0.9003'
0.9003-<0.9536='0.9536'
0.9536-<1='1'
;
run;

 data prob0;
  set &data;
  if _level_=0;
  prob0 = prob;
  prob1 = 1-prob;
  keep id prob0 prob1;

run;


%if (&level = 0) %then %do;

  data pre_hosmer;
   set &data;
   if _level_ = &level;
   rank_prob = prob;
   one = 1;
   if place3 in &place3;
   prob_no_zero = 1-prob;
   rank_no_zero = prob_no_zero;
   prob_format = prob;
    place3_0 = 0;
   place3_1 = 0;
   place3_2 = 0;
   if place3=0 then place3_0=1;
   if place3=1 then place3_1=1;
   if place3=2 then place3_2=1;

   run;

 proc rank data=pre_hosmer out=rank group=&group;
 var rank_prob rank_no_zero;

run;

proc tabulate data=rank noseps;
 class rank_prob rank_no_zero prob_format prob_no_zero;
 var one prob place3_0 place3_1 place3_2;
table (prob_no_zero='' all='Total' ),(
 one =' '*sum='Tot #'*f=comma20.0
 place3_0 =' '*sum='# 0'*f=comma20.0
 prob     =' '*sum='Sum Prob'*f=comma20.3
)
 / rts=25 condense
;
format prob_format prob_no_zero prob.;
title "Results for Level=&level";

%end;
%if (&level = 1) %then %do;

data pre_hosmer;
   set &data;
   if _level_ = &level;
   rank_prob = prob;
   one = 1;
   if place3 in &place3;
   prob_no_zero = 1-prob;
   rank_no_zero = prob_no_zero;
   prob_format = prob;
    place3_0 = 0;
   place3_1 = 0;
   place3_2 = 0;
   if place3=0 then place3_0=1;
   if place3=1 then place3_1=1;
   if place3=2 then place3_2=1;

   run;

   proc sql;
    create table pre_hosmer as
         select a.*,
                b.prob0,
                        b.prob1
         from pre_hosmer a,
              prob0      b
     where a.id=b.id
         ;
         quit;


 proc rank data=pre_hosmer out=rank group=&group;
 var rank_prob rank_no_zero;

run;


proc tabulate data=rank noseps;
 class rank_prob rank_no_zero prob_format prob0 prob1;
 var one prob prob_no_zero place3_0 place3_1 place3_2;
table (prob1='' all='Total' ),(
 one =' '*sum='Tot #'*f=comma20.0
 place3_1 =' '*sum='# 1'*f=comma20.0
 prob     =' '*sum='Sum Prob'*f=comma20.2
)
 / rts=25 condense
;
format prob_format prob0 prob1 prob.;
title "Results for Level=&level";

%end;
%if (&level = 2) %then %do;


data pre_hosmer;
   set &data;
   if _level_ = &level;
   rank_prob = prob;
   one = 1;
   if place3 in &place3;
   prob_no_zero = 1-prob;
   rank_no_zero = prob_no_zero;
   prob_format = prob;
    place3_0 = 0;
   place3_1 = 0;
   place3_2 = 0;
   if place3=0 then place3_0=1;
   if place3=1 then place3_1=1;
   if place3=2 then place3_2=1;

   run;

      proc sql;
    create table pre_hosmer as
         select a.*,
                b.prob0,
                        b.prob1
         from pre_hosmer a,
              prob0      b
     where a.id=b.id
         ;
         quit;


 proc rank data=pre_hosmer out=rank group=&group;
 var rank_prob rank_no_zero;

run;

proc tabulate data=rank noseps;
 class rank_prob rank_no_zero prob_format prob0 prob1;
 var one prob prob_no_zero place3_0 place3_1 place3_2;
table (prob1='' all='Total' ),(
 one =' '*sum='Tot #'*f=comma20.0
 place3_2 =' '*sum='# 2'*f=comma20.0
 prob     =' '*sum='Sum Prob'*f=comma20.2
)
 / rts=25 condense
;
format prob_format prob0 prob1 prob.;
title "Results for Level=&level";

run;

%end;


run;

%mend hlqq;

run;

%hlqq(data=m2,group=10,place3= (0,1,2),level=0) ;

run;


%hlqq(data=m2,group=10,place3= (0,1,2),level=1);

run;

%hlqq(data=m2,group=10,place3= (0,1,2),level=2);

run;


**Step 10: Diagnostic Tests Table 8.12;

run;

**Step 10a: Initial data and logistic regression;

data new_placement;
    set placement;
         danger_d=0;
          if danger > 0 then danger_d = 1;
          LOS_5 = sqrt(los);
          L_C = los_5*custd;
run;

proc freq data=new_placement;
 table place3*danger_d / missing;
  title 'How is danger_d working';

  run;


proc logistic data = new_placement outest=est;
  class place3 (ref='0') viol (ref='0') danger(ref='0') race(ref='0') neuro(ref='0') emot(ref='0') danger_d(ref='0')
        elope(ref='0') custd(ref='0')  /param=ref;
  **model place3 (event='2')  = viol / link=glogit;
  model place3 /*(event='0')*/  =  AGE RACE DANGER_D LOS_5 BEHAV CUSTD L_C
/ link=glogit lackfit;
  output out = m2 p = prob xbeta = logit;
  title 'Predict the event 0 as that is what we need to do for Table 8.11';
  title2 'Note that the class place3 (ref=0) takes priorit over the event=0';


  run;

**Step 10b: try out some diagnostic tools - First try influence and iplots;

ods graphics on;
proc logistic data = new_placement outest=est;
  class place3 (ref='0') viol (ref='0') danger(ref='0') race(ref='0') neuro(ref='0') emot(ref='0') danger_d(ref='0')
        elope(ref='0') custd(ref='0')  /param=ref;
  **model place3 (event='2')  = viol / link=glogit;
  model place3 =  AGE RACE DANGER_D LOS_5 BEHAV CUSTD L_C
/ link=glogit lackfit influence iplots;
  output out = m2 p = prob xbeta = logit;
  title 'Predict the event 0 as that is what we need to do for Table 8.11';
ods graphics off;

run;

**Step 10C: as seen those do not work because there are more than one reference point;
**          so we try the diagnostic tools on just one logistic at a time;

**PLace3 0 and 1;

ods graphics on;
proc logistic data = new_placement outest=est;
  class place3 (ref='0') viol (ref='0') danger(ref='0') race(ref='0') neuro(ref='0') emot(ref='0') danger_d(ref='0')
        elope(ref='0') custd(ref='0')  /param=ref;
  **model place3 (event='2')  = viol / link=glogit;
  model place3 =  AGE RACE DANGER_D LOS_5 BEHAV CUSTD L_C
/ link=glogit lackfit;
  output out = m2 p = p xbeta = logit resdev=dr h=pii reschi=pr difchisq=difchi dfbetas=diff_int diff_age diff_race diff_danger_d
                       diff_los_5 diff_behav diff_custd diff_l_c;
  where place3 in (0,1);
  title 'Predict the event 0 as that is what we need to do for Table 8.11';
ods graphics off;

run;

goptions reset = all;
symbol1 pointlabel = ("#id" h=1 )  value=none;
proc gplot data = m2;
  plot difchi*p;
  title 'results for diff chi square';
run;
quit;

symbol1 pointlabel = ("#id" h=1 )  value=none;
proc gplot data = m2;
  plot pii*p;
  title 'results for diff chi square';
run;
quit;


options mprint symbolgen;
%macro graph(var=);

goptions reset = all;
symbol1 pointlabel = ("#id" h=1 )  value=none;
proc gplot data = m2;
  plot &var*p;
 title "Diff Beta Results for var=&var";
run;
quit;

%mend graph;

run;

%graph(var=diff_age);
run;
%graph(var=diff_behav);
%graph(var=diff_custd);
%graph(var=diff_diff_race);
%graph(var=diff_danger_d);
%graph(var=diff_race);
%graph(var=diff_L_C);
run;


**PLace3 0 vs 2;

ods graphics on;
proc logistic data = new_placement outest=est;
  class place3 (ref='0') viol (ref='0') danger(ref='0') race(ref='0') neuro(ref='0') emot(ref='0') danger_d(ref='0')
        elope(ref='0') custd(ref='0')  /param=ref;
  **model place3 (event='2')  = viol / link=glogit;
  model place3 =  AGE RACE DANGER_D LOS_5 BEHAV CUSTD L_C
/ link=glogit lackfit;
  output out = m2 p = p xbeta = logit resdev=dr h=pii reschi=pr difchisq=difchi dfbetas=diff_int diff_age diff_race diff_danger_d
                       diff_los_5 diff_behav diff_custd diff_l_c;
  where place3 in (0,2);
  title 'Predict the event 0 as that is what we need to do for Table 8.11';
ods graphics off;

run;

goptions reset = all;
symbol1 pointlabel = ("#id" h=1 )  value=none;
proc gplot data = m2;
  plot difchi*p;
  title 'results for diff chi square';
run;
quit;

symbol1 pointlabel = ("#id" h=1 )  value=none;
proc gplot data = m2;
  plot pii*p;
  title 'results for diff chi square';
run;
quit;


options mprint symbolgen;
%macro graph(var=);

goptions reset = all;
symbol1 pointlabel = ("#id" h=1 )  value=none;
proc gplot data = m2;
  plot &var*p;
 title "Diff Beta Results for var=&var";
run;
quit;

%mend graph;

run;

%graph(var=diff_age);
run;
%graph(var=diff_behav);
%graph(var=diff_custd);
%graph(var=diff_diff_race);
%graph(var=diff_danger_d);
%graph(var=diff_race);
%graph(var=diff_L_C);
run;

**Step 11 Table 8.13;

proc logistic data = new_placement covout outest=est;
  class place3 (ref='0') viol (ref='0') danger(ref='0') race(ref='0') neuro(ref='0') emot(ref='0') danger_d(ref='0')
        elope(ref='0') custd(ref='0')  /param=ref;
  **model place3 (event='2')  = viol / link=glogit;
  model place3 =  AGE RACE DANGER_D LOS_5 BEHAV CUSTD L_C
/ link=glogit lackfit;
  output out = m2 p = p xbeta = logit resdev=dr h=pii reschi=pr difchisq=difchi dfbetas=diff_int diff_age diff_race diff_danger_d
                       diff_los_5 diff_behav diff_custd diff_l_c;
  unit age=2 behav=2;
  **where place3 in (0,1);
  title 'Results in Table 8.9';
ods graphics off;

run;

**Step 12: FIgure 8.1;

data _null_;
 set est;

if _name_ in ('Intercept_1') then do;
   call symput('Intercept_1',Intercept_1);
   call symput('Cov_1',LOS_5_1);
 end;
if _name_ in ('Intercept_2') then do;
   call symput('Intercept_2',Intercept_2);
   call symput('Cov_2',LOS_5_2);
 end;


 if _name_ in ('L_C_1') then do;
   call symput('L_C_1',L_C_1);
 end;
if _name_ in ('L_C_2') then do;
   call symput('L_C_2',L_C_2);
 end;
if _name_ in ('LOS_5_1') then do;
   call symput('LOS_5_1',LOS_5_1);
 end;
if _name_ in ('LOS_5_2') then do;
   call symput('LOS_5_2',LOS_5_2);
 end;
run;

 proc print data=est;
  title 'here is est';
  title2 "L_C_1 = &L_C_1 L_C_2=&L_C_2 intercept_1=&intercept_1 cov_1=&cov_1";
  title3 "LOS_5_1 = &LOS_5_1 LOS_5_2=&LOS_5_2 intercept_2=&intercept_2 cov_2=&cov_2";


  run;

  data graph_it;
   set new_placement;
   log_odds1 = 6.068 - 0.639 * LOS_5;
   log_odds2 = 3.086 - 0.254 * LOS_5;
   log_odds1_upper = log_odds1 + 2*sqrt(&intercept_1 + (LOS_5**2)*&los_5_1 +  2*&cov_1);
   log_odds1_lower = log_odds1 - 2*sqrt(&intercept_1 + (LOS_5**2)*&los_5_1 +  2*&cov_1);
   log_odds2_upper = log_odds2 + 2*sqrt(&intercept_2 + (LOS_5**2)*&los_5_2 +  2*&cov_2);
   log_odds2_lower = log_odds2 - 2*sqrt(&intercept_2 + (LOS_5**2)*&los_5_2 +  2*&cov_2);


run;

proc univariate data=graph_it;
 var los log_o;
 where place3 in (0,1);

 run;

proc sort data=graph_it;
 by los;

symbol1 i = join v=circle l=32  c = red;
symbol2 i = join v=none l = 1 c=blue;
symbol3 i = join v=none l = 1 c=blue;
proc gplot data = graph_it;
  plot log_odds1*Los log_odds1_upper*los log_odds1_lower*los / overlay;
  **where place3 in (0,1);
  title "Half Way House  Vs Day Care";

run;
quit;

symbol1 i = join v=circle l=32  c = red;
symbol2 i = join v=none l = 1 c=blue;
symbol3 i = join v=none l = 1 c=blue;
proc gplot data = graph_it;
  plot log_odds2*Los log_odds2_upper*los log_odds2_lower*los / overlay;
  **where place3 in (0,1);
  title " Residential Vs Day Care";

run;
quit;

**Step 13: Table 8.14;

**Step 13a: Start with low birth weight;

proc contents data=lowbirth;
 title 'here is low birth';

 run;

  data new_low_birth;
   set lowbirth;
   bwt_ord = -99999999;
   if bwt > 3500 then bwt_ord = 0;
   if 3000 < BWT <= 3500 then bwt_ord = 1;
   if 2500 < BWT <= 3000 then bwt_ord = 2;
   if BWT <= 2500 then bwt_ord = 3;

   run;

***Step 13b: Table 8.14;

proc freq data=new_low_birth;
 table bwt_ord*smoke / missing;
  title 'BWT_ORD vs Smoke';

  run;

**Step 13c: Verification of Odds provided in top of page 294;

proc logistic data = new_low_birth covout outest=est;
  class bwt_ord(ref='0') smoke (ref='0')  /param=ref;
  **model place3 (event='2')  = viol / link=glogit;
  model bwt_ord = smoke
/ link=glogit lackfit;
  output out = m2 p = p xbeta = logit resdev=dr h=pii reschi=pr difchisq=difchi dfbetas=diff_int diff_smoke;
  title 'Results in Table 8.15';
ods graphics off;

run;

**Step 14: Table 8.15 Adjant Catagory Model;
**     This does not provide the results in table 8.15;
** But it does provide the initial coefficent vales AND;
** The different intercept terms;

proc catmod data = new_low_birth;
  population smoke;
  response alogits;
  model bwt_ord = (0 1 0 0,
                0 0 1 0,
                0 0 0 1,
                1 1 0 0,
                1 0 1 0,
                1 0 0 1) ;
run;
quit;


**Step 15: Table 8.16 Continuation Ratio Model;

**Step 15a: We start with the first logistic which is just 0,1;

proc logistic data = new_low_birth;
   where bwt_ord = 0 | bwt_ord = 1;
   model bwt_ord (event="1") = smoke;
title 'First Row of Table 8.16';
run;

**Step 15b: We start with the first logistic which is just 0 & 1 vs 2;

data new_low_birth2;
  set new_low_birth;
  if (bwt_ord = 0 | bwt_ord = 1) then bcat2 = 0;
  else if bwt_ord = 2 then bcat2 = 1;
  if bwt_ord = 3 then bcat3=1;
  else bcat3=0;
   if bwt > 3500 then bwt_ord2 = 3;
   if 3000 < BWT <= 3500 then bwt_ord2 = 2;
   if 2500 < BWT <= 3000 then bwt_ord2 = 1;
   if BWT <= 2500 then bwt_ord2 = 0;

run;

proc logistic data = new_low_birth2;
   model bcat2 (event="1") = smoke;
title 'Second Row of Table 8.16';
run;

**Step 15b: We start with the first logistic which is just 0 & 1 vs 2;

proc logistic data = new_low_birth2;
   model bcat3 (event="1") = smoke;
title 'third Row of Table 8.16';
run;

**Step 16: Table 8.17 Continuation Ratio Model;
** Results taken from chapter 6 of Allisons SAS book See page 153;

data first;
  set new_low_birth2;
  stage1 = 0;
  stage2 = 0;
  stage3 = 1;
  adv = bwt_ord < 3;
run;

proc freq data=first;
 table bwt_ord*adv / missing;
 title 'first data';

 run;

data second;
  set new_low_birth2;
  stage1 = 0;
  stage2 = 1;
  stage3 = 0;
  if bwt_ord = 3 then delete;
  adv = bwt_ord < 2;
run;


data third;
  set new_low_birth2;
  stage1 = 1;
  stage2 = 0;
  stage3 = 0;
  if bwt_ord >=2 then delete;
  adv = bwt_ord < 1;
run;

data concat;
  set first second third;
run;

proc freq data=concat;
 table adv*(stage1 stage2 stage3) / missing;
  title 'here is concat';

  run;

proc logistic data = concat  ;
 model adv = stage1-stage3 smoke /noint ;
run;


**Step 17: Table 8.18 Proportional Odds Model;

**Step 17a: Results with no change in variable;
**          Results different from book;
**          where the coefficent values is opposite sign;
**          and intercepts are the same;
** NOTE: using decending we are predicting 1 over zero etc;


proc logistic data = new_low_birth2 descending;
  model bwt_ord = lwt ;
  **where bwt_ord in (0,1);


  run;

  **Step 17b: Results with change in variable;
  ** now as we go from low to high birth weight gets higher;

proc logistic data = new_low_birth2 descending;
  model bwt_ord2 = lwt ;

  run;

  **Step 17c: We must take out the descending;
  **          So that we predict prob of being less than K;
  **         over the probablity of being greater than or equal to k in the denominator;


proc logistic data = new_low_birth2; **descending;
  model bwt_ord = lwt ;
  output out=pred p=pred xbeta=logit;
  **where bwt_ord in (0,1);

  proc contents data=pred;
   title 'here is pred';


  run;
 options ps=500;

  proc print data=pred(obs=100);
  var id bwt_ord _level_ lwt pred logit;
  title 'take a look at output';

  run;


  **Step 18: Table 8.19 Smoking Proportional Odds Model;

proc logistic data = new_low_birth2; **descending;
  model bwt_ord = smoke ;
  output out=pred p=pred xbeta=logit;
  **where bwt_ord in (0,1);

  proc contents data=pred;
   title 'here is pred';

  run;
 options ps=500;

  proc print data=pred(obs=100);
  var id bwt_ord _level_ lwt smoke pred logit;
  title 'take a look at output Smoke Example';

  run;

**Step 19: Table 8.21;

  proc means data=new_placement;
   var age age2;
   output out=stats mean=age age2;

   run;

   data _null_;
    set stats;
        call symput('age_mean',age);
        call symput('age2_mean',age2);

        proc print data=stats;
         title "Here is age_mean = &age_mean age2_mean=&age2_mean";

         run;

   data neuro;
    set new_placement;
        age_c = age-&age_mean;
        age2_c = age2 - &age2_mean;
        r_e = race*emot;

        run;

        proc format;
         value neuro
         0 = 'None'
         1 = 'Mild'
         2 = 'Moderate'
         3 = 'Severe'
         ;

 proc freq data=neuro;
  table NEURO / missing;
  **table r_e*(race emot) / missing;
  table neuro*(custd race emot) / missing;
  format neuro neuro.;
  title 'here is neuro';

  run;
**Logistic for Table 8.21;

proc logistic data = neuro; **descending;
  model neuro = AGE_c AGE2_c CUSTD RACE EMOT R_E;
  output out=pred p=pred xbeta=logit;

  run;


  **Check EMOT by itself;

proc logistic data = neuro; **descending;
  model neuro =  EMOT ;
  output out=pred p=pred xbeta=logit;

  run;

**Step 20: Table 8.22;
** This is similiar to Table 8.11;
** described in Step 9;

**Step 20a: Get the individual cuts;
** See power point for why this is difficult;
** 3/2/2016 did not attempt;


options mpring symbolgen;

proc logistic data = neuro; **descending;
  model neuro = AGE_c AGE2_c CUSTD RACE EMOT R_E;
  output out=m2 p=pred xbeta=logit;

  run;

  proc freq data=neuro;
   table neuro place3 / missing;
   title 'neuro';

   run;

  proc freq data=m2;
   table _level_ / missing;
   title 'm2';

   run;

proc sort data=m2;
 by id;

 proc print data=m2(obs=100);
var id neuro AGE_c AGE2_c CUSTD RACE EMOT R_E _level_ pred logit;
title 'check out output from Neuro ';

run;


%macro hl(data=,group=,nuero=);

  data pre_hosmer;
   set &data;
   rank_prob = prob;
   one = 1;
   if neuro in &nuero;

   run;
 proc rank data=pre_hosmer out=rank group=&group;
 var rank_prob;

run;

proc tabulate data=rank noseps;
 class rank_prob;
 var one prob;
table (rank_prob='' all='Total' ),(
 one =' '*sum='Tot #'*f=comma20.0
prob =' '*min ='Min Prob'*f=comma20.4
prob =' '*mean='Mn  Prob'*f=comma20.4
prob =' '*max ='Max Prob'*f=comma20.4

)
 / rts=25 condense
;
title "Results for place3=&place3";

run;

%mend hl;

run;

**%hl(data=m2,group=10,place3= (1));
%hl(data=m2,group=10,neuro= (0,1,2))

run;

**Step 20b: Use the cuts derived above to get individual results for each of the ;
**          nerological types;

options mprint symbolgen;

%macro hlqq(data=,group=,place3=,level=);

proc format;
 value prob
 low - 0.0465='0.0465'
0.0465-<0.0906='0.0906'
0.0906-<0.1386='0.1386'
0.1386-<0.2027='0.2027'
0.2027-<0.428='0.428'
0.428-<0.7746='0.7746'
0.7746-<0.8606='0.8606'
0.8606-<0.9003='0.9003'
0.9003-<0.9536='0.9536'
0.9536-<1='1'
;
run;

 data prob0;
  set &data;
  if _level_=0;
  prob0 = prob;
  prob1 = 1-prob;
  keep id prob0 prob1;

run;


%if (&level = 0) %then %do;

  data pre_hosmer;
   set &data;
   if _level_ = &level;
   rank_prob = prob;
   one = 1;
   if place3 in &place3;
   prob_no_zero = 1-prob;
   rank_no_zero = prob_no_zero;
   prob_format = prob;
    place3_0 = 0;
   place3_1 = 0;
   place3_2 = 0;
   if place3=0 then place3_0=1;
   if place3=1 then place3_1=1;
   if place3=2 then place3_2=1;

   run;

 proc rank data=pre_hosmer out=rank group=&group;
 var rank_prob rank_no_zero;

run;

proc tabulate data=rank noseps;
 class rank_prob rank_no_zero prob_format prob_no_zero;
 var one prob place3_0 place3_1 place3_2;
table (prob_no_zero='' all='Total' ),(
 one =' '*sum='Tot #'*f=comma20.0
 place3_0 =' '*sum='# 0'*f=comma20.0
 prob     =' '*sum='Sum Prob'*f=comma20.3
)
 / rts=25 condense
;
format prob_format prob_no_zero prob.;
title "Results for Level=&level";

%end;
%if (&level = 1) %then %do;

data pre_hosmer;
   set &data;
   if _level_ = &level;
   rank_prob = prob;
   one = 1;
   if place3 in &place3;
   prob_no_zero = 1-prob;
   rank_no_zero = prob_no_zero;
   prob_format = prob;
    place3_0 = 0;
   place3_1 = 0;
   place3_2 = 0;
   if place3=0 then place3_0=1;
   if place3=1 then place3_1=1;
   if place3=2 then place3_2=1;

   run;

   proc sql;
    create table pre_hosmer as
         select a.*,
                b.prob0,
                        b.prob1
         from pre_hosmer a,
              prob0      b
     where a.id=b.id
         ;
         quit;


 proc rank data=pre_hosmer out=rank group=&group;
 var rank_prob rank_no_zero;

run;


proc tabulate data=rank noseps;
 class rank_prob rank_no_zero prob_format prob0 prob1;
 var one prob prob_no_zero place3_0 place3_1 place3_2;
table (prob1='' all='Total' ),(
 one =' '*sum='Tot #'*f=comma20.0
 place3_1 =' '*sum='# 1'*f=comma20.0
 prob     =' '*sum='Sum Prob'*f=comma20.2
)
 / rts=25 condense
;
format prob_format prob0 prob1 prob.;
title "Results for Level=&level";

%end;
%if (&level = 2) %then %do;


data pre_hosmer;
   set &data;
   if _level_ = &level;
   rank_prob = prob;
   one = 1;
   if place3 in &place3;
   prob_no_zero = 1-prob;
   rank_no_zero = prob_no_zero;
   prob_format = prob;
    place3_0 = 0;
   place3_1 = 0;
   place3_2 = 0;
   if place3=0 then place3_0=1;
   if place3=1 then place3_1=1;
   if place3=2 then place3_2=1;

   run;

      proc sql;
    create table pre_hosmer as
         select a.*,
                b.prob0,
                        b.prob1
         from pre_hosmer a,
              prob0      b
     where a.id=b.id
         ;
         quit;


 proc rank data=pre_hosmer out=rank group=&group;
 var rank_prob rank_no_zero;

run;

proc tabulate data=rank noseps;
 class rank_prob rank_no_zero prob_format prob0 prob1;
 var one prob prob_no_zero place3_0 place3_1 place3_2;
table (prob1='' all='Total' ),(
 one =' '*sum='Tot #'*f=comma20.0
 place3_2 =' '*sum='# 2'*f=comma20.0
 prob     =' '*sum='Sum Prob'*f=comma20.2
)
 / rts=25 condense
;
format prob_format prob0 prob1 prob.;
title "Results for Level=&level";

run;

%end;


run;

%mend hlqq;

run;

%hlqq(data=m2,group=10,place3= (0,1,2),level=0) ;

run;


%hlqq(data=m2,group=10,place3= (0,1,2),level=1);

run;

%hlqq(data=m2,group=10,place3= (0,1,2),level=2);

run;

**Step 21: Figure 8.5;

**Step 21a: Establish max and min for age;
**          As seen the age ranges from 11 to 18;

proc means data=neuro;
  var age age2;
output out=stats max=max_age max_age2 mean=mean_age mean_age2  min=min_age min_age2;

  run;

  proc print data=stats;
   title 'here is stats';

   run;

** Step 21b: Now we establish that the logit is minimized at age 14.5;

proc logistic data = neuro; **descending;
  model neuro = AGE_c AGE2_c CUSTD RACE EMOT R_E;
  output out=find_logit p=pred xbeta=logit;

  run;

   proc sort data=find_logit;
    by age;

 goptions reset = all;
symbol1   value=none j=l;
proc gplot data = find_logit;
  **plot logit*age;
  plot pred*age;
  where logit ^=. and _level_ = 0;
  title 'Verify Age and Minimium Logit';
run;
quit;

**Step 21c: Try again this time do a proc sort;
**     by logit and find the max and min age associated with these;
**     The sign of the logit appears to be reversed for SAS vs Strata;


proc sort data=find_logit;
 by logit;

 proc print data=find_logit(obs=100);
  var id _level_ age logit pred;
  title 'finding the age with the minimium logit';

  run;


**Step 21d: The fact remains according to our results;
**          the highest probablity of neurological disease occurs;
**          at 14.5. So lets do a proc tabulate and see who is right;
**  Recall we have three preds. Probablity of being zero compared to probablity of being 1,2,3
**                              Probablity of being 0,1 compared to probablity of being 2,3
**                              Probablity of being 0,1,2 compared to probablity of being 3.;

  run;
  data pre_tabulate;
   set neuro;
   neuro_0=1;
   neuro_01=1;
   neuro_012=1;
   if neuro in (1,2,3) then neuro_0 = 0;
   if neuro in (2,3) then neuro_01 = 0;
   if neuro in (3) then neuro_012 = 0;
   rank_age = age;
   one = 1;
run;
   proc rank data=pre_tabulate group=3 out=tabulate;
   var rank_age;
run;

proc freq data=tabulate;
 table rank_age  /missing;

 run;

proc tabulate data=tabulate noseps;
 class rank_age;
 var one neuro_0 age neuro_01 neuro_012;
table (rank_age='' all='Total' ),(
 one =' '*sum='Tot'*f=comma20.0
 age =' '*mean='Mn Age'*f=comma20.2
 neuro_0 =' '*sum='#0'*f=comma20.0
 neuro_0 =' '*pctsum<one>='%0'*f=comma20.4
 neuro_01 =' '*sum='#01'*f=comma20.0
 neuro_01 =' '*pctsum<one>='%01'*f=comma20.4
 neuro_012 =' '*sum='#012'*f=comma20.0
 neuro_012 =' '*pctsum<one>='%012'*f=comma20.4
)
 / rts=25 condense
;
title "Checking Age Vs Neurological Diseas";

run;

**Step 22: Predicting Danger;

**Step 22a: Reproduce the table 8.23;

  data danger;
   set neuro;
   weeks = LOS/7;


proc logistic data = danger; **descending;
  **model neuro = AGE_c AGE2_c CUSTD RACE EMOT R_E;
   model danger = weeks behav gender custd;
  output out=find_logit_d p=pred xbeta=logit;

  run;

**Step 22b: Look carefully at custd;

  proc freq data=danger;
   table danger*custd / missing;
   title 'checking out custd';

   run;

 **Step 22c: Run custody by itself;

proc logistic data = danger; **descending;
  **model neuro = AGE_c AGE2_c CUSTD RACE EMOT R_E;
   class custd(ref='0') gender(ref='0') behav(ref='0');
   model danger =  custd;
  output out=find_logit_d p=pred xbeta=logit;

  run;

  **Step 22c: Run custody by itself;

proc logistic data = danger; **descending;
  **model neuro = AGE_c AGE2_c CUSTD RACE EMOT R_E;
   class custd(ref='0') gender(ref='0') behav(ref='0');
   model danger(event='0') =  custd;
  output out=find_logit_d p=pred xbeta=logit;
   where danger in (0,1);
   title 'Just look at at danger in (0,1)';

   run;

   proc logistic data = danger; **descending;
  **model neuro = AGE_c AGE2_c CUSTD RACE EMOT R_E;
   class custd(ref='0') gender(ref='0') behav(ref='0');
   model danger /*(event='0')*/ =  custd;
  output out=find_logit_d p=pred xbeta=logit;
   where danger in (0,1,2);
   title 'Look at danger in  0,1,2';

   run;


   proc logistic data = danger; **descending;
  **model neuro = AGE_c AGE2_c CUSTD RACE EMOT R_E;
   class custd(ref='0') gender(ref='0') behav(ref='0');
   model danger /*(event='0')*/ =  custd;
  output out=find_logit_d p=pred xbeta=logit;
   where danger in (0,1,2,3);
   title 'Look at danger in  0,1,2 and 3';

   run;


**Exercise 1;

Data low_birth;
 set chap8.lowbirth;
if BWT > 3500 then BWT4 = 0;
if 3000 < BWT <= 3500 then bwt4 = 1;
if 2500 < BWT <= 3000 then bwt4 = 2;
if BWT <= 2500 then bwt4 = 3;

run;

**Step 1: Start by computing three seperate logistic regrsions;

proc logistic data = low_birth;
  class bwt4 (ref='0') race(ref='1') smoke(ref='0') ptl(ref='0') ht(ref='0') ui(ref='0') ftv(ref='0') /param=ref;
  model bwt4(event='1')  =  AGE      LWT      Race      Smoke      PTL      HT      UI      FTV/ link=glogit;
**where bwt4 in (0,1);
 title 'results for bwt4 0 vs 1';

run;

**Step 2: Lets do univariate anaylsis similiar to what we did in chapter 4;

options mprint symbolgen;

run;

%macro uni(var=,type=,group=);

  data temp;
  set low_birth;
  one =1;
if BWT > 3500 then BWT4 = 0;
if 3000 < BWT <= 3500 then bwt4 = 1;
if 2500 < BWT <= 3000 then bwt4 = 2;
if BWT <= 2500 then bwt4 = 3;
bwt01=0;
bwt02 = 0;
bwt03=0;
bwt04=0;
if bwt4 = 1 then bwt01 = 1;
if bwt4 = 2 then bwt02 = 1;
if bwt4 = 3 then bwt03 = 1;
ftv_binary = 0;
 if ftv > 0 then ftv_binary = 1;
rank = &var;



run;


%if (&type = C) %then %do;

run;

 proc univariate data=temp;
  var &var;
title 'Proc Univeriate Case for Cont Variables';

run;


   proc rank data=temp out=ranking groups=&group;
  var rank;

run;

proc tabulate data=ranking formchar = '           ' noseps out=stats_tab missing;
     class rank;
     var one &var bwt01 bwt02 bwt03;
table (rank="&var" all='Total'),
       (
        one            = ' '*sum='Tot #'*f=comma20.0
        &var           = ' '*min='Min'*f=comma20.1
        &var           = ' '*mean='Mean'*f=comma20.1
        &var           = ' '*max='Max'*f=comma20.1
        bwt01          = ' '*sum='#bwt01'*f=comma20.0
        bwt01          = ' '*pctsum<one>='% bwt01'*f=comma20.4
        bwt02          = ' '*sum='#bwt02'*f=comma20.0
        bwt02          = ' '*pctsum<one>='% bwt02'*f=comma20.4
        bwt03          = ' '*sum='#bwt03'*f=comma20.0
        bwt03          = ' '*pctsum<one>='% bwt03'*f=comma20.4
        )
        / rts=25 condense ;
Title "BWT and &Var";
title2 'Continuous Distribution';

%end;
%else %do;

run;

 proc freq data=temp;
  table &var;
title 'Proc Freq for Discrete Variables';

run;

proc tabulate data=temp formchar = '           ' noseps out=stats_tab missing;
     class rank;
     var one &var bwt01 bwt02 bwt03;
table (rank="&var" all='Total'),
       (
        one            = ' '*sum='Tot #'*f=comma20.0
        &var            = ' '*min='Min'*f=comma20.1
        &var            = ' '*mean='Mean'*f=comma20.1
        &var            = ' '*max='Max'*f=comma20.1
        bwt01          = ' '*sum='#bwt01'*f=comma20.0
        bwt01          = ' '*pctsum<one>='% bwt01'*f=comma20.4
        bwt02          = ' '*sum='#bwt02'*f=comma20.0
        bwt02          = ' '*pctsum<one>='% bwt02'*f=comma20.4
        bwt03          = ' '*sum='#bwt03'*f=comma20.0
        bwt03          = ' '*pctsum<one>='% bwt03'*f=comma20.4
       )
        / rts=25 condense ;
Title "BWT and &Var";
title2 'Continuous Distribution';

%end;


proc logistic data = temp;
  class bwt4 (ref='0') race(ref='1') smoke(ref='0') ptl(ref='0') ht(ref='0') ui(ref='0') ftv(ref='0') ftv_binary(ref='0')/param=ref;
  model bwt4(event='1')  =  &var / link=glogit;
**where bwt4 in (0,1);
 title 'results for bwt4 0 vs 1';

run;




%mend uni;

run;

%uni(var=age,type=C,group=5);  ** Age does not seem to be very good. Possible fractional polynomials;

%uni(var=lwt,type=C,group=3);  ** LWT seems important. Has opposite direction for 01 vs 02 and 03;

run;
%uni(var=race,type=NC,group=3);  **Does seem to differentiate. Might be worth combining have White(0)  vs Black and Other;

run;

%uni(var=smoke,type=NC,group=5); ** Appears to differentiate;

run;

%uni(var=plt,type=NC,group=5);   ** History of premature does seem to impact;

run;

%uni(var=ht,type=NC,group=5);  ** tabulate results appear to support its use but not sig in logistic regression;
                               ** Perhaps it is the large SD due to the small number of accounts ;

run;

%uni(var=UI,type=NC,group=5);   **Ui does seem signficant;

run;


%uni(var=FTV,type=NC,group=5);  ** Hard to say. Make into a binary;


%uni(var=FTV_binary,type=NC,group=5);  ** Does not appear to be significant;


run;


**Step 2 Comment: Appears that LWT, race, smoke, plt, ui;

**Step 3: Do we see anything using transformation of age;


*******************************************************************;
* Adjust the scale of continuous variables;
* Want to see if variable is linear in terms of target;
* Start with PROC LEOSS Results;
* Try loess with mutlivariate values;
*******************************************************************;

run;

options mprint symbolgen;

%macro loess(var=,smooth=,target=,constrain=);

run;

  data temp;
  set low_birth;
  one =1;
if BWT > 3500 then BWT4 = 0;
if 3000 < BWT <= 3500 then bwt4 = 1;
if 2500 < BWT <= 3000 then bwt4 = 2;
if BWT <= 2500 then bwt4 = 3;
bwt01=0;
bwt02 = 0;
bwt03=0;
bwt04=0;
if bwt4 = 1 then bwt01 = 1;
if bwt4 = 2 then bwt02 = 1;
if bwt4 = 3 then bwt03 = 1;
ftv_binary = 0;
 if ftv > 0 then ftv_binary = 1;
rank = &var;
if bwt4 in &constrain;

run;



run;

proc loess data = temp;
  model &target  = &var /smooth=&smooth;
  ods output OutputStatistics=a;
run;

proc sql; /*compute the total number of obs*/
  select count(&target) into :total
  from temp;
  quit;

data b1;
  set a;
  adjust = 1/&total;
  small = .0001;
  if pred < small then pred = adjust;
  else if pred > 1 - small then pred = 1 - adjust;
  log_pred = log(pred/(1-pred));
run;

proc sort data = b1;
  by &var;

run;

proc means data=b1 noprint;
 var log_pred &var;
 output out=stats min = min_log min_var max=max_log max_var;

 data _null_;
 set stats;
 call symput('min_log',min_log);
 call symput('max_log',max_log);
 call symput('min_var',min_var);
 call symput('max_var',max_var);


run;


goptions reset = all;
symbol i = join v=star c=blue;
axis1 order = (&min_var to &max_var by 3) minor=none;
axis2 order = (&min_log to &max_log by .1) minor = none label=(a=90 'Smoothed Logit');
proc gplot data = b1;
  format &var 3.1 pred 5.1;
  plot log_pred*&var /vaxis=axis2 haxis=axis1 ;
title "Loess Results for &Var";
run;
quit;

%mend loess;

run;


%loess(var=age,smooth=.6,target=bwt01,constrain=(0,1));
run;
%loess(var=age,smooth=.6,target=bwt02,constrain=(0,2));
run;
%loess(var=age,smooth=.6,target=bwt03,constrain=(0,3));
run;


**Step 3 conclusion: Looks like we would have to give each target type a seperate age fractional polynomial;
**                   this is too much so we stop;


** Step 4: Main effects model derivaiton prior to evaluation for interaction terms;
**         Appears that LWT, race, smoke, plt, ui;

run;

proc logistic data = low_birth;
  class bwt4 (ref='0') race(ref='1') smoke(ref='0') ptl(ref='0') ht(ref='0') ui(ref='0') ftv(ref='0') /param=ref;
  model bwt4(event='1')  =   LWT      Race      Smoke      PTL    UI / link=glogit;
**where bwt4 in (0,1);
 title 'results for bwt4 0 vs 1';

run;

** Neither UI or PLT appear to be signficant so we drop them;

proc logistic data = low_birth;
  class bwt4 (ref='0') race(ref='1') smoke(ref='0') ptl(ref='0') ht(ref='0') ui(ref='0') ftv(ref='0') /param=ref;
  model bwt4(event='1')  =   LWT      Race      Smoke / link=glogit;
**where bwt4 in (0,1);
 title 'results for bwt4 0 vs 1';

run;

**Step 5 introduct interaction terms;


 data interact;
 set low_birth;
  lwt_race = lwt*race;
  lwt_smoke = lwt*smoke;
   race_smoke = race*smoke;

run;

proc freq data=interact;
 table race*smoke bwt4*race_smoke / missing;
 title 'interact';

run;


proc logistic data = interact;
  class bwt4 (ref='0') race(ref='1') smoke(ref='0') ptl(ref='0') ht(ref='0') ui(ref='0') ftv(ref='0')
        race_smoke(ref='0') /param=ref;
  model bwt4(event='1')  =   LWT      Race      Smoke lwt_race lwt_smoke race_smoke / link=glogit;
**where bwt4 in (0,1);
 title 'Interaction Terms Introduced';

run;

**Final Model;
** None of the interaction terms worked;



proc logistic data = low_birth;
  class bwt4 (ref='0') race(ref='1') smoke(ref='0') ptl(ref='0') ht(ref='0') ui(ref='0') ftv(ref='0') /param=ref;
  model bwt4(event='1')  =   LWT      Race      Smoke / link=glogit;
**where bwt4 in (0,1);
 title 'results for bwt4 0 vs 1';

run;


**Step 6: Regression Diagnostics;
**Step 6a: We try and reproduce Table 8.11;

proc logistic data = low_birth outest=est;
  class bwt4 (ref='0') race(ref='1') smoke(ref='0') ptl(ref='0') ht(ref='0') ui(ref='0') ftv(ref='0') /param=ref;
  model bwt4  =   LWT      Race      Smoke / link=glogit lackfit;
  output out = m2 p = prob xbeta = logit;
  title 'Predict the event 0 as that is what we need to do for Table 8.11';

  run;

options ps=500;

  proc print data=m2;
   title 'here is m2';

   run;


%macro hlq(data=,group=,bwt4=,level=);

  data pre_hosmer;
   set &data;
   if _level_ = &level;
   rank_prob = prob;
   one = 1;
   if bwt4 in &bwt4;
   prob_no_zero = 1-prob;
   rank_no_zero = prob_no_zero;


   run;
 proc rank data=pre_hosmer out=rank group=&group;
 var rank_prob rank_no_zero;

run;

proc tabulate data=rank noseps;
 class rank_prob rank_no_zero;
 var one prob prob_no_zero;
table (rank_no_zero='' all='Total' ),(
 one =' '*sum='Tot #'*f=comma20.0
prob_no_zero =' '*min ='Min Prob'*f=comma20.4
prob_no_zero =' '*mean='Mn  Prob'*f=comma20.4
prob_no_zero =' '*max ='Max Prob'*f=comma20.4

)
 / rts=25 condense
;
title "Results for bwt4==&bwt4";

run;

%mend hlq;

run;

%hlq(data=m2,group=10,bwt4= (1,2,3),level=0)

run;



**Step 9d: Okay now we have the distribution we use that;
** to get the results formated by what we got above;
** and constrain ourselves to levels 0,1,2,3 as that will point;
** to the probablities we need to get our results;
run;
options mprint symbolgen;

proc format;
 value prob
low      -  0.4976      =      '0 - 0.4976'
0.4976   -<      0.7431 =      '0.4976-<0.7431'
0.7431   -<      0.795  =      '0.7431-<0.795'
0.795    -<      0.8129 =      '0.795-<0.8129'
0.8129   -<      0.8288 =      '0.8129-<0.8288'
0.8288   -<      0.8435 =      '0.8288-<0.8435'
0.8435   -<      0.8581 =      '0.8435-<0.8581'
0.8581   -<      0.9068 =      '0.8581-<0.9068'
0.9068   -<      0.9566 =      '0.9068-<0.9566'
0.9566   -<      0.988  =      '0.9566-<0.988'
.988     -      high    = '1'
;

run;

options mprint symbolgen;

%macro hlqq(data=,group=,bwt4=,level=);

proc format;
 value prob
low       -      0.4976      =      '0 -       0.4976'
0.4976      -<      0.7431      =      '0.4976-<0.7431'
0.7431      -<      0.795      =      '0.7431-<0.795'
0.795      -<      0.8129      =      '0.795-<0.8129'
0.8129      -<      0.8288      =      '0.8129-<0.8288'
0.8288      -<      0.8435      =      '0.8288-<0.8435'
0.8435      -<      0.8581      =      '0.8435-<0.8581'
0.8581      -<      0.9068      =      '0.8581-<0.9068'
0.9068      -<      0.9566      =      '0.9068-<0.9566'
0.9566      -<      0.988      =      '0.9566-<0.988'
.988 - high                    = '1'
;

run;

 data prob0;
  set &data;
  if _level_=0;
  prob0 = prob;
  prob1 = 1-prob;
  keep id prob0 prob1;

run;


%if (&level = 1) %then %do;

  data pre_hosmer;
   set &data;
   if _level_ = &level;
   rank_prob = prob;
   one = 1;
   if bwt4 in &bwt4;
   prob_no_zero = 1-prob;
   rank_no_zero = prob_no_zero;
   prob_format = prob;
    bwt4_1 = 0;
   bwt4_2 = 0;
   bwt4_3 = 0;
   if bwt4=1 then bwt4_1=1;
   if bwt4=2 then bwt4_2=1;
   if bwt4=3 then bwt4_3=1;


   run;

 proc rank data=pre_hosmer out=rank group=&group;
 var rank_prob rank_no_zero;

run;

proc tabulate data=rank noseps;
 class rank_prob rank_no_zero prob_format prob_no_zero;
 var one prob bwt4_1 bwt4_2 bwt4_3;
table (prob_no_zero='' all='Total' ),(
 one =' '*sum='Tot #'*f=comma20.0
 bwt4_1 =' '*sum='# 1'*f=comma20.0
 prob     =' '*sum='Sum Prob'*f=comma20.3
)
 / rts=25 condense
;
format prob_format prob_no_zero prob.;
title "Results for Level=&level";

%end;
%if (&level = 2) %then %do;

data pre_hosmer;
   set &data;
   if _level_ = &level;
   rank_prob = prob;
   one = 1;
   if bwt4 in &bwt4;
   prob_no_zero = 1-prob;
   rank_no_zero = prob_no_zero;
   prob_format = prob;
    bwt4_1 = 0;
   bwt4_2 = 0;
   bwt4_3 = 0;
   if bwt4=1 then bwt4_1=1;
   if bwt4=2 then bwt4_2=1;
   if bwt4=3 then bwt4_3=1;

   run;

   proc sql;
    create table pre_hosmer as
         select a.*,
                b.prob0,
                        b.prob1
         from pre_hosmer a,
              prob0      b
     where a.id=b.id
         ;
         quit;


 proc rank data=pre_hosmer out=rank group=&group;
 var rank_prob rank_no_zero;

run;


proc tabulate data=rank noseps;
 class rank_prob rank_no_zero prob_format prob0 prob1;
 var one prob prob_no_zero bwt4_1 bwt4_2 bwt4_3;
table (prob1='' all='Total' ),(
 one =' '*sum='Tot #'*f=comma20.0
 bwt4_2 =' '*sum='# 2'*f=comma20.0
 prob     =' '*sum='Sum Prob'*f=comma20.2
)
 / rts=25 condense
;
format prob_format prob0 prob1 prob.;
title "Results for Level=&level";

%end;
%if (&level = 3) %then %do;


data pre_hosmer;
   set &data;
   if _level_ = &level;
   rank_prob = prob;
   one = 1;
   if bwt4 in &bwt4;
   prob_no_zero = 1-prob;
   rank_no_zero = prob_no_zero;
   prob_format = prob;
    bwt4_1 = 0;
   bwt4_2 = 0;
   bwt4_3 = 0;
   if bwt4=1 then bwt4_1=1;
   if bwt4=2 then bwt4_2=1;
   if bwt4=3 then bwt4_3=1;

   run;

      proc sql;
    create table pre_hosmer as
         select a.*,
                b.prob0,
                        b.prob1
         from pre_hosmer a,
              prob0      b
     where a.id=b.id
         ;
         quit;


 proc rank data=pre_hosmer out=rank group=&group;
 var rank_prob rank_no_zero;

run;

proc tabulate data=rank noseps;
 class rank_prob rank_no_zero prob_format prob0 prob1;
 var one prob prob_no_zero bwt4_1 bwt4_2 bwt4_3;
table (prob1='' all='Total' ),(
 one =' '*sum='Tot #'*f=comma20.0
 bwt4_3  =' '*sum='# 3'*f=comma20.0
 prob     =' '*sum='Sum Prob'*f=comma20.2
)
 / rts=25 condense
;
format prob_format prob0 prob1 prob.;
title "Results for Level=&level";

run;

%end;


run;

%mend hlqq;

run;

%hlqq(data=m2,group=10,bwt4= (1,2,3),level=1) ;

run;

%hlqq(data=m2,group=10,bwt4= (1,2,3),level=2);

run;

%hlqq(data=m2,group=10,bwt4= (1,2,3),level=3);

run;

**Comment on Step 6: 26 is the cutoff and we get 32 so the model does not calibrate as well as we would like;
**                   See spreadsheet for more details;


**Remaining Steps:
** Find the observations that have a large impact - this was not done;
** draw the odds ratios for the various terms which in our case is not hard as we have no interactions;
** THis was done in a spreadsheet;

proc logistic data = low_birth outest=est;
  class bwt4 (ref='0') race(ref='1') smoke(ref='0') ptl(ref='0') ht(ref='0') ui(ref='0') ftv(ref='0') /param=ref;
  model bwt4  =   LWT      Race      Smoke / link=glogit lackfit;
  output out = m2 p = prob xbeta = logit;
  title 'Predict the event 0 as that is what we need to do for Table 8.11';

  run;


**Exercise 4;



  proc means data=new_placement;
   var age age2;
   output out=stats mean=age age2;

   run;

   data _null_;
    set stats;
        call symput('age_mean',age);
        call symput('age2_mean',age2);

        proc print data=stats;
         title "Here is age_mean = &age_mean age2_mean=&age2_mean";

         run;


   data neuro;
    set new_placement;
        age_c = age-&age_mean;
        age2_c = age2 - &age2_mean;
        r_e = race*emot;

        run;

        proc format;
         value neuro
         0 = 'None'
         1 = 'Mild'
         2 = 'Moderate'
         3 = 'Severe'
         ;

 proc freq data=neuro;
  table NEURO / missing;
  **table r_e*(race emot) / missing;
  table neuro*(custd race emot) / missing;
  format neuro neuro.;
  title 'here is neuro';

  run;


proc logistic data = neuro; **descending;
  model neuro = AGE_c AGE2_c CUSTD RACE EMOT R_E;
  output out=pred p=pred xbeta=logit;

  run;
