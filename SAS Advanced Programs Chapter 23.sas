
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
libname chap14  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 14';
libname chap15  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 15';
libname chap23  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 23';

libname chap8_L 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Chapter 8\From Home April 2016'; 
libname uc_data 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Data'; 

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


**Step 1: Lets get some data sets; 

run; 

data burns; 
 set uc_data.burn;  

data glow; 
 set uc_data.glow500; 

 run; 

 proc contents data=burns; 
 title 'burns'; 

 
run; 


**Step 2: Alternative Sorts; 

**Step 2a: data step with no sorting before hand; 
** THis is done automatically by the set statement; 

 data _null_; 
  set burns; 
   by id; 

run; 
**Step 2b: Sort the data first then  use the sorted data; 


proc sort data=burns; 
 by id; 

 data _null_; 
  set burns; 
   by id; 


** Step 2c: Create an index on the data set burns; 
** Then you set set it by id; 
** This is usually the fastest with very large data sets; 

   proc datasets libname=work; 
   modify burns; 
    index create id;
  quit;  

	run; 

data _null_; 
  set burns; 
   by id; 

	run; 

**Step 3: Notsorted ; 
** Can not use this with merge or update; 
** You can use it when you do not care if the proceedure sorts it; 

**Step3a: Just use the notsorted by itself; 
** As you can see if the variables are not sorted there rae problems; 

proc format; 
 value race
 0 = 'Non-White'
 1 = 'White'
 ; 


	proc print data=burns; 
	 by racec notsorted; 
	  format racec race.; 

	  run; 

** Step 3b: Use the sorted statement first; 


  proc sort data=burns; 
   by racec; 

	proc print data=burns; 
	 by racec notsorted; 
	  format racec race.; 

	  run; 


** Step 4: Use the Groupformat option; 

** Step 4a: First bring in the data; 

run; 

libname hazard 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Logistic Reg & Survival Analysis\For Students\Hazard Model\Data'; 

 data heart_attack; 
   set hazard.whas500; 

   run; 

proc contents data=heart_attack; 
 title 'heart_attack '; 

 run; 

 proc freq data=heart_attack; 
  table disdate fdate / missing; 
  format disdate fdate year4.; 

  run; 

** Step 4b: Next use group format to format by the formated statement; 
** Suppose you want to count the number of heart attacks by quarter; 

proc format;
value qtrfmt 
"01jan1999"d - "31mar1999"d = "1"
"01apr1999"d - "30jun1999"d = "2"
"01jul1999"d - "30sep1999"d = "3"
"01oct1999"d - "31dec1999"d = "4";
run;

proc print data=heart_attack; 
var disdate; 
 format disdate qtrfmt.; 
 where year(disdate) = 1999; 

 run; 



data heart_attack2(keep=count disdate rename=(disdate=quarter)); 
 set heart_attack; 
 format disdate qtrfmt.; 
 by disdate groupformat notsorted; 
 where year(disdate) = 1999; 
 if first.disdate then count=0; 
 count +1; 
 if last.disdate; 

 run; 

 proc freq data=heart_attack2; 
  table quarter / missing; 
   title 'here is count'; 

   run; 

proc print data=heart_attack2; 
 title 'here is heart_attack2'; 

 run; 

** Step 5: Use class statement instead of group by; 

 ** Step 5a: You can use the group by in the means statement to get the average for mean and women; 

  proc format; 
   value gender 
   0 = 'Male'
   1 = 'FeMale'
   other = 'Total'
   ; 
   run; 

  proc sort data=heart_attack; 
   by gender; 

   
   proc means data=heart_attack; 
    var age; 
	by gender; 
	output out=stats mean=mean_age p5=p5_age p95=p95_age; 

	run; 

	proc print data=stats;  
	var gender mean_age p5_age p95_age; 
	format gender gender.; 

	run; 

	** Step 5b: use the class statement ; 
	** Notice with the class statement you get the total which you do not get with the by statement; 

proc means data=heart_attack; 
    var age; 
	class gender; 
	output out=stats_class n=age_n mean=mean_age p5=p5_age p95=p95_age; 

	run; 

	proc print data=stats_class; 
	 title 'stats_class'; 

	 run; 

	proc print data=stats_class;  
	var gender age_n mean_age p5_age p95_age; 
	format gender gender.; 

	run; 


