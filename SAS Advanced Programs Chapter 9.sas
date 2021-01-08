
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
libname sasusers 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Data';
run; 
%mend skipit;

run;


libname chap1 'C:\UC Berkley\Summer 2016\Chapter 1';
libname chap2 'C:\UC Berkley\Summer 2016\Chapter 2';
libname chap3 'C:\UC Berkley\Summer 2016\Chapter 3';
libname chap4 'C:\UC Berkley\Summer 2016\Chapter 4';
libname chap5 'C:\UC Berkley\Summer 2016\Chapter 5';
libname chap9 'C:\UC Berkley\Summer 2016\Chapter 9';


libname sasusers 'C:\UC Berkley\Summer 2016\Data';

run;


 proc contents data=sasusers.payrollmaster;



**Step 1: Using the Let Statement;

run;

**Step 1a: Let statement in titles;

options mprint symbolgen ps=500;

 %let title = here is the burns data;


 proc print data=chap3.burns(obs=100);
 title "&title";
title2 "Note the double quotes for the title";


 **Step 1b: Let statement in part of data step;


options mprint symbolgen;

%let percent = .1;
%let cum_per = 1.1;

proc sql;
select empid,jobcode,salary,
salary*&percent as increase format=dollar9.,
salary*&cum_per as new_salary format=dollar9.
from sasuser.payrollmaster
where salary<32000
order by jobcode;

run;


**Step 2: Automatic Macro variables;


run;
footnote1 "Created &systime &sysday, &sysdate9";
footnote2 "on the &sysscp system using Release &sysver";
title "REVENUES FOR DALLAS TRAINING CENTER";
proc tabulate data=sasusers.all(keep=location course_title fee);
where upcase(location)="DALLAS";
class course_title;
var fee;
table course_title=" " all="TOTALS",
fee=" "*(n*f=3. sum*f=dollar10.)
/ rts=30 box="COURSE";

run;



**Step 3: Using the Put statement;
** Generally good when you have complicated code you need to check;
** Notice I put in the put statement with _user_ macro;


****************************************************************************;
* Macro designed to capture univariate effects;
* First Look at distribution of variable for target;
****************************************************************************;

options mprint symbolgen ls=140;
run;

%macro uni(var=,type=,group=);

%put _user_;


  data temp;
  set chap9.umaru;
  one =1;
 IVHX_2=0;
 IVHX_3=0;
 if ivhx = 2 then ivhx_2 =1;
 if ivhx = 3 then ivhx_3 =1;
  rank = &var;


run;


%if (&type = C) %then %do;

run;

 proc univariate data=temp;
  var &var;
title 'Proc Univeriate Case for Cont Variables';

run;


   proc rank data=temp out=ranking groups=&group;
  var rank;

run;

proc tabulate data=ranking formchar = '           ' noseps out=stats_tab missing;
     class rank;
     var one &var dfree;
table (rank="&var" all='Total'),
       (
        one            = ' '*sum='Tot #'*f=comma20.0
        &var            = ' '*min='Min'*f=comma20.1
        &var            = ' '*mean='Mean'*f=comma20.1
        &var            = ' '*max='Max'*f=comma20.1
        dfree          = ' '*sum='Tot DF'*f=comma20.0
        dfree          = ' '*pctsum<one>='% DF'*f=comma20.4


        )
        / rts=25 condense ;
Title "Dfree and &Var";
title2 'Continuous Distribution';

%end;
%else %do;

run;

 proc freq data=temp;
  table &var;
title 'Proc Freq for Discrete Variables';

run;

proc tabulate data=temp formchar = '           ' noseps out=stats_tab missing;
     class rank;
     var one &var dfree;
table (rank="&var" all='Total'),
       (
        one            = ' '*sum='Tot #'*f=comma20.0
        &var            = ' '*min='Min'*f=comma20.1
        &var            = ' '*mean='Mean'*f=comma20.1
        &var            = ' '*max='Max'*f=comma20.1
        dfree          = ' '*sum='Tot DF'*f=comma20.0
        dfree          = ' '*pctsum<one>='% DF'*f=comma20.4


        )
        / rts=25 condense ;
Title "Dfree and &Var";
title2 'Continuous Distribution';

%end;

proc logistic data=temp outest=coeff;
 model dfree (event='1') = &var;
/* output out=stats  p=pred l=lower u=upper;*/
 title "Logistic Regression DFREE Vs &Var";


run;

%mend uni;

run;

%uni(var=age,type=C,group=5);

run;

%uni(var=beck,type=D,group=5);

run;



** Step 4: macro quoting function;

**Step 4a: Use the double quotess to have single quite;


run;
 proc print data=chap3.burns(obs=100);
 title "Michael's data";
title2 "Note the double quotes for the title";

run;


**Step 4b: What if you wnat quotes in your macro statement;

run;
%let title = Michael's data;

run;
 proc print data=chap3.burns(obs=100);
 title "&tile";
title2 "Note the double quotes for the title";

run;


run;

** Use the STR or BQUOTE to hide the quote;

