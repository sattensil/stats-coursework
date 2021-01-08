
*****************************************************;
* Step 1: Bring in the Low Birth Weight Data;
*         We used import wizard to created LBW then;
*         saved it into chap1;
*******************************************************;

run;

libname chap1  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 1';
libname chap2  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 2';
libname chap3  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 3';
libname sasuer 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Data'; 


**libname chap3  'C:\UC Berkley\Summer 2016\Chapter 1';
**libname chap3  'C:\UC Berkley\Summer 2016\Chapter 2';
**libname chap3  'C:\UC Berkley\Summer 2016\Chapter 3';
**libname sasuser 'C:\UC Berkley\Summer 2016\Data';


run;

**Step 1: Define data;

run;

  %macro skipit;


 data chap3.icu;
  set icu;

  data chap3.burns;
   set burns;

  run;

  %mend skipit;


**Step 2: Cartesian Product;

  data small_icu;
   set chap3.icu(obs=10);
   keep id sta age;

   data small_burns;
    set chap3.burns(obs=10);
        keep id death tbsa;

        run;

proc sql;
create table cartesian as
 select a.*,
        b.*
from small_icu a,
     small_burns b
;
quit;

run;

Proc sort data=cartesian;
 by Id;

 proc print data=cartesian(obs=25);
 title 'cartesian';

 run;

**Step 3: Inner Joins;
** Not that when ages differ it takes the age form the first data set;

proc sql feedback;
create table inner_join as
 select a.*,
        b.*
from chap3.icu  a,
     chap3.burns b
where a.id = b.id
order by a.id
;
quit;

proc contents data=inner_join;
 title 'inner_join';

proc print data=inner_join;
var id age gender sta death;
where id=4;
title 'inner join for id=4';

run;

proc print data=chap3.icu;
 var id age gender sta;
 where id=4;
  title 'icu for id = 4';

  run;

  proc print data=chap3.burns;
 var id age gender death;
 where id=4;
  title 'burns for id = 4';

  run;



**Step 4: Handling Duplicate Columns;
**We name what we want to pull in ;

proc sql feedback;
create table inner_join as
 select a.ID,
a.STA,
a.AGE as age_icu,
a.GENDER as gender_icu,
a.RACE as race_icu,
a.SER,
a.CAN,
a.CRN,
a.INF,
a.CPR,
a.SYS,
a.HRA,
a.PRE,
a.TYP,
a.FRA,
a.PO2,
a.PH,
a.PCO,
a.BIC,
a.CRE,
a.LOC,
b.ID,
b.FACILITY,
b.DEATH,
b.AGE as age_burn,
b.GENDER as gender_burn,
b.RACEC as race_burn,
b.TBSA,
b.INH_INJ,
b.FLAME
from chap3.icu  a,
     chap3.burns b
where a.id = b.id
order by a.id
;
quit;




**Step 5:  Match up data sets and create new variables;


proc sql feedback;
create table inner_join_extra as
 select a.ID,
a.STA,
a.AGE as age_icu,
a.GENDER as gender_icu,
a.RACE as race_icu,
b.death,
(sta-death) as sta_death_diff
from chap3.icu  a,
     chap3.burns b
where a.id = b.id
order by a.id
;
quit;


proc print dta=inner_join_extra;
title 'inner_join_extra';

run;


**Step 6:  Do a group by to get summary statistics;

proc format;
 value sta
 0 = 'Lived'
 1 = 'Died'
 ;
run;
proc sql feedback;
 select a.STA format=sta. as status,
 count(a.id) as tot_num,
 sum(a.sta)/count(a.id) format=4.2 as per_tot
from chap3.icu  a,
     chap3.burns b
where a.id = b.id
group by a.sta
;
quit;


**Step 6a: We have obtained the counts but not the percentages;
**         We get the percentage of total by first creating percentage like above then creating total below;


run;
proc sql feedback;
 select a.STA format=sta. as status,
 count(a.id) as sub_total,
 total,
calculated sub_total /total format=4.2 as per_tot
from chap3.icu  a,
(select count(b.id) as total
 from chap3.burns b)
where a.id = b.id
group by a.sta
;
quit;


** Step 6b: Notice that our results were divided by 1000 that is because;
**          1000 is the  total of the second burns group;
**          so lets get two totals one from burns and the other from;
**          the intersection of the two;

