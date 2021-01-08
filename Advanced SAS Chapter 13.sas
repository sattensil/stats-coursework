************************************************************************;
* Chapter 13 taking random samples;
************************************************************************;

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
libname sasusers 'C:\UC Berkley\Summer 2016\Data';
libname sasuser 'C:\UC Berkley\Summer 2016\Data';
libname chap8_L 'C:\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Chapter 8';
libname log_data 'C:\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Data';



run;




**  step 1 - create a very large data set;


run;
    data big_data;
    **do i=1 to 10000000;
     do i= 1 to 1000000;

      death = 0;
      smoke  = 0;
      drug = 0;
      exercise = 1;
      random = ranuni(11);
     **put 'random = ' random;
       if random <= .1 then do;
          death = 1;
       end;
       if (random <= .07 ) then do;
          smoke = 1;
       end;
       if (random <= .075) then do;
          drug = 1;
       end;
       if (random <= .05 ) then do;
          exercise = 0;
       end;

      random2 = ranuni(19);
       if random2 < .15 then smoke = 1;
       if random2 < .25 then drug = 1;
       if random2 > .75 then exercise =0;

       weight = round(200 - ranuni(7)*10);
       weight = max(weight, 100);
       height = round(72 - ranuni(5)*10);
     id = i;
 output;
   end;


run;

proc print data=big_data(obs=1000);
 var id death exercise random random2;
title 'big data';

run;

proc freq data=big_data;
  table death*smoke death*drug death*exercise / missing;
  title 'check exercise';

run;

proc print data=big_data (obs=100);
var death smoke drug exercise weight height;
title 'big data';

run;

proc freq data=big_data(obs=1000);
 table death smoke drug exercise weight height / missing;
title 'data create';

run ;


** Step 2: Lets run a logistic regression;
**         on the whole tthing;

proc logistic data = big_data;
  class exercise(ref='0') smoke(ref='0') drug(ref='0')/param=ref;
  model death(event='1')  = smoke drug exercise weight height;
 title 'big data logistic regression';

run;



** Step 3: Results from Step 2 where taking 20 minutes so I ;
** So now we see to find some samples;
** In step 3 we look at systematic samples;


**Step 3a: Pick a sample 1 out of every 100;
**         These would be samples without replacement;
** we use the point= option;
** We use the stop statement so that SAS doesn't read to the end of the data set each;
** time as this will take a very long time;

   data systamatic;
    do pickit=1 to 10000000 by 100;

    set big_data point=pickit;

    output;

    end;
    stop;

run;

proc logistic data = systamatic;
  class exercise(ref='0') smoke(ref='0') drug(ref='0')/param=ref;
  model death(event='1')  = smoke drug exercise weight height;
 title 'systamatic logistic regression';

run;


**Step 3b: Pick a sample 1 out of every 100;
**         These would be samples without replacement;
** we use the point= option;
** We use the stop statement so that SAS doesn't read to the end of the data set each;
** time as this will take a very long time;
** ADDED - If you do not know the total number of observations just use totobs;

   data systamatic;

    do pickit=1 to totobs by 100;


    set big_data point=pickit nobs=totobs;

    output;

    end;
    stop;

run;


** Step 4:  Lets look at random sample;

**Step 4a: Pick a randome sample with replacement;

      data  random(drop=i sampsize);
    sampsize=10000;
    do i= 1 to sampsize;
     pickit = ceil(ranuni(0)*totobs);
    **put 'pickit=' pickit;
    **put 'i=' i;
    set big_data point=pickit nobs=totobs;
    output;
    end;
    stop;

run;

proc contents data=sasuser.revenue;
 title 'here is revenue';

run;

** Results from text;

data work.rsubset (drop=i sampsize);
sampsize=10;
do i=1 to sampsize;
pickit=ceil(ranuni(0)*totobs);
set sasuser.revenue point=pickit nobs=totobs;
output;
end;
stop;

run;

** Adatpt results from text;
** Not clear why it does not work;

data work.rsubset (drop=i sampsize);
sampsize=10;
do i=1 to sampsize;
pickit=ceil(ranuni(0)*totobs);
set big_data point=pickit nobs=totobs;
output;
end;
stop;

run;


** Step 4b: Take a random sample WITHOUT replaceemnt;
**          From the book;

data work.rsubset(drop=obsleft sampsize);
sampsize=10;
obsleft=totobs;
do while(sampsize>0);
pickit+1;
if ranuni(0)<sampsize/obsleft then do;
set sasuser.revenue point=pickit
nobs=totobs;
output;
sampsize=sampsize-1;
end;
obsleft=obsleft-1;
end;
stop;
run;

** Step 4c: Run the results for big_data;
** THis one works;

data random(drop=obsleft sampsize);
sampsize=10000;
obsleft=totobs;
do while(sampsize>0);
pickit+1;
if ranuni(0)<sampsize/obsleft then do;
set big_data point=pickit
nobs=totobs;
output;
sampsize=sampsize-1;
end;
obsleft=obsleft-1;
end;
stop;
run;


