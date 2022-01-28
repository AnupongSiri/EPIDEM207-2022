/**Run EPIDEM207_Assignment1B.sas to get outdata_label**/
%let workdir = C:\Users\anusiri\Desktop;
libname epi207 "&workdir";

PROC CONTENTS data=epi207.outdata_label VARNUM out=epi207.datades;
RUN;

/** RUN EPIDEM207_Assignment1B.sas to get epi207.outdata_label **/
/** Setup the Table 1 macro **/
/** change this to location where you saved the .sas files**/
%let MacroDir=C:\Users\anusiri\Desktop;

filename tab1  "&MacroDir./Table1.sas";
%include tab1;

/***********************/
/****UTILITY SASJOBS****/
/***********************/
filename tab1prt  "&MacroDir./Table1Print.sas";
%include tab1prt;

filename npar1way  "&MacroDir./Npar1way.sas";
%include npar1way;

filename CheckVar  "&MacroDir./CheckVar.sas";
%include CheckVar;

filename Uni  "&MacroDir./Univariate.sas";
%include Uni;

filename Varlist  "&MacroDir./Varlist.sas";
%include Varlist;

filename Words  "&MacroDir./Words.sas";
%include Words;

filename Append  "&MacroDir./Append.sas";
%include Append;

/** specify folder in which to store results***/
%let results=C:\Users\anusiri\Desktop;

%Table1(DSName=epi207.outdata_label,
        GroupVar=ASM_Wt__Q4,
        NumVars=Age bexam_wt bexam_BMI bexam_wc bexam_BP_systolic bexam_BP_diastolic VFA_cm2 ASM_kg ASM_Wt_ chol HDL LDL TG glu GOT GPT uric_acid HbA1c insulin CRP,
        FreqVars=MS HT DM BMIgr shx_smoke_yn shx_alcohol_yn Sex,
        Mean=Y,
        Median=Y,
        Total=RC,
        P=N,
        FreqCell=N(RP),
        Missing=Y,
        Print=N,
        Label=L,
        Out=Test2,
        Out1way=)
run;

/**Create results for Table 1**/
ods excel file="&results.\Table1_KIM.xlsx";
title 'Characteristics of study participants';
%Table1Print(DSname=Test2,Space=Y)
ods pdf close;
run;

/**Create results for Figure 3 (Table A) and test**/
PROC FREQ data=epi207.outdata_label;
TABLES ASM_Wt__Q4*MS;
RUN;

PROC logistic data=epi207.outdata_label DESC;
   class ASM_Wt__Q4(ref="Q1");
   model MS=ASM_Wt__Q4/ expb clodds=wald orpvalue;
run;

/**Create results for Table 2**/
/*Crude*/
PROC logistic data=epi207.outdata_label DESC;
   class Sarco_ASM_Wt_(ref="0-No");
   model MS = Sarco_ASM_Wt_ /expb clodds=wald orpvalue;
run;

/*Model 1*/
PROC logistic data=epi207.outdata_label DESC;
   class Sarco_ASM_Wt_(ref="0-No") Sex(ref="Male");
   model MS = Sarco_ASM_Wt_ Age Sex /expb clodds=wald orpvalue;
run;

/*Model 2*/
PROC logistic data=epi207.outdata_label DESC;
   class Sarco_ASM_Wt_(ref="0-No") Sex(ref="Male") Obesity(ref="0-No") ;
   model MS = Sarco_ASM_Wt_ Age Sex Obesity /expb clodds=wald orpvalue;
run;

/*Model 3*/
PROC logistic data=epi207.outdata_label DESC;
   class Sarco_ASM_Wt_(ref="0-No") Sex(ref="Male") Obesity(ref="0-No") HT(ref="0-No") DM(ref="0-No") DysL_(ref="0-No");
   model MS = Sarco_ASM_Wt_ Age Sex Obesity HT DM DysL_/expb clodds=wald orpvalue;
run;

/*Model 4*/
PROC logistic data=epi207.outdata_label DESC;
   class Sarco_ASM_Wt_(ref="0-No") Sex(ref="Male") Obesity(ref="0-No") HT(ref="0-No") DM(ref="0-No") DysL_(ref="0-No") shx_smoke_yn(ref="0-No") shx_alcohol_yn(ref="0-No");
   model MS = Sarco_ASM_Wt_ Age Sex Obesity HT DM DysL_ shx_smoke_yn shx_alcohol_yn/expb clodds=wald orpvalue;
