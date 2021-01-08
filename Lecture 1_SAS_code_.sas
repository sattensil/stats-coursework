Data one;
input Student	Control	Piano	Computer	Instructor;
cards;
1	-3.4	-0.2	7.7	12.0
2	-2.8	5.2	5.5	4.1
3	2.2	6.6	-0.8	5.9
4	-0.8	5.2	7.4	13.5
5	2.8	-0.6	0.1	7.5
6	-5.9	5.4	11.7	9.3
7	7.8	3.1	1.2	7.1
8	-3.5	6.5	3.8	-0.9
9	2.9	2.4	5.1	8.3
10	1.9	6.2	4.3	9.8
11	-0.2	7.9	3.9	11.1
12	1.5	7.9	6.9	4.9
13	0.4	6.6	2.8	5.8
14	-0.5	0.2	5.4	2.8
15	1.1	1.9	2.5	12.0
16	5.3	1.3	5.2	8.6
17	-4.0	1.8	3.1	2.0
18	-1.3	3.1	6.6	5.9
19	2.6	1.4	0.2	5.6
20	-0.9	2.1	7.1	11.6
21	-0.6	6.6	9.2	7.8
22	-5.0	7.0	3.0	7.2
23	2.4	-0.7	2.3	8.3
24	-0.1	4.1	10.2	6.5
25	-4.7	3.8	4.7	8.3
;
run;

Data two; set one;
method="Control"; Y=Control; output;
method="Piano"; Y=Piano; output;
method="Computer"; Y=Computer; output;
method="Instructor"; Y=Instructor; output;
keep Y method;
run;

*Run One Way ANOVA;
proc glm data=two;
class method;
model Y=method;
*means method / LSD tukey; 
*means method/ hovtest=levene; 
output out=resids r=res;
run;
quit;

* Test normality assumption;
proc univariate normal plot data=resids;
var res;
run;