run;

 proc sql feedback;
 select a.STA format=sta. as status,
 count(a.id) as sub_total,
 total_burns,
calculated sub_total /total_burns format=4.2 as per_tot_burn,
  total_icu,
calculated sub_total /total_icu format=4.2 as per_tot_icu
from chap3.icu  a,
(select count(b.id) as total_burns
 from chap3.burns b),
(select count(c.id) as total_icu
 from chap3.icu c)
where a.id = b.id
group by a.sta
;
quit;


** Step 7:  Left outer Join;
** We take the burns with 1000 observations;
** combine it with those that match from ICU;
** End up with 1,000 observations because we keep all the burns;


run;
proc sql feedback;
create table left_outer_join as
 select a.* ,
        b.*
from chap3.burns  a
     left join
     chap3.icu b
     on a.id = b.id
;
quit;

run;


** Step 8:  Right outer Join;
** We take the burns with 1000 observations;
** combine it with those that match from ICU;
** End up with 200 observations because we keep all the ICU and only the burn in ICU;
** Just happens to turn out we get the same as innter join;


run;
proc sql feedback;
create table right_outer_join as
 select a.* ,
        b.*
from chap3.burns  a
     right join
     chap3.icu b
     on a.id = b.id
;
quit;

run;


** Step 9:  Full outer Join;
** Here we combine all the rows in each table;
** Since these tables overlab lets get some tables;
** That don not overlap so we can understand the difference;


**Step 9a: Bring in Low Birth Weight;

%macro skipit;


data chap3.low_birth;
 set low_birth;

run;



%mend skipit;


**Step 9b: innter joing notcie there is a subset;
**         of the two data sets;


run;
proc sql feedback;
create table innter_join as
 select a.* ,
        b.*
from chap3.low_birth  a
     inner join
     chap3.icu b
     on a.id = b.id
;
quit;

run;


**Step 9c: Left ouuter Join we end up with the 189 that are in low birth;


run;
proc sql feedback;
create table left_join as
 select a.* ,
        b.*
from chap3.low_birth  a
     left join
     chap3.icu b
     on a.id = b.id
;
quit;

run;


**Step 9d: right ouuter Join we end up with the 200 that are in icu birth;


run;
proc sql feedback;
create table right_join as
 select a.* ,
        b.*
from chap3.low_birth  a
     right join
     chap3.icu b
     on a.id = b.id
;
quit;

run;

**Step 9e: Full ouuter Join we end up with the 344 that overlap both that are in icu birth;
**         notice that non of the id values from ICU are contained in the full_join table;


run;
proc sql feedback;
create table full_join as
 select a.* ,
        b.*
from chap3.low_birth  a
     full join
     chap3.icu b
     on a.id = b.id
;
quit;

run;

proc print data=full_join(obs=1000);
 title 'here is the full join';

run;



**Step 9f: Compare the above with the data set form;
**         Notice here that you get all the ids;

  data icu;
   set chap3.icu;

  proc sort data=icu;
  by id;


  data low_birth;
    set chap3.low_birth;


proc sort data=low_birth;
 by id;

 data data_icu_low_full_join;
 merge icu(in=a) low_birth(in=b);
 by id;

run;

proc print data=data_icu_low_full_join(obs=1000);
 title 'here is the full join using merge';

run;


**Step 9g: To get the full set using SQL add in the coalesce function;


run;
proc sql feedback;
create table full_join_coal as
 select coalesce(a.id,b.id) as id,
a.LOW,
a.AGE as age_low,
a.LWT,
a.RACE as racd_low,
a.SMOKE,
a.PTL,
a.HT,
a.UI,
a.FTV,
a.BWT,
b.STA,
b.AGE as age_icu,
b.GENDER,
b.RACE as race_icu,
b.SER,
b.CAN,
b.CRN,
b.INF,
b.CPR,
b.SYS,
b.HRA,
b.PRE,
b.TYP,
b.FRA,
b.PO2,
b.PH,
b.PCO,
b.BIC,
b.CRE,
b.LOC
from chap3.low_birth  a
     full join
     chap3.icu b
     on a.id = b.id
;
quit;

run;

proc print data=full_join_coal(obs=1000);
 title 'here is the full join';

run;


**Step 10: Inline Views;


** Step 10a: What is in inner view;
** An inner view is where you create a table within;
** the proc sql and then use that table;


