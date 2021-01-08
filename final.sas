
**#1; 

libname log_data 'C:\temp\Stats\Summer 2016\Summer 2016\log_data'; 
libname hazard 'C:\temp\Stats\Summer 2016\Summer 2016\For students\Hazard Model\Hazard Model\overview'; 
libname eyes 'C:\temp\Stats\Summer 2016\Summer 2016\For students\Logistic\Chapter 1\ICU Myopia data'; 
libname data 'C:\temp\Stats\Summer 2016\Summer 2016\Data'; 
libname chap3 'C:\temp\Stats\Summer 2016\Summer 2016\Chapter 3'; 


run; 


 data data.burns1000; 
  set burns_excel; 

  run; 
  


 data burns; 
  set data.burns1000; 

  proc contents data=burns; 
  title 'here is burns'; 

  run; 
  proc format; 
   value race
   0 = 'Non-White'
   1 = 'White'
   ; 

   run; 

   title '0=Non-White 1=White'; 
  proc sql; 
   select 
   racec, 
   mean(tbsa) as tbsa_mean,
   mean(age) as age_mean,
   sum(inh_inj) as num_inh_inj, 
   sum(flame) as num_flame
   from burns
   group by racec
   ; 
   quit; 


   *** Exercise 2; 

  data heart_attack; 
   set hazard.whas500; 

   run; 

   proc contents data=heart_attack; 
    
   run; 

 proc sql; 
 select  
 a.age as age, 
 a.hr  as hr, 
 a.bmi as bmi,
 a.bmi/a.age as bmi_age_ratio,
 calculated bmi_age_ratio/2 as bmi_age_ratio_half
 from heart_attack a
 ; 
 quit; 

 run; 

 

**Exericse #3; 

  data eyes; 
  set eyes.myopia; 

run;  

proc print data=burns; 
 title 'here is burns'; 

 run; 
 
  
 ** Part a: Inner Join; 

 proc sql; 
  create table inner_join as
  select a.*, 
         b.*
  from burns  a, 
       eyes   b
  where a.id = b.id
  ; 
  quit; 

  run; 

** Part b: full outer join; 

  proc sql; 
  create table full_outer_join as
  select a.*, 
         b.*
  from burns  a 
  full join 
       eyes   b
  on a.id = b.id
  ; 
  quit; 

  run; 


  run; 

** Part c: Left outer join; 

  proc sql; 
  create table left_outer_join as
  select a.*, 
         b.*
  from burns  a 
  left join 
       eyes   b
  on a.id = b.id
  ; 
  quit; 

  run; 


** Part d: Right outer join; 


  proc sql; 
  create table right_outer_join as
  select a.*, 
         b.*
  from burns  a 
  right join 
       eyes   b
  on a.id = b.id
  ; 
  quit; 

  run; 

  **Exericse #4; 

  proc means  data=heart_attack; 
   var bmi; 
    output out=stats p20=p20_bmi p80=p80_bmi; 

	run; 

	data _null_; 
	 set stats; 
	  call symput('p20_bmi',p20_bmi); 
      call symput('p80_bmi',p80_bmi); 

	  run; 

	  proc print data=stats; 
	   title "p20_bmi =&p20_bmi p80_bmi = &p80_bmi"; 

	   run; 

options mprint symbolgen;

  proc sql; 
   create table heart_attack_stats as 
    select a.*,
	case 
    when a.bmi < &p20_bmi then "Low"
	when a.bmi > &p20_bmi then "high"
	else "Normal"
	end as bmi_char
	from heart_attack a 
	; 
	quit; 

run;   

** Exercise 5; 

proc contents data=burns; 
 title 'here is burns'; 

 run; 

 options mprint symbolgen; 
%macro burns_reg(data=,covariate=); 

proc logistic data=&data covout outest=coeff;  
model death(event='1') = &covariate; 
output out=stats  p=pred l=lower u=upper;         
title "Logistic Regression Results  &data data";   


%mend burns_reg; 

run; 
%burns_reg(data=burns,covariate=age); 
%burns_reg(data=burns,covariate=tbsa); 


run; 

** Exercise 6; 

  data icu; 
   set chap3.icu; 
   one = 1; 

   run; 

   proc contents data=icu; 
    title 'icu'; 

	run; 

