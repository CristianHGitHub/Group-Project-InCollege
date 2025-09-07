*> This is free-form
IDENTIFICATION DIVISION.
PROGRAM-ID. INCOLLEGE.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT INFILE ASSIGN TO "../data/InCollege-Input.txt"
        ORGANIZATION IS SEQUENTIAL.

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

PROCEDURE DIVISION.
    OPEN INPUT INFILE

    PERFORM UNTIL EOF = "Y"
        READ INFILE
            AT END
                MOVE "Y" TO EOF
            NOT AT END
                UNSTRING IN-REC DELIMITED BY ","
                    INTO COMMAND, ARGS
                END-UNSTRING

                EVALUATE COMMAND
                    WHEN "CREATE"
                        CALL 'CREATE-ACCOUNT' USING ARGS
                END-EVALUATE
        END-READ
    END-PERFORM

    CLOSE INFILE.
    STOP RUN.
