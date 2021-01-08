
*****************************************************;
* Step 1: Bring in the Low Birth Weight Data;
*         We used import wizard to created LBW then;
*         saved it into chap1;
*******************************************************;

run;

**libname chap1  'C:\UC Berkley\Summer 2016\Chapter 1';
**libname chap2  'C:\UC Berkley\Summer 2016\Chapter 2';

libname chap1 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 1';  
libname chap2 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 2';  

run;


  %macro skipit;


 data chap2.LBW;
  set LbW;

  run;

  %mend skipit;


**Step 2: Select all the LWB;


proc sql;
 select a.*
from chap2.LBW  a
;
quit;

run;


**Step 3:  Use Feedback ;

proc sql feedback;
 select a.*
from chap2.LBW  a
;
quit;


run;


**Step 4: Limit number of observations like ussing (outobs=) in data step;


proc sql feedback outobs=25;
 select a.*
from chap2.LBW  a
;
quit;



** Step 5: Dedupting like using nodupkey in proc sort;
** First we need to bring in some data with multiple records per;
** paitent  id Bring in Grace Data;

**Step 5a: Get the GRACE data associated with; 

options ps=500;

DATA grace1000;
  **INFILE "C:\UC Berkley\Logistic Reg & Survival Analysis\For Students\Hazard Model\Data\GRACE1000.dat";
infile "H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Logistic Reg & Survival Analysis\For Students\Hazard Model\Chapter 7\GRACE1000.dat";
   input id    days death revasc revascdays los age sysbp stchange
;

run;

Run;

libname chap7 'C:\UC Berkley\Logistic Reg & Survival Analysis\For Students\Hazard Model\Data';

run;

data chap2.grace1000;
 set grace1000;

RUN;

data grace1000; 
 set chap2.grace1000; 

 run; 

 ** Step 5a1: Distribution of variables in grace model; 

  proc freq data=grace1000; 
   table death revasc revascdays / missing; 
   where revasc = 1; 
    title 'grace1000'; 

	run; 

	options ps=500; 

	proc sort data=grace1000; 
	 by days; 

proc print data=grace1000; 
 var ID days death revasc revascdays los; 
 title 'grace100'; 

 run; 



**Step 5b: Break data up into daily observations;
**         Will do this to enable us to use the counting method in Surival Analysis;

 proc sort data=grace1000;
   by id;

    data expand_grace;
   set grace1000;
   by id;
   days_used = days; 
    if days_used = .5 then days_used = 1; 
if first.id then do;
  do i=0 to days_used by 1; 
     if i=0 then do;
        t=0 and lagt = .;
		revasc_t = 0; 
       if death=0 then g = 0;
       if death=1 then do;
           if t < days then g = 0;
           if t = days then g=1;
       end;
        output;
     end;
      if i>0 then do;
       t=i;
       lagt = i-1;
       if death=0 then g = 0;
       if death=1 then do;
           if t < days then g = 0;
           if t = days then g=1;
       end;
	   if revasc = 0 then revasc_t = 0; 
	   if revasc =1 then do;
           if t <  revascdays then revasc_t = 0;
           if t >= revascdays then revasc_t=1;
       end;
        output;
     end;
    end;
  end;
     
proc print data=expand_grace; 
 var id i t days days_used death revasc revascdays revasc_t g; 
 where id in (1,2,3,54); 
 title 'results for IDs 1,2,3,54'; 

 run; 

%macro skipit; 

**example of expandsion; 

 data expanded;
 set unexpanded;
 by id;
  time = lenfol_years;
  if first.id then do;
    do i=0 to time by 1;
     if i=0 then do;
        t=0 and lagt = .;
       if fstat=0 then g = 0;
       if fstat=1 then do;
           if t < time then g = 0;
           if t = time then g=1;
       end;
        output;
     end;
     if i>0 then do;
       t=i;
       lagt = i-1;
       if fstat=0 then g = 0;
       if fstat=1 then do;
           if t < time then g = 0;
           if t = time then g=1;
       end;
        output;
     end;
    end;
  end;

%mend skipit; 



 run;


**Step 5c: Lets now get distinct values by id and days;


proc sql outobs=25;
 select a.*
from expand_grace  a
;
quit;


proc sql;
 select distinct a.id,
                 a.days
from expand_grace a
;
quit;


run;


**Step 6: Subsetting the data with where statements;


**Step 6a: Using Where;

proc sql feedback;
 select a.*
