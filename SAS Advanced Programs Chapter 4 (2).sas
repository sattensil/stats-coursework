
*****************************************************;
* Step 1: Bring in the Low Birth Weight Data;
*         We used import wizard to created LBW then;
*         saved it into chap1;
*******************************************************;

run;


%macro skipit;
libname chap1  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 1';
libname chap2  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 2';
libname chap3  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 3';
libname chap4  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 4';
libname sasusers 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Data';
%mend skipit;


run;

libname chap4 'C:\UC Berkley\Summer 2016\Chapter 1';
libname chap4 'C:\UC Berkley\Summer 2016\Chapter 2';
libname chap4 'C:\UC Berkley\Summer 2016\Chapter 3';
libname chap4 'C:\UC Berkley\Summer 2016\Chapter 4';
libname chap5 'C:\UC Berkley\Summer 2016\Chapter 5';
libname sasuser 'C:\UC Berkley\Summer 2016\Data';

run;






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


**Step 2: put two data sets on top of one another;
**        the set function;
** It does not actually work you need to use one of the set operators which is;
**  Except, Intercept, Union and Outer Union;

  proc sql;
create table setter as
 select *
  from chap3.icu
  set-operator
    select *
     from chap3.burns
;
quit;


**Step 3: Use the EXCEPT process to remove;
**        unique rows in the first table not found in the second table;

**Step 3a: Start with looking just at example where we have ID from burns_short;
**         Note this will not reduce the data sets;

  data burns_short;
   set chap3.burns;
   **keep id gender;
   keep id;

   run;

    proc sql;
create table except as
 select *
  from chap3.icu
  except
    select *
     from burns_short
;
quit;


**Step 3b: Now lets create a subset of the data from ICU;
**         Notice in this case it does reduce the number;
**         THat is because all the rows are the same;

 data icu_sub_set;
  set chap3.icu;
   if _n_ <= 20;

   run;

    proc sql;
create table except as
 select *
  from chap3.icu
  except
    select *
     from icu_sub_set
;
quit;

**Step 4: INTERCEPT COMMAND.
** Here we will again go through the two examples;
** you have to have all the rows the same for the INTERCEPT to work;

**Step 4a: Start with looking just at example where we have ID from burns_short;
**         Note this will not reduce the data sets;

  data burns_short;
   set chap3.burns;
   if _n_ <= 100;
   **keep id gender;
   keep id;

   proc print data=burns_short;
    title 'burns short';

   run;

 proc sql;
create table Intercept as
 select *
  from chap3.icu
  intersect
    select *
     from burns_short
;
quit;


**Step 4b: We could of course just use the following;
**         This is what we have done in the past;

 proc sql;
create table Intercept_old as
 select a.*
  from chap3.icu a,
       burns_short b
  where a.id = b.id
  ;
quit;

**Step 4c: We do the intercept with the subset of ICU we used;

 data icu_sub_set;
  set chap3.icu;
   if _n_ <= 20;

   run;

    proc sql;
create table intersect as
 select *
  from chap3.icu
  intersect
    select *
     from icu_sub_set
;
quit;


**Step 5: Union COMMAND.
** Overlays columns and rows;

**STep 5a: take the results by column and rows;
** Notice in this first example there is no difference;
** between union and outer union;

run;

  data burns_short;
   set chap3.burns;
   if _n_ <= 100;
   **keep id gender;
   **keep id;

   proc print data=burns_short;
    title 'burns short';

   run;

 proc sql;
create table Union as
 select *
  from chap3.icu
  union
    select *
     from burns_short
;
quit;

run;

 proc sql;
create table Outer_Union as
 select *
  from chap3.icu
  outer union
    select *
     from burns_short
;
quit;


**STep 5b: If we use the subset of ICU then we can see the difference;
**         in Union and Outer Union;

run;

 data icu_sub_set;
  set chap3.icu;
   if _n_ <= 20;

   run;

    proc sql;
create table union as
 select *
  from chap3.icu
  union
    select *
     from icu_sub_set
;
quit;

    proc sql;
create table outer_union as
 select *
  from chap3.icu
  outer union
    select *
     from icu_sub_set
;
quit;


**Step 6: Using the All Command;

