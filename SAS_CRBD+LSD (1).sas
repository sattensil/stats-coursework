*CRBD design;
Data one;
Input pair before after;
datalines;
1	2.37	2.51
2	3.17	2.65
3	3.07	2.6
4	2.73	2.4
5	3.49	2.31
6	4.35	2.28
7	3.65	0.94
8	3.97	2.21
9	3.21	3.29
10	4.46	1.92
11	3.81	3.38
12	4.55	2.43
13	4.51	1.83
14	3.03	2.63
15	4.47	2.31
16	3.44	1.85
17	3.52	2.92
18	3.05	2.26
19	3.66	3.11
20	3.81	1.9
21	3.13	2.5
22	3.43	3.18
23	3.26	3.24
24	2.85	2.16
Run;
 
/*changing from unstacked data to stacked*/
data two; set one;
length treatment $10;
treatment="before"; outcome=before;output;
treatment="after"; outcome=after; output;
keep pair treatment outcome;
run;

/*Model fitting CRBD, pair is the block */;
Proc glm data=two;
Class treatment pair;
Model outcome=treatment pair;
*means treatment / hovtest=levene; 
/* Performs the Levene test for the factor A */
*output out=resids r=res;
Run;
Quit;

/* what is the equivalent test here? - paired t-test 
it runs on the unstacked data, does the result match? */
proc ttest data=one;
paired before*after;
run;

/*pair t-test is one sample t-test on the difference, test the claim*/
/* what is the assumption of using t- test? the difference is normall distributed*/
data one; set one;
difference=before-after;
run;

proc ttest data=one;
var difference;
run; 

proc univariate normal plot data=one;
/* Tells SAS to run tests of normality and give a QQ-plot */
var difference;
run;
 
/*Friedman's test for CRBD */

/* To calculate the ranks within blocks (pairs): */
PROC SORT DATA=two; by pair;
PROC RANK DATA=two OUT=tworanks;
BY pair; VAR outcome;
run;

/* In SAS, the Friedman test can be done with PROC FREQ; */
/* The CMH2 SCORES=RANK option gives the Friedman test.  */
/* The test statistic and P-value are given in the */
/* "Row Mean Scores Differ" row of the output.     */
/* Ask student, when nonparametric, are we testing on the mean or median? */

proc freq data=two;
tables pair*treatment*outcome / cmh2 scores=RANK noprint;
run;


*LSD design;
Data lone;
Input Driver	Model	Blend$	MPG;
datalines;
1	1	A	15.5
2	1	B	16.3
3	1	C	10.5
4	1	D	14
1	2	B	33.8
2	2	C	26.4
3	2	D	31.5
4	2	A	34.5
1	3	C	13.7
2	3	D	19.1
3	3	A	17.5
4	3	B	19.7
1	4	D	29.2
2	4	A	22.5
3	4	B	30.1
4	4	C	21.6
;
run;
Proc glm data=lone;
Class Driver	Model	Blend;
Model MPG=Driver	Model	Blend;
output out=resids r=res;
Run;
Quit;

proc univariate normal plot;
/* Tells SAS to run tests of normality and give a QQ-plot */
var res;
run;

/*HOVTEST=BARTLETT -  specifies Bartlett’s test, 1937/likelihood ratio test || one way ANOVA only*/
Proc glm data=lone;
Class Blend;
Model MPG=Blend;
means Blend/ hovtest=levene; 
output out=resids r=res;
Run;
Quit;
