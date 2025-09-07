*> This is free-form
IDENTIFICATION DIVISION.
PROGRAM-ID. INCOLLEGE.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT INFILE ASSIGN TO "../data/InCollege-Input.txt"
        ORGANIZATION IS LINE SEQUENTIAL.

DATA DIVISION.
FILE SECTION.
FD  INFILE.
01  IN-REC             PIC X(100).

WORKING-STORAGE SECTION.
01  EOF                PIC X(1) VALUE "N".
01  CURRENT-LINE       PIC X(100).
01  PARSED-INPUT.
   05  COMMAND     PIC X(10).
   05  ARGS        PIC X(100).
01  NUM-ACCOUNTS       PIC 9(1) VALUE 0.
01  MAX-ACCOUNTS       PIC 9(1) VALUE 5.

PROCEDURE DIVISION.
    OPEN INPUT INFILE

    PERFORM UNTIL EOF = "Y"
        READ INFILE
            AT END
                MOVE "Y" TO EOF
            NOT AT END
                UNSTRING IN-REC DELIMITED BY "|"
                    INTO COMMAND, ARGS
                END-UNSTRING

                EVALUATE COMMAND
                    WHEN "CREATE"
                        IF NUM-ACCOUNTS < MAX-ACCOUNTS
                           DISPLAY "Creating account..."
                           CALL 'CREATE-ACCOUNT' USING ARGS
                           ADD 1 TO NUM-ACCOUNTS
                        ELSE
                           DISPLAY "Cannot create more than 5 accounts."
                        END-IF
                END-EVALUATE
        END-READ
    END-PERFORM

    CLOSE INFILE.
    STOP RUN.