from chap2.LBW  a
where  a.age > 35 and a.lwt < 100
order by a.id
;
quit;


proc sql feedback;
 select a.*
from chap2.LBW  a
where  a.age > 35 and a.lwt < 125
order by a.id
;
quit;


**Step 6b: Using Between;


 proc sql feedback;
 select a.*
from chap2.LBW  a
where  a.age between 18 and 35
order by a.age
;
quit;


** Step 6c: using Contain;

%macro skipit;

 data chap2.prostate;
  set prostate;

run;

%mend skipit;


 proc sql feedback;
 select a.*
from chap2.prostate  a
where  a.pf contains 'normal'
order by a.age
;
quit;

**step 6d: Using in operator;


 proc sql feedback;
 select a.*
from chap2.prostate  a
where  a.sg in (8,9,10)
order by a.sg
;
quit;


** Step 6e: Using the Null or Missing operator;

 proc sql feedback;
 select a.*
from chap2.prostate  a
where  a.sg is Null
order by a.sg
;
quit;


**Step 6f: Using the Like Operator;

 data prostate; 
  set chap2.prostate; 

  run; 

  proc freq data=prostate; 
   table status / missing; 
   title 'status'; 

   run ; 


 proc sql feedback;
 select a.*
from prostate  a
where  a.status like '% %pros%'
order by a.status
;
quit;

 proc sql feedback;
 select a.*
from prostate  a
where  a.status contains 'pros'
order by a.status
;
quit;


 proc sql feedback;
 select a.*
from chap2.prostate  a
where  a.status like ' p_ostat_'
order by a.status
;
quit;


**Step 6g: Sounds Like;


 proc sql feedback;
 select a.*
from chap2.prostate  a
where  a.rx =* 'plasebo'
order by a.status
;
quit;

**Step 7: using calculated values;

  proc sql feedback;
 select a.*,
  a.sz*a.sg as size_gleason
from chap2.prostate  a
where  size_gleason > 8
order by a.age
;
quit;

run;

  proc sql feedback;
 select a.*,
  a.sz*a.sg as size_gleason
from chap2.prostate  a
where calculated size_gleason > 8
order by a.age
;
quit;


**Step 8: Formats and labels;

**Step 8a: Straight forward example;

 proc format;
 value censor
 0 = 'alive'
 1 = 'Died of prostate cancer'
 2 = 'Died of (CVD)'
 3 = 'Died of Other'
;
run;
 proc sql feedback;
 select a.censor label='Censor Type' format = censor.,
             avg(a.sz) as avg_sz label = 'Avg Size' format 12.2,
             avg(a.sg) as avg_sg label = 'Avg Gleason' format 12.2


from chap2.prostate  a
group by a.censor
;
quit;


**Step 8b: Do an average on a calculated value;

   proc sql feedback;
 select a.censor label='Censor Type' format = censor.,
             avg(a.sz) as avg_sz label = 'Avg Size' format 12.2,
             avg(a.sg) as avg_sg label = 'Avg Gleason' format 12.2,
             avg(a.sg+a.sg) as avg_sg_sg label = 'Avg Size+Gleason' format 12.2,
             avg(a.sg*a.sg) as avg_t_sgsg label = 'Avg Size X Gleason' format 12.2

from chap2.prostate  a
group by a.censor
;
quit;


**Step 8c: Statements prior to values;

     proc sql feedback;
 select a.censor label='Censor Type' format = censor.,
             avg(a.sz) as avg_sz label = 'Avg Size' format 12.2,
             avg(a.sg) as avg_sg label = 'Avg Gleason' format 12.2,
             avg(a.sg) as avg_sg label = 'Avg Gleason' format 12.2,
             'average size times gleason is:',
             avg(a.sg*a.sg) format 12.2

from chap2.prostate  a
group by a.censor
;
quit;


**Step 9: Getting averages and summs for everthing in the table;

**Step 9a: So far we have always grouped the data together;

     proc sql feedback;
 select a.censor label='Censor Type' format = censor.,
             avg(a.sz) as avg_sz label = 'Avg Size' format 12.2,
             avg(a.sg) as avg_sg label = 'Avg Gleason' format 12.2,
             avg(a.sg) as avg_sg label = 'Avg Gleason' format 12.2,
             'average size times gleason is:',
             avg(a.sg*a.sg) format 12.2

from chap2.prostate  a
group by a.censor
;
quit;


