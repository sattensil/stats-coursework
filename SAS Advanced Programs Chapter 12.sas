
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
libname sasusers 'C:\UC Berkley\Summer 2016\Data';
libname sasuser 'C:\UC Berkley\Summer 2016\Data';
libname chap8_L 'C:\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Chapter 8';
libname log_data 'C:\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Data';



run;

%macro skipit;

run;

data chap8_l.low_birth;
 set low_birth;

run;

data chap8_l.placement;
 set placement;

 run;

%mend skipit;



 proc contents data=sasusers.payrollmaster;



**Step 1: Example of SAS Macro;
** Lets go through this macro that does univariate analysis;
 ** on variabgles designed to capture factors impact low birth weight;

 data low_birth;
   set chap8_L.low_birth;

   run;

 data placement;
  set chap8_L.placement;

  run;

  proc format;
   value place
   0 = 'outpaitent'
   1 = 'Half Way House'
   2 = 'Residential'
   ;

   run;

   proc contents data=low_birth;
    title 'low birth';

        run;


 %macro uni(var=,type=,group=);

  data temp;
  set low_birth;
  one =1;
if BWT > 3500 then BWT4 = 0;
if 3000 < BWT <= 3500 then bwt4 = 1;
if 2500 < BWT <= 3000 then bwt4 = 2;
if BWT <= 2500 then bwt4 = 3;
bwt01=0;
bwt02 = 0;
bwt03=0;
bwt04=0;
if bwt4 = 1 then bwt01 = 1;
if bwt4 = 2 then bwt02 = 1;
if bwt4 = 3 then bwt03 = 1;
ftv_binary = 0;
 if ftv > 0 then ftv_binary = 1;
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
     var one &var bwt01 bwt02 bwt03;
table (rank="&var" all='Total'),
       (
        one            = ' '*sum='Tot #'*f=comma20.0
        &var           = ' '*min='Min'*f=comma20.1
        &var           = ' '*mean='Mean'*f=comma20.1
        &var           = ' '*max='Max'*f=comma20.1
        bwt01          = ' '*sum='#bwt01'*f=comma20.0
        bwt01          = ' '*pctsum<one>='% bwt01'*f=comma20.4
        bwt02          = ' '*sum='#bwt02'*f=comma20.0
        bwt02          = ' '*pctsum<one>='% bwt02'*f=comma20.4
        bwt03          = ' '*sum='#bwt03'*f=comma20.0
        bwt03          = ' '*pctsum<one>='% bwt03'*f=comma20.4
        )
        / rts=25 condense ;
Title "BWT and &Var";
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
     var one &var bwt01 bwt02 bwt03;
table (rank="&var" all='Total'),
       (
        one            = ' '*sum='Tot #'*f=comma20.0
        &var            = ' '*min='Min'*f=comma20.1
        &var            = ' '*mean='Mean'*f=comma20.1
        &var            = ' '*max='Max'*f=comma20.1
        bwt01          = ' '*sum='#bwt01'*f=comma20.0
        bwt01          = ' '*pctsum<one>='% bwt01'*f=comma20.4
        bwt02          = ' '*sum='#bwt02'*f=comma20.0
        bwt02          = ' '*pctsum<one>='% bwt02'*f=comma20.4
        bwt03          = ' '*sum='#bwt03'*f=comma20.0
        bwt03          = ' '*pctsum<one>='% bwt03'*f=comma20.4
       )
        / rts=25 condense ;
Title "BWT and &Var";
title2 'Continuous Distribution';

%end;


proc logistic data = temp;
  class bwt4 (ref='0') race(ref='1') smoke(ref='0') ptl(ref='0') ht(ref='0') ui(ref='0') ftv(ref='0') ftv_binary(ref='0')/param=ref;
  model bwt4(event='1')  =  &var / link=glogit;
**where bwt4 in (0,1);
 title 'results for bwt4 0 vs 1';

run;




%mend uni;

run;

%uni(var=age,type=C,group=5);  ** Age does not seem to be very good. Possible fractional polynomials;
run;

%uni(var=lwt,type=C,group=3);  ** LWT seems important. Has opposite direction for 01 vs 02 and 03;

run;

%uni(var=lwt5,type=C,group=3);  ** LWT seems important. Has opposite direction for 01 vs 02 and 03;