options mprint symbolgen;

   %let title = %str(Michael%'s data);

run;
 proc print data=chap3.burns(obs=100);
 title "&title";
title2 "Note the double quotes for the title";
title3 "Notice you have a % sign before the quote";

run;

    %let title = %BQUOTE(Michael's data);

run;
 proc print data=chap3.burns(obs=100);
 title "&title";
title2 "Note the double quotes for the title";
title3 "Notice you have a % sign before the quote";

run;


**Step 5: Substri function;
** Acts just like the substring function in data step;

run;

proc print data=sasusers.schedule;
 title 'here is schedule';

run;

%let dateq=25MAR2002;

 proc print data=sasusers.schedule;
where begin_date between
"01%substr(&dateq,3)"d and
"&sysdate9"d;
title "All Courses Held So Far This Month";
title2 "(as of &sysdate9)";

run;


**Step 6: The index function;
** Here you can find the position of a macro variable;

 %let a=Supercalifragilisticexpialidocious;
   %let b=%index(&a,x);
   %put V appears at position &b.;

run;


**Step 7: The Scan function;
** You can extract words from a macro variable;


%let dateq = 25MAR2002

data work.thisyear;
set sasusers.schedule;
where year(begin_date) =
year("&dateq"d);


run;

%let libref=%scan(&syslast,1,.);
%let dsname=%scan(&syslast,2,.);
proc datasets lib=&libref nolist;
title "Contents of the Data Set &syslast";
contents data=&dsname;
run;
quit;


**Step 7: Using the Sysfunction;
** Can initial functions within macros;
** Lets use it to see if a data set exists;

**Step 7a: For example there is the exists function;

options mprint symbolgen;

%MACRO CHECKIT(DSN);
 %IF %SYSFUNC(EXIST(&DSN)) = 1 %THEN %DO;
 PROC CONTENTS DATA=&DSN;
 %END;
 %ELSE %DO;
 DATA _NULL_;
 FILE PRINT;
 PUT "THE DATASET &DSN DOES NOT EXIST";
 %END;
 RUN;
%MEND checkit;
run;

%checkit(chap3.burns);

run;

%CHECKIT(CYLIB.JUNK);

run;


**Step 7b:Use sysfunction to idenity when data set has user defined variables;

options ps=500;
proc print data=sasusers.empdata;
title 'here is employ';

run;


Proc format;
 value $countryq

"USA"="United States"
"DENMARK"="Denmark"
"CANADA"="Canada"
"BELGIUM"="Belgum"
"GERMANY"="Germany"
"EUROPEAN HQ"="EU Headquarters"
"UNITED KINGDOM"="Britain"
;

run;


  DATA EMPLOY;
 SET sasusers.empdata;
 FORMAT country $countryq.;

RUN;

proc print data=employ;
title 'here is employ';

run;

options mprint symbolgen;

%MACRO CHECKFMT(DSNAME);
 %LET DSID = %SYSFUNC(OPEN(&DSNAME));
 %LET NUMVARS =
%SYSFUNC(ATTRN(&DSID,NVARS));
 %DO I = 1 %TO &NUMVARS;
 %LET FMT = %SYSFUNC(VARFMT(&DSID,&I));
 %IF &FMT NE %THEN %DO;
 %LET TYPE = %SYSFUNC(VARTYPE(&DSID,&I));
 %LET FMT = %SYSFUNC(COMPRESS(&FMT,'$'));
 %LET CATENTRY=
 LIBRARY.FORMATS.&FMT.FORMAT&TYPE;
 %IF %SYSFUNC(CEXIST(&CATENTRY)) %THEN
 %PUT &FMT IS A USER WRITTEN FORMAT
 USED BY &DSNAME;
 %END;
 %END;
 %LET RC = %SYSFUNC(CLOSE(&DSID));
%MEND;

run;

%CHECKFMT(EMPLOY);

run;


**Step 8: putting macros inside text;


**Step 8a: You can put macros after text and its okay;

proc print data=sasusers.y2000;
title 'here is year2000';

run;


%let year=2000;
proc chart data=sasusers.y&year;
hbar date / sumvar=crgorev1;

run;


**Step 8a: But you can not put macro variable before text unless you have a period;

proc print data=sasusers.y2000;
title 'here is year2000';

run;


%let year=2000;
proc chart data=sasusers.y&year;
hbar date / sumvar=crgorev1;
title "Results for &year.year";
title2 "This is the correct title";


run;



%let year=2000;
proc chart data=sasusers.y&year;
hbar date / sumvar=crgorev1;
title "Results for &yearyear";
title2 "This is the incorrect title";


run;



**Step 9: using two periods;
** Sometimes you need to have two periods;


optons mprint symbolgen;

%let lib = burns;

libname &lib 'C:\UC Berkley\Summer 2016\Chapter 3';


run;

 proc univariate data=&lib.burns;
 var tbsa;
title "Note the libname appears to be &lib.burns";

run;

 proc univariate data=&lib..burns;
 var tbsa;
title "Now the libname appears to be &lib..burns";

run;
