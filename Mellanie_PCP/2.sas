
/* Dataset: MedPAR */

/* Variables:
    BENE_ZIP: zip code of the mailing address where the beneficiary may be contacted.
    DRG_CD: indicating the DRG to which the claims that comprise the stay belong for payment purposes
    AD_DGNS: ICD-9-CM code indicating the beneficiary's initial diagnosis at the time of admission
	DGNSCD{x}: ICD-9-CM diagnosis code
    PRCDRCD{x}: ICD-9-CM code identifying the principal or other surgical procedure performed during the beneficiary's stay
    TYPE_ADM: type and priority of the beneficiary's admission to a facility for the Inpatient hospital stay

    stroke admissions with TPA and/or Endovascular(numerator):
        patients administered tPA: DRG_CD=559 ('MS-DRG'=61-63), PRCDRCD=99.1
        endovascular therapy EVT: CPT codes 37184-6,37201,75896
    stroke admissions(denominator): AD_DGNS=433,434,435,436 or DGNSCD{x}=433,434,435,436
    TYPE_ADM=1(Emergency) and 2 (Urgent)?
    DRG or MS-DRG?

*/

libname temp 'D:\Data\Medicare National Sample\Ran';
libname library 'D:\Data\Medicare National Sample\Ran';
libname medpar 'D:\Data\Medicare National Sample\MedPAR';
libname carrier 'D:\Data\Medicare National Sample\Carrier';
*to find out what variables in the file;
proc contents data=medpar.med11p20;
run;
proc contents data=medpar.med09p20;
run;
proc contents data=medpar.med07p20;
run;
proc contents data=carrier.ptb07clms;
run;
proc contents data=carrier.ptb07lnits;
run;

data medpar11;
	set medpar.med11p20;
	if clm_type in ('60','61','62','63','64');/*inpatient claims*/
	if ad_dgns in: ('433','434','435','436') or dgnscd1 in: ('433','434','435','436');/*identify admissions with stroke as primary or admission dx*/
	if drg_cd in ('061','062','063') then tpa_drg=1;else tpa_drg=0;/*identify TPA by Medicare drg (MS_DRG) code*/
	/*identify TPA by procedure codes*/
	tpa_sg=0;
	array sg(25) PRCDRCD1-PRCDRCD25;
	do i=1 to 25;
	if sg(i) in: ('991') then tpa_sg=1;
	end;
	/*identify drip ship by diagnosis code*/
	drip_ship=0;
	array dx(26) ad_dgns dgnscd1-dgnscd25;
	do j=1 to 26;
	if dx(j) in ('V4588') then drip_ship=1;
	end;
	/*identify emergency admission*/
	if type_adm in ('1','2') then emergency=1;else emergency=0;
	/*identify TPA if TPA DRG or TPA procedure equal 1*/
	if tpa_sg=1 or tpa_drg=1 then tpa=1;else tpa=0;
