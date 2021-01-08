
*****************************************************;
* Step 1: Bring in the ICU Data;
*         We used import wizard to created icu then;
*         saved it into chap1;
*******************************************************;

run;

**libname chap1  'C:\UC Berkley\Summer 2016\Chapter 1';
libname chap1 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 1'; 


run;

  %macro skipit;


 data chap1.icu;
  set icu;

  run;

  %mend skipit;


**Step 2:  We select some data from ICU;


proc sql;
 select age, gender, race,
   age/10 as age_decades
from chap1.icu
where age >= 20
;
quit;

run;


**Step 3:  Order by Age;


proc sql;
 select age, gender, race,
   age/10 as age_decades
from chap1.icu
where age >= 20
order by age;
;
quit;

run;


**Step 3:  Order by column location;


proc sql;
 select age, gender, race,
   age/10 as age_decades
from chap1.icu
where age >= 20
order by 1,3;
;
quit;

run;



** Step 4: Data From Multiple Tables;

**Step4a: Create two tables;

  *** Lets bring in two sets of data associated with the burns;
  *** We will first have to create the two data sets then merge them together;

%macro skipit;

 data chap1.burns;
  set burns;

run;

data chap1.burns_part1;
 set chap1.burns;
 keep id  FACILITY
DEATH
AGE
GENDER
;

data chap1.burns_part2;
 set chap1.burns;
 keep id
RACEC
TBSA
INH_INJ
FLAME
;

run;

%mend skipit;

run;


%mend;


**Step 4b: Match the two tables together;

proc sql;
 select a.*,
         b.*
from chap1.burns_part1 a,
     chap1.burns_part2 b
 where a.id = b.id
order by a.id
;

quit;

run;



** Step 5: Summarizing groups of data;


**Step 5a: Create table burns_sql;


proc sql;
create table burns_sql as
 seclect a.*,
         b.*,
         1 as one
from chap1.burns_part1 a,
     chap1.burns_part2 b
 where a.id = b.id
order by a.id
;

quit;

run;


** Step 5b: select number of burn inhilation injuries;

proc sql;
 select a.racec,
        sum(a.INH_INJ) as tot_inh_inj,
        sum(a.one)     as tot
  from burns_sql      a
  group by  a.racec
;
  quit;
run;


**Step 5c: Format Statement;

proc format;
 value racec
 0 ='Non-White'
 1 = 'White'
;

run;


proc sql;
 select a.racec format = racec.,
        sum(a.INH_INJ) as tot_inh_inj,
        sum(a.one)     as tot
  from burns_sql      a
  group by  a.racec
;
  quit;
run;


**Step 5d: Using Having;

proc sql;
 select
        a.facility ,
        sum(a.INH_INJ) as tot_inh_inj,
        sum(a.one)     as tot,
        avg(tbsa)      as avg_tbsa format = 12.2
  from burns_sql      a
  group by  a.facility
  having avg(tbsa) > 20

;
  quit;
run;
