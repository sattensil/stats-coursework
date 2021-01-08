
*****************************************************;
* Step 1: Idenitify your libraries;
*******************************************************;

run;

%macro skipit;

libname chap1  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 1';
libname chap2  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 2';
libname chap3  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 3';
libname chap4  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 4';
libname chap5  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 5';
libname chap9  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 9';
libname chap10  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 10';
libname chap11  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 11';
libname chap12  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 12';
libname chap14  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 14';
libname chap15  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 15';
libname chap23  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 23';

libname chap8_L 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Chapter 8\From Home April 2016';

libname sasusers 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Data';
libname sasuser  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Data';

libname macros 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Macros';
libname macrosq 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\macros';


run;

%mend skipit;

run;


libname chap1 'C:\UC Berkley\Summer 2016\Chapter 1';
libname chap2 'C:\UC Berkley\Summer 2016\Chapter 2';
libname chap3 'C:\UC Berkley\Summer 2016\Chapter 3';
libname chap4 'C:\UC Berkley\Summer 2016\Chapter 4';
libname chap5 'C:\UC Berkley\Summer 2016\Chapter 5';
libname chap9 'C:\UC Berkley\Summer 2016\Chapter 9';
libname chap10 'C:\UC Berkley\Summer 2016\Chapter 10';
libname chap11 'C:\UC Berkley\Summer 2016\Chapter 11';
libname chap12 'C:\UC Berkley\Summer 2016\Chapter 12';
libname chap13 'C:\UC Berkley\Summer 2016\Chapter 13';
libname chap14 'C:\UC Berkley\Summer 2016\Chapter 14';
libname chap15 'C:\UC Berkley\Summer 2016\Chapter 15';


libname sasusers 'C:\UC Berkley\Summer 2016\Data';
libname sasuser 'C:\UC Berkley\Summer 2016\Data';
libname chap8_L 'C:\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Chapter 8';
libname log_data 'C:\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Data';

run;


**Step 1: You manually update the data you have with your own specific knowledge of individuals;
**  Its rare you do this but it happens;

run;

proc print data=sasusers.empdata;
title 'empdata';

proc sort data=sasusers.flightattendants;
by empid;

proc print data=sasusers.flightattendants;
 title 'here is fligth attendents';


run;

**Step1a: Use if then statements;

data employees_new;
set sasusers.empdata;
if empid='E00001' then Birthdate='01JAN1963'd;
else if empid='E00002' then Birthdate='08AUG1946'd;
else if empid='E00003' then Birthdate='23MAR1950'd;
else if empid='E00004' then Birthdate='17JUN1973'd;

run;

 data flightattendent;
  set sasusers.flightattendants;
if empid=1094 then Birthdate='01JAN1963'd;
else if empid=1103 then Birthdate='08AUG1946'd;
else if empid=1113 then Birthdate='23MAR1950'd;
else if empid=1116 then Birthdate='17JUN1973'd;

run;




**Step 1b: use an array ;

data flight_new;
set sasusers.flightattendants;
array employid (4) _temporary_ (1094 1103 1113 1116) ;
array dateq  (4) _temporary_ ("01JAN1963"d "08AUG1946"d "23MAR1950"d "17JUN1973"d);

       do i = 1 to 4;
       if employid{i} = empid then do;
            birthday = dateq{i};
         end;
       end;

run;

proc print data=flight_new;
 format birthday date7.;
 title 'here is flight new';

run;


*** Step 1c: Try formats;
** THis did not work;

proc format;
value birthdate
1094  = ’01JAN1963’
1103 = ’08AUG1946’
1113 = ’23MAR1950’
1116 = ’17JUN1973’
;

run;

proc freq data=sasusers.flightattendants;
table empid  / missing;
 format birhtdate date7.;

run;


data flight_new;
set sasusers.flightattendants;
empid_num = input(empid,8.0);
**first = put(empid,birthdate.);
**birthdate = input(first,date9.);
Birthdate=input(put(empid_num, birthdate.),date9.);

run;

proc contents data=flight_new;

run;


** Step 2: Combining data sets using the merge statement;

run;

proc sort data=sasuser.expenses out=expenses;
by flightid date;

run;

proc sort data=sasuser.revenue out=revenue;
by flightid date;

run;

data revexpns (drop=rev1st revbusiness revecon expenses);
merge expenses(in=e) revenue(in=r);
by flightid date;
if e and r;
Profit=sum(rev1st, revbusiness, revecon, -expenses);

run;

*** Step 3: Combine the data with SQL;
*** NOtice you only end up with 137 that is because you combine;
*** with code as well;


proc sql;
create table sqljoin as
select revenue.flightid, revenue.date format=date9.,
revenue.origin, revenue.dest,
sum(revenue.rev1st,
revenue.revbusiness,
revenue.revecon)
-expenses.expenses as Profit,
acities.city,
acities.name