**Step 6a: all commend with Except;
** Notice here there is no difference;

 data icu_sub_set;
  set chap3.icu;
   if _n_ <= 20;

   run;

    proc sql;
create table except as
 select *
  from chap3.icu
  except
    select *
     from icu_sub_set
;
quit;

    proc sql;
create table except as
 select *
  from chap3.icu
  except all
    select *
     from icu_sub_set
;
quit;

**Step 6b: So if we want to show how this works we need;
**         to make a table with multiple rows;
**         Now we see there are some differences;


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


    proc sql;
create table except_no_all as
 select *
  from use_for_all
  except
    select *
     from icu_sub_set3
order by id;
;
quit;

 proc print data=except_no_all;
 title 'except_no_all';

 run;


    proc sql;
create table except_all as
 select *
  from use_for_all
  except all
    select *
     from icu_sub_set3
order by id;
;
quit;

proc print data=except_all;
 title 'except_all';

 run;


**Step 6c: Using all with intersect function to understand all;

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


proc print data=icu_sub_set3;
 title 'icu_sub_set3';

 run;

 **First we run were BOTH have duplicates;

    proc sql;
create table intersect_no_all as
 select *
  from use_for_all
  intersect
    select *
     from icu_sub_set3
;
quit;

proc print data=intersect_no_all;
title 'inersect_no_all';

    proc sql;
create table intersect_all as
 select *
  from use_for_all
  intersect all
    select *
     from icu_sub_set3
;
quit;

proc print data=intersect_all;
title 'inersect_all';

run;

**Second were only the first has duplicates;
** NOtice that now thre is no difference;

 data icu_sub_set3;
  set use_for_all;
  if 3 <= _n_ <= 10;  **Note we take those with duplicates so we can see the difference with all;

  run;


proc sort data=icu_sub_set3 nodupkey;
 by id;

 run;

 proc sort data=use_for_all;
  by id;

  run;

    proc sql;
create table intersect_no_all as
 select *
  from use_for_all
  intersect
    select *
     from icu_sub_set3
;
quit;

proc print data=intersect_no_all;
title 'inersect_no_all';

    proc sql;
create table intersect_all as
 select *
  from use_for_all
  intersect all
    select *
     from icu_sub_set3
;
quit;

proc print data=intersect_all;
title 'inersect_all';

run;

**Third we have duplicates in the second data set intersection only;
** Notice that these are the same;


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

    data icu_sub_set3;
  set use_for_all;
  if 3 <= _n_ <= 10;  **Note we take those with duplicates so we can see the difference with all;

  run;

proc sort data=use_for_all nodupkey;
 by id;

 run;

    proc sql;
create table intersect_no_all as
 select *
  from use_for_all
  intersect
    select *
     from icu_sub_set3
;
quit;

proc print data=intersect_no_all;
title 'inersect_no_all';

    proc sql;
create table intersect_all as
 select *
  from use_for_all
  intersect all
    select *
     from icu_sub_set3
;
quit;

proc print data=intersect_all;
title 'inersect_all';

run;


**Step 6d: Using all with Union function to understand all;

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


proc print data=icu_sub_set3;
 title 'icu_sub_set3';

 run;

 **First we run were BOTH have duplicates;

    proc sql;
create table union_no_all as
 select *
  from use_for_all
  union
    select *
     from icu_sub_set3
;
quit;

proc sort data=union_no_all;
 by id;

proc print data=union_no_all;
title 'union_no_all';

    proc sql;
create table union_all as
 select *
  from use_for_all
  union all
    select *
     from icu_sub_set3
;
quit;

proc sort data=union_all;
 by id;


proc print data=union_all;
title 'union_all';

run;

**Second were only the first has duplicates;
** Notice that without all they are the same;
** But with the all they are different because we have fewer;
** Results in the second data set;

 data icu_sub_set3;
  set use_for_all;
  if 3 <= _n_ <= 10;  **Note we take those with duplicates so we can see the difference with all;

  run;


proc sort data=icu_sub_set3 nodupkey;
 by id;

 run;

 proc sort data=use_for_all;
  by id;

  run;

    proc sql;
create table union_no_all as
 select *
  from use_for_all
  union
    select *
     from icu_sub_set3
         order by id
