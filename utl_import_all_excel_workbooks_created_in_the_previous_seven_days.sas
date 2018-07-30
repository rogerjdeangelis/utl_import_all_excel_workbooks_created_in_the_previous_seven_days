Import all excel workbooks created in the previous seven days

I assume one sheet per workbook and the sheet name is 'sheet1'.

This technique provides a log with the status for each of the previous 7 days.

see
https://tinyurl.com/ybpcsz6f
https://communities.sas.com/t5/Base-SAS-Programming/How-to-parameterize-the-counter-for-browsing-week-numbers/m-p/482429



INPUT  ( I use the numeric format for dates for QC purposes)
=============================================================

  d:/parent

    day_21387.xlsx  ** not in last week - 8 days old;
                    ** 21388 is missing;

    day_21389.xlsx                  | Past week
    day_21391.xlsx                  |
    day_21393.xlsx                  |
    day_21395.xlsx  ** current date |


 EXAMPLE OUTPUT  (log and datasets)
 -----------------------------------

 WORK LOG total obs=7
                                                          WORKBOOK    CONDITION
       WORKBOOK           STATUS                DATE      EXIST       CODE

   Workbook 21389   24JUL2018 Imported        24JUL2018     1         0
   Workbook 21390   25JUL2018 does not exist  25JUL2018     0         0
   Workbook 21391   26JUL2018 Imported        26JUL2018     1         0
   Workbook 21392   27JUL2018 does not exist  27JUL2018     0         0
   Workbook 21393   28JUL2018 Imported        28JUL2018     1         0
   Workbook 21394   29JUL2018 does not exist  29JUL2018     0         0
   Workbook 21395   30JUL2018 Imported        30JUL2018     1         0


 OUTPUT DATASETS FROM WORKBOOKS

  NAME

   DAY_21389.sas7bdat  ** from workbook d:/parent/day_21389.xlsx
   DAY_21391.sas7bdat
   DAY_21393.sas7bdat
   DAY_21395.sas7bdat


PROCESS
=======

data log;

  length status $64;

  do wekday=today()-6 to today();

     date=put(wekday,date9.);

     call symputx('wekday',wekday);
     xis=fileexist(cats("d:/parent/date_",wekday,".xlsx"));

     if xis then do;
        rc=dosubl('
          libname xel  "d:\&folder.\date_&dsn..xlsx";
          data date_&wekday;
             set xel.sheet1;
          run;quit;
          libname xel clear;
          run;quit;
        ');
     end;
     select;
        when ( rc=0    and xis) status=catx(" ","Workbook ", date, " Imported");
        when ( rc ne 0 and xis) status=catx(" ","Workbook ", date, " exists but import failed");
        when ( not xis)         status=catx(" ","Workbook ", date, " does not exist");
     end;
     output;
  end;

run;quit;


OUTPUT
======

             Member   Obs, Entries
   Name       Type      or Indexes   Vars

   DAY_21389  DATA          19         5
   DAY_21391  DATA          19         5
   DAY_21393  DATA          19         5
   DAY_21395  DATA          19         5

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

data _null_;

  if _n_=0 then do;
    %let rc=%sysfunc(dosubl('
        data _null_;
          rc=dcreate("parent","d:/");
          call symputx("folder","parent");
        run;quit;
    '));
   end;

   do dsns=today()-8 to today() by 2;
     call symputx('dsn',dsns);

     rc=dosubl('
       libname xlsout "d:\&folder.\day_&dsn..xlsx";
          data xlsout.sheet1;
             set sashelp.class;
          run;quit;
       libname xlsout clear;
     ');
   end;

run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

see processs

