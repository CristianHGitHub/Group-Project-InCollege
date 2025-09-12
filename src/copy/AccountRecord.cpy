01     ACCOUNT-INFO.
     05  AR-USERNAME   PIC X(50).
     05  AR-PASSWORD   PIC X(50).
     05  AR-PROFILE.
         10  AR-FIRST-NAME     PIC X(25).
         10  AR-LAST-NAME      PIC X(25).
         10  AR-UNIVERSITY     PIC X(50).
         10  AR-MAJOR          PIC X(50).
         10  AR-GRADUATION-YEAR PIC 9(4).
         10  AR-ABOUT-ME       PIC X(200).
         10  AR-EXPERIENCE.
             15  AR-EXP-ENTRY OCCURS 3 TIMES.
                 20  AR-EXP-TITLE      PIC X(50).
                 20  AR-EXP-COMPANY    PIC X(50).
                 20  AR-EXP-START-DATE PIC X(10).
                 20  AR-EXP-END-DATE   PIC X(10).
                 20  AR-EXP-DESCRIPTION PIC X(200).
         10  AR-EDUCATION.
             15  AR-EDU-ENTRY OCCURS 3 TIMES.
                 20  AR-EDU-SCHOOL     PIC X(50).
                 20  AR-EDU-DEGREE     PIC X(50).
                 20  AR-EDU-START-DATE PIC X(10).
                 20  AR-EDU-END-DATE   PIC X(10).
                 20  AR-EDU-GPA        PIC 9V99.
