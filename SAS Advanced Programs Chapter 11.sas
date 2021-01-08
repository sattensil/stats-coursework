
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
libname sasusers 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Data';

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
libname sasusers 'C:\UC Berkley\Summer 2016\Data';
libname sasuser 'C:\UC Berkley\Summer 2016\Data';
libname chap8_L 'C:\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Chapter 8';
libname log_data 'C:\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Data';



run;





 proc contents data=sasusers.payrollmaster;



**Step 1: Example of SAS Macro;
** Lets look at some examples from logistic regression;
** Reporduce a table from Hosmer and Lemeshow Applied logistic regression 8.6;


           data new_placement;
    set chap8_L.placement;
         danger_d=0;
          if danger > 0 then danger_d = 1;
          LOS_5 = sqrt(los);
          L_C = los_5*custd;
run;
options mprint symbolgen;

%macro skipit;

*); */; /*'*/ /*"*/;

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

run;

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



**Step 2: Compling a Macro;
** Understanding optins mprint symbolgen and  MCOMPILENOTE;
** Look in log to understand MCOMPILENOTE;



options mprint symbolgen MCOMPILENOTE=all;

%macro prtlast;
proc print data=&syslast (obs=5);
title "Listing of &syslast data set";
run;
%mend;


run;


**Step 3: Now call the macro you just created;



proc sort data=sasuser.courses out=courses;
by course_code;

run;

%prtlast;

proc sort data=sasuser.schedule out=schedule;
by begin_date;

run;

%prtlast;

proc sort data=sasuser.students out=students;
by student_name;

run;

%prtlast;

run;


**Step 4: Finding Erros using mprint and mlogic;
** Each step in the macro is outlined and explained;

options mprint symbolgen mlogic;

%hood(data=new_placement,var=gender,num=2,intercept_only=1048.742,dof=2);

run;


**Step 5: Positional Macro Variablwes;


**Step 5a: No Equal Sign;

%macro printdsn(dsn,vars);

proc print data=&dsn;
var &vars;
title "Listing of %upcase(&dsn) data set";
run;

%mend;

%printdsn(sasuser.courses,course_code course_title days);

run;


**Step 5b: With Equal Sign helps you remember;

%macro printdsn(dsn=,vars=);

proc print data=&dsn;
var &vars;
title "Listing of %upcase(&dsn) data set";
run;

%mend;

%printdsn(dsn=sasuser.courses,vars=course_code course_title days);

run;


**Step 5c: useing PARMBUFF so you do not have to have variables in your macro if they are not needed;
** Do not recommend using because it is easy to forget things;


%macro printz/parmbuff;
%put Syspbuff contains: &syspbuff;
%let num=1;
%let dsname=%scan(&syspbuff,&num);
%do %while(&dsname ne);
proc print data=sasuser.&dsname;
run;
%let num=%eval(&num+1);
%let dsname=%scan(&syspbuff,&num);
%end;
%mend printz;

run;

%printz(courses, schedule);

run;


** Step 6: Global and Local variabels;


**Step 6a: When you use a let statement you create a global variable that can be used anywhere;

%macro skipit;

  data log_data.burns1000;
   set burns1000;

%mend skipit;

run;



%Let data_name = burns;
%let orig = log_data.burns1000;


   data &data_name;
     set &orig;

run;


**Step 6b: There are local macro variables only available within the macro program;
** Once the macro runs the local macro variables are no longer available;
** All you need to know;

run;

%macro printdsn(dsn=,vars=);

proc print data=&dsn;
var &vars;
title "Listing of %upcase(&dsn) data set";
run;

%mend;

%printdsn(dsn=sasuser.courses,vars=course_code course_title days);

run;

proc print data=&dns;
 title "Here is &dns";

run;


** Step 7: Using Global and MLOGICNEST;

options mprint symbolgen MCOMPILENOTE=all MLOGICNEST;

run;

** Step 7a: Making the Global Statement;
** You are in a Macro and you send out a global statement;
** Let us refine our earlier macro and get the one thing we want to carry foward;



%macro hoodq(data=,var=,num=,intercept_only=,dof=);

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


%if (&num=3) %then %do;

%global numrows;

proc sql noprint;
select count(*) into :numrows
from stats;
quit;

%end;



%mend hoodq;

run;

