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
       01  EOF                PIC X VALUE "N".
       01  EOF-ACCT           PIC X VALUE "N".
       01  OUTPUT-BUFFER      PIC X(100).
       01  COMMAND            PIC X(10).
       01  ARGS               PIC X(90).
       01  CLEAN-ARGS         PIC X(20).
       01  CREATE-RESPONSE    PIC X(100).
       01  CREATE-STATUS      PIC X VALUE "N".
       01  NUM-ACCOUNTS       PIC 9 VALUE 0.
       01  MAX-ACCOUNTS       PIC 9 VALUE 5.
       
       01  NAV-ACTION         PIC X(20).
       01  NAV-LINE           PIC X(100).
       01  NAV-DONE           PIC X.
       01  NAV-INDEX          PIC 9 VALUE 0.

       PROCEDURE DIVISION.
           *> Count existing accounts
           MOVE 0 TO NUM-ACCOUNTS.
           OPEN INPUT ACCOUNT-FILE
           PERFORM UNTIL EOF-ACCT = "Y"
               READ ACCOUNT-FILE
                   AT END MOVE "Y" TO EOF-ACCT
                   NOT AT END
                       IF ACCOUNT-RECORD NOT = SPACES
                           ADD 1 TO NUM-ACCOUNTS
                       END-IF
               END-READ
           END-PERFORM
           CLOSE ACCOUNT-FILE.

           *> Process input
           MOVE "N" TO EOF.
           OPEN INPUT INFILE
           PERFORM UNTIL EOF = "Y"
               READ INFILE
                   AT END MOVE "Y" TO EOF
                   NOT AT END
                       INSPECT IN-REC REPLACING ALL X"0D" BY SPACE
                       UNSTRING IN-REC DELIMITED BY "|"
                           INTO COMMAND, ARGS
                       END-UNSTRING
                       MOVE FUNCTION TRIM(COMMAND) TO COMMAND
                       MOVE FUNCTION TRIM(ARGS)    TO ARGS
                       INSPECT COMMAND CONVERTING
                           "abcdefghijklmnopqrstuvwxyz" TO "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                       INSPECT ARGS CONVERTING
                           "abcdefghijklmnopqrstuvwxyz" TO "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                       MOVE FUNCTION TRIM(COMMAND) TO COMMAND
                       MOVE FUNCTION TRIM(ARGS)    TO CLEAN-ARGS

                       EVALUATE COMMAND
                           WHEN "CREATE"
                               PERFORM HANDLE-CREATE
                           WHEN "NAV"
                               PERFORM HANDLE-NAV
                           WHEN OTHER
                               CONTINUE
                       END-EVALUATE
               END-READ
           END-PERFORM
           CLOSE INFILE.
           STOP RUN.

       HANDLE-CREATE.
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
           .

       DUAL-OUTPUT.
           DISPLAY OUTPUT-BUFFER
           OPEN EXTEND OUTFILE
           WRITE OUT-REC FROM OUTPUT-BUFFER
           CLOSE OUTFILE
           MOVE SPACES TO OUTPUT-BUFFER
           .

       HANDLE-NAV.
           EVALUATE CLEAN-ARGS
             WHEN "MENU"
               MOVE 0 TO NAV-INDEX
               MOVE "SHOW-MENU" TO NAV-ACTION
               PERFORM NAV-PRINT-LOOP
             WHEN "JOB"
               MOVE 0 TO NAV-INDEX
               MOVE "JOB" TO NAV-ACTION
               PERFORM NAV-PRINT-LOOP
             WHEN "FIND"
               MOVE 0 TO NAV-INDEX
               MOVE "FIND" TO NAV-ACTION
               PERFORM NAV-PRINT-LOOP
             WHEN "SKILLS"
               MOVE 0 TO NAV-INDEX
               MOVE "SHOW-SKILLS" TO NAV-ACTION
               PERFORM NAV-PRINT-LOOP
             WHEN "BACK"
               MOVE 0 TO NAV-INDEX
               MOVE "SHOW-MENU" TO NAV-ACTION
               PERFORM NAV-PRINT-LOOP
             WHEN OTHER
               MOVE 0 TO NAV-INDEX
               MOVE CLEAN-ARGS TO NAV-ACTION
               PERFORM NAV-PRINT-LOOP
           END-EVALUATE
           .

       NAV-PRINT-LOOP.
           MOVE "N" TO NAV-DONE
           PERFORM UNTIL NAV-DONE = "Y"
               CALL 'NAVIGATION' USING
                    BY CONTENT   NAV-ACTION
                    BY REFERENCE NAV-INDEX
                    BY REFERENCE NAV-LINE
                    BY REFERENCE NAV-DONE
               IF NAV-LINE NOT = SPACES
                   MOVE NAV-LINE TO OUTPUT-BUFFER
                   PERFORM DUAL-OUTPUT
               END-IF
           END-PERFORM
           .