;
quit;

proc print data=union_no_all;
title 'inersect_no_all';

    proc sql;
create table union_all as
 select *
  from use_for_all
  union all
    select *
     from icu_sub_set3
         order by id
;
quit;

proc print data=union_all;
title 'union_all';

run;

**Third we have duplicates in the second data set intersection only;

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

    data icu_sub_set3;
  set use_for_all;
  if 3 <= _n_ <= 10;  **Note we take those with duplicates so we can see the difference with all;

  run;

proc sort data=use_for_all nodupkey;
 by id;

 run;

    proc sql;
create table union_no_all as
 select *
  from use_for_all
  union
    select *
     from icu_sub_set3
;
quit;

proc print data=union_no_all;
title 'union_no_all';

    proc sql;
create table union_all as
 select *
  from use_for_all
  union all
    select *
     from icu_sub_set3
;
quit;

proc print data=union_all;
title 'union_all';

run;


**Step 6e: Using all with Outer Union function to understand all;

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


proc print data=icu_sub_set3;
 title 'icu_sub_set3';

 run;

 **First we run were BOTH have duplicates;

    proc sql;
create table outer_union_no_all as
 select *
  from use_for_all
  outer union
    select *
     from icu_sub_set3
         order by id
;
quit;

proc print data=union_no_all;
title 'outer union_no_all';

    proc sql;
create table outer_union_all as
 select *
  from use_for_all
  outer union all
    select *
     from icu_sub_set3
         order by id
;
quit;

**Note it does not work;

proc print data=union_all;
title 'Outer union_all';

run;

**Step 7:  Lets look at Corr statement;
**So if we want to show how this works we need;
**         to make a table with multiple rows;
**         Now we see there are some differences;

**Step 7a: Both have duplicates;

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
  keep id sta age gender;

  run;

 proc print dta=icu_sub_set3;
 title 'icu_sub_set3';

 run;

**Look at Except;

    proc sql;
create table except_no_corr as
 select *
  from use_for_all
  except
    select *
     from icu_sub_set3
order by id;
;
quit;

 proc print data=except_no_corr;
 title 'except_no_corr';

 run;


    proc sql;
create table except_corr as
 select *
  from use_for_all
  except corr
    select *
     from icu_sub_set3
order by id;
;
quit;

proc print data=except_corr;
 title 'except_corr';
 title2 'Notice we limit ourselves to the columns';
 title3 'Also we have less results because Corr takes out all the rows that are duplicate';

 run;

 run;


 **Look at intersect;

  proc print data=use_for_all;
 title 'here is use for all';

 run;

 proc print dta=icu_sub_set3;
 title 'icu_sub_set3';

 run;


   proc sql;
create table intersect_no_corr as
 select *
  from use_for_all
  intersect
    select *
     from icu_sub_set3
order by id;
;
quit;

 proc print data=intersect_no_corr;
 title 'intersect_no_corr';
 title2 'No matches as rows and columns are not the same';

 run;


    proc sql;
create table intersect_corr as
 select *
  from use_for_all
  intersect  corr
    select *
     from icu_sub_set3
order by id;
;
quit;

proc print data=intersect_corr;
 title 'intersect_corr';
 title2 'we get matches because of the Corr';

 run;

    proc sql;
create table intersect_corr_all as
 select *
  from use_for_all
  intersect  all corr
    select *
     from icu_sub_set3
order by id;
;
quit;

proc print data=intersect_corr_all;
 title 'intersect_corr_all';
 title2 'we get matches because of the Corr';
 title3 'we get duplications because we have all';

 run;


 **Look at union;

  proc print data=use_for_all;
 title 'here is use for all';

 run;

 proc print dta=icu_sub_set3;
 title 'icu_sub_set3';

 run;

   proc sql;
create table union_no_corr as
 select *
  from use_for_all
  union
    select *
     from icu_sub_set3
order by id
;
quit;

 proc print data=union_no_corr;
 title 'union_no_corr';
 title2 'matches on all with missing values has no corr';

 run;


    proc sql;
create table union_corr as
 select *
  from use_for_all
  union  corr
    select *
     from icu_sub_set3
order by id;
;
quit;

