*use import to import CSV file, or use infile statement;

data name1;
infile 'H:\CSUEB\Teaching\sta6250 - SAS programming\YanYan\Exam\Name.csv' dsd  firstobs=2;
input studentID name$ college$; run; 

data score;
infile 'H:\CSUEB\Teaching\sta6250 - SAS programming\YanYan\Exam\Score.csv' dsd  firstobs=2;
input studentID	gender$	year$	HW1-HW8	midterm_1	midterm_2	final;
run;


proc sort data=name; by studentID; run;

proc sort data=score; by studentID; run;

data both; merge name score; by studentID; run;
proc print data=both; where name='Lily';
run;
* Lily Science Female Freshman ;
data temp; set both;

Ave_HW= sum(of HW1-HW8) - smallest(1, of HW1-HW8)- smallest(2, of HW1-HW8) - smallest(3, of HW1-HW8);
Ave_HW=100*Ave_HW/5;
overall=0.3*Ave_HW+0.3*max(midterm_1, midterm_2) + 0.4*final;
r_overall=round(overall);
drop HW:;
run;

proc sort data=temp; by overall; run;
*sylvia from education has the highest overall score of 98.8; 

data grade; set temp;
grade="F";
if r_overall ge 90 then grade="A";
else if r_overall ge 75 then grade="B";
else if r_overall ge 65 then grade="C";
else if r_overall ge 55 then grade="D";
run;

Data A; set grade; if grade="A"; run; *17 student got A;
data B; set grade; if grade="B"; run; *25 student got B;

proc univariate normal plot data=temp;
var overall;
run;
*P<0.0050, the overall score is not normally distributed. Highly skewed to the left;

proc freq data=grade;
table gender*grade;
run;

data grade; set grade;
informat PASS $4.;
if grade in ('A' 'B' 'C') then PASS="YES";
else PASS="NO";
run;

data P; set grade; if PASS="YES"; run; *47 students passed;
PROC GCHART DATA=P;
	VBAR college;
RUN;


*Randomly selection;
data subset; set both;
if ranuni(1234567) le 0.3;
run;