run;*114253;
proc freq data=medpar11;
table tpa drip_ship emergency/missing;
table tpa*(drip_ship emergency)/chisq missing;
run;
/*
                                                       Cumulative    Cumulative
                       tpa    Frequency     Percent     Frequency      Percent
                       ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                         0      109519       95.86        109519        95.86
                         1        4734        4.14        114253       100.00


                                                          Cumulative    Cumulative
                    drip_ship    Frequency     Percent     Frequency      Percent
                    ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                            0      113319       99.18        113319        99.18
                            1         934        0.82        114253       100.00


                                                          Cumulative    Cumulative
                    emergency    Frequency     Percent     Frequency      Percent
                    ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                            0       20253       17.73         20253        17.73
                            1       94000       82.27        114253       100.00


                                 tpa       drip_ship

                                 Frequency‚
                                 Percent  ‚
                                 Row Pct  ‚
                                 Col Pct  ‚       0‚       1‚  Total
                                 ƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                                        0 ‚ 108726 ‚    793 ‚ 109519
                                          ‚  95.16 ‚   0.69 ‚  95.86
                                          ‚  99.28 ‚   0.72 ‚
                                          ‚  95.95 ‚  84.90 ‚
                                 ƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                                        1 ‚   4593 ‚    141 ‚   4734
                                          ‚   4.02 ‚   0.12 ‚   4.14
                                          ‚  97.02 ‚   2.98 ‚
                                          ‚   4.05 ‚  15.10 ‚
                                 ƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                                 Total      113319      934   114253
                                             99.18     0.82   100.00

                                            The SAS System          09:35 Wednesday, April 8, 2020  17

                                          The FREQ Procedure

                               Statistics for Table of tpa by drip_ship

                        Statistic                     DF       Value      Prob
                        ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                        Chi-Square                     1    284.4392    <.0001
                        Likelihood Ratio Chi-Square    1    174.5085    <.0001
                        Continuity Adj. Chi-Square     1    281.6655    <.0001
                        Mantel-Haenszel Chi-Square     1    284.4367    <.0001
                        Phi Coefficient                       0.0499
                        Contingency Coefficient               0.0498
                        Cramer's V                            0.0499


                                         Fisher's Exact Test
                                  ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                  Cell (1,1) Frequency (F)    108726
                                  Left-sided Pr <= F          1.0000
                                  Right-sided Pr >= F         <.0001

                                  Table Probability (P)       <.0001
                                  Two-sided Pr <= P           <.0001

                                         Sample Size = 114253


                                      Table of tpa by emergency

                                 tpa       emergency

                                 Frequency‚
                                 Percent  ‚
                                 Row Pct  ‚
                                 Col Pct  ‚       0‚       1‚  Total
                                 ƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                                        0 ‚  19774 ‚  89745 ‚ 109519
                                          ‚  17.31 ‚  78.55 ‚  95.86
                                          ‚  18.06 ‚  81.94 ‚
                                          ‚  97.63 ‚  95.47 ‚
                                 ƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                                        1 ‚    479 ‚   4255 ‚   4734
                                          ‚   0.42 ‚   3.72 ‚   4.14
                                          ‚  10.12 ‚  89.88 ‚
                                          ‚   2.37 ‚   4.53 ‚
                                 ƒƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆƒƒƒƒƒƒƒƒˆ
                                 Total       20253    94000   114253
                                             17.73    82.27   100.00

                                            The SAS System          09:35 Wednesday, April 8, 2020  18

                                          The FREQ Procedure

                               Statistics for Table of tpa by emergency

                        Statistic                     DF       Value      Prob
                        ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                        Chi-Square                     1    196.0123    <.0001
                        Likelihood Ratio Chi-Square    1    223.5846    <.0001
                        Continuity Adj. Chi-Square     1    195.4684    <.0001
                        Mantel-Haenszel Chi-Square     1    196.0105    <.0001
                        Phi Coefficient                       0.0414
                        Contingency Coefficient               0.0414
                        Cramer's V                            0.0414


                                         Fisher's Exact Test
                                  ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                                  Cell (1,1) Frequency (F)     19774
                                  Left-sided Pr <= F          1.0000
                                  Right-sided Pr >= F         <.0001

                                  Table Probability (P)       <.0001
                                  Two-sided Pr <= P           <.0001

                                         Sample Size = 114253
*/
*convert zipcode to hsa;
proc import out=temp.hsa_11 datafile='D:\Anna\HRR\ziphsahrr11.xls' dbms=xls replace;
run;*40722;
proc sort data=medpar11;
by bene_zip;
run;
proc sort data=temp.hsa_11;
by zipcode11;
run;
*change bene_zip from character to number since zipcode11 in ziphsahrr11 file is number format;
data medpar11A;
	set medpar11;
zip_cd=input(bene_zip,5.);
run;
*merge medpar file with ziphsahrr file to get hsanum;
data medpar11B;
	merge medpar11A(in=in_A) temp.hsa_11(in=in_B rename=zipcode11=zip_cd);
	by zip_cd;
	if in_A;
proc freq;
table hsanum/missing;
run;
/*
                                                        Cumulative    Cumulative
                     hsanum    Frequency     Percent     Frequency      Percent
                     ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                          .         769        0.67           769         0.67
*/
*summarize # of admission by HSA;
proc sql;
create table medpar11B_hsa as
select hsanum, count(*) as many_stroke_adm
from medpar11B
where hsanum ne .
group by hsanum;
quit;*3332;
*summarize # of TPA among stroke admission by HSA;
proc sql;
create table medpar11B_hsa_tpa as
select hsanum, count(*) as many_stroke_adm_tpa
from medpar11B
where hsanum ne . and tpa=1
group by hsanum;
quit;*1362;
*merge to know which HSA has TPA and # of TPA by HSA;
data temp.medpar11C;
	merge medpar11B_hsa(in=in_A) medpar11B_hsa_tpa(in=in_B);
	by hsanum;
	if in_A;
	if in_A & in_B then tpa=1;
	else if in_A & not in_B then do;
		tpa=0;
		many_stroke_adm_tpa=0;
	end;
proc freq;
table tpa/missing;
run;
/*
                                                       Cumulative    Cumulative
                       tpa    Frequency     Percent     Frequency      Percent
                       ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ
                         0        1970       59.12          1970        59.12
                         1        1362       40.88          3332       100.00

*/





   