run;



%uni(var=race,type=NC,group=3);  **Does seem to differentiate. Might be worth combining have White(0)  vs Black and Other;

run;


**Step 2: Now we can call this macro anytime we have the program;
** open because it was stored into Work.Sasmacr.uni.Macro;


%uni(var=smoke,type=NC,group=5); ** Appears to differentiate;

run;


**Step 3: Now lets assume you want to store the macro in a permenant place;
** You start by storing the Macro into a permanent location like
H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Macros;
**\uni.sas.txt;

**Step 3a: First you save the program in the directory;


**Step 3b: THen log off and get back on and call the MACRO back in;

run;
**%include 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Macros\uni.sas.txt'/source2;

%include 'C:\UC Berkley\Summer 2016\Chapter 12\uni_sas.txt' /source2;



run;

**Step 3c: Then you can utilize the called in macro as if you had written it in this program;

options mprint symbolgen;

%uni(var=ptl,type=NC,group=5);   ** History of premature does seem to impact;

run;

**Step 4: Cataglogs;

**Step 4a: First you create a SAS program with just the uni macro in it;

**Step 4b: Then you save it by create a Cataloauge with the uni macro in the catalog;

%macro Skipit;

/*
1 Select File ?? Save As Object. In the Save As Object window, select the Sasuser
library.
2 If the Sasuser.Mymacs catalog does not already exist, you need to create it. You
can either select the Create New Catalog icon or right-click the Save As Object
window and select New in order to open the New Catalog window. Enter Mymacs as
the name for the new catalog and click OK.
3 Enter Printit in the Entry Name field. Make sure that the Entry Type is set to
SOURCE entry (SOURCE), then click Save.
*/

%mend skipit;

**Step 4c: You can look at the macro you saved in the catalog;



  PROC CATALOG CATALOG=sasusers.Mymacs;
CONTENTS;
QUIT;


**Step 4d: Calling a macro in from a catalog;
run;

filename uni catalog "sasusers.Mymacs";
%include uni(uni) / source2;


run;


%uni(var=ptl,type=NC,group=5);

run;

**Step 5: creating an autocall libraray;
** Everytime you log on you call in this library;
** Just an easy way to access your macros;
** UNABLE TO GET TO WORK;

**Step 5a: Set mautosource sasautos;

options mprint symbolgen;

options mautosource sasautos=("C:\UC Berkley\Summer 2016\Data");
run;

**Step 5b: Using the autocall;


%uni(var=ptl,type=NC,group=5);

run;

** Step 6: Put a macro into a catalog while the macro is being created;

**Step 6a: Start by running the program;

data one;
input
LTV      approv      td      yhat
;
datalines;
77      1900      100      34
78      1800      250      56
79      1700      310      120
80      1600      345      343
81      800      400      289
82      760      749      420
83      720      859      356
84      321      907      399
85      220      962      508
86      134      962      650
87      94      1069      789
88      59      1389      839
;

run;



%macro skipit;

libname macrolib ’c:\storedlib’;
options mstored sasmstore=macrolib;

%macro words(text,root=w,delim=%str( ))/store source;
%local i word;
%let i=1;
%let word=%scan(&text,&i,&delim);
%do %while (&word ne );
%global &root&i;
%let &root&i=&word;
%let i=%eval(&i+1);
%let word=%scan(&text,&i,&delim);
%end;
%global &root.num;
%let &root.num=%eval(&i-1);
%mend words;

%mend skipit;

**Step 6a: Define a macro;
** First we just go through what the Macro is doing;

%macro ks(fname=,score=,summary_good=,summary_bad=);

proc sort data=&fname(keep=&score &summary_good &summary_bad) out=fname;
   by &score;

data ks_one;
    retain cumgood cummbad 0; /*set initial value for 2 counters*/
   set fname end=last;
   *cumgood+1-&yvar;
    cumgood + &summary_good; /*calculate total cummulative good, using summary data*/
  * cumbad+&yvar;
        cumbad + &summary_bad;      /*calculate total cummulative bad, using summary data*/
   if last then do; /*when last, cummulative gives total good and bads*/
      call symput('tgoods',left(cumgood));
      call symput('tbads',left(cumbad));
   end;
run;

