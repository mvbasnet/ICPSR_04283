/**************************************************************************
 |                                                                         
 |                    STATA SETUP FILE FOR ICPSR 04283
 |           NATIONAL CENTER FOR EARLY DEVELOPMENT AND LEARNING
 |            MULTISTATE STUDY OF PRE-KINDERGARTEN, 2001-2003
 |         (DATASET 0002: KINDERGARTEN CLASSROOM LEVEL PUBLIC-USE
 |                                VERSION)
 |
 |
 |  Please edit this file as instructed below.
 |  To execute, start Stata, change to the directory containing:
 |       - this do file
 |       - the ASCII data file
 |       - the dictionary file
 |
 |  Then execute the do file (e.g., do 04283-0002-statasetup.do)
 |
 **************************************************************************/

set mem 7m  /* Allocating 7 megabyte(s) of RAM for Stata SE to read the
                 data file into memory. */


set more off  /* This prevents the Stata output viewer from pausing the
                 process */

/****************************************************

Section 1: File Specifications
   This section assigns local macros to the necessary files.
   Please edit:
        "data-filename" ==> The name of data file downloaded from ICPSR
        "dictionary-filename" ==> The name of the dictionary file downloaded.
        "stata-datafile" ==> The name you wish to call your Stata data file.

   Note:  We assume that the raw data, dictionary, and setup (this do file) all
          reside in the same directory (or folder).  If that is not the case
          you will need to include paths as well as filenames in the macros.

********************************************************/

local raw_data "data-filename"
local dict "dictionary-filename"
local outfile "stata-datafile"

/********************************************************

Section 2: Infile Command

This section reads the raw data into Stata format.  If Section 1 was defined
properly, there should be no reason to modify this section.  These macros
should inflate automatically.

**********************************************************/

infile using `dict', using (`raw_data') clear


/*********************************************************

Section 3: Value Label Definitions
This section defines labels for the individual values of each variable.
We suggest that users do not modify this section.

**********************************************************/


label data "National Center for Early Development and Learning Multistate Study of Pre-Kindergarten, 2001-2003, Kindergarten Classroom Level Public-Use Version"

#delimit ;
label define CREDENTIALK -99 "System Missing" 1 "ECE credential"
                       2 "K credential" 3 "EE credential"
                       4 "Other Credential" ;
label define BACERT_AK -99 "System Missing"
                       0 "Teacher has a BA or better, but no State Certificate"
                       1 "Teacher has a BA or better, and has State Certificate"
                       2 "Yes, Emergency or Temporary" ;
label define BACERT_BK -99 "System Missing"
                       0 "Teacher has a BA or better, but no State Certificate"
                       1 "Teacher has a BA or better, and has State Certificate"
                       2 "Yes, Emergency or Temporary" ;
label define BACERT_CK -99 "System Missing"
                       0 "Teacher has a BA or better, but no State Certificate"
                       1 "Teacher has a BA or better, and has State Certificate"
                       2 "Yes, Emergency or Temporary" ;
label define BACERT_DK -99 "System Missing"
                       0 "Teacher has a BA or better, but no State Certificate"
                       1 "Teacher has a BA or better, and has State Certificate"
                       2 "Yes, Emergency or Temporary" ;
label define BACERT_EK -99 "System Missing"
                       0 "Teacher has a BA or better, but no State Certificate"
                       1 "Teacher has a BA or better, and has State Certificate"
                       2 "Yes, Emergency or Temporary" ;
label define BACERT_FK -99 "System Missing"
                       0 "Teacher has a BA or better, but no State Certificate"
                       1 "Teacher has a BA or better, and has State Certificate"
                       2 "Yes, Emergency or Temporary" ;
label define BACERT_GK -99 "System Missing"
                       0 "Teacher has a BA or better, but no State Certificate"
                       1 "Teacher has a BA or better, and has State Certificate"
                       2 "Yes, Emergency or Temporary" ;
label define NOBACERTK -99 "System Missing"
                       0 "Teacher has a BA or better, but no State Certificate"
                       1 "Teacher has a BA or better, and has State Certificate"
                       2 "Yes, Emergency or Temporary" ;
