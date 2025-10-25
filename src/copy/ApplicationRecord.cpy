*> Application Record Copybook
*> Defines the structure for job application records
*> Format: APPLICATION-ID|USERNAME|JOB-ID|APPLICATION-DATE

01  APPLICATION-RECORD.
    05  APPLICATION-ID        PIC 9(6).
    05  FILLER                PIC X VALUE "|".
    05  APPLICATION-USERNAME  PIC X(50).
    05  FILLER                PIC X VALUE "|".
    05  APPLICATION-JOB-ID    PIC 9(6).
    05  FILLER                PIC X VALUE "|".
    05  APPLICATION-DATE      PIC X(10).