from sasuser.expenses,
     sasuser.revenue,
     sasuser.acities

where expenses.flightid=revenue.flightid
and expenses.date=revenue.date
and acities.code=revenue.dest
order by revenue.dest,
revenue.flightid,
revenue.date;
quit;


*** Step 4: Comparing merging with SQL;

**Step 4a: Proc SQL;

proc sql;
create table flightemps as
select      a.*,
            b.firstname,
            b.lastname
from sasuser.flightschedule a,
     sasuser.flightattendants b
where flightschedule.empid=flightattendants.empid;
quit;


** Step 4b: SAS Match;
*** Notice the difference;

proc sort data=sasuser.flightattendants out=fa;
by empid;
run;
proc sort data=sasuser.flightschedule out=fs;
by empid;
run;

data flightemps2;
merge fa fs;
by empid;

run;

data flightemps2;
merge fa(in=a)  fs(in=b);
by empid;
if a and b;

run;



** Step 4c: You can us this to constrain yourself to only
             those points where it mateches up;
**  THis replicates the SQL;
** Takes the 34 in fa and matches to the fs by empid;

data flightemps3(drop=empnum jobcode);
set sasuser.flightschedule;
do i=1 to num;
**put 'num=' num;
set sasuser.flightattendants
(rename=(empid=empnum))
nobs=num point=i;
if empid=empnum then output;
end;
run;


** Step 5 Combining summary data with detailed data;

** Step 5a: First summarize the data;

proc means data=sasuser.monthsum noprint;
var revcargo;
output out=sasuser.summary sum=Cargosum;

run;

proc print data=sasuser.summary;

run;

** Step 5b: Use the summarized data to take the spercentage;

data percent1(drop=cargosum);
if _N_=1 then set sasuser.summary(keep=cargosum);
set sasuser.monthsum(keep=salemon revcargo);
PctRev=revcargo/cargosum;
run;

proc print data=percent1;
 title 'here is percentage based on sumarized data';

 run;


 ** Step 5c: You can get the sum statement;

 data percent2(drop=totalrev);
if _N_=1 then do until (LastObs);
set sasuser.monthsum(keep=revcargo) end=lastobs;
TotalRev+revcargo;
end;
set sasuser.monthsum(keep=salemon revcargo);
PctRev=revcargo/totalrev;

run;

proc print data=percent2;
 title 'her eis percent2';

 run;

** Step 6: Creating a key index to make combining data esier;
 ** Cannot get this to work;

**Step 6a:first we create the index of flightdate;

 proc datasets libname=sasuser;
 modify  sale2000;
 index create flightdate=(flightid date);

 run;

 **step 6b: now we run it wihtout _iroc_;


proc print data=sasuser.dnunder;
 title 'dnunder';

run;

proc print data=sasuser.sale2000;
 title 'sale2000';

run;



 run;

data work.profit;
set sasuser.dnunder;
set sasuser.sale2000(keep=routeid flightid date rev1st
revbusiness revecon revcargo) key=flightdate;
Profit=sum(rev1st, revbusiness, revecon, revcargo,
-expenses);

run;

proc print data=profit;
 title 'here is profit';

run;


**Step 6c: Add in _iroc_;
** if _iroc_ = 1 then you found a match from dnunder onto sal2000;
** if _iroc_1 = 0 then you did not find a match;


data work.profit3 work.errors;
set sasuser.dnunder;
set sasuser.sale2000(keep=routeid flightid date rev1st
revbusiness revecon revcargo)key=flightdate;
if _iorc_=0 then do;
Profit=sum(rev1st, revbusiness, revecon, revcargo,
-expenses);
output work.profit3;
end;
else do;
_error_=0;
output work.errors;
end;
run;

** Step 6c now we get profits;

proc contents data=sasuser.sale2000;

run;

data work.profit2;
set sasuser.sale2000(keep=routeid flightid date
rev1st revbusiness revecon revcargo)
key=flightdate;
set sasuser.dnunder;
Profit=sum(rev1st, revbusiness, revecon, revcargo,
-expenses);

run;

** Step 7: Updating data with Update;

**Step 7a: Lets first get some data we can potentiall update;

run;



libname log_data 'C:\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Data';
run;


proc contents data=log_data.glow_11m;
proc contents data=log_data.glow500;

run;


data glow11m;
  set log_data.glow_11m;

  run;

data glow500;
 set log_data.glow500;

 run;

 ** Step7b: Update the glow500 with glow11m;
 ** So we update the values in glow500 with what is in glow11m;
 ** when they have the same sub_id;
** So when they have the same sub_id then glow500 is update with what is in glow11m;


proc sort data=glow500;
by sub_id;

run;
proc sort data=glow11m;
by sub_id;

run;
data master;
update glow500 glow11m;
by sub_id;

run;
