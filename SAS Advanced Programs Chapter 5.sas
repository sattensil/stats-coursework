
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
libname chap5  'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 5'; 
libname sasusers 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Data';

run; 

proc contents data=sasusers.payrollmaster; 


run;

**libname chap1 'C:\UC Berkley\Summer 2016\Chapter 1';
**libname chap2 'C:\UC Berkley\Summer 2016\Chapter 2';
**libname chap3 'C:\UC Berkley\Summer 2016\Chapter 3';
**libname chap4 'C:\UC Berkley\Summer 2016\Chapter 4';
**libname chap5 'C:\UC Berkley\Summer 2016\Chapter 5';
**libname sasuser 'C:\UC Berkley\Summer 2016\Data';

run;






run;

**Step 1: Define data;

run;

  %macro skipit;


 data chap3.icu;
  set icu;

  data chap3.burns;
   set burns;

  run;

data chap5.glow500;
 set glow500;

run;



  %mend skipit;



** Step 2: Create tables;

** Step 2a: Create an table with no observations

**First we need to know the formats being used;

proc contents data=chap5.glow500;
title 'here is glow500';

run;

proc sql;
 create table work.fracture
(fracture num,
 name  char(7),
 fracture_date num format=date9.
)
;
quit;

run;


** Step 2b: Create table like the glow table but it will not have any observations;

proc sql;
 create table work.glow_like
like chap5.glow500
;
quit;

run;


** Step 2c: pull dataq in from other tables to create a new table;


proc sql feedback;
 create table work.glow_burns_sub as
select a.sub_id,
       a.fracture,
       a.age,
       a.bmi,
       b.death,
       b.tbsa
from
  chap5.glow500 a,
  chap3.burns   b
where a.sub_id = b.id
;
quit;

run;


**Step 3: Createing a table with different types of data elements;


%macro skipit;

NUMERIC (or NUM) floating-point NUMERIC
DECIMAL (or DEC) floating-point NUMERIC
FLOAT floating-point NUMERIC
REAL floating-point NUMERIC
DOUBLE PRECISION floating-point NUMERIC
INTEGER (or INT) integer NUMERIC
SMALLINT integer NUMERIC
DATE date NUMERIC with a DATE.7
informat and format

I only use char, varchar num and date format;

%mend skipit;


**Step 3a: typical created table;

proc sql;
 create table work.fracture
(fracture num,
 name  char(7),
 name_var varchar(7),
 fracture_date num format=date9.
)
;
quit;

run;



**Step 3b: Modeify the varibles you are creating;

proc sql;
 create table work.column_modify
(Dept varchar(20) label="Department",
Code integer label="Dept Code",
Manager varchar(20),
AuditDate num format=date9.)
;
quit;

run;



** Step 4: Describing a Table;


proc sql;
describe table chap5.glow500
;

run;


** Step 5: Ccreat a table like another table;

**Step 5a: Redo the creating of like tables that we did before;

proc sql;
 create table work.glow_like
like chap5.glow500
;
quit;

run;



**Step 5b: just keep the fileds you want;


      proc sql;
 create table work.glow_like
(keep= SUB_ID      SITE_ID      PHY_ID      PRIORFRAC      AGE      WEIGHT      HEIGHT)
like chap5.glow500
;
quit;

run;

**Step 5c: just drom some of the fields you want;


      proc sql;
 create table work.glow_like
(drop = BMI      PREMENO      MOMFRAC      ARMASSIST      SMOKE      RATERISK      FRACSCORE      FRACTURE)
like chap5.glow500
;
quit;

run;


** Step 6: Create a table from a query;
**         this one we have done many time;


**Step 6a: Create a table from two other tables as we did before;


proc sql feedback;
 create table work.glow_burns_sub as
select a.sub_id,
       a.fracture,
       a.age,
       a.bmi,
       b.death,
       b.tbsa
from
  chap5.glow500 a,
  chap3.burns   b
where a.sub_id = b.id
;
quit;

run;


**Step 6b: Copy a full table;

proc sql feedback;
 create table work.copy_glow_burns_sub as
select *
from  glow_burns_sub
;
quit;


** Step 7: Inserting Rows into created tables;

**Step 7a: Insererting rows using the set function; 

**First we need to create a table; 

proc datasets libname = work; 
 delete column_modify; 

 run; 

proc sql;
 create table work.column_modify
(Dept varchar(20) label="Department",
Code integer label="Dept Code",
Manager varchar(20),
AuditDate num format=date9.)
;
quit;

**Step 7b: insert rows using set statement; 

proc sql; 
 insert into work.column_modify
 set dept='Production', 
     code = 325,
	 manager = 'Ted Bundy',
	 auditdate = '01JAN2016'd
set dept='Human Resources', 
     code = 326,
	 manager = 'Joseph Stalin',
	 auditdate = '07JAN2016'd