** Step 6: Sortedby variables; 

** Step 6a: What is a sorted by variable ? ;  

libname hazard 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Logistic Reg & Survival Analysis\For Students\Hazard Model\Data'; 


	data heart_attack; 
   set hazard.whas500; 

   run; 

   proc sort data=heart_attack 
        out=sorted; 
    by gender age; 

 run; 

 **Note You have to make the memname CAPTIAL letters (SORTED); 

 PROC SQL; **NOPRINT;
 create table sortby as 
 SELECT MEMNAME, NAME, SORTEDBY
 FROM DICTIONARY.COLUMNS
 WHERE LIBNAME = "WORK" AND
   MEMNAME = "SORTED";
QUIT;

proc print data=sortby2; 
 title 'here is sortby2'; 

 run; 

 **Step 6b: you can set the sorted by variables if you create a new data set; 

 ** First note that if we create a new data set it does not have a sortedby variable; 

 proc sort data=heart_attack; 
  by age; 

   data heart_attack_men; 
    set heart_attack; 
	 if gender = 0; 

 PROC SQL; **NOPRINT;
SELECT MEMNAME, NAME, SORTEDBY
 FROM DICTIONARY.COLUMNS
 WHERE LIBNAME = "WORK" AND
   MEMNAME = "HEART_ATTACK_MEN";
QUIT;

** But if we state the age is to be sorted by variable; 
** it will then be sorted by that variabel; 

 
   data heart_attack_men(sortedby=age); 
    set heart_attack; 
	 if gender = 0; 

 PROC SQL; **NOPRINT;
SELECT MEMNAME, NAME, SORTEDBY
 FROM DICTIONARY.COLUMNS
 WHERE LIBNAME = "WORK" AND
   MEMNAME = "HEART_ATTACK_MEN";
QUIT;


** Step 7: Using Threads if you system allows parrell process can speed up process.; 

proc sort data=heart_attack threads; 
 by bmi; 

 run; 



 ** Step 8: How much room do need to do a sort; 
 **        you need twice the size of a data set; 
 ** To get the size take; 

 proc contents data=heart_attack; 

 run; 

 ** Then use (70+176)*500*2 = 246,000; 
 ** WHich is 1/4 of a megabyte; 


** Step 9: Sortsize; 

**Step9a: You can use the sortsize to get more memory towards the; 

%macro skipit; 

SORTSIZE Time
1 MB 5 minutes 26.89 sec.
2 MB 3 minutes 11.37 sec.
4 MB 3 minutes 9.42 sec.
8 MB 3 minutes 7.25 sec.
16 MB 3 minutes 11.57 sec.
80 MB 3 minutes 13.48 sec.
MAX   2 minutes 45.23 sec.

%mend skipit; 
 

** Step9b: You use sortsize to get more; 

proc sort data=heart_attack sortsize=max; 
 by sysbp; 

 run; 


** Step 10: Sorting Huge data sets; 

 ** Step 10a: Sorting by observation; 

 proc sort data=heart_attack (firstobs=1 obs=199) out=one; 
 by age;  
 
proc sort data=heart_attack (firstobs=200 obs=299) out=two; 
 by age;  
 
 proc sort data=heart_attack (firstobs=300 obs=500) out=three; 
 by age;  
 

 data heart_attack_age; 
  set one two three; 
   by age; 
   year=year(disdate); 

   run; 

   proc freq data=heart_attack_age; 
    table year / missing; 
	title 'heart_attack_age'; 

	run; 

 ** Step 10b: subset by a variable like year; 


 data work.one work.two work.three; 
 set heart_attack; 
   year=year(disdate); 
   if year in (1997) then output work.one; 
   if year in (1999) then output work.two; 
   if year in (2001) then output work.three; 

   run; 
   
proc sort data=work.one; 
 by bmi; 

proc sort data=work.two; 
 by bmi; 

 proc sort data=work.three; 
 by bmi; 

 data heart_attack_bmi; 
  set one two three; 
   by bmi; 

   run; 


** Step 10c: Using an if statement on the variable you want to sort by; 

  ** First get the distribution of age; 

  proc univariate data=heart_attack; 
   var age; 
   title 'univraiate on age'; 

