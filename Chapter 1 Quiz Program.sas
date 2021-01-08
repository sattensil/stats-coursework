
run; 

libname quiz1 'H:\Data\My Documents\SFO Risk\quigleym\TIME\UC Berkley\Summer 2016\Chapter 1'; 


 data glow; 
  set quiz1.glow500; 

  run; 

options ps=500; 
proc contents data=glow; 
 title 'here is glow'; 

 run; 

 **First pass; 

 proc logistic data =glow;
 class armassist(ref='0') premeno (ref='0') momfrac (ref='0') smoke (ref='0') raterisk (ref='1') /param = ref;
  model fracture (event='1') =  AGE ARMASSIST BMI FRACSCORE HEIGHT MOMFRAC 
PREMENO PRIORFRAC RATERISK SMOKE 
;

run; 

**Second pass; 

 proc logistic data =glow;
 class armassist(ref='0') premeno (ref='0') momfrac (ref='0') smoke (ref='0') raterisk (ref='1') /param = ref;
  model fracture (event='1') =  /*AGE ARMASSIST BMI FRACSCORE*/ HEIGHT MOMFRAC 
/*PREMENO*/ PRIORFRAC RATERISK /*SMOKE*/ 
;

run; 



data lbw; 
set quiz1.lbw; 

run; 


data ICU; 
 set quiz1.icu; 

 run; 
