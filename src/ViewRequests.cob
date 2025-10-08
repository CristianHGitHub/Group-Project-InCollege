IDENTIFICATION DIVISION.
PROGRAM-ID. VIEWREQUESTS.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT CONNECTION-FILE ASSIGN TO "../data/ConnectionRecords.txt"
        ORGANIZATION IS LINE SEQUENTIAL
        FILE STATUS IS CONN-STAT.
    SELECT OUTFILE ASSIGN TO "../data/InCollege-Output.txt"
        ORGANIZATION IS LINE SEQUENTIAL.

DATA DIVISION.
FILE SECTION.
FD  CONNECTION-FILE.
01  CONNECTION-RECORD.
    05  CR-SENDER         PIC X(40).
    05  CR-RECEIVER       PIC X(40).

FD  OUTFILE EXTERNAL.
01  OUT-REC               PIC X(200).

WORKING-STORAGE SECTION.
01  EOF                   PIC X     VALUE "N".
01  CONN-STAT             PIC XX.
01  WS-MESSAGE            PIC X(200).
01  FOUND-ANY             PIC X     VALUE "N".

LINKAGE SECTION.
01  L-USERNAME            PIC X(50).

PROCEDURE DIVISION USING L-USERNAME.

    MOVE "N" TO EOF
    MOVE "N" TO FOUND-ANY

    *> Always output the header first
    MOVE SPACES TO WS-MESSAGE
    STRING "Pending connection requests for "
           FUNCTION TRIM(L-USERNAME)
        DELIMITED BY SIZE
        INTO WS-MESSAGE
    END-STRING
    MOVE FUNCTION TRIM(WS-MESSAGE) TO WS-MESSAGE
    PERFORM DUAL-OUTPUT

    OPEN INPUT CONNECTION-FILE
    IF CONN-STAT = "35"
        MOVE "No pending requests." TO WS-MESSAGE
        PERFORM DUAL-OUTPUT
        MOVE "End of connection requests." TO WS-MESSAGE
        PERFORM DUAL-OUTPUT
        GOBACK
    END-IF
    IF CONN-STAT NOT = "00"
        MOVE "Error: cannot open connection file." TO WS-MESSAGE
        PERFORM DUAL-OUTPUT
        GOBACK
    END-IF

    PERFORM UNTIL EOF = "Y"
        READ CONNECTION-FILE
            AT END
                MOVE "Y" TO EOF
            NOT AT END
                IF FUNCTION UPPER-CASE(FUNCTION TRIM(CR-RECEIVER))
                   = FUNCTION UPPER-CASE(FUNCTION TRIM(L-USERNAME))
                    MOVE "Y" TO FOUND-ANY
                    MOVE SPACES  TO WS-MESSAGE
                    STRING "From: "
                           FUNCTION TRIM(CR-SENDER)
                        DELIMITED BY SIZE
                        INTO WS-MESSAGE
                    END-STRING
                    PERFORM DUAL-OUTPUT
                END-IF
        END-READ
    END-PERFORM

    CLOSE CONNECTION-FILE

    IF FOUND-ANY = "N"
        MOVE "No pending requests." TO WS-MESSAGE
        PERFORM DUAL-OUTPUT
    END-IF

    MOVE "End of connection requests." TO WS-MESSAGE
    PERFORM DUAL-OUTPUT

    GOBACK.

DUAL-OUTPUT.
    DISPLAY WS-MESSAGE
    WRITE OUT-REC FROM WS-MESSAGE
    EXIT PARAGRAPH.