; 
select * 
 from column_modify
 ; 
 quit; 

 run; 

**Step 7c: we insert rows using value statement; 

 **Assume you want to insert values into all the columns; 
 ** THen use the results below; 

proc sql; 
 insert into work.column_modify
 (dept,code,manager, auditdate)
 values ('Production', 325,'FDR','01JAN2016'd)
 values ('Human Resources', 326,'Joeseph Stalin','16JAN2016'd)
; 
select * 
 from column_modify
 ; 
 quit; 

 run; 

 **Stpe 7d: Most common way is to pull data in from existing tables; 
 ** Lets assume you update your burn table to include those who had a fracture; 
 ** you could do the following; 

 **First we create two sets of data ; 

 data anchor; 
   set chap3.burns; 
   if _n_ <= 100; 


data addition; 
 set chap3.burns; 
  if _n_ > 100; 

   run; 

proc contents data=addition; 
 title 'addition'; 

 run; 

**Now we insert those with tbsa > 60% from addition into anchor; 
** Notice first one did not work because or order of select; 
 
  proc sql feedback;
 insert into anchor  
 select  AGE,	DEATH,	FACILITY,	FLAME,	GENDER,	ID,	INH_INJ,	RACEC,	TBSA
 from addition 
 where tbsa > 60; 
 select * 
 from anchor
 ; 
 quit; 

run; 

**This way works because the order the insertion is the same as the order of the variables; 

  proc sql feedback;
 insert into anchor  
 select  ID,	FACILITY,	DEATH,	AGE,	GENDER,	RACEC,	TBSA,	INH_INJ,	FLAME
 from addition 
 where tbsa > 60; 
 select * 
 from anchor
 ; 
 quit; 


 **Step 8: Putting in integrity checks as part of the insert statements; 
 **        This is part of the data creation step; 

**Step 8a: We create the data set employees with the constrains; 

 proc sql;
create table work.employees
(ID char (5) primary key,
Name char(10),
Gender char(1) not null check(gender in ("M","F")),
HDate date label="Hire Date");
quit; 

run; 


**Step 8b: We insert fields into the data set; 
**         We start with fields that meet the requirements; 

proc sql; 
 insert into work.employees
 (id, name, gender, hdate)
 values ('23456', 'Michael Quigley','M','01JAN2016'd)
 values ('23344', 'Dolly Parton','F','07JAN2016'd)
 ; 
select * 
 from work.employees
 ; 
 quit; 

run; 

**Now we insert some fields that do not meet integrity constraints; 
** Notice you cannot add them in; 

proc sql; 
 insert into work.employees
 (id, name, gender, hdate)
 values ('23666', 'Alex Travelge','O','02JAN2016'd)
 values ('23355', 'Cate Blancard','T','09JAN2016'd)
 ; 
select * 
 from work.employees
 ; 
 quit; 

run; 

**Step 8c: We can also create integrity constraints; 
**         seperately. So first you create the variables; 
**         then you create the constraints; 
**         Sometimes easier to see constraints; 

 proc sql;
create table work.employees2
(ID char (5) primary key,
Name char(10),
Gender char(1), 
HDate date label="Hire Date",
constraint gender_mf check (gender in ("M","F")),
constraint gender_nonmiss not null(gender));
quit; 

run; 

 **Step 9: Using the Undo_Policy Control; 

**Step 9a: Use required which is the default; 

**First we create the data set; 

proc datasets libname = work; 
 delete employees; 

 run; 

 proc sql;
create table work.employees
(ID char (5) primary key,
Name char(10),
Gender char(1) not null check(gender in ("M","F")),
HDate date label="Hire Date");
quit; 

run; 

** Now we put in data that does not meet the constraint with the Undo_Policy as required; 
** Because some of the fields are bad not table is created; 


proc sql undo_policy=required; 
 insert into work.employees
 (id, name, gender, hdate)
values ('23444', 'Michael Quigley','M','03JAN2016'd)
values ('23666', 'Alex Travelge','O','02JAN2016'd)
 values ('23355', 'Cate Blancard','T','09JAN2016'd)
 ; 
select * 
 from work.employees
 ; 
 quit; 

**Step 9b: Now we put in the None which will not put in results no matter what; 
** One of the rows gets put in that is okay; 

proc datasets libname = work; 
 delete employees; 

proc sql;
create table work.employees
(ID char (5) primary key,
Name char(10),
Gender char(1) not null check(gender in ("M","F")),
HDate date label="Hire Date");
quit; 

run; 

 run; 

 proc sql undo_policy=none; 
 insert into work.employees
 (id, name, gender, hdate)
 values ('23444', 'Michael Quigley','M','03JAN2016'd)
 values ('23666', 'Alex Travelge','O','02JAN2016'd)
 values ('23355', 'Cate Blancard','T','09JAN2016'd)
 ; 
select * 
 from work.employees
 ; 
 quit; 


 **Step 9c: Now we put in the Optional which will put in if possible; 