label define T_AGEK    -99 "System Missing" ;
label define SCHDAYK   -99 "System Missing" ;
label define HOURSDAYPK -99 "System Missing" ;
label define HOURSDAYK -99 "System Missing" ;
label define HOURSWKK  -99 "System Missing" ;
label define FULLDAYK  -99 "System Missing" 0 "No" 1 "Yes" ;
label define T_CDAK    -99 "System Missing" 1 "Yes" 2 "No" ;
label define BOYSK     -99 "System Missing" ;
label define TMAJORK   -99 "System Missing" 1 "Early Childhood Education"
                       2 "Elementary Education" 3 "Special Education"
                       4 "English as a Second Language" 5 "Child Development"
                       6 "N/A (No degree)" 7 "Other" 8 "Other Education"
                       9 "Psychology (Any)" 10 "Home Economics"
                       11 "Social Work/Human Services" 12 "Sociology"
                       13 "Reading" ;
label define EXPER01K  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define EXPER02K  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define EXPER03K  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define EXPTOTK   -99 "System Missing" ;
label define T_EDUCK   -99 "System Missing" 1 "High School diploma or better"
                       2 "Some college or an AA" 3 "Bachelor's degree"
                       4 "At least 1 year beyond BA" 5 "Master's degree"
                       6 "Education specialist or professional diploma"
                       7 "Doctoral degree" 8 "Other" ;
label define T_GENDERK -99 "System Missing" 1 "Male" 2 "Female" ;
label define CLS_SIZEKF -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define IEPKF     -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define DAY_WKK   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define CALC_WAGEK -99 "System Missing" ;
label define MONTHSK   -99 "System Missing" ;
label define CLS_TYPEK -99 "System Missing" 1 "Pre-kindergarten class"
                       2 "Kindergarten class"
                       3 "Pre-K & Kindergarten combined class"
                       4 "Kindergarten - 1st Grade combined class"
                       5 "Transitional or junior" 6 "Other" ;
label define AID_HRSKF -99 "System Missing" ;
label define STCH_HRSK -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define CLANG01K  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable" 0 "No"
                       1 "Yes" ;
label define CLANG02K  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define CLANG03K  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define TLANG01K  -99 "System Missing" 0 "No" 1 "Yes" ;
label define TLANG02K  -99 "System Missing" 0 "No" 1 "Yes" ;
label define TLANG03K  -99 "System Missing" 0 "No" 1 "Yes" ;
label define T_HRSWKK  -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define CHRESKF   -99 "System Missing" 1 "Yes" 2 "No" ;
label define CHRESUSKF -99 "System Missing" 1 "Yes" 2 "No" ;
label define LEPK      -99 "System Missing" ;
label define STDTCHK   -99 "System Missing" 1 "Yes" 2 "No" ;
label define TCHSLEFFK -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define T_CESDK   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define T_BELIEFK -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define AFR_AMTK  -99 "System Missing" 0 "No" 1 "Yes" ;
label define NAT_AMTK  -99 "System Missing" 0 "No" 1 "Yes" ;
label define WHITETK   -99 "System Missing" 0 "No" 1 "Yes" ;
label define ASIANTK   -99 "System Missing" 0 "No" 1 "Yes" ;
label define LATINATK  -99 "System Missing" 0 "No" 1 "Yes" ;
label define OTHERTK   -99 "System Missing" 0 "No" 1 "Yes" ;
label define T_RACEK   -99 "System Missing" 1 "Latin" 2 "African American"
                       3 "Native American" 4 "Asian" 5 "White"
                       6 "Multiracial" ;
label define T_IDEAK   -99 "System Missing" ;
label define T_BAK     -99 "System Missing" 0 "No" 1 "Yes" ;
label define T_EDYRSK  -99 "System Missing" ;
label define AID_KF    -99 "System Missing" 1 "Yes" 2 "No" ;
label define KTRAN1K   -99 "System Missing" 0 "No" 1 "Yes" ;
label define KTRAN2K   -99 "System Missing" 0 "No" 1 "Yes" ;
label define KTRAN3K   -99 "System Missing" 0 "No" 1 "Yes" ;
label define KTRAN4K   -99 "System Missing" 0 "No" 1 "Yes" ;
label define KTRAN5K   -99 "System Missing" 0 "No" 1 "Yes" ;
label define KTRAN6K   -99 "System Missing" 0 "No" 1 "Yes" ;
label define KTRAN7K   -99 "System Missing" 0 "No" 1 "Yes" ;
label define KTRAN8K   -99 "System Missing" 0 "No" 1 "Yes" ;
label define AFR_AMK   -99 "System Missing" ;
label define NAT_AMK   -99 "System Missing" ;
label define WHITEK    -99 "System Missing" ;
label define LATINOK   -99 "System Missing" ;
label define ASIANK    -99 "System Missing" ;
label define OTHERK    -99 "System Missing" ;
label define CCNES1AK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES1BK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES1CK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES1DK  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       1 "Very Unlikely" 4 "Medium" 7 "Very Likely" ;
label define CCNES1EK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES1FK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES2AK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES2BK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES2CK  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       1 "Very Unlikely" 4 "Medium" 7 "Very Likely" ;
label define CCNES2DK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES2EK  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       1 "Very Unlikely" 4 "Medium" 7 "Very Likely" ;
label define CCNES2FK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES3AK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES3BK  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       1 "Very Unlikely" 4 "Medium" 7 "Very Likely" ;
label define CCNES3CK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES3DK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES3EK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES3FK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES4AK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES4BK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES4CK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES4DK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES4EK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES4FK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES5AK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES5BK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES5CK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES5DK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES5EK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define CCNES5FK  -99 "System Missing" 1 "Very Unlikely" 4 "Medium"
                       7 "Very Likely" ;
