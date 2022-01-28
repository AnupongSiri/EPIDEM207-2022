* Macro append replaces proc append.  When proc append is called as in "proc append base = data1 data = data2 force", any variables in data2
  that are not in data1 will not be appended. On the other hand variables in data1 that are not in data2 will be assigned missing values for
  the data2 observations.  The append macro behaves more symmetrically in that variables in data2 that are not in data1 are given missing
  values in data1.  The append macro will not handle situations where a variable is alpha in one file and numeric in another.

  Parameters:

  Base = The (possibly) existing SAS data set to which the dsname data set will be appended.
  Dsname = The SAS data set to be appended to base

  Last revision 09/29/08;

%macro append(Base=,DSName=);
	
	%Local BadVar Exist I TypeMem NNum NAlpha;

	%Let Exist = %sysfunc(exist(&Base));

	* If the Base file does not yet exist, then simply copy DSName to Base;
	%if &Exist = 0 %then
		%do;
			* Need to get the type of dsname;
		   ods listing close;
			proc contents data = &dsname out = _check;
			data _null_;
			   set _check (obs = 1);
				call symput('TypeMem',TypeMem);
			run;
			data &Base (Type = "&TypeMem");
			   set &DSName;
			run;
			%goto ExitAppend;
		%end;

	* Create SAS files of variable lists for each file.  Then merge lists looking for type disagreements;
	proc contents data = &Base out = _BaseVar (keep = name type rename = (type = basetype)) noprint;
	proc sort data = _BaseVar; by name;
	proc contents data = &Dsname out = _Var (keep = name type typemem rename = (type = newtype)) noprint;
	proc sort data = _Var; by name;

	data _null_;
	   set _var (obs = 1);
		Call Symput('TypeMem',TypeMem);
	run;
	
	%Let BadVar =;
	data _null_;
	   merge _BaseVar (in = f1) _Var (in = f2) end = done; by name;
		if _n_ = 1 then do; NNum = 0; NAlpha = 0; end;	* number of numeric, alpha vars in _var, but not in _BaseVar;
		retain NNum NAlpha;
		if f1 and f2 and basetype ne newType then
			do;
				Call Symput('BadVar',name);
			end;
		if not(f1) then
			do;
				if NewType = 1 then
					do;
						NNum = NNum + 1;
						Call symput('_NVar'||left(NNum),name);
					end;
				else
					do;
						NAlpha = NAlpha + 1;
						Call symput('_AVar'||left(NAlpha),name);
					end;
			end;
		if done then
			do;
				Call symput('NNum',NNum);
				Call symput('NAlpha',NAlpha);
			end;
	run;
	%if &BadVar ne %then
		%do;
			%put;
			%put Error: Variable %trim(&BadVar) is numeric in one file and alpha in the other.  Files cannot be appended.;
			%put;
			%goto ExitAppend;
		%end;

		* Copy observations in Base to _NewBase adding any variables where _baseType = .;
	data _NewBase;
	   set &Base;
		%if &NNum > 0 %then
			%do i = 1 %to &NNum;
				&&_NVar&i = .;
			%end;
		%if &NAlpha > 0 %then
			%do i = 1 %to &NAlpha;
				&&_AVar&i = '';
			%end;
	run;

	* Now add the DSName data;
	data &Base (Type = "&TypeMem");
	   set _NewBase &dsname;
	run;
   
	%ExitAppend:
	proc datasets nolist; delete _BaseVar _check _NewBase _Var; quit; 

%mend;