run;  

  ** Okay its 30 to 104 lets use that as part of the sort; 

 data work.one work.two work.three; 
 set heart_attack; 
   if age <= 45 then output work.one; 
   if 45 < age <=70 then output work.two; 
   if 70 < age < 110 then output work.three; 

proc sort data=work.one; 
 by age; 

proc sort data=work.two; 
 by age; 

 proc sort data=work.three; 
 by age; 

 data heart_attack_bmi; 
  set one two three; 
   **by age;  **Note do not need to set by age because already sorted the above; 

   run; 


** Step 10d: Make the sorting part of the IF statement; ; 

 proc univariate data=heart_attack; 
  var bmi; 

  run; 

  ** BMI 13 - 45; 

  proc sort data=heart_attack out=one; 
  by bmi; 
  where 13 <= bmi < 25; 

  proc sort data=heart_attack out=two; 
  by bmi; 
  where 25 <= bmi < 35; 

  proc sort data=heart_attack out=three; 
  by bmi; 
  where 35 <= bmi ; 


  data heart_attack_bmi; 
   set one two three; 

   run; 


**Step 11: you can also use PROC APPEND instead of the last data set; 
** It is not generally recomended as it takes more time so I will not go through it; 

** Step 12: Using tagsort; 
** if you are running of temporray space in your sort you can use this; 
** But it will INCREASE the amount of time it takes so there are clear drawbacks; 

   proc sort data=heart_attack out=heart_attack_los tagsort; 
    by los; 

	run; 


** Step 13: Nodupkey eliminates duplicate records; 

	 ** Step 13a: use nodupkey; 

  proc sort data=heart_attack out=heart_attack_nodup nodupkey; 
  by age ;

run;

   ** Step 13b: use NODPRECS to eliminate exact same type of record; 

     data last_obs; 
	 set heart_attack; 
	 if _n_ = 500; 

	 data expand_heart_attack; 
	  set heart_attack last_obs; 

	  run; 

	  proc sort data=expand_heart_attack noduprecs; 
	   by age; 
  
	   run; 


** Step 14: Look at Equal and NoEqual; 

** Step 14a: We start by creating a data set that we can work with; 

	   data ae0;
input ptnum $6. aeseq event $20.;
cards;
001002 1 HEADACHE
001001 1 FEVER
001001 2 HEADACHE
001003 1 NAUSEA
001003 4 DIARRHEOA
001003 2 VOMITING
001004 1 DIARRHEOA
001001 3 DIARRHEOA
001002 2 DIARRHEOA
001004 2 HEADACHE
001003 3 FEVER
;
run;

** Step 14b: Now we do a sort by ptnum and print it off; 

proc sort data=ae0 out=first nodupkey; 
 by ptnum; 

 run; 

 proc print data=first; 
 title 'first nodupkey no equal or notequal'; 

 run; 

 ** Step 14c: Now we add in the equal notice its the same; 

proc sort data=ae0 out=second nodupkey equals; 
 by ptnum; 

 run; 

 proc print data=second; 
 title 'Second nodupkey has equals'; 
 title2 'Notice that we pick the first observtaions'; 


 run; 

  ** Step 14d: Now we put in the noequals; 

proc sort data=ae0 out=third nodupkey noequals; 
 by ptnum; 

 run; 

 proc print data=third; 
 title 'third nodupkey has Noequals'; 
 title2 'Notice that we pick Do Not pick the first observations'; 
 title3 'noequal does not take as long'; 


 run; 

** Step 15: Using First and Last; 

 proc sort data=heart_attack; 
  by bmi; 

  data first_bmi; 
   set heart_attack; 
   by bmi; 
   if first.bmi; 

   run; 


** Note: Generally its best and fastest to use nodupkey; 
**      you can speed things up some by using noequal; 
**      but that assumes you DO NOT want the first one; 


** Step 16: Using alternative sorting techinques that may be available; 
** Since we rae in windows there is only one type available; 
** But for other systems you can specificy use the best; 
   

   %macro skipit; 
    Operating Environment Host Sort Utilities
     z/OS                     Dfsort (default)
                              Syncsort
      UNIX                    Cosort
                              Syncsort (default)
      Windows               Syncsort

  %mend skipit; 

  options sortpgm=best;  *Host and SAS also available;  

  proc sort data=heart_attack out=heart_attack_los; 
   by los; 

   run; 
