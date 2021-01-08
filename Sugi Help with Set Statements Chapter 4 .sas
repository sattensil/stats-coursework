
*****************************************************;
* Step 1: Bring in the Low Birth Weight Data;
*         We used import wizard to created LBW then;
*         saved it into chap1;
*******************************************************;

run;

libname chap1  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 1';
libname chap2  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 2';
libname chap3  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 3';
libname chap4  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 4'; 
libname sasusers 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Data'; 

run; 

**Example to show difference between joins an sets; 

** Step 1: Create two data sets; 


  DATA first;
A = 1;
RUN;
DATA second;
B = 2;
RUN;


** Step 2: Do a join; 

proc sql; 
select *
 from first, 
      second
 ; 

 run; 


 ** Step 3: Now we a set operator using union; 
 ** This merges the data viritically; 

 proc sql; 
select *
 from  first
 union
 select * 
from   second
 ; 
 quit; 

 run; 

 ** Main difference joins merge them horizontally, sets merge them virtically; 

*** Outer Union; 

 **Step 1: Create the data; 

 proc sql; 
 CREATE TABLE one AS
SELECT name, age, height
FROM sashelp.class
WHERE age<14 and LENGTH(name)<6
ORDER BY age
;
quit; 

proc sql; 
CREATE TABLE two AS
SELECT name, weight, age
FROM sashelp.class
WHERE age<14 and LENGTH(name)>5
ORDER BY age
;
quit; 

run; 

** Step 2: Lets look at the set statement in SAS. Put them on top of each other; 

 data concat; 
  set one two; 
  run; 

  proc print data=concat; 
   title 'concate'; 

   run; 

** Step 3: Now we do the same thing using the outer union; 
   ** Coresponding statement alligns like names which here is age; 

proc sql; 
CREATE TABLE concat AS
SELECT *
FROM one
OUTER UNION CORRESPONDING
SELECT *
FROM two
;
quit; 

proc print data=concat; 
title 'sql concat'; 

run; 

** Step 4: Lets look at the same thing for union; 
** Notice union only brings in the age, where the columns match up; 

proc sql; 
CREATE TABLE concat_union AS
SELECT *
FROM one
UNION CORRESPONDING
SELECT *
FROM two
;
quit; 

proc print data=concat_union; 
title 'sql concat'; 

run; 

** Step 4a: Use union without corsponding; 

proc sql; 
CREATE TABLE no_corresponding_union AS
SELECT *
FROM one
UNION 
SELECT *
FROM two
;
quit; 

proc print data=no_corresponding_union; 
title 'sql No corresponding'; 

run; 


** Outer Unions can also be used to assist with data compatibility problems; 

** Step 1: Make data set with Data Compatablity Problems; 

DATA num;
id = 3;
value = 0;
RUN;
DATA char;
id = 4;
value = 'abc';
RUN;

** Step 2: Do a set statement; 

 data both; 
  set num char; 

  run; 


** Step 3: If we use set operator we will have the same problem; 

proc sql; 
CREATE TABLE both_union AS
SELECT *
FROM num
outer UNION CORRESPONDING
SELECT *
FROM char
;
quit; 

proc print data=both_union; 
title 'Outer Union Corresponding'; 

run; 


** Step 4: If we use outer union alone then we will get the results; 

proc sql; 
CREATE TABLE both_union_no_cor AS
SELECT *
FROM num
outer UNION 
SELECT *
FROM char
;
quit; 

proc print data=both_union_no_cor; 
title 'sql with different variables no cor'; 

run; 

** Step 4: If we just use select then we get the following;
**   So what you get with select operators will vary ;  

proc sql; 
SELECT *
FROM num
outer UNION 
SELECT *
FROM char
;
quit; 

run; 


** Step 5: Do not need coresponding if you name columns; 

 proc sql; 
 CREATE TABLE one AS
SELECT name, age, height
FROM sashelp.class
WHERE age<14 and LENGTH(name)<6
ORDER BY age
;
quit; 

proc sql; 
CREATE TABLE two AS
SELECT name, weight, age
FROM sashelp.class
WHERE age<14 and LENGTH(name)>5
ORDER BY age
;
quit; 

run; 