** Step 5: Indices;

*Step 5a: Indices make sorting and SQL merging faster;
**        so it often good to create them;
** We show how to create an index inside a data step;
* and we highlight the use of MSGLEVEL which prints warnings and error messages;


 Options msglevel=i;

    data big_data2(index=(id/unique));
    **do i=1 to 10000000;
     do i= 1 to 1000000;

      death = 0;
      smoke  = 0;
      drug = 0;
      exercise = 1;
      random = ranuni(11);
     **put 'random = ' random;
       if random <= .1 then do;
          death = 1;
       end;
       if (random <= .07 ) then do;
          smoke = 1;
       end;
       if (random <= .075) then do;
          drug = 1;
       end;
       if (random <= .05 ) then do;
          exercise = 0;
       end;

      random2 = ranuni(19);
       if random2 < .15 then smoke = 1;
       if random2 < .25 then drug = 1;
       if random2 > .75 then exercise =0;

       weight = round(200 - ranuni(7)*10);
       weight = max(weight, 100);
       height = round(72 - ranuni(5)*10);
   id = i;
 output;
   end;


run;


***Step 5b: We can also create a composit index;
** This is good if you want to sort by two variables;
** In my work I often have an appl_id and camp_cd as an identifer;
** So its good to have one index for both of these;
** The new index called id_weight is a concatenated values of id and weight;



 Options msglevel=i;

    data big_data2(index=(id_weight=(id weight)));
    **do i=1 to 10000000;
     do i= 1 to 1000000;

      death = 0;
      smoke  = 0;
      drug = 0;
      exercise = 1;
      random = ranuni(11);
     **put 'random = ' random;
       if random <= .1 then do;
          death = 1;
       end;
       if (random <= .07 ) then do;
          smoke = 1;
       end;
       if (random <= .075) then do;
          drug = 1;
       end;
       if (random <= .05 ) then do;
          exercise = 0;
       end;

      random2 = ranuni(19);
       if random2 < .15 then smoke = 1;
       if random2 < .25 then drug = 1;
       if random2 > .75 then exercise =0;

       weight = round(200 - ranuni(7)*10);
       weight = max(weight, 100);
       height = round(72 - ranuni(5)*10);
   id = i;
 output;
   end;

run;


*Step 5c: Can use proc datasets to creat indices as well;

**From Book;

proc datasets library=sasuser nolist;
modify sale2000;
index create origin;
quit;

**Create Example;

 Options msglevel=i;

    data big_data3;
    **do i=1 to 10000000;
     do i= 1 to 1000;

      death = 0;
      smoke  = 0;
      drug = 0;
      exercise = 1;
      random = ranuni(11);
     **put 'random = ' random;
       if random <= .1 then do;
          death = 1;
       end;
       if (random <= .07 ) then do;
          smoke = 1;
       end;
       if (random <= .075) then do;
          drug = 1;
       end;
       if (random <= .05 ) then do;
          exercise = 0;
       end;

      random2 = ranuni(19);
       if random2 < .15 then smoke = 1;
       if random2 < .25 then drug = 1;
       if random2 > .75 then exercise =0;

       weight = round(200 - ranuni(7)*10);
       weight = max(weight, 100);
       height = round(72 - ranuni(5)*10);
   id = i;
 output;
   end;

run;

proc datasets library=work nolist;
modify big_data3;
index create id_weight=(id weight);
quit;


**Step 5d: Using PROC SQL to create indices;

 Options msglevel=i;

    data big_data4;
    **do i=1 to 10000000;
     do i= 1 to 1000;

      death = 0;
      smoke  = 0;
      drug = 0;
      exercise = 1;
      random = ranuni(11);
     **put 'random = ' random;
       if random <= .1 then do;
          death = 1;
       end;
       if (random <= .07 ) then do;
          smoke = 1;
       end;
       if (random <= .075) then do;
          drug = 1;
       end;
       if (random <= .05 ) then do;
          exercise = 0;
       end;

      random2 = ranuni(19);
       if random2 < .15 then smoke = 1;
       if random2 < .25 then drug = 1;
       if random2 > .75 then exercise =0;

       weight = round(200 - ranuni(7)*10);
       weight = max(weight, 100);
       height = round(72 - ranuni(5)*10);
   id = i;
 output;
   end;

run;

proc sql;
 create index id_weight on big_data4(id, weight);
quit;

run;


*Step 6: Use proc datasets to rename variables in a dataset;
**        For large datasets this is much faster than doing a set statement;
**        and renaming;

proc datasets library=work nolist;
 modify big_data;
rename id=identifier;

run;

proc contents data=big_data;

run;



**Step 7: Proc survey select;
** You may want to create a random sample that is stratify by;
** key variables in your model like death, smoke, drug;


proc sql;
create table big_data5 as
 select a.*
from big_data a
order by a.death, a.smoke, a.drug
;
quit;

run;

proc surveyselect data=big_data5
       method=srs     n=50000      out=sample_big_data;
   strata death / alloc=prop;

run;