%hoodq(data=new_placement,var=age,num=1,intercept_only=1048.742,dof=2);
run;
%hoodq(data=new_placement,var=race,num=2,intercept_only=1048.742,dof=2);
%hoodq(data=new_placement,var=gender,num=3,intercept_only=1048.742,dof=2);

run;

proc print data=stats;
 title "we have number of rows = &numrows";

run;

** Step 7b: Using the MLOGICNEST to see in the log statement what a local and global statement does;

run;
options mprint symbolgen MCOMPILENOTE=all MLOGICNEST;

%macro outer;
%put THIS IS OUTER;
%inner
%mend outer;

%macro inner;
%put THIS IS INNER;
%inrmost
%mend inner;

%macro inrmost;
%put THIS IS INRMOST;
%mend inrmost;


run;

%outer;

run;


** Step 8: If then statements in Macros;


**Step 8a: First example of if then;
** We have seen how thse work above for the hood example;
** Below is another example;


   %macro choice(status=);

data fees;
set sasuser.all;
%if &status=PAID %then %do;
where paid="Y";
keep student_name course_code begin_date totalfee;
%end;
%else %do;
where paid="N";
keep student_name course_code
begin_date totalfee latechg;
latechg=fee*.10;
%end;
/* add local surcharge */
if location="Boston" then totalfee=fee*1.06;
else if location="Seattle" then totalfee=fee*1.025;
else if location="Dallas" then totalfee=fee*1.05;
run;
%mend choice;

run;


options mprint mlogic;
%choice(status=PAID)

run;

proc print data=fees;
 title 'here are fees For paid';

run;


** Step 8b: Second example of if then;
** you print all the course if CRS is missing otherwise just print those for CRS;


%macro attend(crs=,start=,stop=);
%let start=%upcase(&start);
%let stop=%upcase(&stop);
proc freq data=sasuser.all;
where begin_date between "&start"d and "&stop"d;
table location / nocum;
title "Enrollment from &start to &stop";

%if &crs= %then %do;  **if crs is missing;

title2 "for all Courses";
%end;
%else %do;
title2 "for Course &crs only";
where also course_code="&crs";
%end;
run;
%mend attend;

run;


%attend(crs=C003,start=01jan2001,stop=31dec2001);

run;


** Step 8b: adjust your results depending on your macro variables;

         %macro counts (cols=,rows=,dsn=);
         title "Frequency Counts for %upcase(&dsn) data set";

  proc freq data=&dsn;
 tables
%if &rows ne %then &rows *;
&cols;

run;

%mend counts;

run;

%counts(dsn=sasuser.all, cols=paid, rows=course_number);

run;

%counts(dsn=sasuser.all, cols=paid, rows=);

run;

** Step 9: Macros are case sensitive;
** first log off and then log on from SAS;

** Tep 9a: Start with _null_;

%macro prtlast;

%if &syslast=_null_ %then %do;
%put No data sets created yet.;
%end;
%else %do;
proc print;
title "Last Created Data Set is &syslast";
run;
%end;

%mend prtlast;

options mprint mlogic symbolgen;
%prtlast;

run;

***Step 9b: Replace the _null_ with _NULL_ and it works;

%macro prtlastq;

%if &syslast=_NULL_ %then %do;
%put No data sets created yet.;
%end;
%else %do;
proc print;
title "Last Created Data Set is &syslast";
run;
%end;

%mend prtlastq;

options mprint mlogic symbolgen;
%prtlastq;

run;



** Step 10: The do statement;

run;


** Step 10a: This creates a looping function that prints out the teachers names;

options mprint symbolgen Mlogic;

  data _null_;
set sasuser.schedule end=no_more;
call symput("teach"||left(_n_),(trim(teacher)));
if no_more then call symput("count",_n_);
run;


%macro putloop;
%local i;
%do i=1 %to &count;
%put TEACH&i is &&teach&i;

%end;

%mend putloop;

%putloop;

run;


** Step 11: using %SYSEVALF;
** Allows for arthmatic operations within the macro and within do loops;


run;

%macro figureit(a,b);
%let y=%sysevalf(&a+&b);
%put The result with SYSEVALF is: &y;
%put BOOLEAN conversion: %sysevalf(&a +&b, boolean);
%put CEIL conversion: %sysevalf(&a +&b, ceil);
%put FLOOR conversion: %sysevalf(&a +&b, floor);
%put INTEGER conversion: %sysevalf(&a +&b, integer);
%mend figureit;
run;
%figureit(100,1.59);

run;
