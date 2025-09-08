*> This is free-form
IDENTIFICATION DIVISION.
PROGRAM-ID. INCOLLEGE.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT INFILE ASSIGN TO "../data/InCollege-Input.txt"
        ORGANIZATION IS LINE SEQUENTIAL.
    SELECT OUTFILE ASSIGN TO "../data/InCollege-Output.txt"
        ORGANIZATION IS LINE SEQUENTIAL.
    SELECT ACCOUNT-FILE ASSIGN TO "../data/AccountRecords.txt"
        ORGANIZATION IS LINE SEQUENTIAL.

DATA DIVISION.
FILE SECTION.
FD  INFILE.
01  IN-REC             PIC X(100).
FD  OUTFILE.
01  OUT-REC            PIC X(100).
FD  ACCOUNT-FILE.
01  ACCOUNT-RECORD     PIC X(100).

WORKING-STORAGE SECTION.
01  EOF                PIC X(1) VALUE "N".
01  CURRENT-LINE       PIC X(100).
01  PARSED-INPUT.
   05  COMMAND         PIC X(10).
   05  ARGS            PIC X(100).
01  CREATE-RESPONSE    PIC X(100).
01  CREATE-STATUS      PIC X(1) VALUE "N".
01  NUM-ACCOUNTS       PIC 9(1) VALUE 0.
01  MAX-ACCOUNTS       PIC 9(1) VALUE 5.
01  EOF-ACCT           PIC X(1) VALUE "N".
01  OUTPUT-BUFFER      PIC X(100).

PROCEDURE DIVISION.
    *> Count existing accounts from AccountRecords.txt
    MOVE 0 TO NUM-ACCOUNTS.
    OPEN INPUT ACCOUNT-FILE
    PERFORM UNTIL EOF-ACCT = "Y"
        READ ACCOUNT-FILE
            AT END
                MOVE "Y" TO EOF-ACCT
            NOT AT END
                IF ACCOUNT-RECORD NOT = SPACES
                   ADD 1 TO NUM-ACCOUNTS
                END-IF
        END-READ
    END-PERFORM
    CLOSE ACCOUNT-FILE.

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
                           MOVE "Creating account..." TO OUTPUT-BUFFER
                           PERFORM DUAL-OUTPUT

                           CALL 'CREATE-ACCOUNT' USING ARGS CREATE-RESPONSE CREATE-STATUS

                           MOVE CREATE-RESPONSE TO OUTPUT-BUFFER
                           PERFORM DUAL-OUTPUT

                           IF CREATE-STATUS = "Y"
                               ADD 1 TO NUM-ACCOUNTS
                           END-IF
                        ELSE
                           MOVE "Cannot create more than 5 accounts." TO OUTPUT-BUFFER
                           PERFORM DUAL-OUTPUT
                        END-IF
                END-EVALUATE
        END-READ
    END-PERFORM

    CLOSE INFILE.
    STOP RUN.

DUAL-OUTPUT.
    DISPLAY OUTPUT-BUFFER
    OPEN EXTEND OUTFILE
    WRITE OUT-REC FROM OUTPUT-BUFFER
    CLOSE OUTFILE.
    MOVE SPACES TO OUTPUT-BUFFER.
    EXIT PARAGRAPH.