proc sql; 
 select 
 mean(a.age) as mean_age, 
 mean(a.hra) as mean_hra, 
 sum(a.crn) as sum_crn, 
 sum(a.one) as sum_one,
 calculated sum_crn/ calculated sum_one  as per_renal 
  into :mean_age, 
       :mean_hra,
       :sum_crn,
       :sum_one,
	   :per_renal 
from icu a
 ; 
 quit; 


 ** Exercise 7; 

  options mprint symbolgen; 

%macro burns_regq(num=,data=,covariate=); 

%if (&num=1) %then %do; 

proc logistic data=&data outest=coeff;  
model death(event='1') = &covariate; 
output out=stats  p=pred l=lower u=upper;         
title "Logistic Regression Results  &data data";   

  data coeff_final; 
    set coeff; 
	name = "&covariate"; 
	num=&num; 
	var = &covariate; 
	keep name num var; 

%end; 
%else %do; 

proc logistic data=&data outest=coeff;  
model death(event='1') = &covariate; 
output out=stats  p=pred l=lower u=upper;         
title "Logistic Regression Results  &data data";   

 data temp; 
  set coeff; 
  name = "&covariate"; 
  num=&num; 
  var = &covariate; 
  keep name num var; 

  data coeff_final; 
   set coeff_final temp; 

%end;

%mend burns_regq; 

run; 
%burns_regq(num=1,data=burns,covariate=age); 
run; 
%burns_regq(num=2,data=burns,covariate=tbsa); 
run; 

proc print data=coeff_final; 
 title 'coeff_final'; 
 
 run;


  ** Exercise 8; 

     data big_data;                                                                                                                                             
    **do i=1 to 10000000;     
     do i= 1 to 1000000;  
                                                                                                                                                               
      death = 0; 
      smoke  = 0;
      drug = 0;  
      exercise = 1;
      random = ranuni(11);
     **put 'random = ' random; 
       if random <= .1 then do;
          death = 1;
       end; 
       if (random <= .07 ) then do; 
          smoke = 1; 
       end;
       if (random <= .075) then do;
          drug = 1; 
       end;
       if (random <= .05 ) then do; 
          exercise = 0; 
       end;
                                                                                                                                                               
      random2 = ranuni(19);
       if random2 < .15 then smoke = 1;  
       if random2 < .25 then drug = 1;   
       if random2 > .75 then exercise =0;
                                         
       weight = round(200 - ranuni(7)*10);
       weight = max(weight, 100);         
       height = round(72 - ranuni(5)*10); 
     id = i;  
 output;      
   end; 

run; 

**Part a: Logistic on Entire Reults; 


 proc logistic data = big_data;
  class exercise(ref='0') smoke(ref='0') drug(ref='0')/param=ref;
  model death(event='1')  = smoke drug exercise weight height;
 title 'big data logistic regression';

run;

** Part b: Logistic on first 10,000; 

 data first_twenty; 
  set big_data; 
   if _n_ <= 20000; 

   proc freq data=first_ten; 
    table death smoke drug exercise /*weight height*/ / missing; 
	title 'first_twenty'; 

	run; 

   proc logistic data = first_ten;
  class exercise(ref='0') smoke(ref='0') drug(ref='0')/param=ref;
  model death(event='1')  = smoke drug exercise weight height;
 title 'big data logistic regression First twenty';
 title2 'results are different'; 

run;

** part c;

    proc sort data=big_data; 
    by death smoke drug exercise; 

proc surveyselect data=big_data
       method=srs     n=20000      out=big_data_survey;
   strata death smoke drug exercise / alloc=prop;

run;

   proc logistic data = big_data_survey;
  class exercise(ref='0') smoke(ref='0') drug(ref='0')/param=ref;
  model death(event='1')  = smoke drug exercise weight height;
 title 'big data logistic regression Survey Select';
 title2 'results are Similiar'; 


run;

  ** Exercise 9; 

  data flights; 
   set data.marchflights; 

   run; 

   proc contents data=flights; 
    title 'here is flights'; 

	run;

 ** Part a:  Sorting by observation;

 proc sort data=flights (firstobs=1 obs=199) out=one;
 by flightnumber;

proc sort data=flights (firstobs=200 obs=299) out=two;
 by flightnumber;

 proc sort data=flights (firstobs=300 obs=635) out=three;
 by flightnumber;


 data flights_sorted;
  set one two three;
   by flightnumber;
   

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
