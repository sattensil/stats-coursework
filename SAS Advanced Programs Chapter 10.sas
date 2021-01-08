
*****************************************************;
* Step 1: Idenitify your libraries;
*******************************************************;

run;

libname chap1  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 1';
libname chap2  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 2';
libname chap3  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 3';
libname chap4  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 4';
libname chap5  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 5';
libname chap9  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 9';
libname chap10 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 10'; 
libname sasusers 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Data';
libname sasuser 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Data';

run;

%macro skipit;

libname chap1 'C:\UC Berkley\Summer 2016\Chapter 1';
libname chap2 'C:\UC Berkley\Summer 2016\Chapter 2';
libname chap3 'C:\UC Berkley\Summer 2016\Chapter 3';
libname chap4 'C:\UC Berkley\Summer 2016\Chapter 4';
libname chap5 'C:\UC Berkley\Summer 2016\Chapter 5';
libname chap9 'C:\UC Berkley\Summer 2016\Chapter 9';
libname sasusers 'C:\UC Berkley\Summer 2016\Data';
libname sasuser 'C:\UC Berkley\Summer 2016\Data';

%mend skipit;

run;


 proc contents data=sasusers.payrollmaster;



**Step 2: Why we need to derive variables during a data step or SQL; 

run;

**Step 2a: Assume you want footnote to indicate whether all the bills have been paid; 
** The two let statements are done first then the data step is done; 
** So you get all students are paid each time; 

options symbolgen pagesize=30;
%let crsnum=3;
data revenue;
set sasusers.all end=final;
where course_number=&crsnum;
total+1;
if paid="Y" then paidup+1;
if final then do;
put total= paidup=; /* Write informationto the log. */
if paidup<total then do;
%let foot=Some Fees Are Unpaid;
end;
else do;
%let foot=All Students Have Paid;
end;
end;
run;

proc print data=revenue;
var student_name student_company paid;
title "Payment Status for Course &crsnum";
footnote "&foot";
run;

** Step 2b: Adjust the results so we get the correct footnote; 
** Using call symput; 
** With call symput the statement is done in the context of the data step; 

options symbolgen pagesize=30;
%let crsnum=3;
data revenue;
set sasuser.all end=final;
where course_number=&crsnum;
total+1;
if paid="Y" then paidup+1;
if final then do;
if paidup<total then do;
call symput("foot","Some Fees Are Unpaid");
end;
else do;
call symput("foot","All Students Have Paid");
end;
end;
run;

proc print data=revenue;
var student_name student_company paid;
title "Payment Status for Course &crsnum";
footnote "&foot";
run;

** Step 2c: Get total results at the end associated with the data step; 

%let crsnum=3;

data revenue;
set sasuser.all end=final; *Final creates a variable that tells you the last observation; 
where course_number=&crsnum;
total+1;
if paid="Y" then paidup+1;
if final then do;
call symput("numpaid",paidup);
call symput("numstu",total);
call symput("crsname",course_title);
end;
run;

proc print data=revenue noobs;
var student_name student_company paid;
title "Fee Status for &crsname (#&crsnum)";
footnote "Note: &numpaid Paid out of &numstu Students";
run;


** Step 2d: Getting rid of blanks and spaces; 
** use symputx; 

%let crsnum=3;
data revenue;
set sasuser.all end=final;
format course_title2 $45.; 
space = "        "; 
course_title2 = course_title || space; 
where course_number=&crsnum;
total+1;
if paid="Y" then paidup+1;
if final then do;
call symput("crsname",course_title2);
call symput("date",put(begin_date,mmddyy10.));
call symput("due",put(fee*(total-paidup),dollar8.));
end;
run;

ODS Listing Close;

ODS Listing;

proc print data=revenue;
var student_name student_company paid course_title course_title2 space;
title "Fee Status for &crsname (#&crsnum) Held &date";
Title2 "This will also go to output statement and show how SAS sees the program"; 
footnote "Note: &due in Unpaid Fees";


run;

%let crsnum=3;
data revenue;
set sasuser.all end=final;
where course_number=&crsnum;
total+1;
if paid="Y" then paidup+1;
if final then do;
call symputx("crsname",course_title);
call symputx("date",put(begin_date,mmddyy10.));
call symputx("due",put(fee*(total-paidup),dollar8.));
end;
run;

proc print data=revenue;
var student_name student_company paid;
title "Fee Status for &crsname (#&crsnum) Held &date";
title "Notice the macros saved in SAS, see output, have no trailing blanks"; 
footnote "Note: &due in Unpaid Fees";

run;


**Step 3: Using put statement to format macro variables; 
** Assume you want to have the date and amount due formated; 
** Assume in addition you want to trim the spacces then you can also use the put statement; 
** So you can use the symputx function or trim functions in your SAS output; 