%macro skipit;

 proc sql feedback;
select m.sta format sta. as status,
       m.sub_total,
       q.total,
       m.sub_total/q.total as per_total

from (select STA format=sta. as status,
 count (id) as sub_total
from chap3.icu
group by sta) as m
(select count(z.id) as total
 from chap3.icu z) as q
where m.id = q.id
;
quit;

%mend skipit;


 proc sql feedback;
select m.status,
       m.sub_total,
       q.total as total,
   m.sub_total/q.total format = 4.2 as per_total
from (select STA format=sta. as status,
 count (id) as sub_total
from chap3.icu
group by sta) as m,
(select count(z.id) as total
 from chap3.icu z) as q
;
quit;



***Step 11: Complex Example;

**Step 11a: Get the crew of the copenhagen flight;


proc contents data=sasuser.flightschedule;

run;

proc sql;
select empid
from sasuser.flightschedule
where date in ("04mar2000"d)
and destination in ("CPH");
quit;

run;


 **Step 11b: Find the states and job categories of the crew memberst;
 ** Notice that the step 11a results is now a subquery;

  proc sql;
select substr(JobCode,1,2) as JobCategory,
state
from sasuser.staffmaster as s,
sasuser.payrollmaster as p
where s.empid=p.empid and s.empid in
(select empid
from sasuser.flightschedule
where date="04mar2000"d
and destination="CPH");
quit;


 **Step 11c: Now find employee id of the supervisors;
 **   Notice that 11b will be in inline view;


   proc sql;
select empid
from sasuser.supervisors as m,
(select substr(jobcode,1,2) as JobCategory,
state
from sasuser.staffmaster as s,
sasuser.payrollmaster as p
where s.empid=p.empid and s.empid in
(select empid
from sasuser.flightschedule
where date="04mar2000"d
and destination="CPH")) as c
where m.jobcategory=c.jobcategory
and m.state=c.state;
quit;

run;


  **Step 11d: Now find names of the supervisors;
 **  Notice that 11c is now a sub query of this routine;


  proc sql;
select firstname, lastname
from sasuser.staffmaster
where empid in
(select empid
from sasuser.supervisors as m,
(select substr(jobcode,1,2)
as JobCategory,
state
from sasuser.staffmaster as s,
sasuser.payrollmaster as p
where s.empid=p.empid
and s.empid in
(select empid
from sasuser.flightschedule
where date="04mar2000"d
and destination="CPH"))
as c
where m.jobcategory=c.jobcategory
and m.state=c.state);
quit;

run;


** Step 12: Complex Example Solved more Efficently;
** Notice that the staffmaster comes in twice;


proc sql;
select distinct e.firstname, e.lastname
from sasuser.flightschedule as a,
sasuser.staffmaster as b,
sasuser.payrollmaster as c,
sasuser.supervisors as d,
sasuser.staffmaster as e
where a.date="04mar2000"d and
a.destination="CPH" and
a.empid=b.empid and
a.empid=c.empid and
d.jobcategory=substr(c.jobcode,1,2)
and d.state=b.state
and d.empid=e.empid;
quit;

run;


** Step 13: Tranditional SAS Programing Using Data Steps;


/* Find the crew for the flight. */
proc sort data=sasuser.flightschedule (drop=flightnumber)
out=crew (keep=empid);
where destination="CPH" and date="04MAR2000"d;
by empid;
run;


 /* Find the State and job code for the crew. */
proc sort data=sasuser.payrollmaster
(keep=empid jobcode)
out=payroll;
by empid;
run;
proc sort data=sasuser.staffmaster
(keep=empid state firstname lastname)
out=staff;
by empid;
run;
data st_cat (keep=state jobcategory);
merge crew (in=c)
staff
payroll;
by empid;
if c;
jobcategory=substr(jobcode,1,2);
run;
/* Find the supervisor IDs. */
proc sort
data=st_cat;
by jobcategory state;
run;
proc sort data=sasuser.supervisors
out=superv;
by jobcategory state;
run;
data super (keep=empid);
merge st_cat(in=s)
superv;
by jobcategory state;
if s;
run;
/* Find the names of the supervisors. */
proc sort data=super;
by empid;
run;
data names(drop=empid);
merge super (in=super)
staff (keep=empid firstname lastname);
by empid;
if super;


run;
proc print data=names noobs uniform;

run;
