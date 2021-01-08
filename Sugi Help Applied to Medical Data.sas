
*****************************************************;
* Step 1: Bring in the Low Birth Weight Data;
*         We used import wizard to created LBW then;
*         saved it into chap1;
*******************************************************;

run;

libname chap1  'C:\UC Berkley\Summer 2016\Chapter 1';
libname chap2  'C:\UC Berkley\Summer 2016\Chapter 2';
libname chap3  'C:\UC Berkley\Summer 2016\Chapter 3';
libname chap4  'C:\UC Berkley\Summer 2016\Chapter 4';
libname sasusers 'C:\UC Berkley\Summer 2016\Data';

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


**Step 2: Lets use intersect on the two data sets;

**Step 2a: Do a join Notice we state the values we are bring ing;

  proc sql;
create table Joining as
 select a.id,
      a.age as icu_age,
      b.age as burns_age,
      a.race as race_icu,
      b.racec as race_burns
  from chap3.icu  a,
       chap3.burns b
where a.id = b.id
;
quit;

run;

proc print data=joining;
 title 'here is joining';

run;

** Step 2 we use the intersect set operater;

**Step 2a: Start with just ID;

 proc sql;
create table Intercept as
 select a.id
   from chap3.icu  a
  intersect
    select b.id
     from chap3.burns  b
;
quit;


proc print data=intercept;
 title 'intersept';

run;

** Step 2b: Now we introduce age;

 proc sql;
create table Intercept as
 select a.id,
        a.age as icu_age
   from chap3.icu  a
  intersect
    select b.id,
      b.age as burns_age
     from chap3.burns  b
;
quit;


proc print data=intercept;
 title 'intersept Only two Observatons';
 title2 'Only the two that match by age and id';
 title 3 'So for intercept you need both items to match';

run;



** Step 3 Use Coresponding;

 proc sql;
create table Intercept as
 select a.id,
       a.age as icu_age
   from chap3.icu  a
  intersect corr
    select b.id,
      b.age as burns_age
     from chap3.burns  b
;
quit;


proc print data=intercept;
 title 'intersept';
 title2 'Added coresponding';

run;


** Step 4: Lets create two databases with id and age;
** Step 4a: Create the data sets;
run;
  data icu_short;
   set chap3.icu;
   age_icu = age;
  keep id age_icu;

  data burns_short;
   set chap3.burns;
   age_burns = age;
  keep id age_burns;

** Step 4b: Try the intercept;

 proc sql;
create table Intercept as
 select a.*
   from icu_short  a
  intersect
    select b.*
     from burns_short  b
;
quit;

proc print data=intercept;
 title 'intersept';
 title2 'Two Data Sets Only get those that match';

run;

** Step 4c: Put in coresponding;

run;
  data icu_short;
   set chap3.icu;
   age_icu = age;
  keep id age_icu;

  data burns_short;
   set chap3.burns;
   age_burns = age;
  keep id age_burns;

 proc sql;
create table Intercept as
 select a.*
   from icu_short  a
  intersect CORR
    select b.*
     from burns_short  b
;
quit;

proc print data=intercept;
 title 'intersept';
 title2 'Two Data Sets Only get those that match';

run;

** Step 4d: try the all statement;

run;
  data icu_short;
   set chap3.icu;
   age_icu = age;
  keep id age_icu;

  data burns_short;
   set chap3.burns;
   age_burns = age;
  keep id age_burns;

 proc sql;
create table Intercept as
 select a.*
   from icu_short  a
  intersect all
    select b.*
     from burns_short  b
;
quit;

proc print data=intercept;
 title 'intersept';
 title2 'Two Data Sets Only get those that match';

run;


** Step 5: Create two data sets from the ICU data;
** Notice we have crated it with repeating rows so;
** We can explain all;

** Step 5a: we create out data sets which have the same structure;
**  both come from ICU, and both have duplicate records;


data icu_sub_set;
  set chap3.icu;
   if _n_ <= 20;

   run;


data icu_sub_set2;
  set chap3.icu;
  if _n_<=5;

  data use_for_all;
   set icu_sub_set icu_sub_set2;

   run;

proc sort data=use_for_all;
 by id;

 proc print dta=use_for_all;
 title 'here is use for all';

 run;

 data icu_sub_set3;
  set use_for_all;
  if 3 <= _n_ <= 10;  **Note we take those with duplicates so we can see the difference with all;

  run;

 proc print dta=icu_sub_set3;
 title 'icu_sub_set3';

 run;


** Step 5b: Lets start with a join;

proc sql;
 create table join as
 select a.*, b.*
   from use_for_all a,
        icu_sub_set3 b
   where a.id = b.id
order by a.id;
quit;

run;

proc print data=join;
 title 'here is join';

run;

** Step 5c: Now we go to intercept;

 proc sql;
create table Intercept as
 select a.*
   from use_for_all  a
  intersect
    select b.*
     from icu_sub_set3  b
;
quit;

proc print data=intercept;
 title 'intersept';
 title2 'Two Data Sets with Repeats';
 title3 'Intercept by itself takes out the dupes';

run;

** Step 5d: Now we introduce all;


 proc sql;
create table Intercept as
 select a.*
   from use_for_all  a
  intersect all
    select b.*
     from icu_sub_set3  b
;
quit;

proc print data=intercept;
 title 'intersept';
 title2 'Two Data Sets with Repeats';
 title3 'Intercept by itself takes out the dupes ';