proc print data=union_corr;
 title 'union_corr';
 title2 'matches because of the Corr';
 title3 'Notice because of No all no duplicates';


 run;

    proc sql;
create table union_corr_all as
 select *
  from use_for_all
  union  all corr
    select *
     from icu_sub_set3
order by id;
;
quit;

proc print data=union_corr_all;
 title 'union_corr_all';
 title2 'because of the Corr We get fewer columns';
 title3 'we get duplications because we have all';

 run;


 **Look at outer union;

  proc print data=use_for_all;
 title 'here is use for all';

 run;

 proc print dta=icu_sub_set3;
 title 'icu_sub_set3';

 run;

   proc sql;
create table outer_union_no_corr as
 select *
  from use_for_all
  outer union
    select *
     from icu_sub_set3
order by id
;
quit;

 proc print data=outer_union_no_corr;
 title 'outer_union_no_corr';
 title2 'matches on all with missing values has no corr';
 title3 'Notice all the missing because no direct match';

 run;


    proc sql;
create table outer_union_corr as
 select *
  from use_for_all
  outer union  corr
    select *
     from icu_sub_set3
order by id;
;
quit;

proc print data=Outer_union_corr;
 title 'outer union_corr';
 title2 'matches because of the Corr';
 title3 'Becaue of CORR we do not get missing values';


 run;

    proc sql;
create table outer_union_corr_all as
 select *
  from use_for_all
  outer union all corr
    select *
     from icu_sub_set3
order by id;
;
quit;

proc print data=outer_union_corr_all;
 title 'outer union_corr_all';
 title2 'because of the Corr We get fewer columns';
 title3 'We get nothing because can not use all with outer join';

 run;


**Step 7b: only first has duplicates;
**          No difference in results;
** Just use some examples not doing them all;

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
  keep id sta age gender;

  run;

  proc sort data=icu_sub_set3 nodupkey;
   by id;

 proc print dta=icu_sub_set3;
 title 'icu_sub_set3';

 run;


    proc sql;
create table except_no_corr as
 select *
  from use_for_all
  except
    select *
     from icu_sub_set3
order by id;
;
quit;

 proc print data=except_no_corr;
 title 'except_no_corr';

 run;


    proc sql;
create table except_corr as
 select *
  from use_for_all
  except corr
    select *
     from icu_sub_set3
order by id;
;
quit;

proc print data=except_corr;
 title 'except_corr';

 run;

**Step 7c: Now the second has duplicates the first does not;
**          There are differences in results;

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

proc sort data=use_for_all nodupkey;
 by id;

 proc print dta=use_for_all;
 title 'here is use for all';

 run;

 data icu_sub_set3;
  set use_for_all;
  if 3 <= _n_ <= 10;  **Note we take those with duplicates so we can see the difference with all;
  keep id sta age gender;

  run;

  proc sort data=icu_sub_set3;
   by id;

 proc print dta=icu_sub_set3;
 title 'icu_sub_set3';

 run;


    proc sql;
create table except_no_corr as
 select *
  from use_for_all
  except
    select *
     from icu_sub_set3
order by id;
;
quit;

 proc print data=except_no_corr;
 title 'except_no_corr';

 run;


    proc sql;
create table except_corr as
 select *
  from use_for_all
  except corr
    select *
     from icu_sub_set3
order by id;
;
quit;

proc print data=except_corr;
 title 'except_corr';

 run;


**Step 8:  Lets look at Corr with ALL statement;
**So if we want to show how this works we need;
**         to make a table with multiple rows;
**         Now we see there are some differences;

**Step 8a: Both have duplicates;

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
  keep id sta age gender;

  run;

 proc print data=icu_sub_set3;
 title 'icu_sub_set3';

 run;


    proc sql;
create table except_no_corr as
 select *
  from use_for_all
  except
    select *
     from icu_sub_set3
order by id;
;
quit;

 proc print data=except_no_corr;
 title 'except_no_corr No Corr or All';

 run;


    proc sql;
create table except_corr as
 select *
  from use_for_all
  except corr
    select *
     from icu_sub_set3
order by id;
;
quit;

proc print data=except_corr;
 title 'except_corr No All';

 run;


     proc sql;