/*
%let total_nobs=%eval(&tgoods + &tbads);
%put &total_nobs;
*/

data ks_two(keep=&score pctdiff GOODS BADS);
   set ks_one;
*  by &score;

   GOODS=cumgood/&tgoods;
   BADS =cumbad/&tbads;

   pctdiff=abs((GOODS-BADS)*100);

   /*
   put ltv= cumgood= cumbad=;
   put 'tgoods = ' "&tgoods";
   put 'tbads = ' "&tbads";
   put pctdiff=;
   */

   *if last.&score;
run;

proc print data=ks_two;
title "data=ks_two";
run;

/* NEW Instead of proc univariate */
proc means data=ks_two noprint;
   var pctdiff;
   output out=ksdata
          idgroup (max(pctdiff) obs out (&score pctdiff)=);
run;

/* NEW */
proc print data=ksdata;
title "ksdata";
run;

/* CHANGED */
%global ksstat ksref;

/* NEW & CHANGED */
data _null_;
   set ksdata;
   call symput('ksref',&score);
   call symput('ksstat',put(trim(left(pctdiff)),$5.));
run;

/* NEW & CHANGED */
%PUT 'KS PCTDIFF   = ' &KSSTAT;
%PUT 'KS Reference = ' &KSREF;


/*************************GRAPHING KS CURVES****************************/

*FILENAME grafout PIPE 'lp -ddelta -oraw'; /*for UNIX*/
*filename grafout 'D:\jxl\U C B\SAS_CLASS\Graph\Examples\mygraph.ps';  /*testing ps file*/
goptions reset=goptions display;
goptions noprompt /*device=ps300*/ ftext=swiss gsfname=grafout
         gsfmode=append colors=(black) gaccess=sasgaedt gprolog='%!'
         rotate htext=1.4 display;

footnote h=1.5 j=l'Produced by JIANMIN LIU, Ph.D.';
footnote2 h=1.0 j=l'COPYRIGHT (C) 2006 by YOU'
j=r'Data Source: EDUCATION';
/***********************************************************************/

axis1 value=(angle=0 height=1.5 font=SWISSB)
      major=(height=1)
      minor=(height=0.5)
      offset=(1)
      label=(h=1.5);

axis2 value=(angle=0 height=1.5 font=SWISSB)
      label=(justify=left'Percentage%' justify=center' ' h=3.0)
      major=(height=1)
      minor=(height=0.5)
      offset=(1);

symbol1 v=triangle   i=join c=blue h=1;
symbol2 v=dot        i=join c=red  h=1;
*symbol3 v=none       i=join c=green h=1;
*symbol4 v=circle     i=join c=black h=1;

legend origin= (80 pct, 35 pct)
       mode=share
       across=1
       label=none;

proc gplot data=ks_two /*gout=output1*/;
title1 h=2.5 "KS Statistics Curves for Variable &Score";
title2 h=1.5 "Max Vertical Distance Between Curves is: KS= &ksstat";
/* CHANGED */
   plot GOODS*&score BADS*&score / /*name=&name*/
                        haxis=axis1
            vaxis=axis2
                        overlay
            grid
                        chref=green
                        href=&ksref
            legend=legend1;
run;
title;
quit;


proc datasets library=work;
   delete ks_one ks_two ksdata ksobs;
run;

%mend ks;


run;

%ks(fname=one,score=LTV,summary_good=approv,summary_bad=td);

run;

**Step 6b: Now run the macro and create stored macro at the same time;
** Now we run it again note the store source in the macro ks;


run;
**libname macrolib "H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\macros";
libname macrolib "C:\UC Berkley\Summer 2016\Data";
ru;


options mstored sasmstore=macrolib;

run;
%macro ks(fname=,score=,summary_good=,summary_bad=)/ store source;

proc sort data=&fname(keep=&score &summary_good &summary_bad) out=fname;
   by &score;

data ks_one;
    retain cumgood cummbad 0; /*set initial value for 2 counters*/
   set fname end=last;
   *cumgood+1-&yvar;
    cumgood + &summary_good; /*calculate total cummulative good, using summary data*/
  * cumbad+&yvar;
        cumbad + &summary_bad;      /*calculate total cummulative bad, using summary data*/
   if last then do; /*when last, cummulative gives total good and bads*/
      call symput('tgoods',left(cumgood));
      call symput('tbads',left(cumbad));
   end;