run;

** Step 5e: try conresponding;


 proc sql;
create table Intercept as
 select a.*
   from use_for_all  a
  intersect CORR
    select b.*
     from icu_sub_set3  b
;
quit;

proc print data=intercept;
 title 'intersept';
 title2 'Two Data Sets with Repeats';
 title3 'Intercept by itself takes out the dupes ';

run;


** Step 6 Except:

** Step 6a: we create out data sets which have the same structure;
**  both come from ICU, and both have duplicate records;


data icu_sub_set;
  set chap3.icu;
   if _n_ <= 20;

   run;


data icu_sub_set2;
  set chap3.icu;
  if _n_<=5;

  data use_for_all;
   set icu_sub_set icu_sub_set2;

   run;

proc sort data=use_for_all;
 by id;

 proc print dta=use_for_all;
 title 'here is use for all';

 run;

 data icu_sub_set3;
  set use_for_all;
  if 3 <= _n_ <= 10;  **Note we take those with duplicates so we can see the difference with all;

  run;

 proc print dta=icu_sub_set3;
 title 'icu_sub_set3';

 run;


** Step 6b: Lets start with a join;

proc sql;
 create table except as
 select a.*
   from use_for_all a
where a.id notin
(select b.id from
        icu_sub_set3 b)
order by a.id
;
quit;

run;

proc print data=except;
 title 'here is except';

run;


** Step 6c: We use except;

 proc sql;
create table except as
 select a.*
   from use_for_all  a
  except
    select b.*
     from icu_sub_set3  b
;
quit;

proc print data=except;
 title 'except';
 title2 'Notice we get 16 because the id=8 has duplicates';
 title3 'With nothing else duplicates are removed';

run;

** Step 6d: We use except with all;

 proc sql;
create table except as
 select a.*
   from use_for_all  a
  except all
    select b.*
     from icu_sub_set3  b
;
quit;

proc print data=except;
 title 'except with all';
 title2 'Now we get 17 just like the join';

run;


** Step 6e: We use except with Corresponding there is no impact;

 proc sql;
create table except as
 select a.*
   from use_for_all  a
  except CORR
    select b.*
     from icu_sub_set3  b
;
quit;

proc print data=except;
 title 'except with CORR';
 title2 'Now we get 16 just like the except without all';

run;


** Step 7: Using Union;

** Step 7a: we create out data sets which have the same structure;
**  both come from ICU, and both have duplicate records;


data icu_sub_set;
  set chap3.icu;
   if _n_ <= 20;

   run;


data icu_sub_set2;
  set chap3.icu;
  if _n_<=5;

  data use_for_all;
   set icu_sub_set icu_sub_set2;

   run;

proc sort data=use_for_all;
 by id;

 proc print dta=use_for_all;
 title 'here is use for all';

 run;

 data icu_sub_set3;
  set use_for_all;
  if 3 <= _n_ <= 10;  **Note we take those with duplicates so we can see the difference with all;

  run;

 proc print dta=icu_sub_set3;
 title 'icu_sub_set3';

 run;


** Step 7b: We use full union and the term on;

proc sql;
 create table full_union as
 select a.*
   from use_for_all a
   full join
    icu_sub_set3  b
   on a.id = b.id
order by a.id
;
quit;

run;

proc print data=full_union;
 title 'full_union';

run;


** Step 7c: Now we use the union;

run;

 proc sql;
create table union as
 select a.*
   from use_for_all  a
  union
    select b.*
     from icu_sub_set3  b
;
quit;


run;

proc print data=union;
 title 'union';

run;


** Step 7d: Now we use the union with all;

run;

 proc sql;
create table union_all as
 select a.*
   from use_for_all  a
  union all
    select b.*
     from icu_sub_set3  b
;
quit;


run;

proc print data=union_all;
 title 'union All';

run;

** Step 7e: Use CORR;

run;

 proc sql;
create table union_corr as
 select a.*
   from use_for_all  a
    Union CORR
    select b.*
     from icu_sub_set3  b
;
quit;


run;

proc print data=union_corr;
 title 'union corr';

run;


** Step 8: Using outer Union;

** Step 8a: we create out data sets which have the same structure;
**  both come from ICU, and both have duplicate records;


data icu_sub_set;
  set chap3.icu;
   if _n_ <= 20;

   run;


data icu_sub_set2;
  set chap3.icu;
  if _n_<=5;

  data use_for_all;
   set icu_sub_set icu_sub_set2;

   run;

proc sort data=use_for_all;
 by id;

 proc print dta=use_for_all;
 title 'here is use for all';

 run;

 data icu_sub_set3;
  set use_for_all;
  if 3 <= _n_ <= 10;  **Note we take those with duplicates so we can see the difference with all;

  run;

 proc print dta=icu_sub_set3;
 title 'icu_sub_set3';

 run;

** Step 8b: We use full union and the term on ;
** Also called the fulll outer join;

proc sql;
 create table full_union as
 select a.*
   from use_for_all a
   full join
    icu_sub_set3  b
   on a.id = b.id
order by a.id
;
quit;

run;

proc print data=full_union;
 title 'full_union';

run;

** Step 8c: outer join;

run;

 proc sql;
create table outer_union as
 select a.*
   from use_for_all  a
    outer Union
    select b.*
     from icu_sub_set3  b
;
quit;


run;

proc print data=outer_union;
 title 'outer union';

run;