** One of the rows gets put in; 

proc datasets libname = work; 
 delete employees; 

proc sql;
create table work.employees
(ID char (5) primary key,
Name char(10),
Gender char(1) not null check(gender in ("M","F")),
HDate date label="Hire Date");
quit; 

run; 

 proc sql undo_policy=optional; 
 insert into work.employees
 (id, name, gender, hdate)
 values ('23444', 'Michael Quigley','M','03JAN2016'd)
 values ('23666', 'Alex Travelge','O','02JAN2016'd)
 values ('23355', 'Cate Blancard','T','09JAN2016'd)
 ; 
select * 
 from work.employees
 ; 
 quit; 


 **Step 10: Describe table constraints; 

proc sql ; 
 describe table constraints work.employees
 ; 
 quit; 

 run; 

 **Step 11: Updating Values in Existing Tables; 

 **Step 11a: Make a data set you can use to update; 

data payrollmaster_new; 
 set sasusers.payrollmaster;

 run; 

 **Step 11b: Update salary for those in first tier; 

 proc sql;
update work.payrollmaster_new
set salary=salary*1.05
where jobcode like "__1";
quit; 

proc datasets libname=work; 
delete payrollmaster_new;

run; 

data payrollmaster_new; 
 set sasusers.payrollmaster;

 run; 

**Step 11c: update salary across the board; 

proc sql;
update work.payrollmaster_new
set salary=salary*
case when substr(jobcode,3,1)="1"
then 1.05
when substr(jobcode,3,1)="2"
then 1.10
when substr(jobcode,3,1)="3"
then 1.15
else 1.08
end;
quit; 

**Step 11d: Update the values using case statement; 

data insure_new; 
 set sasusers.insure; 

 run; 


proc sql; 
update work.insure_new
set pctinsured=pctinsured*
case
when company="ACME"
then 1.10
when company="RELIABLE"
then 1.15
when company="HOMELIFE"
then 1.25
else 1
end;
quit; 


**Step 12: More Detail on the case statement; 
** Some focus on Case Operand; 

**Step 12a: Here is what we had before; 

data payrollmaster_new2; 
  set sasusers.payrollmaster; 

  run; 

proc sql;
update work.payrollmaster_new2
set salary=salary*
case
when substr(jobcode,3,1)="1"
then 1.05
when substr(jobcode,3,1)="2"
then 1.10
when substr(jobcode,3,1)="3"
then 1.15
else 1.08
end;
quit; 

run; 

**Step 12b: Now we use the Case Operand to make it more efficent; 
**          THe substring function runs only once; 

data payrollmaster_new3; 
  set sasusers.payrollmaster; 

  run; 

proc sql;
update work.payrollmaster_new3
set salary=salary*
case substr(jobcode,3,1)
when "1"
then 1.05
when "2"
then 1.10
when "3"
then 1.15
else 1.08
end;
quit; 

run; 

**Step 12c: Using case statement in the select framework; 
** Note you are defining a new variable job level; 


proc sql outobs=10;
select lastname, firstname, jobcode,
case substr(jobcode,3,1)
when "1"
then "junior"
when "2"
then "intermediate"
when "3"
then "senior"
else "none"
end as JobLevel
from sasusers.payrollmaster,
sasusers.staffmaster
where staffmaster.empid=
payrollmaster.empid;
quit; 


**Step 13: Altering tables; 

**Step 13a: First fine your data set; 

  data burn3; 
   set chap3.burns; 

   run; 

   **Step 13b: Next delete some rows; 
 proc sql;
 delete from work.burn3
where tbsa <= 60;
quit;

run; 


**Step 13c: We can delete some columns using alter; 

  data burn3; 
   set chap3.burns; 

 proc sql;
 alter table work.burn3
drop  tbsa,  death; 
quit;

run; 


**Step 13d: Add columns with alter; 

  data burn3; 
   set chap3.burns; 

proc sql;
alter table work.burn3
add  tbsa_pct num format=comma10.2
; 
quit; 

run; 

**Step 13e: Add columns without alter; 

  data burn3; 
   set chap3.burns; 

proc sql;
select a.*, 
(a.tbsa/100) as tbsa_pct
from work.burn3 a 
; 
quit; 


**Step 14:modifying variables in table;

data payrollmaster4; 
 set sasusers.payrollmaster; 

proc sql;
alter table work.payrollmaster4
modify salary format=dollar11.2 label="Salary Amt";
quit; 

run; 


**Step 15 adding, dropping and modifying columns; 

data payrollmaster4; 
 set sasusers.payrollmaster; 

proc sql;
alter table work.payrollmaster4
add Age num
modify dateofhire date format=mmddyy10.
drop dateofbirth, gender;
quit; 


**Step 16: Drop tables like proc datasets; 

proc sql; 
 drop table work.payrollmaster4; 
 quit; 

 run; 

