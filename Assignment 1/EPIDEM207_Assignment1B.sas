%let workdir = C:\Users\anusiri\Desktop;
libname epi207 "&workdir";

PROC CONTENTS data=epi207.data VARNUM out=epi207.datades;
RUN;

DATA epi207.outdata;
	SET epi207.data;
	KEEP ID 
		 Sex 
		 Age 
		 GOT 
		 GPT 
		 chol 
		 LDL 
		 TG 
		 HDL 
		 glu 
		 MS 
		 MS_5cri
		 HT 
		 DM 
		 DysL_ 
		 bexam_ht 
		 bexam_wt 
		 bexam_wc 
		 bexam_BMI 
		 Obesity 
		 bexam_BP_systolic
		 bexam_BP_diastolic
		 ASM_kg
		 ASM_Wt_
		 ASM_Wt__Q4
		 Sarco_ASM_Wt_
		 VFA_cm2 shx_smoke_yn
		 shx_alcohol_yn
		 insulin
		 uric_acid
		 HbA1c
		 CRP;
RUN;

PROC CONTENTS data=epi207.outdata VARNUM;
RUN;

OPTIONS FMTSEARCH = (epi207);

PROC FORMAT LIBRARY = epi207;
	value Sex 	1='Male'
				2='Female';
	value YN	0='0-No'
				1='1-Yes';
	value BMIgr low-<18.5 = '0'
				18.5-22.9 = '1'
				23-24.9	  = '2'
				25-high   = '3';
	value BMItx 0 = 'Under weight (BMI <18.5 kg/m^2)'
				1 = 'Normal (BMI 18.5-22.9 kg/m^2)'
				2 = 'Overweight (BMI 23-24.9 kg/m^2)'
				3 = 'Obesity (BMI >=25 kg/m^2)';
	value Q		1 = 'Q1'
				2 = 'Q2'
				3 = 'Q3'
				4 = 'Q4';

RUN;	


DATA epi207.outdata2;
	set epi207.outdata;
	BMIgr = put(bexam_BMI, BMIgr.);
	BMIgr2 = input(BMIgr,8.);
	drop BMIgr;
RUN;

PROC CONTENTS data=epi207.outdata2 VARNUM;
RUN;

DATA epi207.outdata_label;
SET epi207.outdata2(rename=(BMIgr2=BMIgr));

Label	ID 		= "ID"
		Sex 	= "Sex (1=Male, 2=Female)"
		Age  	= "Age (years)"
		GOT  	= "Aspartate aminotransferase; AST (IU/L)"
		GPT  	= "Alanine aminotransferase; ALT (IU/L)"
		chol  	= "Cholesterol (mg/dL)"
		LDL  	= "Low-density lipoprotein (mg/dL)"
		TG  	= "Triglyceride (mg/dL)"
		HDL  	= "High-density lipoprotien (mg/dL)"
		glu  	= "Glucose (mg/dL)"
		MS  	= "Metabolic syndrome (0=No, 1=Yes)"
		MS_5cri	= "Metabolic syndrome, number of criteria"
		HT  	= "Hypertension (0=No, 1=Yes)"
		DM  	= "Diabetes (0=No, 1=Yes)"
		DysL_  	= "Dyslipidemia (0=No, 1=Yes)"
		bexam_ht  			= "Height (cm)"
		bexam_wt  			= "Weight (kg)"
		bexam_wc  			= "Waist circumference (cm)"
		bexam_BMI  			= "Body mass index (kg/m^2)"
		Obesity  			= "Obesity (0=No, 1=Yes)"
		bexam_BP_systolic 	= "Systolic blood pressure (mmHg)"
		bexam_BP_diastolic 	= "Diastolic blood pressure (mmHg)"
		ASM_kg 				= "Appendicular skeletal muscle mass (kg)"
		ASM_Wt_ 			= "Appendicular skeletal muscle mass (%)"
		ASM_Wt__Q4 			= "Appendicular skeletal muscle mass (%), 4th quartile (0=No, 1=Yes)"
		Sarco_ASM_Wt_ 		= "Sarcopenia (0=No, 1=Yes)"
		VFA_cm2  			= "Visceral fat area (cm^2)"
		shx_smoke_yn		= "History of smoking (0=No, 1=Yes)"
		shx_alcohol_yn 		= "History of alcohol intake (0=No, 1=Yes)"
		insulin 			= "Insulin"
		uric_acid 			= "Uric acid (mg/dL)"
		HbA1c 				= "Hemoglobin A1C (%)"
		CRP					= "C-reactive protine (mg/dL)"
		BMIgr				= "Obesity status according to BMI"
;
FORMAT 	Sex 			Sex.
		MS				YN.
		HT--DysL_  		YN.
		Obesity 		YN.
		ASM_Wt__Q4		Q.
		Sarco_ASM_Wt_	YN.
		shx_smoke_yn	YN.
		shx_alcohol_yn	YN.
		BMIgr			Bmitx.;
RUN;

PROC CONTENTS data=epi207.outdata_label VARNUM out=epi207.outdatalabdes;
RUN;

PROC FREQ data = epi207.outdata_label;
	TABLES 	Sex 
			MS
			MS_5cri
			HT 
			DM 
			DysL_ 
			Obesity 
			ASM_Wt__Q4 
			Sarco_ASM_Wt_ 
			shx_smoke_yn
			shx_alcohol_yn
			BMIgr;
RUN;

PROC MEANS data = epi207.outdata_label n mean min max nmiss;
	var Age
		GOT
		GPT
		chol
		LDL
		TG
		HDL
		glu
		bexam_ht
		bexam_wt
		bexam_wc
		bexam_BMI
		bexam_BP_systolic
		bexam_BP_diastolic
		ASM_kg
		ASM_Wt_
		VFA_cm2
		insulin
		HbA1c
		uric_acid
		CRP;
RUN;
