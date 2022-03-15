%let workdir = C:\Users\anusiri\Desktop;
libname epi207 "&workdir";

/* Load data */
proc import datafile="C:\Users\anusiri\Desktop\pone.0248856.s001.xlsx" dbms=xlsx out=epi207.data replace;
run;

proc contents data=epi207.data varnum;
run;

/*Setup data*/
/*Filter age 25-60 years and select needed varibles*/
DATA epi207.outdata;
	SET epi207.data;
	where 25<=age & age <=60;
	KEEP ID 
		 Sex 
		 Age 
		 HT 
		 DM 
		 DysL_ 
		 bexam_wc 
		 bexam_BMI 
		 ASM_Wt_
		 shx_smoke_yn
		 shx_alcohol_yn
		 mhx_HT_yn
		 bexam_BP_diastolic
		 bexam_BP_systolic;
RUN;

/*n=10759*/
PROC CONTENTS data=epi207.outdata VARNUM;
RUN;

/*Format data set*/
OPTIONS FMTSEARCH = (epi207);

PROC FORMAT LIBRARY = epi207;
	value Sex 	1='Male'
				2='Female';
	value YN	0='No'
				1='Yes';
	value BMIgr low-<18.5 = '0'
				18.5-22.9 = '1'
				23-24.9	  = '2'
				25-high   = '3';
	value BMItx 0 = 'Under weight (BMI <18.5 kg/m^2)'
				1 = 'Normal (BMI 18.5-22.9 kg/m^2)'
				2 = 'Overweight (BMI 23-24.9 kg/m^2)'
				3 = 'Obesity (BMI >=25 kg/m^2)';
RUN;	

DATA epi207.outdata2;
	set epi207.outdata;
	BMIgr = put(bexam_BMI, BMIgr.);
	BMIgr2 = input(BMIgr,8.);
	MAP= bexam_BP_diastolic + (1/3 * (bexam_BP_systolic - bexam_BP_diastolic));
	ASM_Wt_10 = ASM_Wt_/10;
	MAP_10 = MAP/10;
	drop BMIgr;
RUN;

PROC CONTENTS data=epi207.outdata2 VARNUM;
RUN;

DATA epi207.outdata_label;
SET epi207.outdata2(rename=(BMIgr2=BMIgr));

Label	ID 					= "ID"
		Sex 				= "Sex (1=Male, 2=Female)"
		Age  				= "Age (years)"
		mhx_HT_yn			= "Medical history of hypertension"
		HT  				= "Hypertension (0=No, 1=Yes)"
		DM  				= "Diabetes (0=No, 1=Yes)"
		DysL_  				= "Dyslipidemia (0=No, 1=Yes)"
		bexam_wc  			= "Waist circumference (cm)"
		bexam_BMI  			= "Body mass index (kg/m^2)"
		ASM_Wt_ 			= "Appendicular skeletal muscle mass (%)"
		shx_smoke_yn		= "History of smoking (0=No, 1=Yes)"
		shx_alcohol_yn 		= "History of alcohol intake (0=No, 1=Yes)"
		BMIgr				= "Obesity status according to BMI"
		bexam_BP_diastolic 	= "Diastolic blood pressure (mmHg)"
		bexam_BP_systolic	= "Systolic blood pressure (mmHg)"
		MAP					= "Mean arterial blood pressure (mmHg)"
;
FORMAT 	Sex 				Sex.
		mhx_HT_yn--DysL_  	YN.
		shx_smoke_yn		YN.
		shx_alcohol_yn		YN.
		BMIgr				Bmitx.;
RUN;

PROC CONTENTS data=epi207.outdata_label VARNUM out=epi207.outdatalabdes;
RUN;

/** Setup the Table 1 macro before run**/
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
        NumVars= Age bexam_wc bexam_BMI ASM_Wt_ bexam_BP_diastolic bexam_BP_systolic MAP,
        FreqVars= Sex mhx_HT_yn HT DM DysL_ shx_smoke_yn shx_alcohol_yn BMIgr,
        Mean=Y,
        Median=N,
        Total=RC,
        P=N,
        FreqCell=N(CP),
        Missing=Y,
        Print=N,
        Label=L,
        Out=Test2,
        Out1way=)
run;

/**Create results for Table 1**/
ods excel file="&results.\Table1.xlsx";
title 'Characteristics of study participants';
%Table1Print(DSname=Test2,Space=Y)
ods pdf close;
run;

/*Descriptive statistic for codebook (Table 1)*/
PROC FREQ data = epi207.outdata_label;
	TABLES 	Sex 
			mhx_HT_yn
			HT 
			DM 
			DysL_ 
			shx_smoke_yn
			shx_alcohol_yn
			BMIgr;
