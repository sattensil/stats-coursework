

%LET city = Washington ;
TITLE1 "This city is &city" ;
TITLE2 'This city is &city' ;
proc print;
run;


%LET city = 'Washington, DC' ;
TITLE "The address is &city" ;


******* Conditional Logic **************;
Data orders;
Input customerID $1-3 @5 OrderDate date7. Model $13-25 Quantity;
Datalines;
287  15OCT02 Delta Breeze 15
287  15OCT02 Santa Ana    15
274  16OCT03 Jet Stream   1
174  10OCT03 Santa Ana    20
174  17OCT03 Nor’Easter   5
374  18OCT03 Mistral      1
287  21OCT03 Delta Breeze 30
287  21OCT03 Santa Ana    25
run;

%macro reports;
%if &sysday=Monday %then %do;
Proc print data=orders NOOBS;
Format OrderDate date7.;
Title “&sysday Report: Current Orders”;
Run;

%end;
%else %if &SYSDAY=Sunday %then %do;
Proc tabulate data=orders;
Class customerID;
var Quantity;
table customerID ALL, quantity;
Title “&sysday Report: Summary of Orders”;
Run;

%end;
%mend reports;

%reports;

********* In class practice *******;
DATA grades;
    do i = 1 to 100;
       id = i;
       grade = int(100*ranuni(123)+1);
	   age=int(4*rannor(1234567) + 25);
       output;
    end;
run;

*1;
data new; set grades;
if grade le 70 then status=0;
else status=1;
run;

proc format;
 value status  0='Failed'
 			   1='Passed';
run;

title "Grade distribution when cutoff=70";
proc freq data=new;
table status;
format status status.;
run;

*2;

%let cutoff=60;

data new; set grades;
if grade le &cutoff then status=0;
else status=1;
run;

title "Grade distribution when cutoff=&cutoff";
proc freq data=new;
table status;
format status status.;
run;

*3;

%macro gradecuts(inputdata=, cutoff=);

data new; set &inputdata;
if grade le &cutoff then status=0;
else status=1;
run;

title "Grade distribution when cutoff=&cutoff";
proc freq data=new;
table status;
format status status.;
run;

%mend grade;

%gradecuts(inputdata=grades, cutoff=90);

*4. This is a practice of using conditional logic;
%macro gradecuts(inputdata=, cutoff=, agecutoff=);

data above&agecutoff under&agecutoff; set &inputdata;
if age ge &agecutoff then do;
	if grade le &cutoff then Pass="Failed";
	else Pass="Passed";
	output above&agecutoff;
	end;

else if age lt &agecutoff then output under&agecutoff;
run;
quit;


Proc GCHART data=above&agecutoff;
goptions hsize=4 vsize=8;
Vbar Pass;
Title “Bar chart of pass/fail for age=&agecutoff and above”;
Run;

goptions hsize=4 vsize=4;
proc gplot data=under&agecutoff;
Title “Scatter plot of age vs grade  for age below &agecutoff ”;
plot grade*age;
run;
quit;

%mend gradecuts;

%gradecuts(inputdata=grades, cutoff=70, agecutoff=28);
%gradecuts(inputdata=grades, cutoff=70, agecutoff=24);



*4. Continue .... as an illustration of using %if %then % else, need to apply to a macro variable;

%macro Con_gradecuts(inputdata=, cutoff=, agecutoff=);

data temp; set &inputdata;
if grade le &cutoff then Pass="Failed";
	else Pass="Passed";
run;

%if &agecutoff ge 25 %then %do;
Proc GCHART data=temp;
goptions hsize=4 vsize=8;
Vbar Pass;
Title “Bar chart of pass/fail for agecutoff=&agecutoff and above”;
Run;
%end;

%else %do;
goptions hsize=4 vsize=4;
proc gplot data=temp;
Title “Scatter plot of age vs grade  for agecutoff below &agecutoff ”;
plot grade*age;
run;
%end;
quit;

%mend Con_gradecuts;
%Con_gradecuts(inputdata=grades, cutoff=70, agecutoff=24);
%Con_gradecuts(inputdata=grades, cutoff=70, agecutoff=27);