%let crsnum=3;
data revenue;
set sasuser.all end=final;
where course_number=&crsnum;
total+1;
if paid=’Y’ then paidup+1;
if final then do;
call symput(’crsname’,trim(course_title));
call symput(’date’,put(begin_date,mmddyy10.));
call symput(’due’,trim(left(put(fee*(total-paidup),dollar8.))));
end;
run;

proc print data=revenue;
var student_name student_company paid;
title "Fee Status for &crsname (#&crsnum) Held &date";
footnote "Note: &due in Unpaid Fees";

run;


**Step 4: Using Multiple & & & ; 
** I have learned this by just trail and error; 

**Step 4a: Suppose you want to have the course title above the courses; 
** You might try what is below whic his just the c005 and C002; 
** But you want the name of the course; 
** Look at the log file to see how it resolves; 

options symbolgen mprint;
data _null_;
set sasuser.courses;
call symput(course_code, trim(course_title));
run;

%let crsid=C005;
proc print data=sasuser.schedule noobs label;
where course_code="&crsid";
var location begin_date teacher;
title1 "Schedule for &crsid";
footnote; 
run;
%let crsid=C002;
proc print data=sasuser.schedule noobs label;
where course_code="&crsid";
var location begin_date teacher;
title1 "Schedule for &crsid";
footnote; 
run;

**Step 4b: So lets do two && see what we get; 
** That still doesn't work because the frist scan gets the let; 
** The second time it pickes up the first let only; 
** Only using three do we reference the course code; 

options symbolgen;
data _null_;
set sasuser.courses;
call symput(course_code, trim(course_title));
run;

%let crsid=C005;
proc print data=sasuser.schedule noobs label;
where course_code="&crsid";
var location begin_date teacher;
title1 "Schedule for &&crsid";
footnote; 
run;
%let crsid=C002;
proc print data=sasuser.schedule noobs label;
where course_code="&crsid";
var location begin_date teacher;
title1 "Schedule for &&crsid";
footnote; 
run;


**Step 4c: Using the three &&& we get the course code information that is referenced in the _null_; 
** Looking at the Log file you can see how the macro variables get resolved; 

options symbolgen;
data _null_;
set sasuser.courses;
call symput(course_code, trim(course_title));
run;

%let crsid=C005;
proc print data=sasuser.schedule noobs label;
where course_code="&crsid";
var location begin_date teacher;
title1 "Schedule for &&&crsid";
footnote; 
run;
%let crsid=C002;
proc print data=sasuser.schedule noobs label;
where course_code="&crsid";
var location begin_date teacher;
title1 "Schedule for &&&crsid";
footnote; 
run;

**Step 5: Create a multiple set of macro variables; 

**Step 5a: Lets start with the let statement; 

options symbolgen;

data _null_;
set sasuser.schedule;
call symput("teach"||left(course_number),
trim(teacher));

run;

%let crs=3;

proc print data=sasuser.register noobs;
where course_number=&crs;
var student_name paid;
title1 "Roster for Course &crs";
title2 "Taught by &&teach&crs";

run;


**Step 5b: Lets put it into a macro so we can see all the macros created; 
** As seen now with the null statement you have created 18 macro variables with the names; 
** of teachers associated with them; 

options mprint symbolgen; 

%macro print_it(crs=); 

data _null_;
set sasuser.schedule;
call symput("teach"||left(course_number),
trim(teacher));

run;

%put _user_; 

proc print data=sasuser.register noobs;
where course_number=&crs;
var student_name paid;
title1 "Roster for Course &crs";
title2 "Taught by &&teach&crs";

run;

%mend print_it; 

run; 

%print_it(crs=3); 

run; 


**Step 6: Getting data; 
** You have seen how to put data now lets see how to bring macro data into a data step; 

**step 6a: we first creat the macro variables teach1-teach18; 

%macro print_it(crs=); 

data _null_;
set sasuser.schedule;
call symput("teach"||left(course_number),
trim(teacher));

run;

%put _user_; 

proc print data=sasuser.register noobs;
where course_number=&crs;
var student_name paid;
title1 "Roster for Course &crs";
title2 "Taught by &&teach&crs";

run;

%mend print_it; 

run; 

%print_it(crs=3); 

run; 

**Step 6b:  Now we use the teach1-teach18 to assign teachers to each student; 
**Notice each student has a course; 
options ps=max ls=max; 
proc print data=sasuser.register; 
title 'here is register'; 

run; 

** Now map the teacher to the already created teach1-teach18 using symget; 


data teachers;
set sasuser.register;
length Teacher $ 20;
teacher=symget("teach"||left(course_number));

run;