label define JOINEDK   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define NUM_LEFTK -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define CLS_SIZEKS -99 "System Missing" ;
label define IEPKS     -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define AID_HRSKS -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define AID_EDKS  -99 "System Missing" 1 "8th Grade or Less"
                       2 "Some HS, but no Diploma"
                       3 "HS Diploma or equivalent"
                       4 "HS Diploma + Training Certificate"
                       5 "Some college but no degree"
                       6 "AA, AS, Two-Year Degree" 7 "Bachelor's Degree"
                       8 "At least 1 Year past BA" 9 "Master's Degree"
                       10 "Education Specialist or Professional Degree"
                       11 "Doctoral Degree" 12 "Other" ;
label define AID_CDAKS -99 "System Missing" 1 "Yes" 2 "No" ;
label define LOCATIONK -99 "System Missing" 1 "Yes" 2 "No" ;
label define CHRESKS   -99 "System Missing" 1 "Yes" 2 "No" ;
label define CHRESUSKS -99 "System Missing" 1 "Yes" 2 "No" ;
label define T_PLANPK  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "0"
                       2 "2 or less" 3 "3 - 4" 4 "5 - 6" 5 "7 - 9"
                       6 "10 or More" ;
label define T_PLANUK  -99 "System Missing" 1 "0" 2 "2 or less" 3 "3 - 4"
                       4 "5 - 6" 5 "7 - 9" 6 "10 or More" ;
label define RDGPGMK   -99 "System Missing" 1 "Yes" 2 "No" ;
label define RDGPGMTK  -99 "System Missing" 1 "Phonics-based"
                       2 "Whole language based"
                       3 "A combination of phonics and while language" ;
label define PARVISK   -99 "System Missing" 1 "Not allowed during the day"
                       2 "Only at specific times"
                       3 "Only with advance notice" 4 "At any time" ;
label define PARVOLK   -99 "System Missing" 1 "Never" 2 "Once-twice a Year"
                       3 "Almost Every Month" 4 "Almost Every Week"
                       5 "More Than Once a Week" ;
label define PARMTGK   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define PARRPTK   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define AID_KS    -99 "System Missing" 1 "Yes" 2 "No" ;
label define KIDAGEK1  -99 "System Missing" 0 "No" 1 "Yes" ;
label define KIDAGEK2  -99 "System Missing" 0 "No" 1 "Yes" ;
label define KIDAGEK3  -99 "System Missing" 0 "No" 1 "Yes" ;
label define KIDAGEK4  -99 "System Missing" 0 "No" 1 "Yes" ;
label define KIDAGEK5  -99 "System Missing" 0 "No" 1 "Yes" ;
label define KIDAGEK6  -99 "System Missing" 0 "No" 1 "Yes" ;
label define KIDAGEK7  -99 "System Missing" 0 "No" 1 "Yes" ;
label define KIDAGEK8  -99 "System Missing" 0 "No" 1 "Yes" ;
label define KIDAGEK9  -99 "System Missing" 0 "No" 1 "Yes" ;
label define TARGPOPK  -99 "System Missing" 1 "Not targeted"
                       2 "Children with below average academic skills"
                       3 "Self-contained special education class"
                       4 "Class for English language learners"
                       5 "Spanish language immersion class"
                       6 "Other targeted population" ;