run;

/*Model 5*/
PROC logistic data=epi207.outdata_label DESC;
   class Sarco_ASM_Wt_(ref="0-No") Sex(ref="Male") Obesity(ref="0-No") HT(ref="0-No") DM(ref="0-No") DysL_(ref="0-No") shx_smoke_yn(ref="0-No") shx_alcohol_yn(ref="0-No");
   model MS = Sarco_ASM_Wt_ Age Sex Obesity HT DM DysL_ shx_smoke_yn shx_alcohol_yn CRP/expb clodds=wald orpvalue;
run;

/**Create results for Table 3**/
/*Viseral obesity*/
PROC sort data=epi207.outdata_label out=epi207.outdata_sorted;
   by VFA_;
run;
PROC logistic data=epi207.outdata_sorted DESC;
   by VFA_;
   class Sarco_ASM_Wt_(ref="0-No");
   model MS = Sarco_ASM_Wt_ /expb clodds=wald orpvalue;
run;

/*Obesity*/
PROC sort data=epi207.outdata_label out=epi207.outdata_sorted;
   by Obesity;
run;
PROC logistic data=epi207.outdata_sorted DESC;
   by Obesity;
   class Sarco_ASM_Wt_(ref="0-No");
   model MS = Sarco_ASM_Wt_ /expb clodds=wald orpvalue;
run;

/*Underweight*/
PROC sort data=epi207.outdata_label out=epi207.outdata_sorted;
   by Underweight;
run;
PROC logistic data=epi207.outdata_sorted DESC;
   by Underweight;
   class Sarco_ASM_Wt_(ref="0-No");
   model MS = Sarco_ASM_Wt_ /expb clodds=wald orpvalue;
run;

/*Sex*/
PROC sort data=epi207.outdata_label out=epi207.outdata_sorted;
   by Sex;
run;
PROC logistic data=epi207.outdata_sorted DESC;
   by Sex;
   class Sarco_ASM_Wt_(ref="0-No");
   model MS = Sarco_ASM_Wt_ /expb clodds=wald orpvalue;
run;

/** Create results for Figure 4 (Table B) **/
PROC FREQ data=epi207.outdata_label;
TABLES Agegroup*MS*Sarco_ASM_Wt_;
RUN;

PROC sort data=epi207.outdata_label out=epi207.outdata_sorted;
   by Agegroup;
run;
PROC logistic data=epi207.outdata_sorted DESC;
   by Agegroup;
   class Sarco_ASM_Wt_(ref="0-No");
   model MS = Sarco_ASM_Wt_ /expb clodds=wald orpvalue;
run;
/* Distribution of age group */
PROC MEANS data=epi207.outdata_sorted;
by Agegroup;
var Age;
RUN;

/** Create results for Table 4 **/
/* Recode variable */
DATA epi207.outdataMetS;
Set epi207.outdata_label;
MS45 = .;
IF (MS_5cri='4') or (MS_5cri='5') THEN MS45 = 1;
IF (MS_5cri='2') or (MS_5cri='1') or (MS_5cri='0') THEN MS45 = 0;

MS5 = .;
IF (MS_5cri='5') THEN MS5 = 1;
IF (MS_5cri='2') or (MS_5cri='1') or (MS_5cri='0') THEN MS5 = 0;
RUN; 

PROC FREQ data=epi207.outdataMetS;
TABLE MS_5cri*MS45;
RUN;

PROC FREQ data=epi207.outdataMetS;
TABLE MS_5cri*MS5;
RUN;

/* Metabolic syndrome (4 or 5 criteria) vs (<3 criteria) */
/*Crude*/
PROC logistic data=epi207.outdataMetS DESC;
   class Sarco_ASM_Wt_(ref="0-No");
   model MS45 = Sarco_ASM_Wt_ /expb clodds=wald orpvalue;
run;

/*Model 1*/
PROC logistic data=epi207.outdataMetS DESC;
   class Sarco_ASM_Wt_(ref="0-No") Sex(ref="Male");
   model MS45 = Sarco_ASM_Wt_ Age Sex /expb clodds=wald orpvalue;
