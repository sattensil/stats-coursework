Data Oyster;
Input Trt$ Rep Initial Final;
length Trt$8;
Cards;
1 1 27.2 32.6
1 2 32.0 36.6
1 3 33.0 37.7
1 4 26.8 31.0
2 1 28.6 33.8
2 2 26.8 31.7
2 3 26.5 30.7
2 4 26.8 30.4
3 1 28.6 35.2
3 2 22.4 29.1
3 3 23.2 28.9
3 4 24.4 30.2
4 1 29.3 35.0
4 2 21.8 27.0
4 3 30.3 36.4
4 4 24.3 30.5
5 1 20.4 24.6
5 2 19.6 23.4
5 3 25.1 30.3
5 4 18.1 21.8
;
run;

proc plot data=Oyster;
plot final * initial=Trt;
run;
quit;

*ANCOVA model *;
proc glm data=Oyster;
class Trt;
model final= initial Trt ;
run;

*Regression Model*;
proc glm data=Oyster;
model final=initial ;
run;


*Adjusted means can be calculated in SAS via the LSMEANS (least-squares means) statement;
proc glm data=Oyster;
class Trt;
model final=Trt initial;
LSMeans Trt / StdErr Pdiff CL Adjust = Tukey;
*generats the estimated least-squares means followed by their standard errors;
*p-values for all pairwise tests of treatment differences (Pdiff option);
*according to the Tukey method of means separations (Adjust = Tukey option);
ODS output LSMeanCL=adj;
*output out=adj p=predict r=resid;
run;
quit;

proc means data=Oyster;
var final; by Trt;
output out=obs mean=Obs_mean;
run;

data one; merge adj obs;
by Trt; keep Trt LSMean obs_mean;
run;

*Answer to e: to obtain coefficient, add the solution option to the Model statement;
proc glm data=Oyster;
class Trt;
model final=Trt initial/solution;
run;

Proc GLM Order = Data data=Oyster;
Class Trt;
Model Final = Trt Initial;
LSMeans Trt;
Contrast 'Control vs. Treatment' TRT -1 -1 -1 -1 4;
Contrast 'Bottom vs. Top' TRT -1 1 -1 1 0;
Contrast 'Cool vs. Hot' TRT -1 -1 1 1 0;
Contrast 'Interaction Depth*Temp' TRT 1 -1 -1 1 0;
run;

*g). Test for heterogeneity of slopes, type III SS;
Proc GLM;
Title 'Test for homogeneity of slopes';
Class Trt;
Model Final = Trt Initial Trt*Initial;
run;

* h). Check for the model assumption;
proc glm data=Oyster;
class Trt;
model final=Trt initial;
output out=OysterM p=predict r=resid;
run;
quit;
Proc Univariate Data = OysterM normal;
Var resid; run;

* ). Homogeneity of variances
* Levene's Test is only defined for one-way ANOVAs. To test for homogeneity
of variances in an ANCOVA, one needs to adjust the response variable according to its regression on X and perform a Levene's Test on the adjusted variable;

data Oyster_adj; set Oyster;
final_adj = Final - 1.083179819*(Initial-25.76);run;

Proc GLM data=Oyster_adj;
Title 'Homogeneity of variances';
Class Trt;
Model final_adj = Trt;
Means Trt / hovtest = Levene; run; quit;