label define CLSFRQK   -99 "System Missing" ;
label define PCLIME_K  -99 "System Missing" ;
label define NCLIME_K  -99 "System Missing" ;
label define TSENSE_K  -99 "System Missing" ;
label define OCNTL_K   -99 "System Missing" ;
label define BHVMNG_K  -99 "System Missing" ;
label define PROD_K    -99 "System Missing" ;
label define CNCTDV_K  -99 "System Missing" ;
label define LRNFMT_K  -99 "System Missing" ;
label define RTBSCS_K  -99 "System Missing" ;
label define QUALFD_K  -99 "System Missing" ;
label define PCLIME_CK -99 "System Missing" ;
label define NCLIME_CK -99 "System Missing" ;
label define TSENSE_CK -99 "System Missing" ;
label define OCNTL_CK  -99 "System Missing" ;
label define BHVMNG_CK -99 "System Missing" ;
label define PROD_CK   -99 "System Missing" ;
label define CNCTDV_CK -99 "System Missing" ;
label define LRNFMT_CK -99 "System Missing" ;
label define RTBSCS_CK -99 "System Missing" ;
label define QUALFD_CK -99 "System Missing" ;
label define CLASTOTK  -99 "System Missing" ;
label define CLASF1K   -99 "System Missing" ;
label define CLASF2K   -99 "System Missing" ;
label define ECERTOTK  -99 "System Missing" ;
label define ECERF1K   -99 "System Missing" ;
label define ECERF2K   -99 "System Missing" ;
label define RATIOENK  -99 "System Missing" ;
label define RATIOOBK  -99 "System Missing" ;
label define CSIZEENK  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define CSIZEOBK  -99 "System Missing" ;
label define STAFFOBK  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;


#delimit cr


/***************************************************************************

 Section 4: Missing Values

 This section will replace numeric missing values (i.e., -9) with generic
 system missing ".".  By default the code in this section is commented out.
 Users wishing to apply the generic missing values should remove the comment
 at the beginning and end of this section.  Note that Stata allows you to
 specify up to 27 unique missing value codes.

****************************************************************/