RUN;

PROC MEANS data = epi207.outdata_label n mean std min max nmiss;
	var Age
		bexam_wc
		bexam_BMI
		ASM_Wt_
		bexam_BP_diastolic
		bexam_BP_systolic
		MAP
		MAP_10;
RUN;

/*Association between 10% appendicular skeletal mass per body weight (%) and hypertension (Table 2)*/
/*Crude*/
PROC logistic  data=epi207.outdata_label DESC;
   class HT(ref="No");
   model HT = ASM_Wt_10/expb clodds=wald orpvalue;
   score fitstat;
run;

/*Model 1*/
PROC logistic  data=epi207.outdata_label DESC;
   class HT(ref="No") Sex(ref="Male");
   model HT = ASM_Wt_10 Age Sex/expb clodds=wald orpvalue;
   score out=drop fitstat;
   ods output ScoreFitStat=AIC_Model_1;
run;

/*Model 2*/
PROC logistic  data=epi207.outdata_label DESC;
   class HT(ref="No") Sex(ref="Male") shx_smoke_yn(ref="No") shx_alcohol_yn(ref="No");
   model HT = ASM_Wt_10 Age Sex shx_smoke_yn shx_alcohol_yn/expb clodds=wald orpvalue;
   score out=drop fitstat;
   ods output ScoreFitStat=AIC_Model_2;
run;

/*Model 3*/
PROC logistic  data=epi207.outdata_label DESC;
   class HT(ref="No") Sex(ref="Male") shx_smoke_yn(ref="No") shx_alcohol_yn(ref="No");
   model HT = ASM_Wt_10 Age Sex shx_smoke_yn shx_alcohol_yn bexam_BMI bexam_wc/expb clodds=wald orpvalue;
   score out=drop fitstat;
   ods output ScoreFitStat=AIC_Model_2;
run;

/*Model 4*/
PROC logistic  data=epi207.outdata_label DESC;
   class HT(ref="No") Sex(ref="Male") shx_smoke_yn(ref="No") shx_alcohol_yn(ref="No") DysL_(ref="No") DM(ref="No") ;
   model HT = ASM_Wt_10 Age Sex shx_smoke_yn shx_alcohol_yn bexam_BMI bexam_wc DysL_ DM /expb clodds=wald orpvalue;
   score out=drop fitstat;
   ods output ScoreFitStat=AIC_Model_4;
run;

/*Average differnece of mean arterial blood pressure per 10% increase in appendicular skeletal mass per body weight (Table 3)*/
/*Crude*/
PROC glm  data=epi207.outdata_label;
	model MAP_10 = ASM_Wt_10 / solution CLPARM;
RUN;

/*Model 1*/
PROC glm  data=epi207.outdata_label;
	class Sex(ref="Male");
	model MAP_10 = ASM_Wt_10 Age Sex/ solution CLPARM;
RUN;

/*Model 2*/
PROC glm  data=epi207.outdata_label;
	class Sex(ref="Male") shx_smoke_yn(ref="No") shx_alcohol_yn(ref="No");
   model MAP_10 = ASM_Wt_10 Age Sex shx_smoke_yn shx_alcohol_yn/ solution CLPARM;
RUN;

/*Model 3*/
PROC glm  data=epi207.outdata_label;
	class Sex(ref="Male") shx_smoke_yn(ref="No") shx_alcohol_yn(ref="No");
   model MAP_10 = ASM_Wt_10 Age Sex shx_smoke_yn shx_alcohol_yn bexam_BMI bexam_wc/ solution CLPARM;
RUN;

/*Model 4*/
PROC glm  data=epi207.outdata_label;
	class Sex(ref="Male") shx_smoke_yn(ref="No") shx_alcohol_yn(ref="No") DysL_(ref="No") DM(ref="No");
   model MAP_10 = ASM_Wt_10 Age Sex shx_smoke_yn shx_alcohol_yn bexam_BMI bexam_wc DysL_ DM / solution CLPARM;
RUN;

/*Filter excluded study population age <25 or >60 years and select needed varibles*/
DATA epi207.outdata_ex;
	SET epi207.data;
	where 25<age OR age >60;
	KEEP ID 
		 Sex 
		 Age 
		 HT 
		 DM 
		 DysL_ 
		 bexam_wc 
		 bexam_BMI 
		 ASM_Wt_
		 shx_smoke_yn
		 shx_alcohol_yn
		 mhx_HT_yn
		 bexam_BP_diastolic
		 bexam_BP_systolic;
RUN;

