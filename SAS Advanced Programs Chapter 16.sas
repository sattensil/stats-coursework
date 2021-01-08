
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
libname chap14 'C:\UC Berkley\Summer 2016\Chapter 14';
libname chap15 'C:\UC Berkley\Summer 2016\Chapter 15';


libname sasusers 'C:\UC Berkley\Summer 2016\Data';
libname sasuser 'C:\UC Berkley\Summer 2016\Data';
libname chap8_L 'C:\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Chapter 8';
libname log_data 'C:\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Data';

run;


**Step 1: Want to create a mult-dimentional array to map;
**        speed and tempurature to wind chill factor;

run;

   data work.wndchill; **(drop = column row);
     array WC{8,9} _temporary_
   (-22,-16,-11,-5,1,7,13,19,25,
    -28,-22,-16,-10,-4,3,9,15,21,
-32,-26,-19,-13,-7,0,6,13,19,
-35,-29,-22,-15,-9,-2,4,11,17,
-37,-32,-24,-17,-11,-4,3,9,16,
-39,-33,-26,-19,-12,-5,1,8,15,
-41,-34,-27,-21,-14,-7,0,7,14,
-43,-36,-29,-22,-15,-8,-1,6,13)
;
 set sasusers.flights;
row = round(wspeed,5)/5;      ** The row is the wind speed;
column = (round(temp,5)/5)+3; ** Column is the temperature;
WindChill= wc{row,column};    ** Specify the row and column you get the winchill;

run;

proc print data=wndchill;
 title 'here is wndchill';

run;

**Step 2:   Lets try and merge two data sets together that have different;
**          structures;

**Step 2a: We start by print out the two datasets;
**         As seen the structure of the data is different;
**         So we can not directly match up the two sets of data;
**         We have no match key;

run;

   proc print data=sasusers.monthsum;
   title 'monthsum';

run;

   proc print data=sasusers.ctargets;
   title 'ctargets';

run;


** Step 2b: So we work to create a look up table that
**          provides actual and targeted revenue values;
**          start with unpopulationed array;

run;
**Step 2b1: This creates the arrays. 3 rows 12 columns;

data work.lookup1;
array Targets{1997:1999,12} _temporary_;

**Step 2b2: Now we load the array with values from ctargets;
** Start by creating array from Jan to December;


if _n_=1 then do i= 1 to 3;
set sasusers.ctargets;
array mnth{*} Jan--Dec;

**Step2b3: Then you populatte the array by setting targets equial to the mnth value for c.targets;
** At the end of this you have targets array with ctargets now in terms of year and month;
do j=1 to dim(mnth);
targets{year,j}=mnth{j};
end;
end;

**Step 2b4: Finally you actually read the values for sasusers.monthsum and define ctarget using;
**          year the monthno from monthssum;
set sasusers.monthsum(keep=salemon revcargo monthno);
year=input(substr(salemon,4),4.);
Ctarget=targets{year,monthno};
format ctarget dollar15.2;

run;

** step2b5: Putting the whole thing together we get;

data work.lookup1;
array Targets{1997:1999,12} _temporary_;
if _n_=1 then do i= 1 to 3;
set sasuser.ctargets;
array Mnth{*} Jan--Dec;
do j=1 to dim(mnth);
targets{year,j}=mnth{j};
end;
end;
set sasuser.monthsum(keep=salemon revcargo monthno);
year=input(substr(salemon,4),4.);
Ctarget=targets{year,monthno};
format ctarget dollar15.2;
run;

**Note: The full table now has the ctarget defined by year, month of the monthsum;
**      table and using these we can match to the Jan--Dec and year table of the;
**      original ctarget;

proc print data=lookup1;
**var salemon revcargo ctarget;
 title 'lookup 1';

run;

**Step 3: Using Proc Tanspose;

**Step 3a: Recall the two datasets we have;

run;

   proc print data=sasusers.monthsum;
   title 'monthsum';

run;

   proc print data=sasusers.ctargets;
   title 'ctargets';

run;


**Step 3b: If we can transpose the data set ctargets so that the rows of Jan-Dec;
***        become columns then we can match the year and month in ctargets;
**         to the year and month that is in monthsum;
** We start with the simple transpose and see what we get;


