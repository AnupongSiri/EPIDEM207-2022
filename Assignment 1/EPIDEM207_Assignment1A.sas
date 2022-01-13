%let workdir = \\Client\D$\Documents\UCLA_PhD_Epi\2022_1Winter\EPIDEM207_Reproducibility_in_epidemiology_research\EPIDEM207_wk01\;
libname epi207 "&workdir";

PROC IMPORT OUT= epi207.data DATAFILE= "\\Client\D$\Documents\UCLA_PhD_Epi\2022_1Winter\EPIDEM207_Reproducibility_in_epidemiology_research\EPIDEM207_wk01\journal.pone.0248856.s001.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="tmp_kim_CRP"; 
     GETNAMES=YES;
RUN;

PROC CONTENTS data=epi207.data VARNUM out=epi207.datades;
RUN;
