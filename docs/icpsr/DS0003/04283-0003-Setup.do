/**************************************************************************
 |                                                                         
 |                    STATA SETUP FILE FOR ICPSR 04283
 |           NATIONAL CENTER FOR EARLY DEVELOPMENT AND LEARNING
 |            MULTISTATE STUDY OF PRE-KINDERGARTEN, 2001-2003
 |        (DATASET 0003: PRE-K CLASSROOM LEVEL PUBLIC-USE VERSION)
 |
 |
 |  Please edit this file as instructed below.
 |  To execute, start Stata, change to the directory containing:
 |       - this do file
 |       - the ASCII data file
 |       - the dictionary file
 |
 |  Then execute the do file (e.g., do 04283-0003-statasetup.do)
 |
 **************************************************************************/

set mem 6m  /* Allocating 6 megabyte(s) of RAM for Stata SE to read the
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


label data "National Center for Early Development and Learning Multistate Study of Pre-Kindergarten, 2001-2003, Pre-K Classroom Level Public-Use Version"

#delimit ;
label define STAFFOBPF -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define RATIOENPF -99 "System Missing" ;
label define RATIOOBPF -99 "System Missing" ;
label define ECERTOTPF -99 "System Missing" ;
label define ECERF1PF  -99 "System Missing" ;
label define ECERF2PF  -99 "System Missing" ;
label define STAFFOBPS -99 "System Missing" ;
label define ECERTOTPS -99 "System Missing" ;
label define ECERF1PS  -99 "System Missing" ;
label define ECERF2PS  -99 "System Missing" ;
label define RATIOENPS -99 "System Missing" ;
label define RATIOOBPS -99 "System Missing" ;
label define SNPFRQCPF -99 "System Missing" ;
label define ASBASC_PF -99 "System Missing" ;
label define ASFCCC_PF -99 "System Missing" ;
label define ASINTC_PF -99 "System Missing" ;
label define ASMLSC_PF -99 "System Missing" ;
label define ASSGTC_PF -99 "System Missing" ;
label define ASWGTC_PF -99 "System Missing" ;
label define ASOSTC_PF -99 "System Missing" ;
label define CEAESC_PF -99 "System Missing" ;
label define CEFNMC_PF -99 "System Missing" ;
label define CEGRMC_PF -99 "System Missing" ;
label define CELTSC_PF -99 "System Missing" ;
label define CEMTHC_PF -99 "System Missing" ;
label define CEOLDC_PF -99 "System Missing" ;
label define CEPRRC_PF -99 "System Missing" ;
label define CERDGC_PF -99 "System Missing" ;
label define CESCIC_PF -99 "System Missing" ;
label define CESCSC_PF -99 "System Missing" ;
label define CEWRTC_PF -99 "System Missing" ;
label define CE_LITC_PF -99 "System Missing" ;
label define DSDSTC_PF -99 "System Missing" ;
label define AIRTNC_PF -99 "System Missing" ;
label define AIMINC_PF -99 "System Missing" ;
label define AISMPC_PF -99 "System Missing" ;
label define AIELBC_PF -99 "System Missing" ;
label define TCENCC_PF -99 "System Missing" ;
label define TCSCFC_PF -99 "System Missing" ;
label define TCDDTC_PF -99 "System Missing" ;
label define TCSCLC_PF -99 "System Missing" ;
label define AIELBC_C_PF -99 "System Missing" ;
label define AIRTNC_C_PF -99 "System Missing" ;
label define AISMPC_C_PF -99 "System Missing" ;
label define AINONEC_C_PF -99 "System Missing" ;
label define CEREADC_C_PF -99 "System Missing" ;
label define CELTSC_C_PF -99 "System Missing" ;
label define CEOLDC_C_PF -99 "System Missing" ;
label define CEMTHC_C_PF -99 "System Missing" ;
label define CESCIC_C_PF -99 "System Missing" ;
label define CEWRTC_C_PF -99 "System Missing" ;
label define CESCSC_C_PF -99 "System Missing" ;
label define CEAESC_C_PF -99 "System Missing" ;
label define CEMOTC_C_PF -99 "System Missing" ;
label define CENONEC_C_PF -99 "System Missing" ;
label define SNPFRQCPS -99 "System Missing" ;
label define CLSFRQPF  -99 "System Missing" ;
label define PCLIME_PF -99 "System Missing" ;
label define NCLIME_PF -99 "System Missing" ;
label define TSENSE_PF -99 "System Missing" ;
label define OCNTL_PF  -99 "System Missing" ;
label define BHVMNG_PF -99 "System Missing" ;
label define PROD_PF   -99 "System Missing" ;
label define CNCTDV_PF -99 "System Missing" ;
label define LRNFMT_PF -99 "System Missing" ;
label define RTBSCS_PF -99 "System Missing" ;
label define QUALFD_PF -99 "System Missing" ;
label define PCLIME_CPF -99 "System Missing" ;
label define NCLIME_CPF -99 "System Missing" ;
label define TSENSE_CPF -99 "System Missing" ;
label define OCNTL_CPF -99 "System Missing" ;
label define BHVMNG_CPF -99 "System Missing" ;
label define PROD_CPF  -99 "System Missing" ;
label define CNCTDV_CPF -99 "System Missing" ;
label define LRNFMT_CPF -99 "System Missing" ;
label define RTBSCS_CPF -99 "System Missing" ;
label define QUALFD_CPF -99 "System Missing" ;
label define CLASTOTPF -99 "System Missing" ;
label define CLASF1PF  -99 "System Missing" ;
label define CLASF2PF  -99 "System Missing" ;
label define CLSFRQPS  -99 "System Missing" ;
label define PCLIME_PS -99 "System Missing" ;
label define NCLIME_PS -99 "System Missing" ;
label define TSENSE_PS -99 "System Missing" ;
label define OCNTL_PS  -99 "System Missing" ;
label define BHVMNG_PS -99 "System Missing" ;
label define PROD_PS   -99 "System Missing" ;
label define CNCTDV_PS -99 "System Missing" ;
label define LRNFMT_PS -99 "System Missing" ;
label define RTBSCS_PS -99 "System Missing" ;
label define QUALFD_PS -99 "System Missing" ;
label define PCLIME_CPS -99 "System Missing" ;
label define NCLIME_CPS -99 "System Missing" ;
label define TSENSE_CPS -99 "System Missing" ;
label define OCNTL_CPS -99 "System Missing" ;
label define BHVMNG_CPS -99 "System Missing" ;
label define PROD_CPS  -99 "System Missing" ;
label define CNCTDV_CPS -99 "System Missing" ;
label define LRNFMT_CPS -99 "System Missing" ;
label define RTBSCS_CPS -99 "System Missing" ;
label define QUALFD_CPS -99 "System Missing" ;
label define CLASTOTPS -99 "System Missing" ;
label define CLASF1PS  -99 "System Missing" ;
label define CLASF2PS  -99 "System Missing" ;
label define LEAD_1    -99 "System Missing" ;
label define EXPER01P  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define EXPER02P  -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define EXPER03P  -99 "System Missing" ;
label define RACE_01   -99 "System Missing" 0 "No" 1 "Yes" ;
label define RACE_02   -99 "System Missing" 0 "No" 1 "Yes" ;
label define RACE_03   -99 "System Missing" 0 "No" 1 "Yes" ;
label define RACE_04   -99 "System Missing" 0 "No" 1 "Yes" ;
label define RACE_05   -99 "System Missing" 0 "No" 1 "Yes" ;
label define RACE_06   -99 "System Missing" 0 "No" 1 "Yes" ;
label define RACE_07   -99 "System Missing" 0 "No" 1 "Yes" ;
label define RACE_08   -99 "System Missing" 0 "No" 1 "Yes" ;
label define RACE_09   -99 "System Missing" 0 "No" 1 "Yes" ;
label define RACE_10   -99 "System Missing" 0 "No" 1 "Yes" ;
label define RACE_11   -99 "System Missing" 0 "No" 1 "Yes" ;
label define RACE_12   -99 "System Missing" 0 "No" 1 "Yes" ;
label define RACE_13   -99 "System Missing" 0 "No" 1 "Yes" ;
label define RACE_14   -99 "System Missing" 0 "No" 1 "Yes" ;
label define RACE_15   -99 "System Missing" 0 "No" 1 "Yes" ;
label define RACE_16   -99 "System Missing" 0 "No" 1 "Yes" ;
label define MONTHS    -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define EMPLHRP   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define EXPTOTP   -99 "System Missing" ;
label define BACERT_A  -99 "System Missing"
                       0 "Has a BA or better, but no State Certificate ( < 4 yrs)"
                       1 "Has a BA or better, and has State Certificate ( < 4 yrs)" ;
label define BACERT_B  -99 "System Missing"
                       0 "Has a BA or better, but no State Certificate ( 4 yrs old)"
                       1 "Has a BA or better, and has State Certificate ( 4 yrs old)" ;
label define BACERT_C  -99 "System Missing"
                       0 "Has a BA or better, but no State Certificate (Kind)"
                       1 "Has a BA or better, and has State Certificate (Kind)" ;
label define BACERT_D  -99 "System Missing"
                       0 "Has a BA or better, but no State Certificate (Early Elem)"
                       1 "Has a BA or better, and has State Certificate (Early Elem)" ;
label define BACERT_E  -99 "System Missing"
                       0 "Has a BA or better, but no State Certificate (Special Ed)"
                       1 "Has a BA or better, and has State Certificate (Special Ed)" ;
label define BACERT_F  -99 "System Missing"
                       0 "Has a BA or better, but no State Certificate (LEP or ESL)"
                       1 "Has a BA or better, and has State Certificate (LEP or ESL)" ;
label define BACERT_G  -99 "System Missing"
                       0 "Has a BA or better, but no State Certificate (Other)"
                       1 "Has a BA or better, and has State Certificate (Other)" ;
label define NOBACERT  -99 "System Missing"
                       0 "Teacher does not have a BA, and does not claim accreditation"
                       1 "Teacher does not have a BA, but does claim accreditation" ;
label define T_EDUCP   -99 "System Missing" 1 "8th Grade or Less"
                       2 "Some HS, but no Diploma"
                       3 "HS Diploma or equivalent"
                       4 "HS Diploma + Training Certificate"
                       5 "Some college but no degree"
                       6 "AA, AS, Two-Year Degree" 7 "Bachelor's Degree"
                       8 "At least 1 Year past BA" 9 "Master's Degree"
                       10 "Education Specialist or Professional Degree"
                       11 "Doctoral Degree" 12 "Other" ;
label define TMAJORP   -99 "System Missing" 1 "Early Childhood Education"
                       2 "Elementary Education" 3 "Special Education"
                       4 "English as a Second Language" 5 "Child Development"
                       6 "N/A (No degree)" 7 "Other" 8 "Other Education"
                       9 "Psychology (Any)" 10 "Home Economics"
                       11 "Social Work/Human Services" 12 "Sociology"
                       13 "Reading" ;
label define T_CDAP    -99 "System Missing" 1 "Yes" 2 "No" ;
label define TGENDERP  -99 "System Missing" 1 "Male" 2 "Female" ;
label define AM_NUMP   -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define PM_NUMP   -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define FD_NUMP   -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define CLS_SIZEPF -99 "System Missing" ;
label define CLASTYPP  -99 "System Missing" 1 "3 & 4 year olds"
                       2 "4 year olds (and 5 year olds who will be in K next year)"
                       3 "4 year olds & kindergarteners" 4 "Other" ;
label define LEPPF     -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable" ;
label define LANG_01P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define LANG_02P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define LANG_03P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define TLANG01P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define TLANG02P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define TLANG03P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define IEPPF     -99 "System Missing" -5 "Not Applicable" ;
label define DAY_WKP   -99 "System Missing" ;
label define CREDENTP  -99 "System Missing" 1 "ECE credential"
                       2 "K credential" 3 "EE credential"
                       4 "Other Credential" ;
label define CURRICP   -99 "System Missing" 1 "High Scope" 2 "Creative"
                       3 "Named curriculum" 4 "No clear curriculum" ;
label define CALC_WAGEP -99 "System Missing" ;
label define T_DEPPF   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define SCHDAYP   -99 "System Missing" ;
label define HOURSDAYPP -99 "System Missing" ;
label define HOURSDAYP -99 "System Missing" ;
label define HOURSWKP  -99 "System Missing" ;
label define FULLDAYP  -99 "System Missing" 0 "No" 1 "Yes" ;
label define BOYSP     -99 "System Missing" ;
label define PKTRAN1P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define PKTRAN2P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define PKTRAN3P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define PKTRAN4P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define PKTRAN5P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define PKTRAN6P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define PKTRAN7P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define PKTRAN8P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define CERT4YRP  -99 "System Missing" 0 "No" 1 "Yes" ;
label define ENGONLYP  -99 "System Missing" ;
label define AFR_AMP   -99 "System Missing" ;
label define NAT_AMP   -99 "System Missing" ;
label define WHITEP    -99 "System Missing" ;
label define LATINOP   -99 "System Missing" ;
label define ASIANP    -99 "System Missing" ;
label define OTHERP    -99 "System Missing" ;
label define M_EDUCP   -99 "System Missing" ;
label define INCOME_P  -99 "System Missing" ;
label define MALEP     -99 "System Missing" 0 "Female" 1 "Male" ;
label define PERPOORP  -99 "System Missing" ;
label define PROPFAMP  -99 "System Missing" ;
label define T_EDYRS   -99 "System Missing" ;
label define T_BAP     -99 "System Missing" 0 "No" 1 "Yes" ;
label define T_IDEAP   -99 "System Missing" ;
label define T_BELIEFP -99 "System Missing" ;
label define T_AGEP    -99 "System Missing" ;
label define AFR_AMTP  -99 "System Missing" 0 "No" 1 "Yes" ;
label define NAT_AMTP  -99 "System Missing" 0 "No" 1 "Yes" ;
label define WHITETP   -99 "System Missing" 0 "No" 1 "Yes" ;
label define ASIANTP   -99 "System Missing" 0 "No" 1 "Yes" ;
label define LATINATP  -99 "System Missing" 0 "No" 1 "Yes" ;
label define OTHERTP   -99 "System Missing" 0 "No" 1 "Yes" ;
label define T_RACEP   -99 "System Missing" 1 "Latin American"
                       2 "African American" 3 "Native American" 4 "Asian"
                       5 "White" 6 "Multiracial" ;
label define CLS_SIZEPS -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define JOINEDPS  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define NUM_LEFTPS -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define IEPPS     -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define PPLANHRP  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "0"
                       2 "2 or less" 3 "3 - 4" 4 "5 - 6" 5 "7 - 9"
                       6 "10 or More" ;
label define UPLANHRP  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "0"
                       2 "2 or less" 3 "3 - 4" 4 "5 - 6" 5 "7 - 9"
                       6 "10 or More" ;
label define TRAIN01P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define TRAIN02P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define TRAIN03P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define TRAIN04P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define TRAIN05P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define TRAIN06P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define TRAIN07P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define PARVISP   -99 "System Missing" 1 "Not allowed during the day"
                       2 "Only at specific times"
                       3 "Only with advance notice" 4 "At any time" ;
label define PARVOLP   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define AID_HRSP  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define AID_EDP   -99 "System Missing" 1 "8th Grade or Less"
                       2 "Some HS, but no Diploma"
                       3 "HS Diploma or equivalent"
                       4 "HS Diploma + Training Certificate"
                       5 "Some college but no degree"
                       6 "AA, AS, Two-Year Degree" 7 "Bachelor's Degree"
                       8 "At least 1 Year past BA" 9 "Master's Degree"
                       10 "Education Specialist or Professional Degree"
                       11 "Doctoral Degree" 12 "Other" ;
label define AID_CDAP  -99 "System Missing" 1 "Yes" 2 "No" ;
label define LOCATIONP -99 "System Missing" 1 "Yes" 2 "No" ;
label define TDEPPS    -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define HSCLSP    -99 "System Missing" 1 "Yes" 2 "No" ;
label define TCESDP    -99 "System Missing" 0 "No" 1 "Yes" ;
label define KTRAN1P   -99 "System Missing" 0 "No" 1 "Yes" ;
label define KTRAN2P   -99 "System Missing" 0 "No" 1 "Yes" ;
label define KTRAN3P   -99 "System Missing" 0 "No" 1 "Yes" ;
label define KTRAN4P   -99 "System Missing" 0 "No" 1 "Yes" ;
label define KTRAN5P   -99 "System Missing" 0 "No" 1 "Yes" ;
label define KTRAN6P   -99 "System Missing" 0 "No" 1 "Yes" ;
label define KTRAN7P   -99 "System Missing" 0 "No" 1 "Yes" ;
label define KTRAN8P   -99 "System Missing" 0 "No" 1 "Yes" ;
label define KTRAN9P   -99 "System Missing" 0 "No" 1 "Yes" ;
label define SITE_WT   -99 "System Missing" ;
label define PSU       -99 "System Missing" ;
label define BENEFITP_1 -99 "System Missing" 1 "Yes" 2 "No" ;
label define BENEFITP_2 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define BENEFITP_3 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define BENEFITP_4 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define BENEFITP_5 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define BENEFITP_6 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define BENEFITP_7 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define BENEFITP_8 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define BENEFITP_9 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define POLICYP_1 -99 "System Missing" 1 "Yes" 2 "No" ;
label define POLICYP_2 -99 "System Missing" 1 "Yes" 2 "No" ;
label define POLICYP_3 -99 "System Missing" 1 "Yes" 2 "No" ;
label define POLICYP_4 -99 "System Missing" 1 "Yes" 2 "No" ;
label define POLICYP_5 -99 "System Missing" 1 "Yes" 2 "No" ;
label define POLICYP_6 -99 "System Missing" 1 "Yes" 2 "No" ;
label define POLICYP_7 -99 "System Missing" 1 "Yes" 2 "No" ;
label define POLICYP_8 -99 "System Missing" 1 "Yes" 2 "No" ;
label define POLICYP_9 -99 "System Missing" 1 "Yes" 2 "No" ;
label define SERVICEP_1 -99 "System Missing" 1 "Yes" 2 "No" ;
label define SERVICEP_2 -99 "System Missing" 1 "Yes" 2 "No" ;
label define SERVICEP_3 -99 "System Missing" 1 "Yes" 2 "No" ;
label define SERVICEP_4 -99 "System Missing" 1 "Yes" 2 "No" ;
label define SERVICEP_5 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define SERVICEP_6 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define SERVICEP_7 -99 "System Missing" 1 "Yes" 2 "No" ;
label define SERVICEP_8 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define SERVICEP_9 -99 "System Missing" 1 "Yes" 2 "No" ;
label define SERVICEP_10 -99 "System Missing" 1 "Yes" 2 "No" ;
label define SERVICEP_11 -99 "System Missing" 1 "Yes" 2 "No" ;
label define T_CHNG    -99 "System Missing"
                       0 "No change in teacher, classroom"
                       1 "Change in teacher" 2 "Change in classroom" ;


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
replace STAFFOBPF = . if (STAFFOBPF == -6 | STAFFOBPF == -99)
replace RATIOENPF = . if (RATIOENPF == -99.00)
replace RATIOOBPF = . if (RATIOOBPF == -99.00)
replace ECERTOTPF = . if (ECERTOTPF == -99.00)
replace ECERF1PF = . if (ECERF1PF == -99.00)
replace ECERF2PF = . if (ECERF2PF == -99.00)
replace STAFFOBPS = . if (STAFFOBPS == -99)
replace ECERTOTPS = . if (ECERTOTPS == -99.00)
replace ECERF1PS = . if (ECERF1PS == -99.00)
replace ECERF2PS = . if (ECERF2PS == -99.00)
replace RATIOENPS = . if (RATIOENPS == -99.00)
replace RATIOOBPS = . if (RATIOOBPS == -99.00)
replace SNPFRQCPF = . if (SNPFRQCPF == -99)
replace ASBASC_PF = . if (ASBASC_PF == -99.000)
replace ASFCCC_PF = . if (ASFCCC_PF == -99.000)
replace ASINTC_PF = . if (ASINTC_PF == -99.000)
replace ASMLSC_PF = . if (ASMLSC_PF == -99.000)
replace ASSGTC_PF = . if (ASSGTC_PF == -99.000)
replace ASWGTC_PF = . if (ASWGTC_PF == -99.000)
replace ASOSTC_PF = . if (ASOSTC_PF == -99.000)
replace CEAESC_PF = . if (CEAESC_PF == -99.000)
replace CEFNMC_PF = . if (CEFNMC_PF == -99.000)
replace CEGRMC_PF = . if (CEGRMC_PF == -99.000)
replace CELTSC_PF = . if (CELTSC_PF == -99.000)
replace CEMTHC_PF = . if (CEMTHC_PF == -99.000)
replace CEOLDC_PF = . if (CEOLDC_PF == -99.000)
replace CEPRRC_PF = . if (CEPRRC_PF == -99.000)
replace CERDGC_PF = . if (CERDGC_PF == -99.000)
replace CESCIC_PF = . if (CESCIC_PF == -99.000)
replace CESCSC_PF = . if (CESCSC_PF == -99.000)
replace CEWRTC_PF = . if (CEWRTC_PF == -99.000)
replace CE_LITC_PF = . if (CE_LITC_PF == -99.000)
replace DSDSTC_PF = . if (DSDSTC_PF == -99.000)
replace AIRTNC_PF = . if (AIRTNC_PF == -99.000)
replace AIMINC_PF = . if (AIMINC_PF == -99.000)
replace AISMPC_PF = . if (AISMPC_PF == -99.000)
replace AIELBC_PF = . if (AIELBC_PF == -99.000)
replace TCENCC_PF = . if (TCENCC_PF == -99.000)
replace TCSCFC_PF = . if (TCSCFC_PF == -99.000)
replace TCDDTC_PF = . if (TCDDTC_PF == -99.000)
replace TCSCLC_PF = . if (TCSCLC_PF == -99.000)
replace AIELBC_C_PF = . if (AIELBC_C_PF == -99.000)
replace AIRTNC_C_PF = . if (AIRTNC_C_PF == -99.000)
replace AISMPC_C_PF = . if (AISMPC_C_PF == -99.000)
replace AINONEC_C_PF = . if (AINONEC_C_PF == -99.000)
replace CEREADC_C_PF = . if (CEREADC_C_PF == -99.000)
replace CELTSC_C_PF = . if (CELTSC_C_PF == -99.000)
replace CEOLDC_C_PF = . if (CEOLDC_C_PF == -99.000)
replace CEMTHC_C_PF = . if (CEMTHC_C_PF == -99.000)
replace CESCIC_C_PF = . if (CESCIC_C_PF == -99.000)
replace CEWRTC_C_PF = . if (CEWRTC_C_PF == -99.000)
replace CESCSC_C_PF = . if (CESCSC_C_PF == -99.000)
replace CEAESC_C_PF = . if (CEAESC_C_PF == -99.000)
replace CEMOTC_C_PF = . if (CEMOTC_C_PF == -99.000)
replace CENONEC_C_PF = . if (CENONEC_C_PF == -99.000)
replace SNPFRQCPS = . if (SNPFRQCPS == -99)
replace CLSFRQPF = . if (CLSFRQPF == -99)
replace PCLIME_PF = . if (PCLIME_PF == -99.00)
replace NCLIME_PF = . if (NCLIME_PF == -99.00)
replace TSENSE_PF = . if (TSENSE_PF == -99.00)
replace OCNTL_PF = . if (OCNTL_PF == -99.00)
replace BHVMNG_PF = . if (BHVMNG_PF == -99.00)
replace PROD_PF = . if (PROD_PF == -99.00)
replace CNCTDV_PF = . if (CNCTDV_PF == -99.00)
replace LRNFMT_PF = . if (LRNFMT_PF == -99.00)
replace RTBSCS_PF = . if (RTBSCS_PF == -99.00)
replace QUALFD_PF = . if (QUALFD_PF == -99.00)
replace PCLIME_CPF = . if (PCLIME_CPF == -99)
replace NCLIME_CPF = . if (NCLIME_CPF == -99)
replace TSENSE_CPF = . if (TSENSE_CPF == -99)
replace OCNTL_CPF = . if (OCNTL_CPF == -99)
replace BHVMNG_CPF = . if (BHVMNG_CPF == -99)
replace PROD_CPF = . if (PROD_CPF == -99)
replace CNCTDV_CPF = . if (CNCTDV_CPF == -99)
replace LRNFMT_CPF = . if (LRNFMT_CPF == -99)
replace RTBSCS_CPF = . if (RTBSCS_CPF == -99)
replace QUALFD_CPF = . if (QUALFD_CPF == -99)
replace CLASTOTPF = . if (CLASTOTPF == -99.00)
replace CLASF1PF = . if (CLASF1PF == -99.00)
replace CLASF2PF = . if (CLASF2PF == -99.00)
replace CLSFRQPS = . if (CLSFRQPS == -99)
replace PCLIME_PS = . if (PCLIME_PS == -99.00)
replace NCLIME_PS = . if (NCLIME_PS == -99.00)
replace TSENSE_PS = . if (TSENSE_PS == -99.00)
replace OCNTL_PS = . if (OCNTL_PS == -99.00)
replace BHVMNG_PS = . if (BHVMNG_PS == -99.00)
replace PROD_PS = . if (PROD_PS == -99.00)
replace CNCTDV_PS = . if (CNCTDV_PS == -99.00)
replace LRNFMT_PS = . if (LRNFMT_PS == -99.00)
replace RTBSCS_PS = . if (RTBSCS_PS == -99.00)
replace QUALFD_PS = . if (QUALFD_PS == -99.00)
replace PCLIME_CPS = . if (PCLIME_CPS == -99)
replace NCLIME_CPS = . if (NCLIME_CPS == -99)
replace TSENSE_CPS = . if (TSENSE_CPS == -99)
replace OCNTL_CPS = . if (OCNTL_CPS == -99)
replace BHVMNG_CPS = . if (BHVMNG_CPS == -99)
replace PROD_CPS = . if (PROD_CPS == -99)
replace CNCTDV_CPS = . if (CNCTDV_CPS == -99)
replace LRNFMT_CPS = . if (LRNFMT_CPS == -99)
replace RTBSCS_CPS = . if (RTBSCS_CPS == -99)
replace QUALFD_CPS = . if (QUALFD_CPS == -99)
replace CLASTOTPS = . if (CLASTOTPS == -99.00)
replace CLASF1PS = . if (CLASF1PS == -99.00)
replace CLASF2PS = . if (CLASF2PS == -99.00)
replace LEAD_1 = . if (LEAD_1 == -99)
replace EXPER01P = . if (EXPER01P == -6.00 | EXPER01P == -99.00)
replace EXPER02P = . if (EXPER02P == -5.00 | EXPER02P == -99.00)
replace EXPER03P = . if (EXPER03P == -99.00)
replace RACE_01 = . if (RACE_01 == -99)
replace RACE_02 = . if (RACE_02 == -99)
replace RACE_03 = . if (RACE_03 == -99)
replace RACE_04 = . if (RACE_04 == -99)
replace RACE_05 = . if (RACE_05 == -99)
replace RACE_06 = . if (RACE_06 == -99)
replace RACE_07 = . if (RACE_07 == -99)
replace RACE_08 = . if (RACE_08 == -99)
replace RACE_09 = . if (RACE_09 == -99)
replace RACE_10 = . if (RACE_10 == -99)
replace RACE_11 = . if (RACE_11 == -99)
replace RACE_12 = . if (RACE_12 == -99)
replace RACE_13 = . if (RACE_13 == -99)
replace RACE_14 = . if (RACE_14 == -99)
replace RACE_15 = . if (RACE_15 == -99)
replace RACE_16 = . if (RACE_16 == -99)
replace MONTHS = . if (MONTHS == -6.00 | MONTHS == -99.00)
replace EMPLHRP = . if (EMPLHRP == -6.00 | EMPLHRP == -99.00)
replace EXPTOTP = . if (EXPTOTP == -99.00)
replace BACERT_A = . if (BACERT_A == -99)
replace BACERT_B = . if (BACERT_B == -99)
replace BACERT_C = . if (BACERT_C == -99)
replace BACERT_D = . if (BACERT_D == -99)
replace BACERT_E = . if (BACERT_E == -99)
replace BACERT_F = . if (BACERT_F == -99)
replace BACERT_G = . if (BACERT_G == -99)
replace NOBACERT = . if (NOBACERT == -99)
replace T_EDUCP = . if (T_EDUCP == -99)
replace TMAJORP = . if (TMAJORP == -99)
replace T_CDAP = . if (T_CDAP == -99)
replace TGENDERP = . if (TGENDERP == -99)
replace AM_NUMP = . if (AM_NUMP == -5 | AM_NUMP == -99)
replace PM_NUMP = . if (PM_NUMP == -5 | PM_NUMP == -99)
replace FD_NUMP = . if (FD_NUMP == -5 | FD_NUMP == -99)
replace CLS_SIZEPF = . if (CLS_SIZEPF == -99)
replace CLASTYPP = . if (CLASTYPP == -99)
replace LEPPF = . if (LEPPF == -5 | LEPPF == -6 | LEPPF == -99)
replace LANG_01P = . if (LANG_01P == -99)
replace LANG_02P = . if (LANG_02P == -99)
replace LANG_03P = . if (LANG_03P == -99)
replace TLANG01P = . if (TLANG01P == -99)
replace TLANG02P = . if (TLANG02P == -99)
replace TLANG03P = . if (TLANG03P == -99)
replace IEPPF = . if (IEPPF == -5 | IEPPF == -99)
replace DAY_WKP = . if (DAY_WKP == -99)
replace CREDENTP = . if (CREDENTP == -99)
replace CURRICP = . if (CURRICP == -99)
replace CALC_WAGEP = . if (CALC_WAGEP == -99.00)
replace T_DEPPF = . if (T_DEPPF == -6.00 | T_DEPPF == -99.00)
replace SCHDAYP = . if (SCHDAYP == -99.00)
replace HOURSDAYPP = . if (HOURSDAYPP == -99.00)
replace HOURSDAYP = . if (HOURSDAYP == -99.00)
replace HOURSWKP = . if (HOURSWKP == -99.00)
replace FULLDAYP = . if (FULLDAYP == -99)
replace BOYSP = . if (BOYSP == -99.000)
replace PKTRAN1P = . if (PKTRAN1P == -99)
replace PKTRAN2P = . if (PKTRAN2P == -99)
replace PKTRAN3P = . if (PKTRAN3P == -99)
replace PKTRAN4P = . if (PKTRAN4P == -99)
replace PKTRAN5P = . if (PKTRAN5P == -99)
replace PKTRAN6P = . if (PKTRAN6P == -99)
replace PKTRAN7P = . if (PKTRAN7P == -99)
replace PKTRAN8P = . if (PKTRAN8P == -99)
replace CERT4YRP = . if (CERT4YRP == -99)
replace ENGONLYP = . if (ENGONLYP == -99.00)
replace AFR_AMP = . if (AFR_AMP == -99.00)
replace NAT_AMP = . if (NAT_AMP == -99.000)
replace WHITEP = . if (WHITEP == -99.00)
replace LATINOP = . if (LATINOP == -99.00)
replace ASIANP = . if (ASIANP == -99.000)
replace OTHERP = . if (OTHERP == -99.000)
replace M_EDUCP = . if (M_EDUCP == -99.00)
replace INCOME_P = . if (INCOME_P == -99.00)
replace MALEP = . if (MALEP == -99.00)
replace PERPOORP = . if (PERPOORP == -99.00)
replace PROPFAMP = . if (PROPFAMP == -99.00)
replace T_EDYRS = . if (T_EDYRS == -99)
replace T_BAP = . if (T_BAP == -99)
replace T_IDEAP = . if (T_IDEAP == -99.00)
replace T_BELIEFP = . if (T_BELIEFP == -99.00)
replace T_AGEP = . if (T_AGEP == -99)
replace AFR_AMTP = . if (AFR_AMTP == -99)
replace NAT_AMTP = . if (NAT_AMTP == -99)
replace WHITETP = . if (WHITETP == -99)
replace ASIANTP = . if (ASIANTP == -99)
replace LATINATP = . if (LATINATP == -99)
replace OTHERTP = . if (OTHERTP == -99)
replace T_RACEP = . if (T_RACEP == -99)
replace CLS_SIZEPS = . if (CLS_SIZEPS == -6 | CLS_SIZEPS == -99)
replace JOINEDPS = . if (JOINEDPS == -6 | JOINEDPS == -99)
replace NUM_LEFTPS = . if (NUM_LEFTPS == -6 | NUM_LEFTPS == -99)
replace IEPPS = . if (IEPPS == -6 | IEPPS == -99)
replace PPLANHRP = . if (PPLANHRP == -6 | PPLANHRP == -99)
replace UPLANHRP = . if (UPLANHRP == -6 | UPLANHRP == -99)
replace TRAIN01P = . if (TRAIN01P == -99)
replace TRAIN02P = . if (TRAIN02P == -99)
replace TRAIN03P = . if (TRAIN03P == -99)
replace TRAIN04P = . if (TRAIN04P == -99)
replace TRAIN05P = . if (TRAIN05P == -99)
replace TRAIN06P = . if (TRAIN06P == -99)
replace TRAIN07P = . if (TRAIN07P == -99)
replace PARVISP = . if (PARVISP == -99)
replace PARVOLP = . if (PARVOLP == -6 | PARVOLP == -99)
replace AID_HRSP = . if (AID_HRSP == -6.00 | AID_HRSP == -99.00)
replace AID_EDP = . if (AID_EDP == -99)
replace AID_CDAP = . if (AID_CDAP == -99)
replace LOCATIONP = . if (LOCATIONP == -99)
replace TDEPPS = . if (TDEPPS == -6.00 | TDEPPS == -99.00)
replace HSCLSP = . if (HSCLSP == -99)
replace TCESDP = . if (TCESDP == -99)
replace KTRAN1P = . if (KTRAN1P == -99)
replace KTRAN2P = . if (KTRAN2P == -99)
replace KTRAN3P = . if (KTRAN3P == -99)
replace KTRAN4P = . if (KTRAN4P == -99)
replace KTRAN5P = . if (KTRAN5P == -99)
replace KTRAN6P = . if (KTRAN6P == -99)
replace KTRAN7P = . if (KTRAN7P == -99)
replace KTRAN8P = . if (KTRAN8P == -99)
replace KTRAN9P = . if (KTRAN9P == -99)
replace SITE_WT = . if (SITE_WT == -99.00)
replace PSU = . if (PSU == -99)
replace BENEFITP_1 = . if (BENEFITP_1 == -99)
replace BENEFITP_2 = . if (BENEFITP_2 == -6 | BENEFITP_2 == -99)
replace BENEFITP_3 = . if (BENEFITP_3 == -6 | BENEFITP_3 == -99)
replace BENEFITP_4 = . if (BENEFITP_4 == -6 | BENEFITP_4 == -99)
replace BENEFITP_5 = . if (BENEFITP_5 == -6 | BENEFITP_5 == -99)
replace BENEFITP_6 = . if (BENEFITP_6 == -6 | BENEFITP_6 == -99)
replace BENEFITP_7 = . if (BENEFITP_7 == -6 | BENEFITP_7 == -99)
replace BENEFITP_8 = . if (BENEFITP_8 == -6 | BENEFITP_8 == -99)
replace BENEFITP_9 = . if (BENEFITP_9 == -6 | BENEFITP_9 == -99)
replace POLICYP_1 = . if (POLICYP_1 == -99)
replace POLICYP_2 = . if (POLICYP_2 == -99)
replace POLICYP_3 = . if (POLICYP_3 == -99)
replace POLICYP_4 = . if (POLICYP_4 == -99)
replace POLICYP_5 = . if (POLICYP_5 == -99)
replace POLICYP_6 = . if (POLICYP_6 == -99)
replace POLICYP_7 = . if (POLICYP_7 == -99)
replace POLICYP_8 = . if (POLICYP_8 == -99)
replace POLICYP_9 = . if (POLICYP_9 == -99)
replace SERVICEP_1 = . if (SERVICEP_1 == -99)
replace SERVICEP_2 = . if (SERVICEP_2 == -99)
replace SERVICEP_3 = . if (SERVICEP_3 == -99)
replace SERVICEP_4 = . if (SERVICEP_4 == -99)
replace SERVICEP_5 = . if (SERVICEP_5 == -6 | SERVICEP_5 == -99)
replace SERVICEP_6 = . if (SERVICEP_6 == -6 | SERVICEP_6 == -99)
replace SERVICEP_7 = . if (SERVICEP_7 == -99)
replace SERVICEP_8 = . if (SERVICEP_8 == -6 | SERVICEP_8 == -99)
replace SERVICEP_9 = . if (SERVICEP_9 == -6 | SERVICEP_9 == -99)
replace SERVICEP_10 = . if (SERVICEP_10 == -6 | SERVICEP_10 == -99)
replace SERVICEP_11 = . if (SERVICEP_11 == -6 | SERVICEP_11 == -99)
replace T_CHNG = . if (T_CHNG == -6 | T_CHNG == -99)


*/
/********************************************************************

 Section 5: Save Outfile

  This section saves out a Stata system format file.  There is no reason to
  modify it if the macros in Section 1 were specified correctly.

*********************************************************************/

save `outfile', replace