proc print data=teachers;
var student_name course_number teacher;
title1 "Teacher for Each Registered Student";

run; 


**Step 7 Creating Macro variables in Proc SQL; 

**Step 7a: First we use proc sql to create a macro variable; 

proc sql noprint;
select sum(fee) format=dollar10. into :totalfee
from sasuser.all;
quit;

proc means data=sasuser.all sum maxdec=0;
class course_title;
var fee;
title "Grand Total for All Courses Is &totalfee";

run;

**Step 7b: Now the HTLM looks find but if you look at the output; 
**         it shows spaces. to get rid of those we can use the let statement; 

proc sql noprint;
select sum(fee) format=dollar10. into :totalfee
from sasuser.all;
quit;

%let totalfee=&totalfee;

proc means data=sasuser.all sum maxdec=0;
class course_title;
var fee;
title "Grand Total for All Courses Is &totalfee";

run;


** Step 8: Create groups of macro variables; 

**Step 8a: Look at course_code, location and begin_date; 

proc freq data=sasuser.schedule; 
 table course_code location begin_date / missing; 
 format begin_date date7.; 
 title 'Results for sasuser.schedule'; 

 run; 

**Step 8b: Now we create courses, places and dates;

 proc print data=sasuer.schedule; 
 title 'schedule'; 

 run; 

 options mprint symbolgen; 

 %macro mk_macro(course_num=,place_num=,date_num=); 

proc sql;
create table first as  
select course_code, location, begin_date format=mmddyy10.
into :crsid1-:crsid&course_num,
:place1-:place&place_num,
:date1-:date&date_num
from sasuser.schedule
where year(begin_date)=2002
order by begin_date;
quit;

%put _user_; 

proc print data=first; 
 title "crsid1=&crsid1 crsid2=&crsid2 crsid3=&crsid3"; 
 title2 "place1=&place1 place2=&place2 place3=&place3";
 title3 "date1=&date1 date2=&date2 date3=&date3";

run; 

%mend mk_macro; 

run; 

%mk_macro(course_num=3,place_num=3,date_num=3); 

run; 


proc sql;
create table first as  
select course_code, location, begin_date format=mmddyy10.
into :crsid1-:crsid3,
:place1-:place3,
:date1-:date3
from sasuser.schedule
where year(begin_date)=2002
order by begin_date;
%put _user_; 
quit;

proc print data=first; 
 title "crsid1=&crsid1 crsid2=&crsid2 crsid3=&crsid3"; 
 title2 "place1=&place1 place2=&place2 place3=&place3";
 title3 "date1=&date1 date2=&date2 date3=&date3";

 run; 

 **Step 8c: Now count the number of rows in you are  capturing and use that to get number of places;

 proc sql noprint;
 create table second as 
select count(*) into :numrows
from sasuser.schedule
where year(begin_date)=2002;
%let numrows=&numrows;
%put There are &numrows courses in 2002;
select course_code, location,
begin_date format=mmddyy10.
into :crsid1-:crsid&numrows,
:place1-:place&numrows,
:date1-:date&numrows
from sasuser.schedule
where year(begin_date)=2002
order by begin_date;
%put _user_;
quit;

proc print data=second; 
 title "crsid1=&crsid1 crsid2=&crsid2 crsid3=&crsid3"; 
 title2 "place1=&place1 place2=&place2 place3=&place3";
 title3 "date1=&date1 date2=&date2 date3=&date3";

 run; 


**Step 9: Create a macro name for all sites;

 proc sql noprint;
 create table location as 
select distinct location into :sites separated by " "
from sasuser.schedule;
quit;

 proc sql noprint;
select distinct location into :sites separated by " "
from sasuser.schedule;
quit;

proc print data=second; 
 title "sites=&sites"; 

run; 


** Step 10: Creating a view and using it to create macro variables; 
** Now your crsid can be any of the course codes and whichever one; 
** you pick is avaialbe to constrain subscrid; 

**Step 10a: Working with charaters; 

proc sql;
create view subcrsid as
select student_name,student_company,paid, course_code
from sasuser.all
where course_code=symget("crsid");
quit;


%let crsid=C003;

proc print data=subcrsid noobs;
title "Status of Students in Course Code &crsid";
run;

%let crsid=C004;
proc print data=subcrsid noobs;
title "Status of Students in Course Code &crsid";

run;

**Step 10b: working with numbers; 
** You have to convert macro to numeric value; 

proc sql;
create view subcnum as
select student_name, student_company, paid, course_code,course_number
from sasuser.all
where course_number=input(symget("crsnum"),2.);
quit;

%let crsnum=4;
proc print data=subcnum noobs;
title "Status of Students in Course Number &crsnum";
run;


***************************************************************; 
* SCL Language will not review this section; 
***************************************************************; 