run;

/*Model 2*/
PROC logistic data=epi207.outdataMetS DESC;
   class Sarco_ASM_Wt_(ref="0-No") Sex(ref="Male") Obesity(ref="0-No") ;
   model MS45 = Sarco_ASM_Wt_ Age Sex Obesity /expb clodds=wald orpvalue;
run;

/*Model 3*/
PROC logistic data=epi207.outdataMetS DESC;
   class Sarco_ASM_Wt_(ref="0-No") Sex(ref="Male") Obesity(ref="0-No") HT(ref="0-No") DM(ref="0-No") DysL_(ref="0-No");
   model MS45 = Sarco_ASM_Wt_ Age Sex Obesity HT DM DysL_/expb clodds=wald orpvalue;
run;

/*Model 4*/
PROC logistic data=epi207.outdataMetS DESC;
   class Sarco_ASM_Wt_(ref="0-No") Sex(ref="Male") Obesity(ref="0-No") HT(ref="0-No") DM(ref="0-No") DysL_(ref="0-No") shx_smoke_yn(ref="0-No") shx_alcohol_yn(ref="0-No");
   model MS45 = Sarco_ASM_Wt_ Age Sex Obesity HT DM DysL_ shx_smoke_yn shx_alcohol_yn/expb clodds=wald orpvalue;
run;

/*Model 5*/
PROC logistic data=epi207.outdataMetS DESC;
   class Sarco_ASM_Wt_(ref="0-No") Sex(ref="Male") Obesity(ref="0-No") HT(ref="0-No") DM(ref="0-No") DysL_(ref="0-No") shx_smoke_yn(ref="0-No") shx_alcohol_yn(ref="0-No");
   model MS45 = Sarco_ASM_Wt_ Age Sex Obesity HT DM DysL_ shx_smoke_yn shx_alcohol_yn CRP/expb clodds=wald orpvalue;
run;


/* Metabolic syndrome (5 criteria) vs (<3 criteria) */
/*Crude*/
PROC logistic data=epi207.outdataMetS DESC;
   class Sarco_ASM_Wt_(ref="0-No");
   model MS5 = Sarco_ASM_Wt_ /expb clodds=wald orpvalue;
run;

/*Model 1*/
PROC logistic data=epi207.outdataMetS DESC;
   class Sarco_ASM_Wt_(ref="0-No") Sex(ref="Male");
   model MS5 = Sarco_ASM_Wt_ Age Sex /expb clodds=wald orpvalue;
run;

/*Model 2*/
PROC logistic data=epi207.outdataMetS DESC;
   class Sarco_ASM_Wt_(ref="0-No") Sex(ref="Male") Obesity(ref="0-No") ;
   model MS5 = Sarco_ASM_Wt_ Age Sex Obesity /expb clodds=wald orpvalue;
run;

/*Model 3*/
PROC logistic data=epi207.outdataMetS DESC;
   class Sarco_ASM_Wt_(ref="0-No") Sex(ref="Male") Obesity(ref="0-No") HT(ref="0-No") DM(ref="0-No") DysL_(ref="0-No");
   model MS5 = Sarco_ASM_Wt_ Age Sex Obesity HT DM DysL_/expb clodds=wald orpvalue;
run;

/*Model 4*/
PROC logistic data=epi207.outdataMetS DESC;
   class Sarco_ASM_Wt_(ref="0-No") Sex(ref="Male") Obesity(ref="0-No") HT(ref="0-No") DM(ref="0-No") DysL_(ref="0-No") shx_smoke_yn(ref="0-No") shx_alcohol_yn(ref="0-No");
   model MS5 = Sarco_ASM_Wt_ Age Sex Obesity HT DM DysL_ shx_smoke_yn shx_alcohol_yn/expb clodds=wald orpvalue;
run;

/*Model 5*/
PROC logistic data=epi207.outdataMetS DESC;
   class Sarco_ASM_Wt_(ref="0-No") Sex(ref="Male") Obesity(ref="0-No") HT(ref="0-No") DM(ref="0-No") DysL_(ref="0-No") shx_smoke_yn(ref="0-No") shx_alcohol_yn(ref="0-No");
   model MS5 = Sarco_ASM_Wt_ Age Sex Obesity HT DM DysL_ shx_smoke_yn shx_alcohol_yn CRP/expb clodds=wald orpvalue;
