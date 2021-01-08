
****************  Page 1114 Table 18.18 *********************;
****************  Crossover design      *********************;
*** Option 1 enter the data the traditional way *******;
data de;
do sequence=1 to 3;
	do patient =1 to 4;
		do period = 1 to 3;
			input treatment duration@@;
			output;
		end;
	end;
end;
cards;
1 1.5 2 2.2 3 3.4 1 2.0 2 2.6 3 3.1
1 1.6 2 2.7 3 3.2 1 1.1 2 2.3 3 2.9
2 2.5 3 3.5 1 1.9 2 2.8 3 3.1 1 1.5
2 2.7 3 2.9 1 2.4 2 2.4 3 2.6 1 2.3
3 3.3 1 1.9 2 2.7 3 3.1 1 1.6 2 2.5
3 3.6 1 2.3 2 2.2 3 3.0 1 2.5 2 2.0
;
run;

*** option 2, figure out a pattern. sometimes may not work depends on treatment allocation;
*The MOD function returns the remainder of the division of elements of the first argument by elements of the second argument;

data de;
do sequence=1 to 3;
	do patient =1 to 4;
		do period = 1 to 3;
		treatment= mod(sequence+period-2,3)+1;
			input  duration@@;
			output;
		end;
	end;
end;
cards;
1.5 2.2 3.4
2.0 2.6 3.1
1.6 2.7 3.2
1.1 2.3 2.9
2.5 3.5 1.9
2.8 3.1 1.5
2.7 2.9 2.4
2.4 2.6 2.3
3.3 1.9 2.7
3.1 1.6 2.5
3.6 2.3 2.2
3.0 2.5 2.0
;run;

*** option 3 *****************;
data de;
do sequence=1 to 3;
	do patient =1 to 4;
		do period = 1 to 3;
			input  duration@@;
			output;
		end;
	end;
end;
cards;
1.5 2.2 3.4
2.0 2.6 3.1
1.6 2.7 3.2
1.1 2.3 2.9
2.5 3.5 1.9
2.8 3.1 1.5
2.7 2.9 2.4
2.4 2.6 2.3
3.3 1.9 2.7
3.1 1.6 2.5
3.6 2.3 2.2
3.0 2.5 2.0
;run;

data de; set de;
if sequence=1 and period=1 then treatment="T1";
if sequence=1 and period=2 then treatment="T2";
if sequence=1 and period=3 then treatment="T3";

if sequence=2 and period=1 then treatment="T2";
if sequence=2 and period=2 then treatment="T3";
if sequence=2 and period=3 then treatment="T1";

if sequence=3 and period=1 then treatment="T3";
if sequence=3 and period=2 then treatment="T1";
if sequence=3 and period=3 then treatment="T2";
run;



proc sort; by treatment period; run;
proc means mean noprint;
var duration; by treatment period;
output out=outa mean=mdur; *mdur: mean duration;
run;


proc plot data=outa;
plot mdur*period=treatment; */hpos=60 vpos=20;
*hpos=columns: specifies the number of columns in the graphics output area, which is equivalent to the number of hardware characters that can be displayed horizontally;
run;quit;


proc glm data=de;
class sequence patient period treatment;
model duration=sequence patient(sequence) treatment period treatment*period;
test H=sequence E=patient(sequence) /htype=1 etype=1;* htype=1 etype=1;
*lsmeans treatment/pdiff CL E;
run;


proc mixed data=de;
class sequence patient period treatment;
model duration=sequence treatment| period;
random patient(sequence);
*lsmeans treatment /pdiff CL E;
run;

proc mixed data=de;
class sequence patient period treatment;
model duration=treatment period;
random patient(sequence);
*lsmeans treatment /pdiff CL E;
run;