run;

/*
%let total_nobs=%eval(&tgoods + &tbads);
%put &total_nobs;
*/

data ks_two(keep=&score pctdiff GOODS BADS);
   set ks_one;
*  by &score;

   GOODS=cumgood/&tgoods;
   BADS =cumbad/&tbads;

   pctdiff=abs((GOODS-BADS)*100);

   /*
   put ltv= cumgood= cumbad=;
   put 'tgoods = ' "&tgoods";
   put 'tbads = ' "&tbads";
   put pctdiff=;
   */

   *if last.&score;
run;

proc print data=ks_two;
title "data=ks_two";
run;

/* NEW Instead of proc univariate */
proc means data=ks_two noprint;
   var pctdiff;
   output out=ksdata
          idgroup (max(pctdiff) obs out (&score pctdiff)=);
run;

/* NEW */
proc print data=ksdata;
title "ksdata";
run;

/* CHANGED */
%global ksstat ksref;

/* NEW & CHANGED */
data _null_;
   set ksdata;
   call symput('ksref',&score);
   call symput('ksstat',put(trim(left(pctdiff)),$5.));
run;

/* NEW & CHANGED */
%PUT 'KS PCTDIFF   = ' &KSSTAT;
%PUT 'KS Reference = ' &KSREF;


/*************************GRAPHING KS CURVES****************************/

*FILENAME grafout PIPE 'lp -ddelta -oraw'; /*for UNIX*/
*filename grafout 'D:\jxl\U C B\SAS_CLASS\Graph\Examples\mygraph.ps';  /*testing ps file*/
goptions reset=goptions display;
goptions noprompt /*device=ps300*/ ftext=swiss gsfname=grafout
         gsfmode=append colors=(black) gaccess=sasgaedt gprolog='%!'
         rotate htext=1.4 display;

footnote h=1.5 j=l'Produced by JIANMIN LIU, Ph.D.';
footnote2 h=1.0 j=l'COPYRIGHT (C) 2006 by YOU'
j=r'Data Source: EDUCATION';
/***********************************************************************/

axis1 value=(angle=0 height=1.5 font=SWISSB)
      major=(height=1)
      minor=(height=0.5)
      offset=(1)
      label=(h=1.5);

axis2 value=(angle=0 height=1.5 font=SWISSB)
      label=(justify=left'Percentage%' justify=center' ' h=3.0)
      major=(height=1)
      minor=(height=0.5)
      offset=(1);

symbol1 v=triangle   i=join c=blue h=1;
symbol2 v=dot        i=join c=red  h=1;
*symbol3 v=none       i=join c=green h=1;
*symbol4 v=circle     i=join c=black h=1;

legend origin= (80 pct, 35 pct)
       mode=share
       across=1
       label=none;

proc gplot data=ks_two /*gout=output1*/;
title1 h=2.5 "KS Statistics Curves for Variable &Score";
title2 h=1.5 "Max Vertical Distance Between Curves is: KS= &ksstat";
/* CHANGED */
   plot GOODS*&score BADS*&score / /*name=&name*/
                        haxis=axis1
            vaxis=axis2
                        overlay
            grid
                        chref=green
                        href=&ksref
            legend=legend1;
run;
title;
quit;


proc datasets library=work;
   delete ks_one ks_two ksdata ksobs;
run;

%mend ks;

run;


**Step 6c: Now we look at where the SAS macro is located;

proc catalog cat=macrolib.sasmacr;
contents;
title "Stored Compiled Macros";
quit;


** Step 6d: Call the macro in;
** First we log off then we call it in;

run;

libname macrolib "C:\UC Berkley\Summer 2016\Data";
options mstored sasmstore=macrolib;

data one;
input
LTV      approv      td      yhat
;
datalines;
77      1900      100      34
78      1800      250      56
79      1700      310      120
80      1600      345      343
81      800      400      289
82      760      749      420
83      720      859      356
84      321      907      399
85      220      962      508
86      134      962      650
87      94      1069      789
88      59      1389      839
;

run;

%ks(fname=one,score=LTV,summary_good=approv,summary_bad=td);

run;


**Step 7: Take a look at the stored macro with copy;
** Unable to get this to work;


%copy ks/source;

run;