/*
replace CREDENTIALK = . if (CREDENTIALK == -99)
replace BACERT_AK = . if (BACERT_AK == -99)
replace BACERT_BK = . if (BACERT_BK == -99)
replace BACERT_CK = . if (BACERT_CK == -99)
replace BACERT_DK = . if (BACERT_DK == -99)
replace BACERT_EK = . if (BACERT_EK == -99)
replace BACERT_FK = . if (BACERT_FK == -99)
replace BACERT_GK = . if (BACERT_GK == -99)
replace NOBACERTK = . if (NOBACERTK == -99)
replace T_AGEK = . if (T_AGEK == -99)
replace SCHDAYK = . if (SCHDAYK == -99.00)
replace HOURSDAYPK = . if (HOURSDAYPK == -99.00)
replace HOURSDAYK = . if (HOURSDAYK == -99.00)
replace HOURSWKK = . if (HOURSWKK == -99.00)
replace FULLDAYK = . if (FULLDAYK == -99)
replace T_CDAK = . if (T_CDAK == -99)
replace BOYSK = . if (BOYSK == -99.000)
replace TMAJORK = . if (TMAJORK == -99)
replace EXPER01K = . if (EXPER01K == -6.00 | EXPER01K == -99.00)
replace EXPER02K = . if (EXPER02K == -6.00 | EXPER02K == -99.00)
replace EXPER03K = . if (EXPER03K == -6.00 | EXPER03K == -99.00)
replace EXPTOTK = . if (EXPTOTK == -99.00)
replace T_EDUCK = . if (T_EDUCK == -99)
replace T_GENDERK = . if (T_GENDERK == -99)
replace CLS_SIZEKF = . if (CLS_SIZEKF == -6 | CLS_SIZEKF == -99)
replace IEPKF = . if (IEPKF == -5 | IEPKF == -99)
replace DAY_WKK = . if (DAY_WKK == -6 | DAY_WKK == -99)
replace CALC_WAGEK = . if (CALC_WAGEK == -99.00)
replace MONTHSK = . if (MONTHSK == -99.00)
replace CLS_TYPEK = . if (CLS_TYPEK == -99)
replace AID_HRSKF = . if (AID_HRSKF == -6.00 | AID_HRSKF == -99.00)
replace STCH_HRSK = . if (STCH_HRSK == -5.00 | STCH_HRSK == -6.00 | STCH_HRSK == -99.00)
replace CLANG01K = . if (CLANG01K == -5 | CLANG01K == -6 | CLANG01K == -99)
replace CLANG02K = . if (CLANG02K == -6 | CLANG02K == -99)
replace CLANG03K = . if (CLANG03K == -6 | CLANG03K == -99)
replace TLANG01K = . if (TLANG01K == -99)
replace TLANG02K = . if (TLANG02K == -99)
replace TLANG03K = . if (TLANG03K == -99)
replace T_HRSWKK = . if (T_HRSWKK == -5.00 | T_HRSWKK == -99.00)
replace CHRESKF = . if (CHRESKF == -99)
replace CHRESUSKF = . if (CHRESUSKF == -99)
replace LEPK = . if (LEPK == -99)
replace STDTCHK = . if (STDTCHK == -99)
replace TCHSLEFFK = . if (TCHSLEFFK == -6.00 | TCHSLEFFK == -99.00)
replace T_CESDK = . if (T_CESDK == -6.00 | T_CESDK == -99.00)
replace T_BELIEFK = . if (T_BELIEFK == -6.00 | T_BELIEFK == -99.00)
replace AFR_AMTK = . if (AFR_AMTK == -99)
replace NAT_AMTK = . if (NAT_AMTK == -99)
replace WHITETK = . if (WHITETK == -99)
replace ASIANTK = . if (ASIANTK == -99)
replace LATINATK = . if (LATINATK == -99)
replace OTHERTK = . if (OTHERTK == -99)
replace T_RACEK = . if (T_RACEK == -99)
replace T_IDEAK = . if (T_IDEAK == -99.00)
replace T_BAK = . if (T_BAK == -99)
replace T_EDYRSK = . if (T_EDYRSK == -99)
replace AID_KF = . if (AID_KF == -99)
replace KTRAN1K = . if (KTRAN1K == -99)
replace KTRAN2K = . if (KTRAN2K == -99)
replace KTRAN3K = . if (KTRAN3K == -99)
replace KTRAN4K = . if (KTRAN4K == -99)
replace KTRAN5K = . if (KTRAN5K == -99)
replace KTRAN6K = . if (KTRAN6K == -99)
replace KTRAN7K = . if (KTRAN7K == -99)
replace KTRAN8K = . if (KTRAN8K == -99)
replace AFR_AMK = . if (AFR_AMK == -99.00)
replace NAT_AMK = . if (NAT_AMK == -99.000)
replace WHITEK = . if (WHITEK == -99.00)
replace LATINOK = . if (LATINOK == -99.00)
replace ASIANK = . if (ASIANK == -99.000)
replace OTHERK = . if (OTHERK == -99.000)
replace CCNES1AK = . if (CCNES1AK == -6 | CCNES1AK == -99)
replace CCNES1BK = . if (CCNES1BK == -99)
replace CCNES1CK = . if (CCNES1CK == -99)
replace CCNES1DK = . if (CCNES1DK == -99)
replace CCNES1EK = . if (CCNES1EK == -99)
replace CCNES1FK = . if (CCNES1FK == -99)
replace CCNES2AK = . if (CCNES2AK == -99)
replace CCNES2BK = . if (CCNES2BK == -99)
replace CCNES2CK = . if (CCNES2CK == -6 | CCNES2CK == -99)
replace CCNES2DK = . if (CCNES2DK == -99)
replace CCNES2EK = . if (CCNES2EK == -6 | CCNES2EK == -99)
replace CCNES2FK = . if (CCNES2FK == -99)
replace CCNES3AK = . if (CCNES3AK == -99)
replace CCNES3BK = . if (CCNES3BK == -6 | CCNES3BK == -99)
replace CCNES3CK = . if (CCNES3CK == -99)
replace CCNES3DK = . if (CCNES3DK == -99)
replace CCNES3EK = . if (CCNES3EK == -99)
replace CCNES3FK = . if (CCNES3FK == -99)
replace CCNES4AK = . if (CCNES4AK == -99)
replace CCNES4BK = . if (CCNES4BK == -99)
replace CCNES4CK = . if (CCNES4CK == -99)
replace CCNES4DK = . if (CCNES4DK == -99)
replace CCNES4EK = . if (CCNES4EK == -99)
replace CCNES4FK = . if (CCNES4FK == -99)
replace CCNES5AK = . if (CCNES5AK == -99)
replace CCNES5BK = . if (CCNES5BK == -99)
replace CCNES5CK = . if (CCNES5CK == -99)
replace CCNES5DK = . if (CCNES5DK == -99)
replace CCNES5EK = . if (CCNES5EK == -99)
replace CCNES5FK = . if (CCNES5FK == -99)
replace JOINEDK = . if (JOINEDK == -6 | JOINEDK == -99)
replace NUM_LEFTK = . if (NUM_LEFTK == -6 | NUM_LEFTK == -99)
replace CLS_SIZEKS = . if (CLS_SIZEKS == -99)
replace IEPKS = . if (IEPKS == -6 | IEPKS == -99)
replace AID_HRSKS = . if (AID_HRSKS == -6.00 | AID_HRSKS == -99.00)
replace AID_EDKS = . if (AID_EDKS == -99)
replace AID_CDAKS = . if (AID_CDAKS == -99)
replace LOCATIONK = . if (LOCATIONK == -99)
replace CHRESKS = . if (CHRESKS == -99)
replace CHRESUSKS = . if (CHRESUSKS == -99)
replace T_PLANPK = . if (T_PLANPK == -99)
replace T_PLANUK = . if (T_PLANUK == -99)
replace RDGPGMK = . if (RDGPGMK == -99)
replace RDGPGMTK = . if (RDGPGMTK == -99)
replace PARVISK = . if (PARVISK == -99)
replace PARVOLK = . if (PARVOLK == -99)
replace PARMTGK = . if (PARMTGK == -6 | PARMTGK == -99)
replace PARRPTK = . if (PARRPTK == -6 | PARRPTK == -99)
replace AID_KS = . if (AID_KS == -99)
replace KIDAGEK1 = . if (KIDAGEK1 == -99)
replace KIDAGEK2 = . if (KIDAGEK2 == -99)
replace KIDAGEK3 = . if (KIDAGEK3 == -99)
replace KIDAGEK4 = . if (KIDAGEK4 == -99)
replace KIDAGEK5 = . if (KIDAGEK5 == -99)
replace KIDAGEK6 = . if (KIDAGEK6 == -99)
replace KIDAGEK7 = . if (KIDAGEK7 == -99)
replace KIDAGEK8 = . if (KIDAGEK8 == -99)
replace KIDAGEK9 = . if (KIDAGEK9 == -99)
replace TARGPOPK = . if (TARGPOPK == -99)
replace CLSFRQK = . if (CLSFRQK == -99)
replace PCLIME_K = . if (PCLIME_K == -99.00)
replace NCLIME_K = . if (NCLIME_K == -99.00)
replace TSENSE_K = . if (TSENSE_K == -99.00)
replace OCNTL_K = . if (OCNTL_K == -99.00)
replace BHVMNG_K = . if (BHVMNG_K == -99.00)
replace PROD_K = . if (PROD_K == -99.00)
replace CNCTDV_K = . if (CNCTDV_K == -99.00)
replace LRNFMT_K = . if (LRNFMT_K == -99.00)
replace RTBSCS_K = . if (RTBSCS_K == -99.00)
replace QUALFD_K = . if (QUALFD_K == -99.00)
replace PCLIME_CK = . if (PCLIME_CK == -99)
replace NCLIME_CK = . if (NCLIME_CK == -99)
replace TSENSE_CK = . if (TSENSE_CK == -99)
replace OCNTL_CK = . if (OCNTL_CK == -99)
replace BHVMNG_CK = . if (BHVMNG_CK == -99)
replace PROD_CK = . if (PROD_CK == -99)
replace CNCTDV_CK = . if (CNCTDV_CK == -99)
replace LRNFMT_CK = . if (LRNFMT_CK == -99)
replace RTBSCS_CK = . if (RTBSCS_CK == -99)
replace QUALFD_CK = . if (QUALFD_CK == -99)
replace CLASTOTK = . if (CLASTOTK == -99.00)
replace CLASF1K = . if (CLASF1K == -99.00)
replace CLASF2K = . if (CLASF2K == -99.00)
replace ECERTOTK = . if (ECERTOTK == -99.00)
replace ECERF1K = . if (ECERF1K == -99.00)
replace ECERF2K = . if (ECERF2K == -99.00)
replace RATIOENK = . if (RATIOENK == -99.00)
replace RATIOOBK = . if (RATIOOBK == -99.00)
replace CSIZEENK = . if (CSIZEENK == -6 | CSIZEENK == -99)
replace CSIZEOBK = . if (CSIZEOBK == -99)
replace STAFFOBK = . if (STAFFOBK == -6 | STAFFOBK == -99)


*/
/********************************************************************

 Section 5: Save Outfile

  This section saves out a Stata system format file.  There is no reason to
  modify it if the macros in Section 1 were specified correctly.

*********************************************************************/

save `outfile', replace

