
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
libname chap11 'C:\UC Berkley\Summer 2016\Chapter 12';
libname chap11 'C:\UC Berkley\Summer 2016\Chapter 13';
libname chap11 'C:\UC Berkley\Summer 2016\Chapter 14';
libname sasusers 'C:\UC Berkley\Summer 2016\Data';
libname sasuser 'C:\UC Berkley\Summer 2016\Data';
libname chap8_L 'C:\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Chapter 8';
libname log_data 'C:\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Data';

run;


*** Step 1: We use the file to read in a dat file.;
** DAT files contain data in text or binary format. ;
** They are typically found as winmail.dat files in email attachments,
created by Microsoft Exchange Servers;


**filename qtr1 ("H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Data\month1.dat"
               "H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Data\month2.dat"
                           "H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Data\month3.dat");


filename qtr1 ("C:\UC Berkley\Summer 2016\Data\month1.dat"
               "C:\UC Berkley\Summer 2016\Data\month2.dat"
               "C:\UC Berkley\Summer 2016\Data\month3.dat");


run;



data work.firstqtr;
infile qtr1;
input Flight $ Origin $ Dest $
Date : date9. RevCargo : comma15.2;
run;

** Step 2: Using the Infile and filevar;


**Step 2a: pull some files in;

data work.quarter;
    nextfile="C:\UC Berkley\Summer 2016\Data\month1.dat";
 infile temp filevar=nextfile;
input Flight $ Origin $ Dest $
Date : date9. RevCargo : comma15.2;

run;

data work.quarter;
    nextfile="C:\UC Berkley\Summer 2016\Data\month9.dat";
 infile temp filevar=nextfile;
input Flight $ Origin $ Dest $
Date : date9. RevCargo : comma15.2;

run;

data work.quarter;
    nextfile="C:\UC Berkley\Summer 2016\Data\month10.dat";
 infile temp filevar=nextfile;
input Flight $ Origin $ Dest $
Date : date9. RevCargo : comma15.2;

run;

**Step 2b: Bring in the looping;
*** Goes and goes;

data work.quarter;
do i = 10 to 12 by 1;
     nextfile="C:\UC Berkley\Summer 2016\Data\month"!!put(i,2.)!!".dat";
         **nextfile=compress (nextfile," ");
   infile temp filevar=nextfile;
input Flight $ Origin $ Dest $
Date : date9. RevCargo : comma15.2;
end;

run;

**Step 2c: Bring in the looping;
** Stop it with last observation;

data work.quarter;
do i = 10, 11, 12 ;
     nextfile="C:\UC Berkley\Summer 2016\Data\month"!!put(i,2.)!!".dat";
         **nextfile=compress (nextfile," ");
do until (lastobs);
   infile temp filevar=nextfile end=lastobs;
   input Flight $ Origin $ Dest $
Date : date9. RevCargo : comma15.2;
output;
end;
end;
stop;
run;

**Step 3: Use the date function to get the most recent information;
** You can get the last three months starting with this month;

run;
***Step3a: Get last three months;

data work.quarter (drop=monthnum midmon lastmon);
monthnum=month(today());
midmon=monthnum-1;
lastmon=midmon-1;
do i = monthnum, midmon, lastmon;
nextfile="C:\UC Berkley\Summer 2016\Data\month"
!!compress(put(i,2.)!!".dat",' ');
do until (lastobs);
infile temp filevar=nextfile end=lastobs;
input Flight $ Origin $ Dest $ Date : date9.
RevCargo : comma15.2;
output;
end;
end;
stop;
run;


**Step 3b: what if today is January 15 there will be problems;
** There is no month0;

%let todayq = "15JAN2016"d;

run;

data work.quarter (drop=monthnum midmon lastmon);
monthnum=month(&todayq);
midmon=monthnum-1;
lastmon=midmon-1;
do i = monthnum, midmon, lastmon;
nextfile="C:\UC Berkley\Summer 2016\Data\month"
!!compress(put(i,2.)!!".dat",' ');
do until (lastobs);
infile temp filevar=nextfile end=lastobs;
input Flight $ Origin $ Dest $ Date : date9.
RevCargo : comma15.2;
output;
end;
end;
stop;
run;


** Step 3c: Here you use the intnx function that takes you one month back;

run;
%let todayq = "15JAN2016"d;

data work.quarter (drop=monthnum midmon lastmon);
monthnum=month(&todayq);
midmon=month(intnx('month',&todayq,-1));
lastmon=month(intnx('month',&todayq,-2));
do i = monthnum, midmon, lastmon;
nextfile="C:\UC Berkley\Summer 2016\Data\month"!!compress(put(i,2.)!!".dat",' ');
do until (lastobs);
infile temp filevar=nextfile end=lastobs;
input Flight $ Origin $ Dest $ Date : date9.
RevCargo : comma15.2;
output;
end;
end;
stop;
run;