**Step 9b: If we do not group it we get the results for the entire set of data;

     proc sql feedback;
 select
             avg(a.sz) as avg_sz label = 'Avg Size' format 12.2,
             avg(a.sg) as avg_sg label = 'Avg Gleason' format 12.2,
             avg(a.sg) as avg_sg label = 'Avg Gleason' format 12.2,
             'average size times gleason is:',
             avg(a.sg*a.sg) format 12.2

from chap2.prostate  a
;
quit;


***Step 10: Counting function;

**Step 10a: Counting everything;

      proc sql feedback;
 select  count(*)
from chap2.prostate
;
quit;


**Step 10b: Count the non-missing column;


  proc sql feedback;
 select  count(status)
from chap2.prostate
;
quit;



**Step 10c: Count the distinct non-missing column;


  proc sql feedback;
 select  count(distinct status)
from chap2.prostate
;
quit;


**Step 10d: Count number in each status;


  proc sql feedback;
 select censor label='Censor Type' format = censor.,
  count(distinct id)
from chap2.prostate
group by 1
;
quit;



**Step 11: Remerging data;

**Step 11a: Resmergeing ddata;
** Example of re-submerging;

     proc sql feedback;
 select     a.id,a.sz,
            avg(a.sz)        as avg_size label = 'Avg Size' format 12.2,
            (a.sz/avg(a.sz)) as pct_size label = 'Pct Size' format 12.2

from chap2.prostate  a
;
quit;


** Step 12: using a subquery;


**Step 12a: Subquery on same data set;
** Select only those censored values whose avearge prostate size;
** is greatger than the overall average;
** That is why we only get those who died of prostate cancer;

      proc sql feedback;
 select     a.censor format=censor.,
            avg(a.sz)        as avg_size label = 'Avg Size' format 12.2
 from chap2.prostate  a
 group by a.censor
 having avg(a.sz) >
  (select avg(a.sz) from chap2.prostate a)
;
quit;


**Step 12b: Subquery on two different data sets;

options ps=500;
proc contents data=chap1.burns_part1;
proc contents data=chap1.burns_part2;

run;

proc format;
 value racec
0= 'White'
1 = 'Non-White'
;

run;


      proc sql feedback;
 select     a.id,
            a.Racec format=racec.,
            inh_inj    label = 'Inhalation Inj' format 12.0

 from chap1.burns_part2  a
 where a.id in
  (select b.id from chap1.burns_part1 b)
;
quit;


**Step 12c: Subquery from the same dataset;

 title 'Avg Prostate Size of those whose age is greater than the overall average age';

      proc sql feedback;
 select     a.censor format=censor.,
            count(*) as count label = 'Tot' format=12.2,
            avg(a.sz)        as avg_size label = 'Avg Size' format 12.0
 from chap2.prostate  a
 group by a.censor
 having avg(a.age) >
  (select avg(a.age) from chap2.prostate a)
;
quit;


**Step 13: Using the All statment in a sub query;


 title 'Avg Prostate Size of those whose age is greater than ALL those who are alive';
      proc sql feedback;
 select     a.censor format=censor.,
            count(*) as count label = 'Tot' format=12.2,
            avg(a.sz)        as avg_size label = 'Avg Size' format 12.0
 from chap2.prostate  a
 where a.age  > all
  (select a.age from chap2.prostate a
   where a.status in ('alive'))
 group by a.censor
;
quit;


**Step 14: Using Not Exists;

**Step 14a: Lets first create a dataset of those who are alive;

   data alive;
   set chap2.prostate;
   if censor = 0;

**Step 14b: Lets use the exists to find average prostate size for those show are alive;
**          This one does not work;


 title 'Avg Prostate Size of those whose are alive';
      proc sql feedback;
 select     a.censor format=censor.,
            count(*) as count label = 'Tot' format=12.0,
            avg(a.sz)        as avg_size label = 'Avg Size' format 12.0
 from chap2.prostate  a
 where  exists
  (select a.*
   from chap2.prostate a
   where a.age > 60)
 group by a.censor
;
quit;


** Step 15: Validate a Query;

 title 'Avg Prostate Size of those whose age is greater than ALL those who are alive';
      proc sql noexec ;
 select     a.censor format=censor.,
            count(*) as count label = 'Tot' format=12.2,
            avg(a.sz)        as avg_size label = 'Avg Size' format 12.0
 from chap2.prostate  a
 where a.age  > all
  (select a.age from chap2.prostate a
   where a.status in ('alive'))
 group by a.censor
;
quit;
