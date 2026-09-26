/**************************************************************************
 |                                                                         
 |                    STATA SETUP FILE FOR ICPSR 04283
 |           NATIONAL CENTER FOR EARLY DEVELOPMENT AND LEARNING
 |            MULTISTATE STUDY OF PRE-KINDERGARTEN, 2001-2003
 |          (DATASET 0001: MAIN CHILD LEVEL PUBLIC-USE VERSION)
 |
 |
 |  Please edit this file as instructed below.
 |  To execute, start Stata, change to the directory containing:
 |       - this do file
 |       - the ASCII data file
 |       - the dictionary file
 |
 |  Then execute the do file (e.g., do 04283-0001-statasetup.do)
 |
 **************************************************************************/

set mem 20m  /* Allocating 20 megabyte(s) of RAM for Stata SE to read the
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


label data "National Center for Early Development and Learning Multistate Study of Pre-Kindergarten, 2001-2003, Main Child Level Public-Use Version"

#delimit ;
label define CHGENP    -99 "System Missing" 1 "Male" 2 "Female" ;
label define CHMATEDCP -99 "System Missing" 1 "8th Grade or less"
                       2 "Some high school" 3 "HS diploma or equivalent"
                       4 "Some college" 5 "HS + tech training"
                       6 "AA, AS, 2yr degree" 7 "Bachelor's" 8 "Master's"
                       9 "Doctoral" 10 "Other" ;
label define POORP     -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHRACE_AAP -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHRACE_ASP -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHRACE_LTP -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHRACE_NAP -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHRACE_OTP -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHRACE_WHP -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHRACEP   -99 "System Missing" 1 "Latino" 2 "African American"
                       3 "Native American" 4 "Asian American" 5 "White"
                       6 "Multiracial" ;
label define CCARRP_1  -99 "System Missing" 0 "No" 1 "Yes" ;
label define CCARRP_2  -99 "System Missing" 0 "No" 1 "Yes" ;
label define CCARRP_3  -99 "System Missing" 0 "No" 1 "Yes" ;
label define CCARRP_4  -99 "System Missing" 0 "No" 1 "Yes" ;
label define CCARRP_5  -99 "System Missing" 0 "No" 1 "Yes" ;
label define CCARRP_6  -99 "System Missing" 0 "No" 1 "Yes" ;
label define CCARRP_7  -99 "System Missing" 0 "No" 1 "Yes" ;
label define CCARRP_8  -99 "System Missing" 0 "No" 1 "Yes" ;
label define CCARRP_9  -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHHLTHFP  -99 "System Missing" 1 "Poor" 2 "Fair" 3 "Good"
                       4 "Very Good" 5 "Excellent" ;
label define CHFLANGP_1 -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHFLANGP_2 -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHFLANGP_3 -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHCLANGP_1 -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHCLANGP_2 -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHCLANGP_3 -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHHSNUMP  -99 "System Missing" ;
label define CHHSUN18P -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define CHINCOMCP -99 "System Missing" 1 "$5,000 or <"
                       2 "$5,001 - $10,000" 3 "$10,001 - $15,000"
                       4 "$15,001 - $20,000" 5 "$20,001 - $25,000"
                       6 "$25,001 - $30,000" 7 "$30,001 - $35,000"
                       8 "$35,001 - $40,000" 9 "$40,001 - $45,000"
                       10 "$45,001 - $50,000" 11 "$50,001 - $55,000"
                       12 "$55,001 - $60,000" 13 "$60,001 - $65,000"
                       14 "$65,001 - $70,000" 15 "$70,001 - $75,000"
                       16 "$75,001 - $80,000" 17 "$80,001 - $85,000"
                       18 "$85,001 or >" ;
label define CHLIVEP_1 -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHLIVEP_2 -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHLIVEP_3 -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHLIVEP_4 -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHLIVEP_5 -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHLIVEP_6 -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHLIVEP_7 -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHLIVEP_8 -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHADULTP  -99 "System Missing" ;
label define CHMATEDNP -99 "System Missing" ;
label define CHINCOMNP -99 "System Missing" ;
label define PRELASTPF -99 "System Missing" ;
label define LETTEREPF -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define NUMBEREPF -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define COLOREPF  -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define HICNTEPF  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define HICNTCOREPF -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define CTOPPEPF  -99 "System Missing" -7 "Child Failed Practice Items"
                       -5 "No Response from Child / Not Applicable" ;
label define PPVTEPF   -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define PPVREPF   -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define OWLSEPF   -99 "System Missing" -8 "Error in Proctoring Form"
                       -7 "Child Failed Practice Items"
                       -5 "No Response from Child / Not Applicable" ;
label define WJ10_WEPF -99 "System Missing" -7 "Child Failed Practice Items"
                       -5 "No Response from Child / Not Applicable" ;
label define WJ10_SSEPF -99 "System Missing" -7 "Child Failed Practice Items"
                       -5 "No Response from Child / Not Applicable" ;
label define WJ21AEPF  -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define LETTERSPF -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define NUMBERSPF -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define COLORSPF  -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define TVIPSPF   -99 "System Missing" ;
label define TVIPRSPF  -99 "System Missing" ;
label define WM25SSPF  -99 "System Missing" ;
label define WM25WPF   -99 "System Missing" ;
label define HICNTSPF  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define HICNTCORSPF -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define ASMSTATPF -99 "System Missing" 1 "Absent"
                       2 "Full Assessment (English)"
                       3 "Full Assessment (Spanish)"
                       4 "Non-English, Spanish-Speaking Child Failed Pre-LAS"
                       5 "Partial Assessment (English)"
                       6 "Partial Assessment (Spanish)"
                       7 "Child Refused Assessment" ;
label define PRELASTPS -99 "System Missing" ;
label define LETTEREPS -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define NUMBEREPS -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define COLOREPS  -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define HICNTEPS  -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define HICNTCOREPS -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define CTOPPEPS  -99 "System Missing" -7 "Child Failed Practice Items"
                       -5 "No Response from Child / Not Applicable" ;
label define PPVTEPS   -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define PPVREPS   -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define OWLSEPS   -99 "System Missing" -8 "Error in Proctoring Form"
                       -5 "No Response from Child / Not Applicable" ;
label define WJ10_WEPS -99 "System Missing" -7 "Child Failed Practice Items"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable" ;
label define WJ10_SSEPS -99 "System Missing" -7 "Child Failed Practice Items"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable" ;
label define WJ21AEPS  -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define LETTERSPS -99 "System Missing" ;
label define NUMBERSPS -99 "System Missing" ;
label define COLORSPS  -99 "System Missing" ;
label define TVIPSPS   -99 "System Missing" ;
label define TVIPRSPS  -99 "System Missing" ;
label define WM25SSPS  -99 "System Missing" ;
label define WM25WPS   -99 "System Missing" ;
label define HICNTSPS  -99 "System Missing" ;
label define HICNTCORSPS -99 "System Missing" ;
label define ASMSTATPS -99 "System Missing" 1 "Absent"
                       2 "Full Assessment (English)"
                       3 "Full Assessment (Spanish)"
                       4 "Non-English, Spanish-Speaking Child Failed Pre-LAS"
                       5 "Partial Assessment (English)"
                       6 "Partial Assessment (Spanish)"
                       7 "Child Refused Assessment" 8 "DR" ;
label define HTCOMPPF  -99 "System Missing" ;
label define HTFTOLPF  -99 "System Missing" ;
label define HTASRTPF  -99 "System Missing" ;
label define HTTKORPF  -99 "System Missing" ;
label define HTPSSKPF  -99 "System Missing" ;
label define HTPROBPF  -99 "System Missing" ;
label define HTCNPRPF  -99 "System Missing" ;
label define HTINTNPF  -99 "System Missing" ;
label define HTLNPRPF  -99 "System Missing" ;
label define CSLANGPF  -99 "System Missing" ;
label define CSLANGPF1 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGPF2 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGPF3 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGPF4 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGPF5 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGPF6 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGPF7 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGPF8 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGPF9 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CHATNDPRKP -99 "System Missing" 1 "Yes" 2 "No" ;
label define CHHLTHTPF -99 "System Missing" 1 "Poor" 2 "Fair" 3 "Good"
                       4 "Very Good" 5 "Excellent" ;
label define COMPAREPF -99 "System Missing" 1 "Better Than Many"
                       2 "About the Same" 3 "A Little Worse" 4 "Much Worse"
                       5 "Worst in Class" ;
label define BLOCKPF   -99 "System Missing" 1 "Not at All" 2 "Very Little"
                       3 "To Some Extent" 4 "To a Great Extent"
                       5 "To a Very Great Extent" ;
label define SETTINGPF -99 "System Missing"
                       1 "Only single class activity, person, situation, or setting"
                       2 "Only 2-3 class activities, persons, situations, or settings"
                       3 "Occurs in all settings and activities at school"
                       4 "Occurs anywhere and everywhere" ;
label define SERIOUSPF -99 "System Missing" -9 "Don't Know"
                       1 "No, Not Serious" 2 "Somewhat Serious"
                       3 "Yes, Pretty Serious" 4 "Yes, Extremely Serious" ;
label define SERVICEPF -99 "System Missing" 1 "Services not necessary"
                       2 "May benefit from, but has not been referred for services"
                       3 "Yes, referred"
                       4 "Yes, referred but not receiving services"
                       5 "Yes, has received or is receiving services"
                       6 "I do not know" ;
label define PROBPF_01 -99 "System Missing" 0 "Teacher did not indicate"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPF_02 -99 "System Missing" 0 "Teacher did not indicate"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPF_03 -99 "System Missing" 0 "Teacher did not indicate"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPF_04 -99 "System Missing" 0 "Teacher did not indicate"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPF_05 -99 "System Missing" 0 "Teacher did not indicate"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPF_06 -99 "System Missing" 0 "Teacher did not indicate"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPF_07 -99 "System Missing" 0 "Teacher did not indicate"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPF_08 -99 "System Missing" 0 "Teacher did not indicate"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPF_09 -99 "System Missing" 0 "Teacher did not indicate"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPF_10 -99 "System Missing" 0 "Teacher did not indicate"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPF_11 -99 "System Missing" 0 "Teacher did not indicate"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPF_12 -99 "System Missing" 0 "Teacher did not indicate"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPF_13 -99 "System Missing" 0 "Teacher did not indicate"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPF_14 -99 "System Missing" 0 "Teacher did not indicate"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPF_15 -99 "System Missing" 0 "Teacher did not indicate"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPF_16 -99 "System Missing" 0 "Teacher did not indicate"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPF_17 -99 "System Missing" 0 "Teacher did not indicate"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPF_18 -99 "System Missing" 0 "Teacher did not indicate"
                       1 "Teacher did indicate this was a serious problem" ;
label define HTCOMPPS  -99 "System Missing" ;
label define HTFTOLPS  -99 "System Missing" ;
label define HTASRTPS  -99 "System Missing" ;
label define HTTKORPS  -99 "System Missing" ;
label define HTPSSKPS  -99 "System Missing" ;
label define HTPROBPS  -99 "System Missing" ;
label define HTCNPRPS  -99 "System Missing" ;
label define HTINTNPS  -99 "System Missing" ;
label define HTLNPRPS  -99 "System Missing" ;
label define CSLANGPS  -99 "System Missing" ;
label define CSMATHPS  -99 "System Missing" ;
label define CSTOTPS   -99 "System Missing" ;
label define CSLANGPS1 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGPS2 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGPS3 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGPS4 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGPS5 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGPS6 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGPS7 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGPS8 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGPS9 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSMATHPS1 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSMATHPS2 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSMATHPS3 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSMATHPS4 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSMATHPS5 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSMATHPS6 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSMATHPS7 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define FIPCNP    -99 "System Missing" ;
label define FITSIP    -99 "System Missing" ;
label define OPGRFNP   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define OPSPEVP   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define OPPTCP    -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define PARCALLP  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define TCRCALLP  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define PARVISTP  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define TCRVISTP  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define PARINVTP  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define PARATNDP  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define PARSPEVP  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define PARATSEP  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define PARINPCP  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define PARATPCP  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define PARSNMTP  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define PARVOLP   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define STCLOSEPS -99 "System Missing" ;
label define STCONFLPS -99 "System Missing" ;
label define CHHLTHTPS -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Poor"
                       2 "Fair" 3 "Good" 4 "Very Good" 5 "Excellent" ;
label define COMPAREPS -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       1 "Better Than Many" 2 "About the Same"
                       3 "A Little Worse" 4 "Much Worse" 5 "Worst in Class" ;
label define BLOCKPS   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       1 "Not at All" 2 "Very Little" 3 "To Some Extent"
                       4 "To a Great Extent" 5 "To a Very Great Extent" ;
label define SETTINGPS -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       1 "Only single class activity, person, situation, or setting"
                       2 "Only 2-3 class activities, persons, situations, or settings"
                       3 "Occurs in all settings and activities at school"
                       4 "Occurs anywhere and everywhere" ;
label define SERIOUSPS -99 "System Missing" -9 "Don't Know"
                       -6 "Item is Missing (But Form is Present)"
                       1 "No, Not Serious" 2 "Somewhat Serious"
                       3 "Yes, Pretty Serious" 4 "Yes, Extremely Serious" ;
label define SERVICEPS -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       1 "Services not necessary"
                       2 "May benefit from, but has not been referred for services"
                       3 "Yes, referred"
                       4 "Yes, referred but not receiving services"
                       5 "Yes, has received or is receiving services"
                       6 "I do not know" ;
label define PROBPS_01 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPS_02 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPS_03 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPS_04 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPS_05 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPS_06 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPS_07 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPS_08 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPS_09 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPS_10 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPS_11 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPS_12 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPS_13 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPS_14 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPS_15 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPS_16 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPS_17 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBPS_18 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define IEPRFTQP  -99 "System Missing" 0 "No" 1 "Yes" ;
label define IEPTQP    -99 "System Missing" 0 "No" 1 "Yes" ;
label define IEPMONP   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define IEPYEARP  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define IEPSPCHP  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       0 "Child has IEP, but not this disability"
                       1 "This disability described on IEP" ;
label define IEPPHYSP  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       0 "Child has IEP, but not this disability"
                       1 "This disability described on IEP" ;
label define IEPCOGP   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       0 "Child has IEP, but not this disability"
                       1 "This disability described on IEP" ;
label define IEPSOCP   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       0 "Child has IEP, but not this disability"
                       1 "This disability described on IEP" ;
label define IEPOTHP   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       0 "Child has IEP, but not this disability"
                       1 "This disability described on IEP" ;
label define PARRELP   -99 "System Missing" 1 "Very Satisfying"
                       2 "Somewhat Satisfying" 3 "Somewhat Unsatisfying"
                       4 "Very Unsatisfying" ;
label define PAREMOTP  -99 "System Missing" 1 "Very Warm" 2 "Somewhat Warm"
                       3 "Somewhat Cold" 4 "Very Cold" ;
label define PARTRSTP  -99 "System Missing" 1 "A Great Deal of Trust"
                       2 "A Little Trust" 3 "A Little Suspicious"
                       4 "Much Suspicion" ;
label define PARCOMMP  -99 "System Missing" 1 "Very Clear" 2 "Somewhat Clear"
                       3 "Somewhat Confused" 4 "Very Confused" ;
label define PARAGRP   -99 "System Missing"
                       1 "We agree on just about every issue"
                       2 "We agree more often than not"
                       3 "We sometimes disagree" 4 "We always disagree" ;
label define PARAPPP   -99 "System Missing" 1 "A Great Deal" 2 "Often"
                       3 "Rarely" 4 "Not at All" ;
label define PARCOOPP  -99 "System Missing" 1 "A Great Deal"
                       2 "A Fair Amount" 3 "Some Cooperation"
                       4 "We Never Cooperate" ;
label define IEPEYP    -99 "System Missing" 0 "No" 1 "Yes" ;
label define IEPRFEYP  -99 "System Missing" 0 "No" 1 "Yes" ;
label define CHABSENTP -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define ASFCC_MPF -99 "System Missing" ;
label define ASMLS_MPF -99 "System Missing" ;
label define ASSGT_MPF -99 "System Missing" ;
label define ASWGT_MPF -99 "System Missing" ;
label define ASOST_MPF -99 "System Missing" ;
label define CEAES_MPF -99 "System Missing" ;
label define CEFNM_MPF -99 "System Missing" ;
label define CEGRM_MPF -99 "System Missing" ;
label define CELTS_MPF -99 "System Missing" ;
label define CEMTH_MPF -99 "System Missing" ;
label define CEOLD_MPF -99 "System Missing" ;
label define CEPRR_MPF -99 "System Missing" ;
label define CERDG_MPF -99 "System Missing" ;
label define CESCI_MPF -99 "System Missing" ;
label define CESCS_MPF -99 "System Missing" ;
label define CEWRT_MPF -99 "System Missing" ;
label define CE_LIT_MPF -99 "System Missing" ;
label define DSDST_MPF -99 "System Missing" ;
label define AIRSM_MPF -99 "System Missing" ;
label define TCESC_MPF -99 "System Missing" ;
label define TCDDT_MPF -99 "System Missing" ;
label define TCSCL_MPF -99 "System Missing" ;
label define CEREAD_C_MPF -99 "System Missing" ;
label define CELTS_C_MPF -99 "System Missing" ;
label define CEOLD_C_MPF -99 "System Missing" ;
label define CEMTH_C_MPF -99 "System Missing" ;
label define CESCI_C_MPF -99 "System Missing" ;
label define CEWRT_C_MPF -99 "System Missing" ;
label define CESCS_C_MPF -99 "System Missing" ;
label define CEAES_C_MPF -99 "System Missing" ;
label define CEMOT_C_MPF -99 "System Missing" ;
label define CENONE_C_MPF -99 "System Missing" ;
label define SNAPOBSPF -99 "System Missing" ;
label define SNAPDAYPF -99 "System Missing" ;
label define ASFCC_MPS -99 "System Missing" ;
label define ASMLS_MPS -99 "System Missing" ;
label define ASSGT_MPS -99 "System Missing" ;
label define ASWGT_MPS -99 "System Missing" ;
label define ASOST_MPS -99 "System Missing" ;
label define CEAES_MPS -99 "System Missing" ;
label define CEFNM_MPS -99 "System Missing" ;
label define CEGRM_MPS -99 "System Missing" ;
label define CELTS_MPS -99 "System Missing" ;
label define CEMTH_MPS -99 "System Missing" ;
label define CEOLD_MPS -99 "System Missing" ;
label define CEPRR_MPS -99 "System Missing" ;
label define CERDG_MPS -99 "System Missing" ;
label define CESCI_MPS -99 "System Missing" ;
label define CESCS_MPS -99 "System Missing" ;
label define CEWRT_MPS -99 "System Missing" ;
label define CE_LIT_MPS -99 "System Missing" ;
label define DSDST_MPS -99 "System Missing" ;
label define AIRTN_MPS -99 "System Missing" ;
label define AIMIN_MPS -99 "System Missing" ;
label define AISMP_MPS -99 "System Missing" ;
label define AIELB_MPS -99 "System Missing" ;
label define TCENC_MPS -99 "System Missing" ;
label define TCSCF_MPS -99 "System Missing" ;
label define TCDDT_MPS -99 "System Missing" ;
label define TCSCL_MPS -99 "System Missing" ;
label define AIELB_C_MPS -99 "System Missing" ;
label define AIRTN_C_MPS -99 "System Missing" ;
label define AISMP_C_MPS -99 "System Missing" ;
label define AINONE_C_MPS -99 "System Missing" ;
label define CEREAD_C_MPS -99 "System Missing" ;
label define CELTS_C_MPS -99 "System Missing" ;
label define CEOLD_C_MPS -99 "System Missing" ;
label define CEMTH_C_MPS -99 "System Missing" ;
label define CESCI_C_MPS -99 "System Missing" ;
label define CEWRT_C_MPS -99 "System Missing" ;
label define CESCS_C_MPS -99 "System Missing" ;
label define CEAES_C_MPS -99 "System Missing" ;
label define CEMOT_C_MPS -99 "System Missing" ;
label define CENONE_C_MPS -99 "System Missing" ;
label define SNAPOBSPS -99 "System Missing" ;
label define SNAPDAYPS -99 "System Missing" ;
label define CHILD_WTPF -99 "System Missing" ;
label define CHILD_WTPS -99 "System Missing" ;
label define CHBYEARP  -99 "System Missing" ;
label define CHPARTP   -99 "System Missing" 1 "Fall & Spring" 2 "Fall Only"
                       3 "Spring Only" ;
label define ASMTAGEPF -99 "System Missing" ;
label define ASMTAGEPS -99 "System Missing" ;
label define EWTNMEPF  -99 "System Missing" ;
label define EWTNMSPF  -99 "System Missing" ;
label define EWTNMEPS  -99 "System Missing" ;
label define EWTNMSPS  -99 "System Missing" ;
label define T_CHNGCP  -99 "System Missing"
                       0 "No change in teacher, Classroom"
                       1 "Change in Teacher" 2 "Change in Classroom" ;
label define AMSNTDAYP -99 "System Missing" ;
label define SITE_PS   -99 "System Missing" ;
label define SITE_PF   -99 "System Missing" ;
label define SITE_TRPS -99 "System Missing" ;
label define HHTYPEP   -99 "System Missing" 1 "Single Mom or Dad"
                       2 "Mom & Dad Both in Home" 3 "w/o Dad"
                       4 "Multiple Adults, but Parents/Step-Parents not both in home"
                       5 "Single Adult, Not Mother or Father" ;
label define ASINT_MPF -99 "System Missing" ;
label define ASRTN_MPF -99 "System Missing" ;
label define ASINT_MPS -99 "System Missing" ;
label define ASRTN_MPS -99 "System Missing" ;
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
label define ASRTNC_CF -99 "System Missing" ;
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
label define EXPER01P  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define EXPER02P  -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define EXPER03P  -99 "System Missing" ;
label define MONTHS    -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define EMPLHRP   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define EXPTOTP   -99 "System Missing" ;
label define BACERT_AP -99 "System Missing"
                       0 "Has a BA or better, but no State Certificate ( < 4 yrs)"
                       1 "Has a BA or better, and has State Certificate ( < 4 yrs)" ;
label define BACERT_BP -99 "System Missing"
                       0 "Has a BA or better, but no State Certificate ( 4 yrs old)"
                       1 "Has a BA or better, and has State Certificate ( 4 yrs old)" ;
label define BACERT_CP -99 "System Missing"
                       0 "Has a BA or better, but no State Certificate (Kind)"
                       1 "Has a BA or better, and has State Certificate (Kind)" ;
label define BACERT_DP -99 "System Missing"
                       0 "Has a BA or better, but no State Certificate (Early Elem)"
                       1 "Has a BA or better, and has State Certificate (Early Elem)" ;
label define BACERT_EP -99 "System Missing"
                       0 "Has a BA or better, but no State Certificate (Special Ed)"
                       1 "Has a BA or better, and has State Certificate (Special Ed)" ;
label define BACERT_FP -99 "System Missing"
                       0 "Has a BA or better, but no State Certificate (LEP or ESL)"
                       1 "Has a BA or better, and has State Certificate (LEP or ESL)" ;
label define BACERT_GP -99 "System Missing"
                       0 "Has a BA or better, but no State Certificate (Other)"
                       1 "Has a BA or better, and has State Certificate (Other)" ;
label define NOBACERTP -99 "System Missing"
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
label define CLASTYPP  -99 "System Missing" 1 "3 and 4 year olds"
                       2 "4 year olds (and 5 year olds who will be in K next year)"
                       3 "4 year olds and kindergarteners" 4 "Other" ;
label define LEPPF     -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable" ;
label define LANG_01P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define LANG_02P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define LANG_03P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define TLANG01P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define TLANG02P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define TLANG03P  -99 "System Missing" 0 "No" 1 "Yes" ;
label define IEPPF     -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define DAY_WKP   -99 "System Missing" ;
label define CREDENTP  -99 "System Missing" 1 "ECE credential"
                       2 "K credential" 3 "EE credential"
                       4 "Other Credential" ;
label define CURRICP   -99 "System Missing" 1 "High Scope" 2 "Creative"
                       3 "Named curriculum" 4 "No clear curriculum" ;
label define CALC_WAGEP -99 "System Missing" -7 "Child Failed Practice Items" ;
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
label define ADMTITLEP -99 "System Missing" 1 "School Principal"
                       2 "Center Director" 3 "Pre-K Supervisor" 4 "Other" ;
label define BENEFITP_1 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
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
label define SERVICEP_1 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define SERVICEP_2 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define SERVICEP_3 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define SERVICEP_4 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define SERVICEP_5 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define SERVICEP_6 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define SERVICEP_7 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define SERVICEP_8 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define SERVICEP_9 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define SERVICEP_10 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define SERVICEP_11 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define T_CHNG    -99 "System Missing"
                       0 "No change in teacher, classroom"
                       1 "Change in teacher" 2 "Change in classroom" ;
label define PRELASTKF -99 "System Missing" ;
label define LETTEREKF -99 "System Missing" ;
label define NUMBEREKF -99 "System Missing" ;
label define HICNTEKF  -99 "System Missing" ;
label define HICNTCOREKF -99 "System Missing" ;
label define CTOPPEKF  -99 "System Missing" -7 "Child Failed Practice Items" ;
label define PPVTEKF   -99 "System Missing" ;
label define OWLSEKF   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define WJ1_WEKF  -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define WJ1_SSEKF -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define WJ10_WEKF -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define WJ10_SSEKF -99 "System Missing"
                       -5 "No Response from Child / Not Applicable" ;
label define WJ21AEKF  -99 "System Missing" ;
label define LETTERSKF -99 "System Missing" ;
label define NUMBERSKF -99 "System Missing" ;
label define COLORSKF  -99 "System Missing" ;
label define TVIPSKF   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define WM25SSKF  -99 "System Missing" ;
label define WM25WKF   -99 "System Missing" ;
label define WM22SSKF  -99 "System Missing" ;
label define WM22WKF   -99 "System Missing" ;
label define HICNTSKF  -99 "System Missing" ;
label define HICNTCORSKF -99 "System Missing" ;
label define EWTNMEKF  -99 "System Missing" ;
label define EWTNMSKF  -99 "System Missing" ;
label define ASMSTATKF -99 "System Missing" 1 "Absent"
                       2 "Full Assessment (English)"
                       3 "Full Assessment (Spanish)"
                       4 "Non-English, Spanish-Speaking Child Failed Pre-LAS"
                       5 "Partial Assessment (English)"
                       6 "Partial Assessment (Spanish)"
                       7 "Child Refused Assessment" ;
label define PRELASTKS -99 "System Missing" ;
label define LETTEREKS -99 "System Missing" ;
label define NUMBEREKS -99 "System Missing" ;
label define HICNTEKS  -99 "System Missing" ;
label define HICNTCOREKS -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define CTOPPEKS  -99 "System Missing" -7 "Child Failed Practice Items" ;
label define PPVTEKS   -99 "System Missing" ;
label define OWLSEKS   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define WJ1_WEKS  -99 "System Missing" ;
label define WJ1_SSEKS -99 "System Missing" ;
label define WJ10_WEKS -99 "System Missing" ;
label define WJ10_SSEKS -99 "System Missing" ;
label define WJ21AEKS  -99 "System Missing" ;
label define LETTERSKS -99 "System Missing" ;
label define NUMBERSKS -99 "System Missing" ;
label define COLORSKS  -99 "System Missing" ;
label define TVIPSKS   -99 "System Missing" ;
label define WM22SSKS  -99 "System Missing" ;
label define WM22WKS   -99 "System Missing" ;
label define WM25SSKS  -99 "System Missing" ;
label define WM25WKS   -99 "System Missing" ;
label define HICNTSKS  -99 "System Missing" ;
label define HICNTCORSKS -99 "System Missing" ;
label define EWTNMEKS  -99 "System Missing" ;
label define EWTNMSKS  -99 "System Missing" ;
label define ASMSTATKS -99 "System Missing" 1 "Absent"
                       2 "Full Assessment (English)"
                       3 "Full Assessment (Spanish)"
                       4 "Non-English, Spanish-Speaking Child Failed Pre-LAS"
                       5 "Partial Assessment (English)"
                       6 "Partial Assessment (Spanish)"
                       7 "Child Refused Assessment" ;
label define CHLDGRK   -99 "System Missing" 1 "Pre-K" 2 "Kindergarten"
                       3 "Other" ;
label define CHHLTHTKF -99 "System Missing" 1 "Poor" 2 "Fair" 3 "Good"
                       4 "Very Good" 5 "Excellent" ;
label define WHYPKK    -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       1 "Not old enough"
                       2 "School/teacher suggested be kept in prek, parents agreed"
                       3 "School/teacher suggested be kept in prek, parents disagreed"
                       4 "Parents requested keeping child in Pre-K" 5 "Other" ;
label define ATPKLYK   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define TLANG1KF  -99 "System Missing" 0 "No" 1 "Yes" ;
label define TLANG2KF  -99 "System Missing" 0 "No" 1 "Yes" ;
label define TLANG3KF  -99 "System Missing" 0 "No" 1 "Yes" ;
label define TQSCDATEKF -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define HTCOMPKF  -99 "System Missing" ;
label define HTFTOLKF  -99 "System Missing" ;
label define HTASRTKF  -99 "System Missing" ;
label define HTTKORKF  -99 "System Missing" ;
label define HTPSSKKF  -99 "System Missing" ;
label define HTPROBKF  -99 "System Missing" ;
label define HTCNPRKF  -99 "System Missing" ;
label define HTINTNKF  -99 "System Missing" ;
label define HTLNPRKF  -99 "System Missing" ;
label define CSLANGKF  -99 "System Missing" ;
label define CSMATHKF  -99 "System Missing" ;
label define CSTOTKF   -99 "System Missing" ;
label define CSLANGKF1 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGKF2 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGKF3 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGKF4 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGKF5 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGKF6 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGKF7 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGKF8 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGKF9 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSMATHKF1 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSMATHKF2 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSMATHKF3 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSMATHKF4 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSMATHKF5 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSMATHKF6 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSMATHKF7 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define COMPAREKF -99 "System Missing" 1 "Better Than Many"
                       2 "About the Same" 3 "A Little Worse" 4 "Much Worse"
                       5 "Worst in Class" ;
label define BLOCKKF   -99 "System Missing" 1 "Not at All" 2 "Very Little"
                       3 "To Some Extent" 4 "To a Great Extent"
                       5 "To a Very Great Extent" ;
label define SETTINGKF -99 "System Missing"
                       1 "Only single class activity, person, situation, or setting"
                       2 "Only 2-3 class activities, persons, situations, or settings"
                       3 "Occurs in all settings and activities at school"
                       4 "Occurs anywhere and everywhere" ;
label define SERIOUSKF -99 "System Missing" -9 "Don't Know"
                       1 "No, Not Serious" 2 "Somewhat Serious"
                       3 "Yes, Pretty Serious" 4 "Yes, Extremely Serious" ;
label define SERVICEKF -99 "System Missing" 1 "Services not necessary"
                       2 "May benefit from, but has not been referred for services"
                       3 "Yes, referred"
                       4 "Yes, referred but not receiving services"
                       5 "Yes, has received or is receiving services"
                       6 "I do not know" ;
label define PROBKF_01 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKF_02 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKF_03 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKF_04 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKF_05 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKF_06 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKF_07 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKF_08 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKF_09 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKF_10 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKF_11 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKF_12 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKF_13 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKF_14 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKF_15 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKF_16 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKF_17 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKF_18 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define IEPRFTQKF -99 "System Missing" 0 "No" 1 "Yes" ;
label define IEPTQKF   -99 "System Missing" 0 "No" 1 "Yes" ;
label define IEPMONKF  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define IEPYEARKF -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define IEPSPCHKF -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       0 "Child has IEP, but not this disability"
                       1 "This disability described on IEP" ;
label define IEPPHYSKF -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       0 "Child has IEP, but not this disability"
                       1 "This disability described on IEP" ;
label define IEPCOGKF  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       0 "Child has IEP, but not this disability"
                       1 "This disability described on IEP" ;
label define IEPSOCKF  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       0 "Child has IEP, but not this disability"
                       1 "This disability described on IEP" ;
label define IEPOTHKF  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       0 "Child has IEP, but not this disability"
                       1 "This disability described on IEP" ;
label define CHHLTHTKS -99 "System Missing" 1 "Poor" 2 "Fair" 3 "Good"
                       4 "Very Good" 5 "Excellent" ;
label define TQSCDATEKS -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define XPHELPK   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       1 "No, did not help" 2 "Helped a little"
                       3 "Helped a lot" ;
label define TLANG1KS  -99 "System Missing" 0 "No" 1 "Yes" ;
label define TLANG2KS  -99 "System Missing" 0 "No" 1 "Yes" ;
label define TLANG3KS  -99 "System Missing" 0 "No" 1 "Yes" ;
label define HTCOMPKS  -99 "System Missing" ;
label define HTFTOLKS  -99 "System Missing" ;
label define HTASRTKS  -99 "System Missing" ;
label define HTTKORKS  -99 "System Missing" ;
label define HTPSSKKS  -99 "System Missing" ;
label define HTPROBKS  -99 "System Missing" ;
label define HTCNPRKS  -99 "System Missing" ;
label define HTINTNKS  -99 "System Missing" ;
label define HTLNPRKS  -99 "System Missing" ;
label define CSLANGKS  -99 "System Missing" ;
label define CSMATHKS  -99 "System Missing" ;
label define CSTOTKS   -99 "System Missing" ;
label define CSLANGKS1 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGKS2 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Not Yet"
                       2 "Beginning" 3 "In Progress" 4 "Intermediate"
                       5 "Proficient" ;
label define CSLANGKS3 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Not Yet"
                       2 "Beginning" 3 "In Progress" 4 "Intermediate"
                       5 "Proficient" ;
label define CSLANGKS4 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGKS5 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGKS6 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGKS7 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGKS8 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSLANGKS9 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSMATHKS1 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSMATHKS2 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSMATHKS3 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSMATHKS4 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSMATHKS5 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSMATHKS6 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define CSMATHKS7 -99 "System Missing"
                       -5 "No Response from Child / Not Applicable"
                       1 "Not Yet" 2 "Beginning" 3 "In Progress"
                       4 "Intermediate" 5 "Proficient" ;
label define COMPAREKS -99 "System Missing" 1 "Better Than Many"
                       2 "About the Same" 3 "A Little Worse" 4 "Much Worse"
                       5 "Worst in Class" ;
label define BLOCKKS   -99 "System Missing" 1 "Not at All" 2 "Very Little"
                       3 "To Some Extent" 4 "To a Great Extent"
                       5 "To a Very Great Extent" ;
label define SETTINGKS -99 "System Missing"
                       1 "Only single class activity, person, situation, or setting"
                       2 "Only 2-3 class activities, persons, situations, or settings"
                       3 "Occurs in all settings and activities at school"
                       4 "Occurs anywhere and everywhere" ;
label define SERIOUSKS -99 "System Missing" -9 "Don't Know"
                       1 "No, Not Serious" 2 "Somewhat Serious"
                       3 "Yes, Pretty Serious" 4 "Yes, Extremely Serious" ;
label define SERVICEKS -99 "System Missing" 1 "Services not necessary"
                       2 "May benefit from, but has not been referred for services"
                       3 "Yes, referred"
                       4 "Yes, referred but not receiving services"
                       5 "Yes, has received or is receiving services"
                       6 "I do not know" ;
label define PROBKS_01 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKS_02 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKS_03 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKS_04 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKS_05 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKS_06 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKS_07 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKS_08 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKS_09 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKS_10 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKS_11 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKS_12 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKS_13 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKS_14 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKS_15 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKS_16 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKS_17 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBKS_18 -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define STCLOSEKS -99 "System Missing" ;
label define STCONFLKS -99 "System Missing" ;
label define IEPRFTQKS -99 "System Missing" 0 "No" 1 "Yes" ;
label define IEPTQKS   -99 "System Missing" 0 "No" 1 "Yes" ;
label define IEPMONKS  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define IEPYEARKS -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define IEPSPCHKS -99 "System Missing"
                       0 "Child has IEP, but not this disability"
                       1 "This disability described on IEP" ;
label define IEPPHYSKS -99 "System Missing"
                       0 "Child has IEP, but not this disability"
                       1 "This disability described on IEP" ;
label define IEPCOGKS  -99 "System Missing"
                       0 "Child has IEP, but not this disability"
                       1 "This disability described on IEP" ;
label define IEPSOCKS  -99 "System Missing"
                       0 "Child has IEP, but not this disability"
                       1 "This disability described on IEP" ;
label define IEPOTHKS  -99 "System Missing"
                       0 "Child has IEP, but not this disability"
                       1 "This disability described on IEP" ;
label define IEPRCEYKS -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define IEPRCFGKS -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define PARRELK   -99 "System Missing" 1 "Very Satisfying"
                       2 "Somewhat Satisfying" 3 "Somewhat Unsatisfying"
                       4 "Very Unsatisfying" ;
label define PAREMOTK  -99 "System Missing" 1 "Very Warm" 2 "Somewhat Warm"
                       3 "Somewhat Cold" 4 "Very Cold" ;
label define PARTRSTK  -99 "System Missing" 1 "A Great Deal of Trust"
                       2 "A Little Trust" 3 "A Little Suspicious"
                       4 "Much Suspicion" ;
label define PARCOMMK  -99 "System Missing" 1 "Very Clear"
                       2 "Somewhat Confused" 3 "Somewhat Confused"
                       4 "Very Confused" ;
label define PARAGRK   -99 "System Missing"
                       1 "We agree on just about every issue"
                       2 "We agree more often than not"
                       3 "We sometimes disagree" 4 "We always disagree" ;
label define PARAPPK   -99 "System Missing" 1 "A Great Deal" 2 "Often"
                       3 "Rarely" 4 "Not at All" ;
label define PARCOOPK  -99 "System Missing" 1 "A Great Deal"
                       2 "A Fair Amount" 3 "Some Cooperation"
                       4 "We Never Cooperate" ;
label define PARCALLK  -99 "System Missing" 1 "Never" 2 "Once-twice a Year"
                       3 "Almost Every Month" 4 "Almost Every Week"
                       5 "More Than Once a Week" ;
label define TCRCALLK  -99 "System Missing" 1 "Never" 2 "Once-twice a Year"
                       3 "Almost Every Month" 4 "Almost Every Week"
                       5 "More Than Once a Week" ;
label define PARVISTK  -99 "System Missing" 1 "Never" 2 "Once-twice a Year"
                       3 "Almost Every Month" 4 "Almost Every Week"
                       5 "More Than Once a Week" ;
label define TCRVISTK  -99 "System Missing" 1 "Never" 2 "Once-twice a Year"
                       3 "Almost Every Month" 4 "Almost Every Week"
                       5 "More Than Once a Week" ;
label define PARINVTK  -99 "System Missing" 1 "Never" 2 "Once-twice a Year"
                       3 "Almost Every Month" 4 "Almost Every Week"
                       5 "More Than Once a Week" ;
label define PATATNDK  -99 "System Missing" 1 "Never" 2 "Once-twice a Year"
                       3 "Almost Every Month" 4 "Almost Every Week"
                       5 "More Than Once a Week" ;
label define PARSPEVK  -99 "System Missing" 1 "Never" 2 "Once-twice a Year"
                       3 "Almost Every Month" 4 "Almost Every Week"
                       5 "More Than Once a Week" ;
label define PARATSEK  -99 "System Missing" 1 "Never" 2 "Once-twice a Year"
                       3 "Almost Every Month" 4 "Almost Every Week"
                       5 "More Than Once a Week" ;
label define PARINPCK  -99 "System Missing" 1 "Never" 2 "Once-twice a Year"
                       3 "Almost Every Month" 4 "Almost Every Week"
                       5 "More Than Once a Week" ;
label define PARATPCK  -99 "System Missing" 1 "Never" 2 "Once-twice a Year"
                       3 "Almost Every Month" 4 "Almost Every Week"
                       5 "More Than Once a Week" ;
label define PARSNMTK  -99 "System Missing" 1 "Never" 2 "Once-twice a Year"
                       3 "Almost Every Month" 4 "Almost Every Week"
                       5 "More Than Once a Week" ;
label define PARVOLK   -99 "System Missing" 1 "Never" 2 "Once-twice a Year"
                       3 "Almost Every Month" 4 "Almost Every Week"
                       5 "More Than Once a Week" ;
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
label define CALC_WAGEK -99 "System Missing" -7 "Child Failed Practice Items" ;
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
label define CLSSTARTK -99 "System Missing" ;
label define CLSENDK   -99 "System Missing" ;
label define STDTCHK   -99 "System Missing" 1 "Yes" 2 "No" ;
label define TCHSLEFFK -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define T_CESDK   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define TQDATEKF  -99 "System Missing"
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
label define LOCATIONK -99 "System Missing"
                       1 "Regular public elementary school"
                       2 "Public magnet school" 3 "Public charter school"
                       4 "Private, religious school"
                       5 "Private, non-religious school"
                       6 "Pre-k, preschool, or child care center"
                       7 "Head Start program" 8 "Other" ;
label define CHRESKS   -99 "System Missing" 1 "Yes" 2 "No" ;
label define CHRESUSKS -99 "System Missing" 1 "Yes" 2 "No" ;
label define T_PLANPK  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "0"
                       2 "2 or less" 3 "3 - 4" 4 "5 - 6" 5 "7 - 9"
                       6 "10 or More" ;
label define T_PLANUK  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "0"
                       2 "2 or less" 3 "3 - 4" 4 "5 - 6" 5 "7 - 9"
                       6 "10 or More" ;
label define RDGPGMK   -99 "System Missing" 1 "Yes" 2 "No" ;
label define RDGPGMTK  -99 "System Missing" 1 "Phonics-based"
                       2 "Whole language based"
                       3 "A combination of phonics and while language" ;
label define PARVISK   -99 "System Missing" 1 "Not allowed during the day"
                       2 "Only at specific times"
                       3 "Only with advance notice" 4 "At any time" ;
label define PARMTGK   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define PARRPTK   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define AID_KS    -99 "System Missing" 1 "Yes" 2 "No" ;
label define TQDATEKS  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
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
label define ASOTH_SK  -99 "System Missing" ;
label define ASRTN_MK  -99 "System Missing" ;
label define ASFCC_MK  -99 "System Missing" ;
label define ASINT_MK  -99 "System Missing" ;
label define ASMLS_MK  -99 "System Missing" ;
label define ASSGT_MK  -99 "System Missing" ;
label define ASWGT_MK  -99 "System Missing" ;
label define ASCMP_MK  -99 "System Missing" ;
label define CEAES_MK  -99 "System Missing" ;
label define CEFNM_MK  -99 "System Missing" ;
label define CEGRM_MK  -99 "System Missing" ;
label define CELTS_MK  -99 "System Missing" ;
label define CEMTH_MK  -99 "System Missing" ;
label define CECPY_MK  -99 "System Missing" ;
label define CEOLD_MK  -99 "System Missing" ;
label define CEPRR_MK  -99 "System Missing" ;
label define CERDG_MK  -99 "System Missing" ;
label define CESCI_MK  -99 "System Missing" ;
label define CESCS_MK  -99 "System Missing" ;
label define CEWRT_MK  -99 "System Missing" ;
label define CE_LIT_MK -99 "System Missing" ;
label define DSDST_MK  -99 "System Missing" ;
label define AIRTN_MK  -99 "System Missing" ;
label define AIMIN_MK  -99 "System Missing" ;
label define AISMP_MK  -99 "System Missing" ;
label define AIELB_MK  -99 "System Missing" ;
label define TCENC_MK  -99 "System Missing" ;
label define TCSCF_MK  -99 "System Missing" ;
label define TCDDT_MK  -99 "System Missing" ;
label define TCSCL_MK  -99 "System Missing" ;
label define AIELB_C_MK -99 "System Missing" ;
label define AIRTN_C_MK -99 "System Missing" ;
label define AISMP_C_MK -99 "System Missing" ;
label define AINONE_C_MK -99 "System Missing" ;
label define CEREAD_C_MK -99 "System Missing" ;
label define CELTS_C_MK -99 "System Missing" ;
label define CEOLD_C_MK -99 "System Missing" ;
label define CEMTH_C_MK -99 "System Missing" ;
label define CESCI_C_MK -99 "System Missing" ;
label define CEWRT_C_MK -99 "System Missing" ;
label define CESCS_C_MK -99 "System Missing" ;
label define CEAES_C_MK -99 "System Missing" ;
label define CEMOT_C_MK -99 "System Missing" ;
label define CENONE_C_MK -99 "System Missing" ;
label define ASOTH_NK  -99 "System Missing" ;
label define SNAPOBSK  -99 "System Missing" ;
label define SNAPCLASSK -99 "System Missing" ;
label define SNAPDAYK  -99 "System Missing" ;
label define FAMFORMLK -99 "System Missing" 1 "English" 2 "Spanish" ;
label define FORMRESPK -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Mother"
                       2 "Father" 3 "Grandmother" 4 "Foster Parent" 5 "Other" ;
label define CHKINDERK -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define KTRANP1K  -99 "System Missing" 1 "Yes" 2 "No" 3 "Not Offered" ;
label define KTRANP2K  -99 "System Missing" 1 "Yes" 2 "No" 3 "Not Offered" ;
label define KTRANP3K  -99 "System Missing" 1 "Yes" 2 "No" 3 "Not Offered" ;
label define KTRANP4K  -99 "System Missing" 1 "Yes" 2 "No" 3 "Not Offered" ;
label define KTRANP5K  -99 "System Missing" 1 "Yes" 2 "No" 3 "Not Offered" ;
label define TCHTALKK  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "A few times a year" 3 "At least once a month"
                       4 "At least once a week" 5 "Daily" ;
label define TCHTRSTK  -99 "System Missing" -9 "Don't Know"
                       -6 "Item is Missing (But Form is Present)"
                       1 "A great deal of trust" 2 "A little trust"
                       3 "A little suspicion" 4 "Much suspicion" ;
label define TCHCOMMK  -99 "System Missing" -9 "Don't Know"
                       -6 "Item is Missing (But Form is Present)"
                       1 "Very Clear" 2 "Somewhat clear"
                       3 "Somewhat confused" 4 "Very confused" ;
label define TCHAGRK   -99 "System Missing" -9 "Don't Know"
                       -6 "Item is Missing (But Form is Present)"
                       1 "We agree on just about every issue"
                       2 "We agree more often than not"
                       3 "We sometimes disagree" 4 "We always disagree" ;
label define TCHSATK   -99 "System Missing" -9 "Don't Know"
                       -6 "Item is Missing (But Form is Present)"
                       1 "Very dissatisfied" 2 "Somewhat dissatisfied"
                       3 "Neither satisfied nor dissatisfied"
                       4 "Somewhat satisfied" 5 "Very satisfied" ;
label define HOMLIFK01 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once or twice" 3 "3-6 times" 4 "Every Day" ;
label define HOMLIFK02 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once or twice" 3 "3-6 times" 4 "Every Day" ;
label define HOMLIFK03 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once or twice" 3 "3-6 times" 4 "Every Day" ;
label define HOMLIFK04 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once or twice" 3 "3-6 times" 4 "Every Day" ;
label define HOMLIFK05 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once or twice" 3 "3-6 times" 4 "Every Day" ;
label define HOMLIFK06 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once or twice" 3 "3-6 times" 4 "Every Day" ;
label define HOMLIFK07 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once or twice" 3 "3-6 times" 4 "Every Day" ;
label define HOMLIFK08 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once or twice" 3 "3-6 times" 4 "Every Day" ;
label define HOMLIFK09 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once or twice" 3 "3-6 times" 4 "Every Day" ;
label define HOMLIFK10 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once or twice" 3 "3-6 times" 4 "Every Day" ;
label define HOMLIFK11 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once or twice" 3 "3-6 times" 4 "Every Day" ;
label define DECISION1K -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable"
                       1 "I decide alone" 2 "I decide after discussion"
                       3 "Decide together" 4 "Child decides after discussion"
                       5 "Child decides alone" ;
label define DECISION2K -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable"
                       1 "I decide alone" 2 "I decide after discussion"
                       3 "Decide together" 4 "Child decides after discussion"
                       5 "Child decides alone" ;
label define DECISION3K -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable"
                       1 "I decide alone" 2 "I decide after discussion"
                       3 "Decide together" 4 "Child decides after discussion"
                       5 "Child decides alone" ;
label define DECISION4K -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable"
                       1 "I decide alone" 2 "I decide after discussion"
                       3 "Decide together" 4 "Child decides after discussion"
                       5 "Child decides alone" ;
label define TALKTIMEK -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define READTIMEK -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define HMWKTIMEK -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       -5 "No Response from Child / Not Applicable" ;
label define HTCOMPPK  -99 "System Missing" ;
label define HTFTOLPK  -99 "System Missing" ;
label define HTTKORPK  -99 "System Missing" ;
label define HTPROBPK  -99 "System Missing" ;
label define HTINTNPK  -99 "System Missing" ;
label define CHHLPROBK -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define CHLKSCHLK -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       1 "Not at all" 2 "A little" 3 "A lot" 4 "A whole lot" ;
label define IMPADDK   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       1 "Not at all" 2 "A little" 3 "A lot" 4 "A whole lot" ;
label define SCHLCHNGK -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define FQDATEK   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define HTCOMPE   -99 "System Missing" ;
label define HTFTOLE   -99 "System Missing" ;
label define HTASRTE   -99 "System Missing" ;
label define HTTKORE   -99 "System Missing" ;
label define HTPSSKE   -99 "System Missing" ;
label define HTPROBE   -99 "System Missing" ;
label define HTCNPRE   -99 "System Missing" ;
label define HTINTNE   -99 "System Missing" ;
label define HTLNPRE   -99 "System Missing" ;
label define STCLOSEE  -99 "System Missing" ;
label define STCONFLE  -99 "System Missing" ;
label define CSLANGE   -99 "System Missing" ;
label define CSMATHE   -99 "System Missing" ;
label define CSTOTE    -99 "System Missing" ;
label define CHLDGRE   -99 "System Missing" 1 "Kindergarten" 2 "1st Grade"
                       3 "Other" ;
label define CHHLTHTE  -99 "System Missing" 1 "Poor" 2 "Fair" 3 "Good"
                       4 "Very Good" 5 "Excellent" ;
label define WHYNFGE   -99 "System Missing"
                       1 "Was not in kindergarten last year"
                       2 "School/teacher suggested child be kept in K, parents agreed"
                       3 "School/teacher suggested kept in K, parents did not agree"
                       4 "Parents requested keeping child in K" 5 "Other" ;
label define PROBE_01  -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBE_02  -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBE_03  -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBE_04  -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBE_05  -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBE_06  -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBE_07  -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBE_08  -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBE_09  -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBE_10  -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBE_11  -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBE_12  -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBE_13  -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBE_14  -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBE_15  -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBE_16  -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBE_17  -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define PROBE_18  -99 "System Missing"
                       0 "Teacher indicated problem, but not this one"
                       1 "Teacher did indicate this was a serious problem" ;
label define COMPAREE  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       1 "Better than many" 2 "About the same"
                       3 "A little worse" 4 "Much worse" 5 "Worst in class" ;
label define BLOCKE    -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       1 "Not at all" 2 "Very little" 3 "To some extent"
                       4 "To a great extent" 5 "To a very great extent" ;
label define SETTINGE  -99 "System Missing"
                       1 "Only single class activity, person, situation, or setting"
                       2 "Only 2-3 class activities, persons, situations, or settings"
                       3 "Occurs in all settings and activities at school"
                       4 "Occurs anywhere and everywhere" ;
label define SERIOUSE  -99 "System Missing" -9 "Don't Know"
                       -6 "Item is Missing (But Form is Present)"
                       1 "No, Not Serious" 2 "Somewhat Serious"
                       3 "Yes, Pretty Serious" 4 "Yes, Extremely Serious" ;
label define SERVICEE  -99 "System Missing" 1 "Services not necessary"
                       2 "May benefit from, but has not been referred for services"
                       3 "Yes, referred"
                       4 "Yes, referred but not receiving services"
                       5 "Yes, has received or is receiving services"
                       6 "I do not know" ;
label define IEPRFTQE  -99 "System Missing" 0 "No" 1 "Yes" ;
label define IEPTQE    -99 "System Missing" 0 "No" 1 "Yes" ;
label define IEPMONE   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define IEPYEARE  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define IEPSPCHE  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       0 "Child has IEP, but not this disability"
                       1 "This disability described on IEP" ;
label define IEPPHYSE  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       0 "Child has IEP, but not this disability"
                       1 "This disability described on IEP" ;
label define IEPCOGE   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       0 "Child has IEP, but not this disability"
                       1 "This disability described on IEP" ;
label define IEPSOCE   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       0 "Child has IEP, but not this disability"
                       1 "This disability described on IEP" ;
label define IEPOTHE   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       0 "Child has IEP, but not this disability"
                       1 "This disability described on IEP" ;
label define IEPRCEYE  -99 "System Missing" 1 "Yes" 2 "No" ;
label define IEPRCSGE  -99 "System Missing" 1 "Yes" 2 "No" ;
label define TLANG1E   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define TLANG2E   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define TLANG3E   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define PARRELE   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       1 "Very Satisfying" 2 "Somewhat Setisfying"
                       3 "Somewhat Unsatisfying" 4 "Very Unsatisfying" ;
label define PAREMOTE  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       1 "Very Warm" 2 "Somewhat Warm" 3 "Somewhat Cold"
                       4 "Very Cold" ;
label define PARTRSTE  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       1 "A Great Deal of Trust" 2 "A Little Trust"
                       3 "A Little Suspicious" 4 "Much Suspicion" ;
label define PARCOMME  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       1 "Very Clear" 2 "Somewhat Clear"
                       3 "Somewhat Confused" 4 "Very Confused" ;
label define PARAGRE   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       1 "We agree on just about every issue"
                       2 "We agree more often than not"
                       3 "We sometimes disagree" 4 "We always disagree" ;
label define PARAPPE   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       1 "A Great Deal" 2 "Often" 3 "Rarely" 4 "Not at All" ;
label define PARCOOPE  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       1 "A Great Deal" 2 "A Fair Amount"
                       3 "Some Cooperation" 4 "We Never Cooperate" ;
label define PARCALLE  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define TCRCALLE  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define PARVISTE  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define TCRVISTE  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define PARINVTE  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define PATATNDE  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define PARSPEVE  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define PARATSEE  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define PARINPCE  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define PARATPCE  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define PARSNMTE  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define PARVOLE   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Never"
                       2 "Once-twice a Year" 3 "Almost Every Month"
                       4 "Almost Every Week" 5 "More Than Once a Week" ;
label define TQSCDATEE -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define CSLANGE1  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Not Yet"
                       2 "Beginning" 3 "In Progress" 4 "Intermediate"
                       5 "Proficient" ;
label define CSLANGE2  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Not Yet"
                       2 "Beginning" 3 "In Progress" 4 "Intermediate"
                       5 "Proficient" ;
label define CSLANGE3  -99 "System Missing" 1 "Not Yet" 2 "Beginning"
                       3 "In Progress" 4 "Intermediate" 5 "Proficient" ;
label define CSLANGE4  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Not Yet"
                       2 "Beginning" 3 "In Progress" 4 "Intermediate"
                       5 "Proficient" ;
label define CSLANGE5  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Not Yet"
                       2 "Beginning" 3 "In Progress" 4 "Intermediate"
                       5 "Proficient" ;
label define CSLANGE6  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Not Yet"
                       2 "Beginning" 3 "In Progress" 4 "Intermediate"
                       5 "Proficient" ;
label define CSLANGE7  -99 "System Missing" 1 "Not Yet" 2 "Beginning"
                       3 "In Progress" 4 "Intermediate" 5 "Proficient" ;
label define CSLANGE8  -99 "System Missing" 1 "Not Yet" 2 "Beginning"
                       3 "In Progress" 4 "Intermediate" 5 "Proficient" ;
label define CSLANGE9  -99 "System Missing" 1 "Not Yet" 2 "Beginning"
                       3 "In Progress" 4 "Intermediate" 5 "Proficient" ;
label define CSMATHE1  -99 "System Missing" 1 "Not Yet" 2 "Beginning"
                       3 "In Progress" 4 "Intermediate" 5 "Proficient" ;
label define CSMATHE2  -99 "System Missing" 1 "Not Yet" 2 "Beginning"
                       3 "In Progress" 4 "Intermediate" 5 "Proficient" ;
label define CSMATHE3  -99 "System Missing" 1 "Not Yet" 2 "Beginning"
                       3 "In Progress" 4 "Intermediate" 5 "Proficient" ;
label define CSMATHE4  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Not Yet"
                       2 "Beginning" 3 "In Progress" 4 "Intermediate"
                       5 "Proficient" ;
label define CSMATHE5  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Not Yet"
                       2 "Beginning" 3 "In Progress" 4 "Intermediate"
                       5 "Proficient" ;
label define CSMATHE6  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Not Yet"
                       2 "Beginning" 3 "In Progress" 4 "Intermediate"
                       5 "Proficient" ;
label define CSMATHE7  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Not Yet"
                       2 "Beginning" 3 "In Progress" 4 "Intermediate"
                       5 "Proficient" ;
label define CREDENTIALE -99 "System Missing" 1 "ECE credential"
                       2 "K credential" 3 "EE credential"
                       4 "Other credential" ;
label define BACERT_AE -99 "System Missing"
                       0 "Teacher has a BA or better, but no State Certificate"
                       1 "Teacher has a BA or better, and has State Certificate"
                       2 "Yes, Emergency or Temporary" ;
label define BACERT_BE -99 "System Missing"
                       0 "Teacher has a BA or better, but no State Certificate"
                       1 "Teacher has a BA or better, and has State Certificate"
                       2 "Yes, Emergency or Temporary" ;
label define BACERT_CE -99 "System Missing"
                       0 "Teacher has a BA or better, but no State Certificate"
                       1 "Teacher has a BA or better, and has State Certificate"
                       2 "Yes, Emergency or Temporary" ;
label define BACERT_DE -99 "System Missing"
                       0 "Teacher has a BA or better, but no State Certificate"
                       1 "Teacher has a BA or better, and has State Certificate"
                       2 "Yes, Emergency or Temporary" ;
label define BACERT_EE -99 "System Missing"
                       0 "Teacher has a BA or better, but no State Certificate"
                       1 "Teacher has a BA or better, and has State Certificate"
                       2 "Yes, Emergency or Temporary" ;
label define BACERT_FE -99 "System Missing"
                       0 "Teacher has a BA or better, but no State Certificate"
                       1 "Teacher has a BA or better, and has State Certificate"
                       2 "Yes, Emergency or Temporary" ;
label define BACERT_GE -99 "System Missing"
                       0 "Teacher has a BA or better, but no State Certificate"
                       1 "Teacher has a BA or better, and has State Certificate"
                       2 "Yes, Emergency or Temporary" ;
label define NOBACERTE -99 "System Missing"
                       0 "Teacher does not have a BA, and does not claim accreditation" ;
label define CALC_WAGEE -99 "System Missing" -7 "Child Failed Practice Items"
                       -6 "Item is Missing (But Form is Present)" ;
label define T_EDUCE   -99 "System Missing" 1 "High School diploma or better"
                       2 "Some college or an AA" 3 "Bachelor's degree"
                       4 "At least 1 year beyond BA" 5 "Master's degree"
                       6 "Education specialist or professional diploma"
                       7 "Doctoral degree" 8 "Other" ;
label define T_EDYRSE  -99 "System Missing" ;
label define T_BAE     -99 "System Missing" 0 "No" 1 "Yes" ;
label define T_MAJORE  -99 "System Missing" 1 "Early Childhood Education"
                       2 "Elementary Education" 3 "Special Education"
                       4 "English as a Second Language" 5 "Child Development"
                       6 "N/A (No degree)" 7 "Other" 8 "Other Education"
                       9 "Psychology (Any)" 10 "Home Economics"
                       11 "Social Work/Human Services" 12 "Sociology"
                       13 "Reading" ;
label define AFR_AMTE  -99 "System Missing" 0 "No" 1 "Yes" ;
label define NAT_AMTE  -99 "System Missing" 0 "No" 1 "Yes" ;
label define WHITETE   -99 "System Missing" 0 "No" 1 "Yes" ;
label define ASIANTE   -99 "System Missing" 0 "No" 1 "Yes" ;
label define LATINATE  -99 "System Missing" 0 "No" 1 "Yes" ;
label define OTHERTE   -99 "System Missing" 0 "No" 1 "Yes" ;
label define T_RACEE   -99 "System Missing" 1 "Latin" 2 "African American"
                       3 "Native American" 4 "Asian" 5 "White"
                       6 "Multiracial" ;
label define EXPER01E  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define EXPER02E  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define EXPER04E  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define EXPER05E  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define EXPTOTE   -99 "System Missing" ;
label define T_GENDERE -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Male"
                       2 "Female" ;
label define T_AGEE    -99 "System Missing" ;
label define MONTHSE   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define T_PLANPE  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "0"
                       2 "2 or less" 3 "3 - 4" 4 "5 - 6" 5 "7 - 9"
                       6 "10 or More" ;
label define T_PLANUE  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "0"
                       2 "2 or less" 3 "3 - 4" 4 "5 - 6" 5 "7 - 9"
                       6 "10 or More" ;
label define CLS_SIZEE -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define MALEPE    -99 "System Missing" ;
label define IEPE      -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define CLANG01E  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define CLANG02E  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define CLANG03E  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define TLANG01E  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define TLANG02E  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define TLANG03E  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define LEPE      -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define CHRESE    -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define CHRESUSE  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 1 "Yes"
                       2 "No" ;
label define AFR_AME   -99 "System Missing" ;
label define NAT_AME   -99 "System Missing" ;
label define WHITEE    -99 "System Missing" ;
label define LATINOE   -99 "System Missing" ;
label define ASIANE    -99 "System Missing" ;
label define OTHERE    -99 "System Missing" ;
label define CLS_TYPEE -99 "System Missing" -9 "System Missing"
                       1 "Kindergarten Class" 2 "1st Grade Class"
                       3 "Kindergarten and 1st Grade combined class"
                       4 "1st and 2nd grade combined class"
                       5 "Transitional 1st or junior 1st" 6 "Other"
                       9 "System Missing" ;
label define TARGPOPE  -99 "System Missing" -9 "System Missing"
                       1 "Not targeted"
                       2 "Children with below average academic skills"
                       3 "Regular edu. class with fully included special edu. students"
                       4 "Self-contained special education class"
                       5 "Class for English language learners"
                       6 "Spanish language immersion class"
                       7 "Other targeted population" 9 "System Missing" ;
label define LOCATIONE -99 "System Missing"
                       1 "Regular public elementary school"
                       2 "Public magnet school" 3 "Public charter school"
                       4 "Private, religious school"
                       5 "Private, non-religious school" 6 "Other" ;
label define LITCURE01 -99 "System Missing" 0 "No" 1 "Yes" ;
label define LITCURE02 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define LITCURE03 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define LITCURE04 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define LITCURE05 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define LITCURE06 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define LITCURE07 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define LITCURE08 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define LITCURE09 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define LITCURE10 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define LITCURE11 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define LITCURE12 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define LITCURE13 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define LITCURE14 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define LITCURE15 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define LITCURE16 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define LITCURE17 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define LITCURE18 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define LITCURE19 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define LITCURE20 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define LITCURE21 -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" 0 "No"
                       1 "Yes" ;
label define PARVISE   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)"
                       1 "Not allowed during the day"
                       2 "Only at specific times"
                       3 "Only with advance notice" 4 "At any time" ;
label define PARMTGE   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define PARRPTE   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define AID_E     -99 "System Missing" 1 "Yes" 2 "No" ;
label define AID_HRSE  -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define TQDATEE   -99 "System Missing"
                       -6 "Item is Missing (But Form is Present)" ;
label define SCHYRK    -99 "System Missing" ;
label define CHPARTK   -99 "System Missing" 0 "No Kindergarten Participation"
                       1 "Partial Kindergarten Participation"
                       2 "Full Kindergarten Participation" ;
label define ASMTAGEKF -99 "System Missing" ;
label define ASMTAGEKS -99 "System Missing" ;
label define AMSNTDAYK -99 "System Missing" ;
label define TCHCHNGK  -99 "System Missing" 0 "No" 1 "Yes" ;
label define CLASSCHNGK -99 "System Missing" 0 "No" 1 "Yes" ;
label define SITE_ECK  -99 "System Missing" ;
label define SITE_TRKF -99 "System Missing" ;
label define SITE_TRKS -99 "System Missing" ;
label define CHNRCDK   -99 "System Missing" 1 "Absent during repeat visits"
                       2 "Could not locate" 3 "Child deceased"
                       4 "Home schooled or not in school"
                       5 "Moved to another country" 6 "Medical"
                       7 "Moved to another state"
                       8 "Principal refused to allow full participation"
                       9 "Passive refusal; teacher agreed but never returned form"
                       10 "Parent asked to withdraw child"
                       11 "Teacher refused" 12 "Unable to schedule" ;
label define NUMCLSRMK -99 "System Missing" ;
label define ASMNTDAYPKK -99 "System Missing" ;


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
replace CHGENP = . if (CHGENP == -99)
replace CHMATEDCP = . if (CHMATEDCP == -99)
replace POORP = . if (POORP == -99)
replace CHRACE_AAP = . if (CHRACE_AAP == -99)
replace CHRACE_ASP = . if (CHRACE_ASP == -99)
replace CHRACE_LTP = . if (CHRACE_LTP == -99)
replace CHRACE_NAP = . if (CHRACE_NAP == -99)
replace CHRACE_OTP = . if (CHRACE_OTP == -99)
replace CHRACE_WHP = . if (CHRACE_WHP == -99)
replace CHRACEP = . if (CHRACEP == -99)
replace CCARRP_1 = . if (CCARRP_1 == -99)
replace CCARRP_2 = . if (CCARRP_2 == -99)
replace CCARRP_3 = . if (CCARRP_3 == -99)
replace CCARRP_4 = . if (CCARRP_4 == -99)
replace CCARRP_5 = . if (CCARRP_5 == -99)
replace CCARRP_6 = . if (CCARRP_6 == -99)
replace CCARRP_7 = . if (CCARRP_7 == -99)
replace CCARRP_8 = . if (CCARRP_8 == -99)
replace CCARRP_9 = . if (CCARRP_9 == -99)
replace CHHLTHFP = . if (CHHLTHFP == -99)
replace CHFLANGP_1 = . if (CHFLANGP_1 == -99)
replace CHFLANGP_2 = . if (CHFLANGP_2 == -99)
replace CHFLANGP_3 = . if (CHFLANGP_3 == -99)
replace CHCLANGP_1 = . if (CHCLANGP_1 == -99)
replace CHCLANGP_2 = . if (CHCLANGP_2 == -99)
replace CHCLANGP_3 = . if (CHCLANGP_3 == -99)
replace CHHSNUMP = . if (CHHSNUMP == -99)
replace CHHSUN18P = . if (CHHSUN18P == -6 | CHHSUN18P == -99)
replace CHINCOMCP = . if (CHINCOMCP == -99)
replace CHLIVEP_1 = . if (CHLIVEP_1 == -99)
replace CHLIVEP_2 = . if (CHLIVEP_2 == -99)
replace CHLIVEP_3 = . if (CHLIVEP_3 == -99)
replace CHLIVEP_4 = . if (CHLIVEP_4 == -99)
replace CHLIVEP_5 = . if (CHLIVEP_5 == -99)
replace CHLIVEP_6 = . if (CHLIVEP_6 == -99)
replace CHLIVEP_7 = . if (CHLIVEP_7 == -99)
replace CHLIVEP_8 = . if (CHLIVEP_8 == -99)
replace CHADULTP = . if (CHADULTP == -99)
replace CHMATEDNP = . if (CHMATEDNP == -99)
replace CHINCOMNP = . if (CHINCOMNP == -99)
replace PRELASTPF = . if (PRELASTPF == -99)
replace LETTEREPF = . if (LETTEREPF == -5 | LETTEREPF == -99)
replace NUMBEREPF = . if (NUMBEREPF == -5 | NUMBEREPF == -99)
replace COLOREPF = . if (COLOREPF == -5 | COLOREPF == -99)
replace HICNTEPF = . if (HICNTEPF == -6 | HICNTEPF == -99)
replace HICNTCOREPF = . if (HICNTCOREPF == -6 | HICNTCOREPF == -99)
replace CTOPPEPF = . if (CTOPPEPF == -5 | CTOPPEPF == -99)
replace PPVTEPF = . if (PPVTEPF == -5 | PPVTEPF == -99)
replace PPVREPF = . if (PPVREPF == -5 | PPVREPF == -99)
replace OWLSEPF = . if (OWLSEPF == -99)
replace OWLSEPF = . if (OWLSEPF >= -8 & OWLSEPF <= -5)
replace WJ10_WEPF = . if (WJ10_WEPF == -5 | WJ10_WEPF == -99)
replace WJ10_SSEPF = . if (WJ10_SSEPF == -5 | WJ10_SSEPF == -99)
replace WJ21AEPF = . if (WJ21AEPF == -5 | WJ21AEPF == -99)
replace LETTERSPF = . if (LETTERSPF == -5 | LETTERSPF == -99)
replace NUMBERSPF = . if (NUMBERSPF == -5 | NUMBERSPF == -99)
replace COLORSPF = . if (COLORSPF == -5 | COLORSPF == -99)
replace TVIPSPF = . if (TVIPSPF == -99)
replace TVIPRSPF = . if (TVIPRSPF == -99)
replace WM25SSPF = . if (WM25SSPF == -99)
replace WM25WPF = . if (WM25WPF == -99)
replace HICNTSPF = . if (HICNTSPF == -6 | HICNTSPF == -99)
replace HICNTCORSPF = . if (HICNTCORSPF == -6 | HICNTCORSPF == -99)
replace ASMSTATPF = . if (ASMSTATPF == -99)
replace PRELASTPS = . if (PRELASTPS == -99)
replace LETTEREPS = . if (LETTEREPS == -5 | LETTEREPS == -99)
replace NUMBEREPS = . if (NUMBEREPS == -5 | NUMBEREPS == -99)
replace COLOREPS = . if (COLOREPS == -5 | COLOREPS == -99)
replace HICNTEPS = . if (HICNTEPS == -5 | HICNTEPS == -99)
replace HICNTCOREPS = . if (HICNTCOREPS == -5 | HICNTCOREPS == -99)
replace CTOPPEPS = . if (CTOPPEPS == -5 | CTOPPEPS == -99)
replace PPVTEPS = . if (PPVTEPS == -5 | PPVTEPS == -99)
replace PPVREPS = . if (PPVREPS == -5 | PPVREPS == -99)
replace OWLSEPS = . if (OWLSEPS == -5 | OWLSEPS == -8 | OWLSEPS == -99)
replace WJ10_WEPS = . if (WJ10_WEPS == -5 | WJ10_WEPS == -6 | WJ10_WEPS == -99)
replace WJ10_SSEPS = . if (WJ10_SSEPS == -5 | WJ10_SSEPS == -6 | WJ10_SSEPS == -99)
replace WJ21AEPS = . if (WJ21AEPS == -5 | WJ21AEPS == -99)
replace LETTERSPS = . if (LETTERSPS == -99)
replace NUMBERSPS = . if (NUMBERSPS == -99)
replace COLORSPS = . if (COLORSPS == -99)
replace TVIPSPS = . if (TVIPSPS == -99)
replace TVIPRSPS = . if (TVIPRSPS == -99)
replace WM25SSPS = . if (WM25SSPS == -99)
replace WM25WPS = . if (WM25WPS == -99)
replace HICNTSPS = . if (HICNTSPS == -99)
replace HICNTCORSPS = . if (HICNTCORSPS == -99)
replace ASMSTATPS = . if (ASMSTATPS == -99)
replace HTCOMPPF = . if (HTCOMPPF == -99.00)
replace HTFTOLPF = . if (HTFTOLPF == -99.00)
replace HTASRTPF = . if (HTASRTPF == -99.00)
replace HTTKORPF = . if (HTTKORPF == -99.00)
replace HTPSSKPF = . if (HTPSSKPF == -99.00)
replace HTPROBPF = . if (HTPROBPF == -99.00)
replace HTCNPRPF = . if (HTCNPRPF == -99.00)
replace HTINTNPF = . if (HTINTNPF == -99.00)
replace HTLNPRPF = . if (HTLNPRPF == -99.00)
replace CSLANGPF = . if (CSLANGPF == -99.00)
replace CSLANGPF1 = . if (CSLANGPF1 == -5 | CSLANGPF1 == -99)
replace CSLANGPF2 = . if (CSLANGPF2 == -5 | CSLANGPF2 == -99)
replace CSLANGPF3 = . if (CSLANGPF3 == -5 | CSLANGPF3 == -99)
replace CSLANGPF4 = . if (CSLANGPF4 == -5 | CSLANGPF4 == -99)
replace CSLANGPF5 = . if (CSLANGPF5 == -5 | CSLANGPF5 == -99)
replace CSLANGPF6 = . if (CSLANGPF6 == -5 | CSLANGPF6 == -99)
replace CSLANGPF7 = . if (CSLANGPF7 == -5 | CSLANGPF7 == -99)
replace CSLANGPF8 = . if (CSLANGPF8 == -5 | CSLANGPF8 == -99)
replace CSLANGPF9 = . if (CSLANGPF9 == -5 | CSLANGPF9 == -99)
replace CHATNDPRKP = . if (CHATNDPRKP == -99)
replace CHHLTHTPF = . if (CHHLTHTPF == -99)
replace COMPAREPF = . if (COMPAREPF == -99)
replace BLOCKPF = . if (BLOCKPF == -99)
replace SETTINGPF = . if (SETTINGPF == -99)
replace SERIOUSPF = . if (SERIOUSPF == -9 | SERIOUSPF == -99)
replace SERVICEPF = . if (SERVICEPF == -99)
replace PROBPF_01 = . if (PROBPF_01 == -99)
replace PROBPF_02 = . if (PROBPF_02 == -99)
replace PROBPF_03 = . if (PROBPF_03 == -99)
replace PROBPF_04 = . if (PROBPF_04 == -99)
replace PROBPF_05 = . if (PROBPF_05 == -99)
replace PROBPF_06 = . if (PROBPF_06 == -99)
replace PROBPF_07 = . if (PROBPF_07 == -99)
replace PROBPF_08 = . if (PROBPF_08 == -99)
replace PROBPF_09 = . if (PROBPF_09 == -99)
replace PROBPF_10 = . if (PROBPF_10 == -99)
replace PROBPF_11 = . if (PROBPF_11 == -99)
replace PROBPF_12 = . if (PROBPF_12 == -99)
replace PROBPF_13 = . if (PROBPF_13 == -99)
replace PROBPF_14 = . if (PROBPF_14 == -99)
replace PROBPF_15 = . if (PROBPF_15 == -99)
replace PROBPF_16 = . if (PROBPF_16 == -99)
replace PROBPF_17 = . if (PROBPF_17 == -99)
replace PROBPF_18 = . if (PROBPF_18 == -99)
replace HTCOMPPS = . if (HTCOMPPS == -99.00)
replace HTFTOLPS = . if (HTFTOLPS == -99.00)
replace HTASRTPS = . if (HTASRTPS == -99.00)
replace HTTKORPS = . if (HTTKORPS == -99.00)
replace HTPSSKPS = . if (HTPSSKPS == -99.00)
replace HTPROBPS = . if (HTPROBPS == -99.00)
replace HTCNPRPS = . if (HTCNPRPS == -99.00)
replace HTINTNPS = . if (HTINTNPS == -99.00)
replace HTLNPRPS = . if (HTLNPRPS == -99.00)
replace CSLANGPS = . if (CSLANGPS == -99.00)
replace CSMATHPS = . if (CSMATHPS == -99.00)
replace CSTOTPS = . if (CSTOTPS == -99.00)
replace CSLANGPS1 = . if (CSLANGPS1 == -5 | CSLANGPS1 == -6 | CSLANGPS1 == -99)
replace CSLANGPS2 = . if (CSLANGPS2 == -5 | CSLANGPS2 == -99)
replace CSLANGPS3 = . if (CSLANGPS3 == -5 | CSLANGPS3 == -6 | CSLANGPS3 == -99)
replace CSLANGPS4 = . if (CSLANGPS4 == -5 | CSLANGPS4 == -6 | CSLANGPS4 == -99)
replace CSLANGPS5 = . if (CSLANGPS5 == -5 | CSLANGPS5 == -6 | CSLANGPS5 == -99)
replace CSLANGPS6 = . if (CSLANGPS6 == -5 | CSLANGPS6 == -6 | CSLANGPS6 == -99)
replace CSLANGPS7 = . if (CSLANGPS7 == -5 | CSLANGPS7 == -6 | CSLANGPS7 == -99)
replace CSLANGPS8 = . if (CSLANGPS8 == -5 | CSLANGPS8 == -6 | CSLANGPS8 == -99)
replace CSLANGPS9 = . if (CSLANGPS9 == -5 | CSLANGPS9 == -6 | CSLANGPS9 == -99)
replace CSMATHPS1 = . if (CSMATHPS1 == -5 | CSMATHPS1 == -6 | CSMATHPS1 == -99)
replace CSMATHPS2 = . if (CSMATHPS2 == -5 | CSMATHPS2 == -6 | CSMATHPS2 == -99)
replace CSMATHPS3 = . if (CSMATHPS3 == -5 | CSMATHPS3 == -6 | CSMATHPS3 == -99)
replace CSMATHPS4 = . if (CSMATHPS4 == -5 | CSMATHPS4 == -6 | CSMATHPS4 == -99)
replace CSMATHPS5 = . if (CSMATHPS5 == -5 | CSMATHPS5 == -99)
replace CSMATHPS6 = . if (CSMATHPS6 == -5 | CSMATHPS6 == -6 | CSMATHPS6 == -99)
replace CSMATHPS7 = . if (CSMATHPS7 == -5 | CSMATHPS7 == -99)
replace FIPCNP = . if (FIPCNP == -99.00)
replace FITSIP = . if (FITSIP == -99.00)
replace OPGRFNP = . if (OPGRFNP == -6.00 | OPGRFNP == -99.00)
replace OPSPEVP = . if (OPSPEVP == -6.00 | OPSPEVP == -99.00)
replace OPPTCP = . if (OPPTCP == -6.00 | OPPTCP == -99.00)
replace PARCALLP = . if (PARCALLP == -6 | PARCALLP == -99)
replace TCRCALLP = . if (TCRCALLP == -6 | TCRCALLP == -99)
replace PARVISTP = . if (PARVISTP == -6 | PARVISTP == -99)
replace TCRVISTP = . if (TCRVISTP == -6 | TCRVISTP == -99)
replace PARINVTP = . if (PARINVTP == -6 | PARINVTP == -99)
replace PARATNDP = . if (PARATNDP == -6 | PARATNDP == -99)
replace PARSPEVP = . if (PARSPEVP == -6 | PARSPEVP == -99)
replace PARATSEP = . if (PARATSEP == -6 | PARATSEP == -99)
replace PARINPCP = . if (PARINPCP == -6 | PARINPCP == -99)
replace PARATPCP = . if (PARATPCP == -6 | PARATPCP == -99)
replace PARSNMTP = . if (PARSNMTP == -6 | PARSNMTP == -99)
replace PARVOLP = . if (PARVOLP == -6 | PARVOLP == -99)
replace STCLOSEPS = . if (STCLOSEPS == -99.00)
replace STCONFLPS = . if (STCONFLPS == -99.00)
replace CHHLTHTPS = . if (CHHLTHTPS == -6 | CHHLTHTPS == -99)
replace COMPAREPS = . if (COMPAREPS == -6 | COMPAREPS == -99)
replace BLOCKPS = . if (BLOCKPS == -6 | BLOCKPS == -99)
replace SETTINGPS = . if (SETTINGPS == -6 | SETTINGPS == -99)
replace SERIOUSPS = . if (SERIOUSPS == -9 | SERIOUSPS == -6 | SERIOUSPS == -99)
replace SERVICEPS = . if (SERVICEPS == -6 | SERVICEPS == -99)
replace PROBPS_01 = . if (PROBPS_01 == -99)
replace PROBPS_02 = . if (PROBPS_02 == -99)
replace PROBPS_03 = . if (PROBPS_03 == -99)
replace PROBPS_04 = . if (PROBPS_04 == -99)
replace PROBPS_05 = . if (PROBPS_05 == -99)
replace PROBPS_06 = . if (PROBPS_06 == -99)
replace PROBPS_07 = . if (PROBPS_07 == -99)
replace PROBPS_08 = . if (PROBPS_08 == -99)
replace PROBPS_09 = . if (PROBPS_09 == -99)
replace PROBPS_10 = . if (PROBPS_10 == -99)
replace PROBPS_11 = . if (PROBPS_11 == -99)
replace PROBPS_12 = . if (PROBPS_12 == -99)
replace PROBPS_13 = . if (PROBPS_13 == -99)
replace PROBPS_14 = . if (PROBPS_14 == -99)
replace PROBPS_15 = . if (PROBPS_15 == -99)
replace PROBPS_16 = . if (PROBPS_16 == -99)
replace PROBPS_17 = . if (PROBPS_17 == -99)
replace PROBPS_18 = . if (PROBPS_18 == -99)
replace IEPRFTQP = . if (IEPRFTQP == -99)
replace IEPTQP = . if (IEPTQP == -99)
replace IEPMONP = . if (IEPMONP == -6 | IEPMONP == -99)
replace IEPYEARP = . if (IEPYEARP == -6 | IEPYEARP == -99)
replace IEPSPCHP = . if (IEPSPCHP == -6 | IEPSPCHP == -99)
replace IEPPHYSP = . if (IEPPHYSP == -6 | IEPPHYSP == -99)
replace IEPCOGP = . if (IEPCOGP == -6 | IEPCOGP == -99)
replace IEPSOCP = . if (IEPSOCP == -6 | IEPSOCP == -99)
replace IEPOTHP = . if (IEPOTHP == -6 | IEPOTHP == -99)
replace PARRELP = . if (PARRELP == -99)
replace PAREMOTP = . if (PAREMOTP == -99)
replace PARTRSTP = . if (PARTRSTP == -99)
replace PARCOMMP = . if (PARCOMMP == -99)
replace PARAGRP = . if (PARAGRP == -99)
replace PARAPPP = . if (PARAPPP == -99)
replace PARCOOPP = . if (PARCOOPP == -99)
replace IEPEYP = . if (IEPEYP == -99)
replace IEPRFEYP = . if (IEPRFEYP == -99)
replace CHABSENTP = . if (CHABSENTP == -6.00 | CHABSENTP == -99.00)
replace ASFCC_MPF = . if (ASFCC_MPF == -99.000)
replace ASMLS_MPF = . if (ASMLS_MPF == -99.000)
replace ASSGT_MPF = . if (ASSGT_MPF == -99.000)
replace ASWGT_MPF = . if (ASWGT_MPF == -99.000)
replace ASOST_MPF = . if (ASOST_MPF == -99.000)
replace CEAES_MPF = . if (CEAES_MPF == -99.000)
replace CEFNM_MPF = . if (CEFNM_MPF == -99.000)
replace CEGRM_MPF = . if (CEGRM_MPF == -99.000)
replace CELTS_MPF = . if (CELTS_MPF == -99.000)
replace CEMTH_MPF = . if (CEMTH_MPF == -99.000)
replace CEOLD_MPF = . if (CEOLD_MPF == -99.000)
replace CEPRR_MPF = . if (CEPRR_MPF == -99.000)
replace CERDG_MPF = . if (CERDG_MPF == -99.000)
replace CESCI_MPF = . if (CESCI_MPF == -99.000)
replace CESCS_MPF = . if (CESCS_MPF == -99.000)
replace CEWRT_MPF = . if (CEWRT_MPF == -99.000)
replace CE_LIT_MPF = . if (CE_LIT_MPF == -99.000)
replace DSDST_MPF = . if (DSDST_MPF == -99.000)
replace AIRSM_MPF = . if (AIRSM_MPF == -99.000)
replace TCESC_MPF = . if (TCESC_MPF == -99.000)
replace TCDDT_MPF = . if (TCDDT_MPF == -99.000)
replace TCSCL_MPF = . if (TCSCL_MPF == -99.000)
replace CEREAD_C_MPF = . if (CEREAD_C_MPF == -99.000)
replace CELTS_C_MPF = . if (CELTS_C_MPF == -99.000)
replace CEOLD_C_MPF = . if (CEOLD_C_MPF == -99.000)
replace CEMTH_C_MPF = . if (CEMTH_C_MPF == -99.000)
replace CESCI_C_MPF = . if (CESCI_C_MPF == -99.000)
replace CEWRT_C_MPF = . if (CEWRT_C_MPF == -99.000)
replace CESCS_C_MPF = . if (CESCS_C_MPF == -99.000)
replace CEAES_C_MPF = . if (CEAES_C_MPF == -99.000)
replace CEMOT_C_MPF = . if (CEMOT_C_MPF == -99.000)
replace CENONE_C_MPF = . if (CENONE_C_MPF == -99.000)
replace SNAPOBSPF = . if (SNAPOBSPF == -99)
replace SNAPDAYPF = . if (SNAPDAYPF == -99)
replace ASFCC_MPS = . if (ASFCC_MPS == -99.000)
replace ASMLS_MPS = . if (ASMLS_MPS == -99.000)
replace ASSGT_MPS = . if (ASSGT_MPS == -99.000)
replace ASWGT_MPS = . if (ASWGT_MPS == -99.000)
replace ASOST_MPS = . if (ASOST_MPS == -99.000)
replace CEAES_MPS = . if (CEAES_MPS == -99.000)
replace CEFNM_MPS = . if (CEFNM_MPS == -99.000)
replace CEGRM_MPS = . if (CEGRM_MPS == -99.000)
replace CELTS_MPS = . if (CELTS_MPS == -99.000)
replace CEMTH_MPS = . if (CEMTH_MPS == -99.000)
replace CEOLD_MPS = . if (CEOLD_MPS == -99.000)
replace CEPRR_MPS = . if (CEPRR_MPS == -99.000)
replace CERDG_MPS = . if (CERDG_MPS == -99.000)
replace CESCI_MPS = . if (CESCI_MPS == -99.000)
replace CESCS_MPS = . if (CESCS_MPS == -99.000)
replace CEWRT_MPS = . if (CEWRT_MPS == -99.000)
replace CE_LIT_MPS = . if (CE_LIT_MPS == -99.000)
replace DSDST_MPS = . if (DSDST_MPS == -99.000)
replace AIRTN_MPS = . if (AIRTN_MPS == -99.000)
replace AIMIN_MPS = . if (AIMIN_MPS == -99.000)
replace AISMP_MPS = . if (AISMP_MPS == -99.000)
replace AIELB_MPS = . if (AIELB_MPS == -99.000)
replace TCENC_MPS = . if (TCENC_MPS == -99.000)
replace TCSCF_MPS = . if (TCSCF_MPS == -99.000)
replace TCDDT_MPS = . if (TCDDT_MPS == -99.000)
replace TCSCL_MPS = . if (TCSCL_MPS == -99.000)
replace AIELB_C_MPS = . if (AIELB_C_MPS == -99.000)
replace AIRTN_C_MPS = . if (AIRTN_C_MPS == -99.000)
replace AISMP_C_MPS = . if (AISMP_C_MPS == -99.000)
replace AINONE_C_MPS = . if (AINONE_C_MPS == -99.000)
replace CEREAD_C_MPS = . if (CEREAD_C_MPS == -99.000)
replace CELTS_C_MPS = . if (CELTS_C_MPS == -99.000)
replace CEOLD_C_MPS = . if (CEOLD_C_MPS == -99.000)
replace CEMTH_C_MPS = . if (CEMTH_C_MPS == -99.000)
replace CESCI_C_MPS = . if (CESCI_C_MPS == -99.000)
replace CEWRT_C_MPS = . if (CEWRT_C_MPS == -99.000)
replace CESCS_C_MPS = . if (CESCS_C_MPS == -99.000)
replace CEAES_C_MPS = . if (CEAES_C_MPS == -99.000)
replace CEMOT_C_MPS = . if (CEMOT_C_MPS == -99.000)
replace CENONE_C_MPS = . if (CENONE_C_MPS == -99.000)
replace SNAPOBSPS = . if (SNAPOBSPS == -99)
replace SNAPDAYPS = . if (SNAPDAYPS == -99)
replace CHILD_WTPF = . if (CHILD_WTPF == -99.00)
replace CHILD_WTPS = . if (CHILD_WTPS == -99.00)
replace CHBYEARP = . if (CHBYEARP == -99)
replace CHPARTP = . if (CHPARTP == -99)
replace ASMTAGEPF = . if (ASMTAGEPF == -99.00)
replace ASMTAGEPS = . if (ASMTAGEPS == -99.00)
replace EWTNMEPF = . if (EWTNMEPF == -99.00)
replace EWTNMSPF = . if (EWTNMSPF == -99.00)
replace EWTNMEPS = . if (EWTNMEPS == -99.00)
replace EWTNMSPS = . if (EWTNMSPS == -99.00)
replace T_CHNGCP = . if (T_CHNGCP == -99)
replace AMSNTDAYP = . if (AMSNTDAYP == -99.00)
replace SITE_PS = . if (SITE_PS == -99)
replace SITE_PF = . if (SITE_PF == -99)
replace SITE_TRPS = . if (SITE_TRPS == -99)
replace HHTYPEP = . if (HHTYPEP == -99)
replace ASINT_MPF = . if (ASINT_MPF == -99.000)
replace ASRTN_MPF = . if (ASRTN_MPF == -99.000)
replace ASINT_MPS = . if (ASINT_MPS == -99.000)
replace ASRTN_MPS = . if (ASRTN_MPS == -99.000)
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
replace ASRTNC_CF = . if (ASRTNC_CF == -99.000)
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
replace EXPER01P = . if (EXPER01P == -6.00 | EXPER01P == -99.00)
replace EXPER02P = . if (EXPER02P == -5.00 | EXPER02P == -99.00)
replace EXPER03P = . if (EXPER03P == -99.00)
replace MONTHS = . if (MONTHS == -6.00 | MONTHS == -99.00)
replace EMPLHRP = . if (EMPLHRP == -6.00 | EMPLHRP == -99.00)
replace EXPTOTP = . if (EXPTOTP == -99.00)
replace BACERT_AP = . if (BACERT_AP == -99)
replace BACERT_BP = . if (BACERT_BP == -99)
replace BACERT_CP = . if (BACERT_CP == -99)
replace BACERT_DP = . if (BACERT_DP == -99)
replace BACERT_EP = . if (BACERT_EP == -99)
replace BACERT_FP = . if (BACERT_FP == -99)
replace BACERT_GP = . if (BACERT_GP == -99)
replace NOBACERTP = . if (NOBACERTP == -99)
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
replace CALC_WAGEP = . if (CALC_WAGEP == -7.00 | CALC_WAGEP == -99.00)
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
replace ADMTITLEP = . if (ADMTITLEP == -99)
replace BENEFITP_1 = . if (BENEFITP_1 == -6 | BENEFITP_1 == -99)
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
replace SERVICEP_9 = . if (SERVICEP_9 == -99)
replace SERVICEP_10 = . if (SERVICEP_10 == -99)
replace SERVICEP_11 = . if (SERVICEP_11 == -99)
replace T_CHNG = . if (T_CHNG == -99)
replace PRELASTKF = . if (PRELASTKF == -99)
replace LETTEREKF = . if (LETTEREKF == -99)
replace NUMBEREKF = . if (NUMBEREKF == -99)
replace HICNTEKF = . if (HICNTEKF == -99)
replace HICNTCOREKF = . if (HICNTCOREKF == -99)
replace CTOPPEKF = . if (CTOPPEKF == -7 | CTOPPEKF == -99)
replace PPVTEKF = . if (PPVTEKF == -99)
replace OWLSEKF = . if (OWLSEKF == -6 | OWLSEKF == -99)
replace WJ1_WEKF = . if (WJ1_WEKF == -5 | WJ1_WEKF == -99)
replace WJ1_SSEKF = . if (WJ1_SSEKF == -5 | WJ1_SSEKF == -99)
replace WJ10_WEKF = . if (WJ10_WEKF == -5 | WJ10_WEKF == -99)
replace WJ10_SSEKF = . if (WJ10_SSEKF == -5 | WJ10_SSEKF == -99)
replace WJ21AEKF = . if (WJ21AEKF == -99)
replace LETTERSKF = . if (LETTERSKF == -99)
replace NUMBERSKF = . if (NUMBERSKF == -99)
replace COLORSKF = . if (COLORSKF == -99)
replace TVIPSKF = . if (TVIPSKF == -6 | TVIPSKF == -99)
replace WM25SSKF = . if (WM25SSKF == -99)
replace WM25WKF = . if (WM25WKF == -99)
replace WM22SSKF = . if (WM22SSKF == -99)
replace WM22WKF = . if (WM22WKF == -99)
replace HICNTSKF = . if (HICNTSKF == -99)
replace HICNTCORSKF = . if (HICNTCORSKF == -99)
replace EWTNMEKF = . if (EWTNMEKF == -99.00)
replace EWTNMSKF = . if (EWTNMSKF == -99.00)
replace ASMSTATKF = . if (ASMSTATKF == -99)
replace PRELASTKS = . if (PRELASTKS == -99)
replace LETTEREKS = . if (LETTEREKS == -99)
replace NUMBEREKS = . if (NUMBEREKS == -99)
replace HICNTEKS = . if (HICNTEKS == -99)
replace HICNTCOREKS = . if (HICNTCOREKS == -6 | HICNTCOREKS == -99)
replace CTOPPEKS = . if (CTOPPEKS == -7 | CTOPPEKS == -99)
replace PPVTEKS = . if (PPVTEKS == -99)
replace OWLSEKS = . if (OWLSEKS == -6 | OWLSEKS == -99)
replace WJ1_WEKS = . if (WJ1_WEKS == -99)
replace WJ1_SSEKS = . if (WJ1_SSEKS == -99)
replace WJ10_WEKS = . if (WJ10_WEKS == -99)
replace WJ10_SSEKS = . if (WJ10_SSEKS == -99)
replace WJ21AEKS = . if (WJ21AEKS == -99)
replace LETTERSKS = . if (LETTERSKS == -99)
replace NUMBERSKS = . if (NUMBERSKS == -99)
replace COLORSKS = . if (COLORSKS == -99)
replace TVIPSKS = . if (TVIPSKS == -99)
replace WM22SSKS = . if (WM22SSKS == -99)
replace WM22WKS = . if (WM22WKS == -99)
replace WM25SSKS = . if (WM25SSKS == -99)
replace WM25WKS = . if (WM25WKS == -99)
replace HICNTSKS = . if (HICNTSKS == -99)
replace HICNTCORSKS = . if (HICNTCORSKS == -99)
replace EWTNMEKS = . if (EWTNMEKS == -99.00)
replace EWTNMSKS = . if (EWTNMSKS == -99)
replace ASMSTATKS = . if (ASMSTATKS == -99)
replace CHLDGRK = . if (CHLDGRK == -99)
replace CHHLTHTKF = . if (CHHLTHTKF == -99)
replace WHYPKK = . if (WHYPKK == -6 | WHYPKK == -99)
replace ATPKLYK = . if (ATPKLYK == -6 | ATPKLYK == -99)
replace TLANG1KF = . if (TLANG1KF == -99)
replace TLANG2KF = . if (TLANG2KF == -99)
replace TLANG3KF = . if (TLANG3KF == -99)
replace TQSCDATEKF = . if (TQSCDATEKF == -6 | TQSCDATEKF == -99)
replace HTCOMPKF = . if (HTCOMPKF == -99.00)
replace HTFTOLKF = . if (HTFTOLKF == -99.00)
replace HTASRTKF = . if (HTASRTKF == -99.00)
replace HTTKORKF = . if (HTTKORKF == -99.00)
replace HTPSSKKF = . if (HTPSSKKF == -99.00)
replace HTPROBKF = . if (HTPROBKF == -99.00)
replace HTCNPRKF = . if (HTCNPRKF == -99.00)
replace HTINTNKF = . if (HTINTNKF == -99.00)
replace HTLNPRKF = . if (HTLNPRKF == -99.00)
replace CSLANGKF = . if (CSLANGKF == -99.00)
replace CSMATHKF = . if (CSMATHKF == -99.00)
replace CSTOTKF = . if (CSTOTKF == -99.00)
replace CSLANGKF1 = . if (CSLANGKF1 == -5 | CSLANGKF1 == -99)
replace CSLANGKF2 = . if (CSLANGKF2 == -5 | CSLANGKF2 == -99)
replace CSLANGKF3 = . if (CSLANGKF3 == -5 | CSLANGKF3 == -99)
replace CSLANGKF4 = . if (CSLANGKF4 == -5 | CSLANGKF4 == -99)
replace CSLANGKF5 = . if (CSLANGKF5 == -5 | CSLANGKF5 == -99)
replace CSLANGKF6 = . if (CSLANGKF6 == -5 | CSLANGKF6 == -99)
replace CSLANGKF7 = . if (CSLANGKF7 == -5 | CSLANGKF7 == -99)
replace CSLANGKF8 = . if (CSLANGKF8 == -5 | CSLANGKF8 == -99)
replace CSLANGKF9 = . if (CSLANGKF9 == -5 | CSLANGKF9 == -99)
replace CSMATHKF1 = . if (CSMATHKF1 == -5 | CSMATHKF1 == -99)
replace CSMATHKF2 = . if (CSMATHKF2 == -5 | CSMATHKF2 == -99)
replace CSMATHKF3 = . if (CSMATHKF3 == -5 | CSMATHKF3 == -99)
replace CSMATHKF4 = . if (CSMATHKF4 == -5 | CSMATHKF4 == -99)
replace CSMATHKF5 = . if (CSMATHKF5 == -5 | CSMATHKF5 == -6 | CSMATHKF5 == -99)
replace CSMATHKF6 = . if (CSMATHKF6 == -5 | CSMATHKF6 == -99)
replace CSMATHKF7 = . if (CSMATHKF7 == -5 | CSMATHKF7 == -6 | CSMATHKF7 == -99)
replace COMPAREKF = . if (COMPAREKF == -99)
replace BLOCKKF = . if (BLOCKKF == -99)
replace SETTINGKF = . if (SETTINGKF == -99)
replace SERIOUSKF = . if (SERIOUSKF == -9 | SERIOUSKF == -99)
replace SERVICEKF = . if (SERVICEKF == -99)
replace PROBKF_01 = . if (PROBKF_01 == -99)
replace PROBKF_02 = . if (PROBKF_02 == -99)
replace PROBKF_03 = . if (PROBKF_03 == -99)
replace PROBKF_04 = . if (PROBKF_04 == -99)
replace PROBKF_05 = . if (PROBKF_05 == -99)
replace PROBKF_06 = . if (PROBKF_06 == -99)
replace PROBKF_07 = . if (PROBKF_07 == -99)
replace PROBKF_08 = . if (PROBKF_08 == -99)
replace PROBKF_09 = . if (PROBKF_09 == -99)
replace PROBKF_10 = . if (PROBKF_10 == -99)
replace PROBKF_11 = . if (PROBKF_11 == -99)
replace PROBKF_12 = . if (PROBKF_12 == -99)
replace PROBKF_13 = . if (PROBKF_13 == -99)
replace PROBKF_14 = . if (PROBKF_14 == -99)
replace PROBKF_15 = . if (PROBKF_15 == -99)
replace PROBKF_16 = . if (PROBKF_16 == -99)
replace PROBKF_17 = . if (PROBKF_17 == -99)
replace PROBKF_18 = . if (PROBKF_18 == -99)
replace IEPRFTQKF = . if (IEPRFTQKF == -99)
replace IEPTQKF = . if (IEPTQKF == -99)
replace IEPMONKF = . if (IEPMONKF == -6 | IEPMONKF == -99)
replace IEPYEARKF = . if (IEPYEARKF == -6 | IEPYEARKF == -99)
replace IEPSPCHKF = . if (IEPSPCHKF == -6 | IEPSPCHKF == -99)
replace IEPPHYSKF = . if (IEPPHYSKF == -6 | IEPPHYSKF == -99)
replace IEPCOGKF = . if (IEPCOGKF == -6 | IEPCOGKF == -99)
replace IEPSOCKF = . if (IEPSOCKF == -6 | IEPSOCKF == -99)
replace IEPOTHKF = . if (IEPOTHKF == -6 | IEPOTHKF == -99)
replace CHHLTHTKS = . if (CHHLTHTKS == -99)
replace TQSCDATEKS = . if (TQSCDATEKS == -6 | TQSCDATEKS == -99)
replace XPHELPK = . if (XPHELPK == -6 | XPHELPK == -99)
replace TLANG1KS = . if (TLANG1KS == -99)
replace TLANG2KS = . if (TLANG2KS == -99)
replace TLANG3KS = . if (TLANG3KS == -99)
replace HTCOMPKS = . if (HTCOMPKS == -99.00)
replace HTFTOLKS = . if (HTFTOLKS == -99.00)
replace HTASRTKS = . if (HTASRTKS == -99.00)
replace HTTKORKS = . if (HTTKORKS == -99.00)
replace HTPSSKKS = . if (HTPSSKKS == -99.00)
replace HTPROBKS = . if (HTPROBKS == -99.00)
replace HTCNPRKS = . if (HTCNPRKS == -99.00)
replace HTINTNKS = . if (HTINTNKS == -99.00)
replace HTLNPRKS = . if (HTLNPRKS == -99.00)
replace CSLANGKS = . if (CSLANGKS == -99.00)
replace CSMATHKS = . if (CSMATHKS == -99.00)
replace CSTOTKS = . if (CSTOTKS == -99.00)
replace CSLANGKS1 = . if (CSLANGKS1 == -5 | CSLANGKS1 == -99)
replace CSLANGKS2 = . if (CSLANGKS2 == -6 | CSLANGKS2 == -99)
replace CSLANGKS3 = . if (CSLANGKS3 == -6 | CSLANGKS3 == -99)
replace CSLANGKS4 = . if (CSLANGKS4 == -5 | CSLANGKS4 == -99)
replace CSLANGKS5 = . if (CSLANGKS5 == -5 | CSLANGKS5 == -6 | CSLANGKS5 == -99)
replace CSLANGKS6 = . if (CSLANGKS6 == -5 | CSLANGKS6 == -99)
replace CSLANGKS7 = . if (CSLANGKS7 == -5 | CSLANGKS7 == -99)
replace CSLANGKS8 = . if (CSLANGKS8 == -5 | CSLANGKS8 == -99)
replace CSLANGKS9 = . if (CSLANGKS9 == -5 | CSLANGKS9 == -99)
replace CSMATHKS1 = . if (CSMATHKS1 == -5 | CSMATHKS1 == -99)
replace CSMATHKS2 = . if (CSMATHKS2 == -5 | CSMATHKS2 == -99)
replace CSMATHKS3 = . if (CSMATHKS3 == -5 | CSMATHKS3 == -99)
replace CSMATHKS4 = . if (CSMATHKS4 == -5 | CSMATHKS4 == -99)
replace CSMATHKS5 = . if (CSMATHKS5 == -5 | CSMATHKS5 == -99)
replace CSMATHKS6 = . if (CSMATHKS6 == -5 | CSMATHKS6 == -99)
replace CSMATHKS7 = . if (CSMATHKS7 == -5 | CSMATHKS7 == -99)
replace COMPAREKS = . if (COMPAREKS == -99)
replace BLOCKKS = . if (BLOCKKS == -99)
replace SETTINGKS = . if (SETTINGKS == -99)
replace SERIOUSKS = . if (SERIOUSKS == -9 | SERIOUSKS == -99)
replace SERVICEKS = . if (SERVICEKS == -99)
replace PROBKS_01 = . if (PROBKS_01 == -99)
replace PROBKS_02 = . if (PROBKS_02 == -99)
replace PROBKS_03 = . if (PROBKS_03 == -99)
replace PROBKS_04 = . if (PROBKS_04 == -99)
replace PROBKS_05 = . if (PROBKS_05 == -99)
replace PROBKS_06 = . if (PROBKS_06 == -99)
replace PROBKS_07 = . if (PROBKS_07 == -99)
replace PROBKS_08 = . if (PROBKS_08 == -99)
replace PROBKS_09 = . if (PROBKS_09 == -99)
replace PROBKS_10 = . if (PROBKS_10 == -99)
replace PROBKS_11 = . if (PROBKS_11 == -99)
replace PROBKS_12 = . if (PROBKS_12 == -99)
replace PROBKS_13 = . if (PROBKS_13 == -99)
replace PROBKS_14 = . if (PROBKS_14 == -99)
replace PROBKS_15 = . if (PROBKS_15 == -99)
replace PROBKS_16 = . if (PROBKS_16 == -99)
replace PROBKS_17 = . if (PROBKS_17 == -99)
replace PROBKS_18 = . if (PROBKS_18 == -99)
replace STCLOSEKS = . if (STCLOSEKS == -99.00)
replace STCONFLKS = . if (STCONFLKS == -99.00)
replace IEPRFTQKS = . if (IEPRFTQKS == -99)
replace IEPTQKS = . if (IEPTQKS == -99)
replace IEPMONKS = . if (IEPMONKS == -6 | IEPMONKS == -99)
replace IEPYEARKS = . if (IEPYEARKS == -6 | IEPYEARKS == -99)
replace IEPSPCHKS = . if (IEPSPCHKS == -99)
replace IEPPHYSKS = . if (IEPPHYSKS == -99)
replace IEPCOGKS = . if (IEPCOGKS == -99)
replace IEPSOCKS = . if (IEPSOCKS == -99)
replace IEPOTHKS = . if (IEPOTHKS == -99)
replace IEPRCEYKS = . if (IEPRCEYKS == -6 | IEPRCEYKS == -99)
replace IEPRCFGKS = . if (IEPRCFGKS == -6 | IEPRCFGKS == -99)
replace PARRELK = . if (PARRELK == -99)
replace PAREMOTK = . if (PAREMOTK == -99)
replace PARTRSTK = . if (PARTRSTK == -99)
replace PARCOMMK = . if (PARCOMMK == -99)
replace PARAGRK = . if (PARAGRK == -99)
replace PARAPPK = . if (PARAPPK == -99)
replace PARCOOPK = . if (PARCOOPK == -99)
replace PARCALLK = . if (PARCALLK == -99)
replace TCRCALLK = . if (TCRCALLK == -99)
replace PARVISTK = . if (PARVISTK == -99)
replace TCRVISTK = . if (TCRVISTK == -99)
replace PARINVTK = . if (PARINVTK == -99)
replace PATATNDK = . if (PATATNDK == -99)
replace PARSPEVK = . if (PARSPEVK == -99)
replace PARATSEK = . if (PARATSEK == -99)
replace PARINPCK = . if (PARINPCK == -99)
replace PARATPCK = . if (PARATPCK == -99)
replace PARSNMTK = . if (PARSNMTK == -99)
replace PARVOLK = . if (PARVOLK == -99)
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
replace TMAJORK = . if (TMAJORK == -99.00)
replace EXPER01K = . if (EXPER01K == -6.00 | EXPER01K == -99.00)
replace EXPER02K = . if (EXPER02K == -6.00 | EXPER02K == -99.00)
replace EXPER03K = . if (EXPER03K == -6.00 | EXPER03K == -99.00)
replace EXPTOTK = . if (EXPTOTK == -99.00)
replace T_EDUCK = . if (T_EDUCK == -99)
replace T_GENDERK = . if (T_GENDERK == -99)
replace CLS_SIZEKF = . if (CLS_SIZEKF == -6 | CLS_SIZEKF == -99)
replace IEPKF = . if (IEPKF == -5 | IEPKF == -99)
replace DAY_WKK = . if (DAY_WKK == -6 | DAY_WKK == -99)
replace CALC_WAGEK = . if (CALC_WAGEK == -7.00 | CALC_WAGEK == -99.00)
replace MONTHSK = . if (MONTHSK == -99.00)
replace CLS_TYPEK = . if (CLS_TYPEK == -99)
replace AID_HRSKF = . if (AID_HRSKF == -99.00)
replace STCH_HRSK = . if (STCH_HRSK == -6.00 | STCH_HRSK == -99.00)
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
replace CLSSTARTK = . if (CLSSTARTK == -99)
replace CLSENDK = . if (CLSENDK == -99)
replace STDTCHK = . if (STDTCHK == -99)
replace TCHSLEFFK = . if (TCHSLEFFK == -6.00 | TCHSLEFFK == -99.00)
replace T_CESDK = . if (T_CESDK == -6.00 | T_CESDK == -99.00)
replace TQDATEKF = . if (TQDATEKF == -6 | TQDATEKF == -99)
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
replace CCNES1AK = . if (CCNES1AK == -99)
replace CCNES1BK = . if (CCNES1BK == -99)
replace CCNES1CK = . if (CCNES1CK == -99)
replace CCNES1DK = . if (CCNES1DK == -6 | CCNES1DK == -99)
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
replace T_PLANPK = . if (T_PLANPK == -6 | T_PLANPK == -99)
replace T_PLANUK = . if (T_PLANUK == -99)
replace RDGPGMK = . if (RDGPGMK == -99)
replace RDGPGMTK = . if (RDGPGMTK == -99)
replace PARVISK = . if (PARVISK == -99)
replace PARMTGK = . if (PARMTGK == -6 | PARMTGK == -99)
replace PARRPTK = . if (PARRPTK == -6 | PARRPTK == -99)
replace AID_KS = . if (AID_KS == -99)
replace TQDATEKS = . if (TQDATEKS == -6 | TQDATEKS == -99)
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
replace ECERTOTK = . if (ECERTOTK == -99.00)
replace ECERF1K = . if (ECERF1K == -99.00)
replace ECERF2K = . if (ECERF2K == -99.00)
replace RATIOENK = . if (RATIOENK == -99.00)
replace RATIOOBK = . if (RATIOOBK == -99.00)
replace CSIZEENK = . if (CSIZEENK == -6 | CSIZEENK == -99)
replace CSIZEOBK = . if (CSIZEOBK == -99)
replace STAFFOBK = . if (STAFFOBK == -6 | STAFFOBK == -99)
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
replace ASOTH_SK = . if (ASOTH_SK == -99)
replace ASRTN_MK = . if (ASRTN_MK == -99.000)
replace ASFCC_MK = . if (ASFCC_MK == -99.000)
replace ASINT_MK = . if (ASINT_MK == -99.000)
replace ASMLS_MK = . if (ASMLS_MK == -99.000)
replace ASSGT_MK = . if (ASSGT_MK == -99.000)
replace ASWGT_MK = . if (ASWGT_MK == -99.000)
replace ASCMP_MK = . if (ASCMP_MK == -99.000)
replace CEAES_MK = . if (CEAES_MK == -99.000)
replace CEFNM_MK = . if (CEFNM_MK == -99.000)
replace CEGRM_MK = . if (CEGRM_MK == -99.000)
replace CELTS_MK = . if (CELTS_MK == -99.000)
replace CEMTH_MK = . if (CEMTH_MK == -99.000)
replace CECPY_MK = . if (CECPY_MK == -99.000)
replace CEOLD_MK = . if (CEOLD_MK == -99.000)
replace CEPRR_MK = . if (CEPRR_MK == -99.000)
replace CERDG_MK = . if (CERDG_MK == -99.000)
replace CESCI_MK = . if (CESCI_MK == -99.000)
replace CESCS_MK = . if (CESCS_MK == -99.000)
replace CEWRT_MK = . if (CEWRT_MK == -99.000)
replace CE_LIT_MK = . if (CE_LIT_MK == -99.000)
replace DSDST_MK = . if (DSDST_MK == -99.000)
replace AIRTN_MK = . if (AIRTN_MK == -99.000)
replace AIMIN_MK = . if (AIMIN_MK == -99.000)
replace AISMP_MK = . if (AISMP_MK == -99.000)
replace AIELB_MK = . if (AIELB_MK == -99.000)
replace TCENC_MK = . if (TCENC_MK == -99.000)
replace TCSCF_MK = . if (TCSCF_MK == -99.000)
replace TCDDT_MK = . if (TCDDT_MK == -99.000)
replace TCSCL_MK = . if (TCSCL_MK == -99.000)
replace AIELB_C_MK = . if (AIELB_C_MK == -99.000)
replace AIRTN_C_MK = . if (AIRTN_C_MK == -99.000)
replace AISMP_C_MK = . if (AISMP_C_MK == -99.000)
replace AINONE_C_MK = . if (AINONE_C_MK == -99.000)
replace CEREAD_C_MK = . if (CEREAD_C_MK == -99.000)
replace CELTS_C_MK = . if (CELTS_C_MK == -99.000)
replace CEOLD_C_MK = . if (CEOLD_C_MK == -99.000)
replace CEMTH_C_MK = . if (CEMTH_C_MK == -99.000)
replace CESCI_C_MK = . if (CESCI_C_MK == -99.000)
replace CEWRT_C_MK = . if (CEWRT_C_MK == -99.000)
replace CESCS_C_MK = . if (CESCS_C_MK == -99.000)
replace CEAES_C_MK = . if (CEAES_C_MK == -99.000)
replace CEMOT_C_MK = . if (CEMOT_C_MK == -99.000)
replace CENONE_C_MK = . if (CENONE_C_MK == -99.000)
replace ASOTH_NK = . if (ASOTH_NK == -99)
replace SNAPOBSK = . if (SNAPOBSK == -99)
replace SNAPCLASSK = . if (SNAPCLASSK == -99)
replace SNAPDAYK = . if (SNAPDAYK == -99)
replace FAMFORMLK = . if (FAMFORMLK == -99)
replace FORMRESPK = . if (FORMRESPK == -6 | FORMRESPK == -99)
replace CHKINDERK = . if (CHKINDERK == -6 | CHKINDERK == -99)
replace KTRANP1K = . if (KTRANP1K == -99)
replace KTRANP2K = . if (KTRANP2K == -99)
replace KTRANP3K = . if (KTRANP3K == -99)
replace KTRANP4K = . if (KTRANP4K == -99)
replace KTRANP5K = . if (KTRANP5K == -99)
replace TCHTALKK = . if (TCHTALKK == -6 | TCHTALKK == -99)
replace TCHTRSTK = . if (TCHTRSTK == -9 | TCHTRSTK == -6 | TCHTRSTK == -99)
replace TCHCOMMK = . if (TCHCOMMK == -9 | TCHCOMMK == -6 | TCHCOMMK == -99)
replace TCHAGRK = . if (TCHAGRK == -9 | TCHAGRK == -6 | TCHAGRK == -99)
replace TCHSATK = . if (TCHSATK == -9 | TCHSATK == -6 | TCHSATK == -99)
replace HOMLIFK01 = . if (HOMLIFK01 == -6 | HOMLIFK01 == -99)
replace HOMLIFK02 = . if (HOMLIFK02 == -6 | HOMLIFK02 == -99)
replace HOMLIFK03 = . if (HOMLIFK03 == -6 | HOMLIFK03 == -99)
replace HOMLIFK04 = . if (HOMLIFK04 == -6 | HOMLIFK04 == -99)
replace HOMLIFK05 = . if (HOMLIFK05 == -6 | HOMLIFK05 == -99)
replace HOMLIFK06 = . if (HOMLIFK06 == -6 | HOMLIFK06 == -99)
replace HOMLIFK07 = . if (HOMLIFK07 == -6 | HOMLIFK07 == -99)
replace HOMLIFK08 = . if (HOMLIFK08 == -6 | HOMLIFK08 == -99)
replace HOMLIFK09 = . if (HOMLIFK09 == -6 | HOMLIFK09 == -99)
replace HOMLIFK10 = . if (HOMLIFK10 == -6 | HOMLIFK10 == -99)
replace HOMLIFK11 = . if (HOMLIFK11 == -6 | HOMLIFK11 == -99)
replace DECISION1K = . if (DECISION1K == -5 | DECISION1K == -6 | DECISION1K == -99)
replace DECISION2K = . if (DECISION2K == -5 | DECISION2K == -6 | DECISION2K == -99)
replace DECISION3K = . if (DECISION3K == -5 | DECISION3K == -6 | DECISION3K == -99)
replace DECISION4K = . if (DECISION4K == -5 | DECISION4K == -6 | DECISION4K == -99)
replace TALKTIMEK = . if (TALKTIMEK == -6 | TALKTIMEK == -99)
replace READTIMEK = . if (READTIMEK == -6.00 | READTIMEK == -99.00)
replace HMWKTIMEK = . if (HMWKTIMEK == -5.00 | HMWKTIMEK == -6.00 | HMWKTIMEK == -99.00)
replace HTCOMPPK = . if (HTCOMPPK == -99.00)
replace HTFTOLPK = . if (HTFTOLPK == -99.00)
replace HTTKORPK = . if (HTTKORPK == -99.00)
replace HTPROBPK = . if (HTPROBPK == -99.00)
replace HTINTNPK = . if (HTINTNPK == -99.00)
replace CHHLPROBK = . if (CHHLPROBK == -6 | CHHLPROBK == -99)
replace CHLKSCHLK = . if (CHLKSCHLK == -6 | CHLKSCHLK == -99)
replace IMPADDK = . if (IMPADDK == -6 | IMPADDK == -99)
replace SCHLCHNGK = . if (SCHLCHNGK == -6 | SCHLCHNGK == -99)
replace FQDATEK = . if (FQDATEK == -6 | FQDATEK == -99)
replace HTCOMPE = . if (HTCOMPE == -99.00)
replace HTFTOLE = . if (HTFTOLE == -99.00)
replace HTASRTE = . if (HTASRTE == -99.00)
replace HTTKORE = . if (HTTKORE == -99.00)
replace HTPSSKE = . if (HTPSSKE == -99.00)
replace HTPROBE = . if (HTPROBE == -99.00)
replace HTCNPRE = . if (HTCNPRE == -99.00)
replace HTINTNE = . if (HTINTNE == -99.00)
replace HTLNPRE = . if (HTLNPRE == -99.00)
replace STCLOSEE = . if (STCLOSEE == -99.00)
replace STCONFLE = . if (STCONFLE == -99.00)
replace CSLANGE = . if (CSLANGE == -99.00)
replace CSMATHE = . if (CSMATHE == -99.00)
replace CSTOTE = . if (CSTOTE == -99.00)
replace CHLDGRE = . if (CHLDGRE == -99)
replace CHHLTHTE = . if (CHHLTHTE == -99)
replace WHYNFGE = . if (WHYNFGE == -99)
replace PROBE_01 = . if (PROBE_01 == -99)
replace PROBE_02 = . if (PROBE_02 == -99)
replace PROBE_03 = . if (PROBE_03 == -99)
replace PROBE_04 = . if (PROBE_04 == -99)
replace PROBE_05 = . if (PROBE_05 == -99)
replace PROBE_06 = . if (PROBE_06 == -99)
replace PROBE_07 = . if (PROBE_07 == -99)
replace PROBE_08 = . if (PROBE_08 == -99)
replace PROBE_09 = . if (PROBE_09 == -99)
replace PROBE_10 = . if (PROBE_10 == -99)
replace PROBE_11 = . if (PROBE_11 == -99)
replace PROBE_12 = . if (PROBE_12 == -99)
replace PROBE_13 = . if (PROBE_13 == -99)
replace PROBE_14 = . if (PROBE_14 == -99)
replace PROBE_15 = . if (PROBE_15 == -99)
replace PROBE_16 = . if (PROBE_16 == -99)
replace PROBE_17 = . if (PROBE_17 == -99)
replace PROBE_18 = . if (PROBE_18 == -99)
replace COMPAREE = . if (COMPAREE == -6 | COMPAREE == -99)
replace BLOCKE = . if (BLOCKE == -6 | BLOCKE == -99)
replace SETTINGE = . if (SETTINGE == -99)
replace SERIOUSE = . if (SERIOUSE == -9 | SERIOUSE == -6 | SERIOUSE == -99)
replace SERVICEE = . if (SERVICEE == -99)
replace IEPRFTQE = . if (IEPRFTQE == -99)
replace IEPTQE = . if (IEPTQE == -99)
replace IEPMONE = . if (IEPMONE == -6 | IEPMONE == -99)
replace IEPYEARE = . if (IEPYEARE == -6 | IEPYEARE == -99)
replace IEPSPCHE = . if (IEPSPCHE == -6 | IEPSPCHE == -99)
replace IEPPHYSE = . if (IEPPHYSE == -6 | IEPPHYSE == -99)
replace IEPCOGE = . if (IEPCOGE == -6 | IEPCOGE == -99)
replace IEPSOCE = . if (IEPSOCE == -6 | IEPSOCE == -99)
replace IEPOTHE = . if (IEPOTHE == -6 | IEPOTHE == -99)
replace IEPRCEYE = . if (IEPRCEYE == -99)
replace IEPRCSGE = . if (IEPRCSGE == -99)
replace TLANG1E = . if (TLANG1E == -6 | TLANG1E == -99)
replace TLANG2E = . if (TLANG2E == -6 | TLANG2E == -99)
replace TLANG3E = . if (TLANG3E == -6 | TLANG3E == -99)
replace PARRELE = . if (PARRELE == -6 | PARRELE == -99)
replace PAREMOTE = . if (PAREMOTE == -6 | PAREMOTE == -99)
replace PARTRSTE = . if (PARTRSTE == -6 | PARTRSTE == -99)
replace PARCOMME = . if (PARCOMME == -6 | PARCOMME == -99)
replace PARAGRE = . if (PARAGRE == -6 | PARAGRE == -99)
replace PARAPPE = . if (PARAPPE == -6 | PARAPPE == -99)
replace PARCOOPE = . if (PARCOOPE == -6 | PARCOOPE == -99)
replace PARCALLE = . if (PARCALLE == -6 | PARCALLE == -99)
replace TCRCALLE = . if (TCRCALLE == -6 | TCRCALLE == -99)
replace PARVISTE = . if (PARVISTE == -6 | PARVISTE == -99)
replace TCRVISTE = . if (TCRVISTE == -6 | TCRVISTE == -99)
replace PARINVTE = . if (PARINVTE == -6 | PARINVTE == -99)
replace PATATNDE = . if (PATATNDE == -6 | PATATNDE == -99)
replace PARSPEVE = . if (PARSPEVE == -6 | PARSPEVE == -99)
replace PARATSEE = . if (PARATSEE == -6 | PARATSEE == -99)
replace PARINPCE = . if (PARINPCE == -6 | PARINPCE == -99)
replace PARATPCE = . if (PARATPCE == -6 | PARATPCE == -99)
replace PARSNMTE = . if (PARSNMTE == -6 | PARSNMTE == -99)
replace PARVOLE = . if (PARVOLE == -6 | PARVOLE == -99)
replace TQSCDATEE = . if (TQSCDATEE == -6 | TQSCDATEE == -99)
replace CSLANGE1 = . if (CSLANGE1 == -6 | CSLANGE1 == -99)
replace CSLANGE2 = . if (CSLANGE2 == -6 | CSLANGE2 == -99)
replace CSLANGE3 = . if (CSLANGE3 == -99)
replace CSLANGE4 = . if (CSLANGE4 == -6 | CSLANGE4 == -99)
replace CSLANGE5 = . if (CSLANGE5 == -6 | CSLANGE5 == -99)
replace CSLANGE6 = . if (CSLANGE6 == -6 | CSLANGE6 == -99)
replace CSLANGE7 = . if (CSLANGE7 == -99)
replace CSLANGE8 = . if (CSLANGE8 == -99)
replace CSLANGE9 = . if (CSLANGE9 == -99)
replace CSMATHE1 = . if (CSMATHE1 == -99)
replace CSMATHE2 = . if (CSMATHE2 == -99)
replace CSMATHE3 = . if (CSMATHE3 == -99)
replace CSMATHE4 = . if (CSMATHE4 == -6 | CSMATHE4 == -99)
replace CSMATHE5 = . if (CSMATHE5 == -6 | CSMATHE5 == -99)
replace CSMATHE6 = . if (CSMATHE6 == -6 | CSMATHE6 == -99)
replace CSMATHE7 = . if (CSMATHE7 == -6 | CSMATHE7 == -99)
replace CREDENTIALE = . if (CREDENTIALE == -99)
replace BACERT_AE = . if (BACERT_AE == -99)
replace BACERT_BE = . if (BACERT_BE == -99)
replace BACERT_CE = . if (BACERT_CE == -99)
replace BACERT_DE = . if (BACERT_DE == -99)
replace BACERT_EE = . if (BACERT_EE == -99)
replace BACERT_FE = . if (BACERT_FE == -99)
replace BACERT_GE = . if (BACERT_GE == -99)
replace NOBACERTE = . if (NOBACERTE == -99)
replace CALC_WAGEE = . if (CALC_WAGEE == -99.00)
replace T_EDUCE = . if (T_EDUCE == -99)
replace T_EDYRSE = . if (T_EDYRSE == -99)
replace T_BAE = . if (T_BAE == -99)
replace T_MAJORE = . if (T_MAJORE == -99)
replace AFR_AMTE = . if (AFR_AMTE == -99)
replace NAT_AMTE = . if (NAT_AMTE == -99)
replace WHITETE = . if (WHITETE == -99)
replace ASIANTE = . if (ASIANTE == -99)
replace LATINATE = . if (LATINATE == -99)
replace OTHERTE = . if (OTHERTE == -99)
replace T_RACEE = . if (T_RACEE == -99)
replace EXPER01E = . if (EXPER01E == -6.00 | EXPER01E == -99.00)
replace EXPER02E = . if (EXPER02E == -6.00 | EXPER02E == -99.00)
replace EXPER04E = . if (EXPER04E == -6.00 | EXPER04E == -99.00)
replace EXPER05E = . if (EXPER05E == -6.00 | EXPER05E == -99.00)
replace EXPTOTE = . if (EXPTOTE == -99.00)
replace T_GENDERE = . if (T_GENDERE == -6 | T_GENDERE == -99)
replace T_AGEE = . if (T_AGEE == -99)
replace MONTHSE = . if (MONTHSE == -6.00 | MONTHSE == -99.00)
replace T_PLANPE = . if (T_PLANPE == -6 | T_PLANPE == -99)
replace T_PLANUE = . if (T_PLANUE == -6 | T_PLANUE == -99)
replace CLS_SIZEE = . if (CLS_SIZEE == -6 | CLS_SIZEE == -99)
replace MALEPE = . if (MALEPE == -99.00)
replace IEPE = . if (IEPE == -6 | IEPE == -99)
replace CLANG01E = . if (CLANG01E == -6 | CLANG01E == -99)
replace CLANG02E = . if (CLANG02E == -6 | CLANG02E == -99)
replace CLANG03E = . if (CLANG03E == -6 | CLANG03E == -99)
replace TLANG01E = . if (TLANG01E == -6 | TLANG01E == -99)
replace TLANG02E = . if (TLANG02E == -6 | TLANG02E == -99)
replace TLANG03E = . if (TLANG03E == -6 | TLANG03E == -99)
replace LEPE = . if (LEPE == -6 | LEPE == -99)
replace CHRESE = . if (CHRESE == -6 | CHRESE == -99)
replace CHRESUSE = . if (CHRESUSE == -6 | CHRESUSE == -99)
replace AFR_AME = . if (AFR_AME == -99.00)
replace NAT_AME = . if (NAT_AME == -99.000)
replace WHITEE = . if (WHITEE == -99.00)
replace LATINOE = . if (LATINOE == -99.00)
replace ASIANE = . if (ASIANE == -99.000)
replace OTHERE = . if (OTHERE == -99.000)
replace CLS_TYPEE = . if (CLS_TYPEE == 9 | CLS_TYPEE == -9 | CLS_TYPEE == -99)
replace TARGPOPE = . if (TARGPOPE == 9 | TARGPOPE == -9 | TARGPOPE == -99)
replace LOCATIONE = . if (LOCATIONE == -99)
replace LITCURE01 = . if (LITCURE01 == -99)
replace LITCURE02 = . if (LITCURE02 == -6 | LITCURE02 == -99)
replace LITCURE03 = . if (LITCURE03 == -6 | LITCURE03 == -99)
replace LITCURE04 = . if (LITCURE04 == -6 | LITCURE04 == -99)
replace LITCURE05 = . if (LITCURE05 == -6 | LITCURE05 == -99)
replace LITCURE06 = . if (LITCURE06 == -6 | LITCURE06 == -99)
replace LITCURE07 = . if (LITCURE07 == -6 | LITCURE07 == -99)
replace LITCURE08 = . if (LITCURE08 == -6 | LITCURE08 == -99)
replace LITCURE09 = . if (LITCURE09 == -6 | LITCURE09 == -99)
replace LITCURE10 = . if (LITCURE10 == -6 | LITCURE10 == -99)
replace LITCURE11 = . if (LITCURE11 == -6 | LITCURE11 == -99)
replace LITCURE12 = . if (LITCURE12 == -6 | LITCURE12 == -99)
replace LITCURE13 = . if (LITCURE13 == -6 | LITCURE13 == -99)
replace LITCURE14 = . if (LITCURE14 == -6 | LITCURE14 == -99)
replace LITCURE15 = . if (LITCURE15 == -6 | LITCURE15 == -99)
replace LITCURE16 = . if (LITCURE16 == -6 | LITCURE16 == -99)
replace LITCURE17 = . if (LITCURE17 == -6 | LITCURE17 == -99)
replace LITCURE18 = . if (LITCURE18 == -6 | LITCURE18 == -99)
replace LITCURE19 = . if (LITCURE19 == -6 | LITCURE19 == -99)
replace LITCURE20 = . if (LITCURE20 == -99)
replace LITCURE21 = . if (LITCURE21 == -6 | LITCURE21 == -99)
replace PARVISE = . if (PARVISE == -6 | PARVISE == -99)
replace PARMTGE = . if (PARMTGE == -6.00 | PARMTGE == -99.00)
replace PARRPTE = . if (PARRPTE == -6.00 | PARRPTE == -99.00)
replace AID_E = . if (AID_E == -99)
replace AID_HRSE = . if (AID_HRSE == -6.00 | AID_HRSE == -99.00)
replace TQDATEE = . if (TQDATEE == -6 | TQDATEE == -99)
replace SCHYRK = . if (SCHYRK == -99)
replace CHPARTK = . if (CHPARTK == -99)
replace ASMTAGEKF = . if (ASMTAGEKF == -99.00)
replace ASMTAGEKS = . if (ASMTAGEKS == -99.00)
replace AMSNTDAYK = . if (AMSNTDAYK == -99)
replace TCHCHNGK = . if (TCHCHNGK == -99)
replace CLASSCHNGK = . if (CLASSCHNGK == -99)
replace SITE_ECK = . if (SITE_ECK == -99)
replace SITE_TRKF = . if (SITE_TRKF == -99)
replace SITE_TRKS = . if (SITE_TRKS == -99)
replace CHNRCDK = . if (CHNRCDK == -99)
replace NUMCLSRMK = . if (NUMCLSRMK == -99)
replace ASMNTDAYPKK = . if (ASMNTDAYPKK == -99)


*/
/********************************************************************

 Section 5: Save Outfile

  This section saves out a Stata system format file.  There is no reason to
  modify it if the macros in Section 1 were specified correctly.

*********************************************************************/

save `outfile', replace