DATA epi207.outdata_ex2;
	set epi207.outdata_ex;
	BMIgr = put(bexam_BMI, BMIgr.);
	BMIgr2 = input(BMIgr,8.);
	MAP= bexam_BP_diastolic + (1/3 * (bexam_BP_systolic - bexam_BP_diastolic));
	ASM_Wt_10 = ASM_Wt_/10;
	drop BMIgr;
RUN;

DATA epi207.outdata_ex_label;
SET epi207.outdata_ex2(rename=(BMIgr2=BMIgr));

Label	ID 					= "ID"
		Sex 				= "Sex (1=Male, 2=Female)"
		Age  				= "Age (years)"
		mhx_HT_yn			= "Medical history of hypertension"
		HT  				= "Hypertension (0=No, 1=Yes)"
		DM  				= "Diabetes (0=No, 1=Yes)"
		DysL_  				= "Dyslipidemia (0=No, 1=Yes)"
		bexam_wc  			= "Waist circumference (cm)"
		bexam_BMI  			= "Body mass index (kg/m^2)"
		ASM_Wt_ 			= "Appendicular skeletal muscle mass (%)"
		shx_smoke_yn		= "History of smoking (0=No, 1=Yes)"
		shx_alcohol_yn 		= "History of alcohol intake (0=No, 1=Yes)"
		BMIgr				= "Obesity status according to BMI"
		bexam_BP_diastolic 	= "Diastolic blood pressure (mmHg)"
		bexam_BP_systolic	= "Systolic blood pressure (mmHg)"
		MAP					= "Mean arterial blood pressure (mmHg)"
;
FORMAT 	Sex 				Sex.
		mhx_HT_yn--DysL_  	YN.
		shx_smoke_yn		YN.
		shx_alcohol_yn		YN.
		BMIgr				Bmitx.;
RUN;

/*Descriptive statistic for those who excluded*/
%Table1(DSName=epi207.outdata_ex_label,
        NumVars= Age bexam_wc bexam_BMI ASM_Wt_ bexam_BP_diastolic bexam_BP_systolic MAP,
        FreqVars= Sex mhx_HT_yn HT DM DysL_ shx_smoke_yn shx_alcohol_yn BMIgr,
        Mean=Y,
        Median=N,
        Total=RC,
        P=N,
        FreqCell=N(CP),
        Missing=Y,
        Print=N,
        Label=L,
        Out=Test_ex,
        Out1way=)
run;

/**Create results for Table 1_ex**/
ods excel file="&results.\Table1_ex.xlsx";
title 'Characteristics of study participants who excluded';
%Table1Print(DSname=Test_ex,Space=Y)
ods pdf close;
run;

/*Sensitivity analysis*/
/*Average differnce of 10 mmHg of mean arterial blood pressure per 10% increase in appendicular skeletal mass per body weight excluded those with known history of hypertension*/
DATA epi207.outdata_label2;
	SET epi207.outdata_label;
	where mhx_HT_yn=0;
RUN;

PROC MEANS data = epi207.outdata_label2 n mean std min max nmiss;
	var MAP_10;
RUN;

/*Crude*/
PROC glm  data=epi207.outdata_label2;
	model MAP_10 = ASM_Wt_10 / solution CLPARM;
RUN;

/*Model 1*/
PROC glm  data=epi207.outdata_label2;
	class Sex(ref="Male");
	model MAP_10 = ASM_Wt_10 Age Sex/ solution CLPARM;
RUN;

/*Model 2*/
PROC glm  data=epi207.outdata_label2;
	class Sex(ref="Male") shx_smoke_yn(ref="No") shx_alcohol_yn(ref="No");
   model MAP_10 = ASM_Wt_10 Age Sex shx_smoke_yn shx_alcohol_yn/ solution CLPARM;
RUN;

/*Model 3*/
PROC glm  data=epi207.outdata_label2;
	class Sex(ref="Male") shx_smoke_yn(ref="No") shx_alcohol_yn(ref="No");
   model MAP_10 = ASM_Wt_10 Age Sex shx_smoke_yn shx_alcohol_yn bexam_BMI bexam_wc/ solution CLPARM;
RUN;

/*Model 4*/
PROC glm  data=epi207.outdata_label2;
	class Sex(ref="Male") shx_smoke_yn(ref="No") shx_alcohol_yn(ref="No") DysL_(ref="No") DM(ref="No");
   model MAP_10 = ASM_Wt_10 Age Sex shx_smoke_yn shx_alcohol_yn bexam_BMI bexam_wc DysL_ DM / solution CLPARM;
RUN;

/**** END ****/