proc sql; 
CREATE TABLE no_corresponding_union AS
SELECT a.name,a.age
FROM one  a 
UNION 
SELECT b.name, b.age
FROM two  b
;
quit; 

proc print data=no_corresponding_union; 
title 'sql No corresponding'; 

run; 


*** Union using ALl; 

%macro skipit; 

 Data chap4.abc; 
  set abc; 

  data chap4.ab; 
   set ab; 

   run; 

%mend skipit;

run;  

** Step 1 use union with no all statement; 
** Only get the overlap; 

proc sql; 
CREATE TABLE union_no_all AS
SELECT *
FROM abc
UNION
SELECT *
FROM ab
;

proc print data=union_no_all; 
 title 'union_no_all'; 

 run; 

 ** Step 2 add the all; 
** get it all with duplicates; 

proc sql; 
CREATE TABLE union_all AS
SELECT *
FROM abc
UNION  all 
SELECT *
FROM ab
;

proc print data=union_all; 
 title 'union_all'; 

 run; 


 *** Intersect using ALl; 

run;  

** Step 1 use intersect with no all statement; 
** Only get the overlap; 

proc sql; 
CREATE TABLE intersect_no_all AS
SELECT *
FROM abc
intersect
SELECT *
FROM ab
;

proc print data=intersect_no_all; 
 title 'intersect_no_all'; 

 run; 

 ** Step 2 add the all; 
** get it all with duplicates; 

proc sql; 
CREATE TABLE intersect_all AS
SELECT *
FROM abc
intersect all 
SELECT *
FROM ab
;

proc print data=intersect_all; 
 title 'intersect_no_all'; 

 run; 

 *** Except using ALl; 

run;  

** Step 1 use except with no all statement; 
** Only get the overlap; 

proc sql; 
CREATE TABLE except_no_all AS
SELECT *
FROM abc
except
SELECT *
FROM ab
;

proc print data=except_no_all; 
 title 'except_no_all'; 

 run; 

 ** Step 2 add the all; 
** get it all with duplicates; 

proc sql; 
CREATE TABLE except_all AS
SELECT *
FROM abc
except all 
SELECT *
FROM ab
;

proc print data=except_all; 
 title 'except_no_all'; 

 run; 


** Example: 

 **Step 1: Data construction; 

 DATA sales2004 sales2005 sales2006;
DO cust_id = 1001 TO 9999;
DO year = 2004 TO 2006;
date = MDY(1,1,year);
IF ranuni(123)>0.5 THEN
DO UNTIL (date > MDY(12,31,year) );
date + ROUND(RANUNI(123) * 80);
value = ROUND(250 * RANUNI(123),0.01);
IF RANUNI(123)>0.6 THEN SELECT (year);
WHEN (2004) OUTPUT sales2004;
WHEN (2005) OUTPUT sales2005;
WHEN (2006) OUTPUT sales2006;
END;
END;
END;
END;
RUN;

** Step 2: Data step; 

PROC SUMMARY DATA=sales2004 NWAY;
CLASS cust_id;
OUTPUT OUT=sum2004 SUM(value)=value2004;
RUN;
**The other years are a bit simpler, since the dollar values are not needed; 

PROC SUMMARY DATA=sales2005 NWAY;
CLASS cust_id;
OUTPUT OUT=sum2005;
RUN;
PROC SUMMARY DATA=sales2006 NWAY;
CLASS cust_id;
OUTPUT OUT=sum2006;
RUN;
**The solution can be derived by merging the three years data; 

DATA target(KEEP=cust_id);
MERGE sum2004(KEEP=cust_id value2004)
sum2005(KEEP=cust_id IN=in2005)
sum2006(KEEP=cust_id IN=in2006);
BY cust_id;
IF value2004>1000 AND NOT in2005 AND in2006;

RUN;

** Step 3 Using various set operators; 
** See how much easier it is; 

PROC SQL;
CREATE TABLE target_sql AS
  SELECT cust_id
 FROM sales2004
  GROUP BY cust_id
   HAVING SUM(value)>1000
 INTERSECT
   SELECT cust_id
 FROM sales2006
  EXCEPT
  SELECT cust_id
 FROM sales2005
;
QUIT;