run;

/** Create results for Table 5 **/
/*Crude*/
PROC logistic data=epi207.outdata_label DESC;
   class ASM_Wt__Q4 (ref="Q1");
   model MS = ASM_Wt__Q4 /expb clodds=wald orpvalue;
run;
PROC logistic data=epi207.outdata_label DESC;
   model MS = ASM_Wt__Q4 /expb clodds=wald orpvalue;
run;

/*Model 1*/
PROC logistic data=epi207.outdata_label DESC;
   class ASM_Wt__Q4 (ref="Q1") Sex(ref="Male");
   model MS = ASM_Wt__Q4 Age Sex /expb clodds=wald orpvalue;
run;
PROC logistic data=epi207.outdata_label DESC;
   class Sex(ref="Male");
   model MS = ASM_Wt__Q4 Age Sex /expb clodds=wald orpvalue;
run;

/*Model 2*/
PROC logistic data=epi207.outdata_label DESC;
   class ASM_Wt__Q4 (ref="Q1") Sex(ref="Male") Obesity(ref="0-No") ;
   model MS = ASM_Wt__Q4 Age Sex Obesity /expb clodds=wald orpvalue;
run;
PROC logistic data=epi207.outdata_label DESC;
   class Sex(ref="Male") Obesity(ref="0-No") ;
   model MS = ASM_Wt__Q4 Age Sex Obesity /expb clodds=wald orpvalue;
run;

/*Model 3*/
PROC logistic data=epi207.outdata_label DESC;
   class ASM_Wt__Q4 (ref="Q1") Sex(ref="Male") Obesity(ref="0-No") HT(ref="0-No") DM(ref="0-No") DysL_(ref="0-No");
   model MS = ASM_Wt__Q4 Age Sex Obesity HT DM DysL_/expb clodds=wald orpvalue;
run;
PROC logistic data=epi207.outdata_label DESC;
   class Sex(ref="Male") Obesity(ref="0-No") HT(ref="0-No") DM(ref="0-No") DysL_(ref="0-No");
   model MS = ASM_Wt__Q4 Age Sex Obesity HT DM DysL_/expb clodds=wald orpvalue;
run;

/*Model 4*/
PROC logistic data=epi207.outdata_label DESC;
   class ASM_Wt__Q4 (ref="Q1") Sex(ref="Male") Obesity(ref="0-No") HT(ref="0-No") DM(ref="0-No") DysL_(ref="0-No") shx_smoke_yn(ref="0-No") shx_alcohol_yn(ref="0-No");
   model MS = ASM_Wt__Q4 Age Sex Obesity HT DM DysL_ shx_smoke_yn shx_alcohol_yn/expb clodds=wald orpvalue;
run;
PROC logistic data=epi207.outdata_label DESC;
   class Sex(ref="Male") Obesity(ref="0-No") HT(ref="0-No") DM(ref="0-No") DysL_(ref="0-No") shx_smoke_yn(ref="0-No") shx_alcohol_yn(ref="0-No");
   model MS = ASM_Wt__Q4 Age Sex Obesity HT DM DysL_ shx_smoke_yn shx_alcohol_yn/expb clodds=wald orpvalue;
run;

/*Model 5*/
PROC logistic data=epi207.outdata_label DESC;
   class ASM_Wt__Q4 (ref="Q1") Sex(ref="Male") Obesity(ref="0-No") HT(ref="0-No") DM(ref="0-No") DysL_(ref="0-No") shx_smoke_yn(ref="0-No") shx_alcohol_yn(ref="0-No");
   model MS = ASM_Wt__Q4 Age Sex Obesity HT DM DysL_ shx_smoke_yn shx_alcohol_yn CRP/expb clodds=wald orpvalue;
run;
PROC logistic data=epi207.outdata_label DESC;
   class Sex(ref="Male") Obesity(ref="0-No") HT(ref="0-No") DM(ref="0-No") DysL_(ref="0-No") shx_smoke_yn(ref="0-No") shx_alcohol_yn(ref="0-No");
   model MS = ASM_Wt__Q4 Age Sex Obesity HT DM DysL_ shx_smoke_yn shx_alcohol_yn CRP/expb clodds=wald orpvalue;
run;