** Step 4: Proc Append;

** Step 4a: You can use a set statement;

  data full_set;
   set sasusers.cap2001 sasusers.capacity;

   run;

** Step 4b: The problem is that if we proc print this you see some are missing;

   proc print data=full_set;
    title 'Full Set note the missing Date Variable';

        run;


** Step 4c: If you do a proc append then you will be told that one
            of the data sets has a different set of variables;

   data cap2001;
    set sasusers.cap2001;

        data capacity;
         set sasusers.capacity;

         run;

   proc append base=cap2001
           data=capacity;

run;

** Step 5:  Using FORCE Statement;

**Step 5a: If we try and add a data set that has variables not on the base
       it will not work;


   data cap2001;
    set sasusers.cap2001;

        data capacity;
         set sasusers.capacity;

         run;

   proc append base=capacity
           data=cap2001;

run;

proc contents data=cap2001;
 title 'here is cap2001';

run;


** Step 5b: We try and use force;

   data cap2001;
    set sasusers.cap2001;

        data capacity;
         set sasusers.capacity;

         run;

   proc append base=capacity
           data=cap2001 force;

run;

** Step 6: What if you are appending data and some of the variables have different
           lengths;

** Step 6a: assume we have two data sets with same variables of different lengths;

   data acities;
    set sasusers.acities;

        data westaust;
         set sasusers.westaust;

         run;


proc append base=work.acities
data=work.westaust;

 run;

** Step 6b: We can use force - the lenght of the variables goes to the base;

    data acities;
    set sasusers.acities;

        data westaust;
         set sasusers.westaust;

         run;


proc append base=work.acities
data=work.westaust force;

 run;

proc contents data=acities;

proc contents data=westaust;
 title 'west australia';

run;

** Step 7: What if the variables are of a different type;

 ** Step 7a: Combine two data sets where the variables is of a different type;

 data allemps;
   set sasusers.allemps;

   data newemps;
    set sasusers.newemps;

        run;

 proc append base=work.allemps
data=work.newemps;

run;

 ** Step 7b: Use the force variable is droped from the data being added ;

 data allemps;
   set sasusers.allemps;

   data newemps;
    set sasusers.newemps;

        run;

 proc append base=work.allemps
data=work.newemps force;

run;

 proc print data=allemps;
 title 'here is allemps';

run;

**Step 8: This was trying to read in files but it failed.;

**Step 8a: First we create a raw data on sasusers;
** I was unable to get these to work;

run;


filename qtr1 ("C:\UC Berkley\Summer 2016\Data\route1.dat"
               "C:\UC Berkley\Summer 2016\Data\route2.dat"
               "C:\UC Berkley\Summer 2016\Data\route3.dat");

run;

               **"C:\UC Berkley\Summer 2016\Data\route4.dat"
               "C:\UC Berkley\Summer 2016\Data\route5.dat"
                  );

data sasusers.rawdata;
infile qtr1 ;
input @1 RouteID $7. @8 Origin $3. @11 Dest $3.
@14 Distance 5. @19 Fare1st 4.
@23 FareBusiness 4. @27 FareEcon 4.
@31 FareCargo 5.
;
run;

** Step 8b;

   run;

data work.newroute;
set sasusers.rawdata;
infile in filevar = readit end = lastfile;
do while(lastfile = 0);
input @1 RouteID $7. @8 Origin $3. @11 Dest $3.
@14 Distance 5. @19 Fare1st 4.
@23 FareBusiness 4. @27 FareEcon 4.
@31 FareCargo 5.;
output;
end;
run;


** Step 8c:;

data work.newroute;
infile 'C:\UC Berkley\Summer 2016\Data\rawdata.dat';
input readit $10.;
infile in filevar=readit end=lastfile;
do while(lastfile = 0);
input @1 RouteID $7. @8 Origin $3. @11 Dest $3.
@14 Distance 5. @19 Fare1st 4.
@23 FareBusiness 4. @27 FareEcon 4.
@31 FareCargo 5.;
output;
end;
run;


** Step 9: moving from numeric to charater variable;

libname log 'C:\UC Berkley\Logistic Reg & Survival Analysis\For Students\Logistic\Data';

  data glow;
  set log.glow500;

run;

proc contents data=glow;
 title 'here is glow';

run;

proc freq data=glow;
 table weight / missing;
 title 'glow';

run;



  data first;
  set glow;
 if _N_ <= 250;


  data pre_second;
   set glow;
  if _n_ > 250;
   weight_char = put(weight, 8.);
  drop weight;


run;

 data second;
  set pre_second;
  weight = weight_char;
  drop weight_char;

run;

proc contents data=second;
  title 'here is second';

run;

proc freq data=second;
 table weight / missing;
 title 'second';

run;