create table except_corr_all as
 select *
  from use_for_all
  except all corr
    select *
     from icu_sub_set3
order by id;
;
quit;

proc print data=except_corr;
 title 'except_corr Has Both CORR and All';
 title2 'Here there is no Difference in Corr and All';

 run;


**Step 8b: only first has duplicates;

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
  keep id sta age gender;

  run;

  proc sort data=icu_sub_set3 nodupkey;
   by id;

 proc print dta=icu_sub_set3;
 title 'icu_sub_set3';

 run;

    proc sql;
create table except_no_corr as
 select *
  from use_for_all
  except
    select *
     from icu_sub_set3
order by id;
;
quit;

 proc print data=except_no_corr;
 title 'except_no_corr No Corr or All';

 run;

    proc sql;
create table except_corr as
 select *
  from use_for_all
  except corr
    select *
     from icu_sub_set3
order by id;
;
quit;

proc print data=except_corr;
 title 'except_corr No All';

 run;


     proc sql;
create table except_corr_all as
 select *
  from use_for_all
  except all corr
    select *
     from icu_sub_set3
order by id;
;
quit;

proc print data=except_corr;
 title 'except_corr Has Both CORR and All';
 title2 'Here there is no Difference in Corr and All';

 run;


**Step 8c: Now the second has duplicates the first does not;
**          There are differences in results;

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

 run;
proc print data=use_for_all;
 title 'use_for_all With Dupes';

run;

 data icu_sub_set3;
  set use_for_all;
  if 3 <= _n_ <= 10;  **Note we take those with duplicates so we can see the difference with all;
  keep id sta age gender;

  run;

  proc sort data=use_for_all nodupkey;
 by id;

 proc print dta=use_for_all;
 title 'here is use for all No Dupkeys';

 run;

  proc sort data=icu_sub_set3;
   by id;

 proc print dta=icu_sub_set3;
 title 'icu_sub_set3 Has Dupkeys';

 run;


    proc sql;
create table except_no_corr as
 select *
  from use_for_all
  except
    select *
     from icu_sub_set3
order by id;
;
quit;

 proc print data=except_no_corr;
 title 'except_no_corr No Corr or All';
 title2 'No Dedup on first dupes on second';

 run;

    proc sql;
create table except_corr as
 select *
  from use_for_all
  except corr
    select *
     from icu_sub_set3
order by id;
;
quit;

proc print data=except_corr;
 title 'except_corr No All';
 title2 'No Dedup on first dupes on second';

 run;


     proc sql;
create table except_corr_all as
 select *
  from use_for_all
  except all corr
    select *
     from icu_sub_set3
order by id;
;
quit;

proc print data=except_corr;
 title 'except_corr Has Both CORR and All';
 title2 'Here there is no Difference in Corr and All';
 title3 'No Dedup on first dupes on second';


 run;

**Step 9: Compare outer union with set;

 **Step 9a: Lets first create a data set using set statement;

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

 run;
proc print data=use_for_all;
 title 'use_for_all With Dupes';

run;

 data icu_sub_set3;
  set use_for_all;
  if 3 <= _n_ <= 10;  **Note we take those with duplicates so we can see the difference with all;
  keep id sta age gender;

  run;

  proc sort data=use_for_all nodupkey;
 by id;

 proc print dta=use_for_all;
 title 'here is use for all No Dupkeys';

 run;

  data set_data;
   set use_for_all icu_sub_set3;

   run;

 proc print data=set_data;
   title 'set_data One on tope of each other';


   run;


 **Step 9b: Now we use outer union;
 ** With no adjustments;

proc sql;
create table outer_union as
 select *
  from use_for_all
  outer union
    select *
     from icu_sub_set3
order by id;
;
quit;


   run;

 proc print data=outer_union;
   title 'Outer Union';
   title2 'Notice that there are all missing for those in the second data set';

   run;

**Step 9c: Now we use outer union;
 ** Now we add the Corr;

proc sql;
create table outer_union_Corr as
 select *
  from use_for_all
  outer union corr
    select *
     from icu_sub_set3
order by id;
;
quit;


   run;

 proc print data=outer_union_Corr;
   title 'Outer Union Corr';
   title2 'Notice that there are Not missing for those in the second data set';

   run;