proc transpose data=sasuser.ctargets
out=work.ctarget2;

run;

proc print data=ctarget2;
 title 'ctarget2';

run;

** Step 3c: That data set as given cannot be merged to monthsum;
**  But it is close;
** if we get rid of the first row which is year;
** and keep the other rows we should be okay;
** We can od that by sorting by year;

 proc sort data=sasuser.ctargets;
 by year;

proc transpose data=sasuser.ctargets
out=work.ctarget3
name = month
prefix = ctarget;
by year;


proc print data=ctarget3;
 title 'here is ctarget3';

run;


** Step 3d: Now we need to change the monthsum data because we only have the year and month;
**          togher. And the month is in upper case, so that must be put into lower;
**          case;


data work.mnthsum2;
set sasuser.monthsum(keep=SaleMon RevCargo);
length Month $ 8;
Year=input(substr(SaleMon,4),4.);
Month=substr(SaleMon,1,1)
||lowcase(substr(SaleMon,2,2));
run;

  proc print data=mnthsum2;
 title 'mnthsum2';

run;

** Step 3e: Now we merge them together;

 proc sort data=ctarget3;
 by year month;

proc sort data=mnthsum2;
 by year month;

 data merged;
 merge mnthsum2 ctarget3;
 by year month;

run;

** Step 3f: print off the final data set;

proc print data=work.merged;
format ctarget1 dollar15.2;
var month year revcargo ctarget1;
 title 'merged ';


run;


** Step 4: Using Hash Objects;

*** Step 4a: First look at the data set contribution;

proc print data=sasusers.contrib;
 title 'here is constribute';

run;


*** Step 4b: We want to create an object that compares the amount to the goal and;
**           takes the difference. We uses hashes because they are faster then lookup tables;
**           Start by declaring the hash object which we call goal;

data work.difference; **(drop= goalamount);
length goalamount 8;
if _N_ = 1 then do;
declare hash goal;


**  step 4c: Next we initiate the hash object, which we means we create something;
**           like a library statement;

data work.difference; **(drop= goalamount);
length goalamount 8;
if _N_ = 1 then do;
declare hash goal;
goal = _new_ hash();


** step 4d: Now we define the key variable QTR and the variable goal amount;
**          which we will use to get the differences between the actual and targeted;
**          amount;

data work.difference (drop= goalamount);
length goalamount 8;
if _N_ = 1 then do;
declare hash goal();
goal.definekey ("QtrNum");
goal.definedata ("GoalAmount");
goal.definedone();


**  Step 4e: Now we put missing values into the hash objects;
**           so in case we do not have a match their will be a missing;
**           value in the hash;

data Work.Difference (drop= goalamount);
length GoalAmount 8;
if _N_ = 1 then do; declare hash goal();
goal.definekey("QtrNum");
goal.definedata("GoalAmount");
goal.definedone();
call missing(qtrnum, goalamount);


**Step 4f: Loading up the key and data values that make up the hash object;
** Notice that the quarters have target variables in them;

data work.difference (drop= goalamount);
length goalamount 8;
if _N_ = 1 then do; declare hash goal();
declare hash goal( );
goal.definekey("QtrNum");
goal.definedata("GoalAmount");
goal.definedone( );
call missing(qtrnum, goalamount);
goal.add(key:’qtr1’, data:10 );
goal.add(key:’qtr2’, data:15 );
goal.add(key:’qtr3’, data: 5 );
goal.add(key:’qtr4’, data:15 );
end;

** Step 4g: Now we get our data set and use the FIND() key  to match up with QRT and;
** Figure out the difference between what was made and the goal;


data work.difference; **(drop= goalamount);
length goalamount 8;
length qtrnum $8.;
if _N_ = 1 then do;
declare hash goal( );
goal.definekey("QtrNum");
goal.definedata("GoalAmount");
goal.definedone( );
call missing(qtrnum, goalamount);
goal.add(key:"qtr1", data:10 );
goal.add(key:"qtr2", data:15 );
goal.add(key:"qtr3", data: 5 );
goal.add(key:"qtr4", data:15 );
end;
set sasuser.contrib;
goal.find();
Diff = amount - goalamount;
run;

proc print data=difference;
var qtrnum empid goalamount amount diff;
title 'Difference';

run;
