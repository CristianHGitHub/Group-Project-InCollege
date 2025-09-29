IDENTIFICATION DIVISION.
PROGRAM-ID. CONNECTION.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT CONNECTION-FILE ASSIGN TO '../data/ConnectionRecords.txt'
        ORGANIZATION IS LINE SEQUENTIAL
        FILE STATUS IS CONN-STAT.
     SELECT OUTPUT-FILE ASSIGN TO '../data/InCollege-Output.txt'
        ORGANIZATION IS LINE SEQUENTIAL.


DATA DIVISION.
FILE SECTION.
FD  CONNECTION-FILE.
01  CONNECTION-RECORD.
    05  CR-SENDER         PIC X(80).
    05  CR-RECEIVER       PIC X(80).

FD OUTPUT-FILE.
01 OUT-REC PIC X(200).

WORKING-STORAGE SECTION.
01  EOF PIC X VALUE "N".
01 WS-MESSAGE PIC X(100).
01  CONN-STAT        PIC XX.
01  WS-EXISTS       PIC X VALUE "N".
01 WS-OPENED PIC X VALUE "N".


LINKAGE SECTION.
01 L-SENDER      PIC X(80).
01 L-RECEIVER    PIC X(80).
01 L-ACTION      PIC X(20).
01 L-RESPONSE     PIC X(100).


PROCEDURE DIVISION USING L-SENDER L-RECEIVER L-ACTION L-RESPONSE.
    EVALUATE FUNCTION TRIM(L-ACTION)
        WHEN "SEND"
            PERFORM SEND-REQUEST
        WHEN "VIEW"
            PERFORM VIEW-REQUEST
    END-EVALUATE

    GOBACK.

SEND-REQUEST.
    IF FUNCTION UPPER-CASE(FUNCTION TRIM(L-SENDER))
     = FUNCTION UPPER-CASE(FUNCTION TRIM(L-RECEIVER))
      MOVE "You cannot connect with yourself." TO L-RESPONSE

      EXIT PARAGRAPH
    END-IF

    PERFORM CHECK-REQUEST-EXISTS
    IF WS-EXISTS = "Y"
        MOVE "You are already connected with this user." TO L-RESPONSE
        EXIT PARAGRAPH
    END-IF


    MOVE "N" TO WS-OPENED
    OPEN EXTEND CONNECTION-FILE
    IF CONN-STAT = "35"
       OPEN OUTPUT CONNECTION-FILE
       IF CONN-STAT = "00"
           CLOSE CONNECTION-FILE
           OPEN EXTEND CONNECTION-FILE
       END-IF
    END-IF

    IF CONN-STAT = "00"
        MOVE "Y" TO WS-OPENED
    ELSE
        MOVE "Error accessing connection records." TO L-RESPONSE
        EXIT PARAGRAPH
    END-IF




    MOVE L-SENDER   TO CR-SENDER
    MOVE L-RECEIVER TO CR-RECEIVER
    WRITE CONNECTION-RECORD
    IF WS-OPENED = "Y"
        CLOSE CONNECTION-FILE
        MOVE "N" TO WS-OPENED
    END-IF

    MOVE "Connection Request Sent to New Student" TO L-RESPONSE

    EXIT PARAGRAPH.



CHECK-REQUEST-EXISTS.
    MOVE "N" TO WS-EXISTS
    OPEN INPUT CONNECTION-FILE
    IF CONN-STAT = "35"
        *> File doesn't exist yet -> no requests
        CLOSE CONNECTION-FILE
        EXIT PARAGRAPH
    END-IF
    IF CONN-STAT NOT = "00"
        *> Can't open to check; treat as no dup (optional: log error)
        CLOSE CONNECTION-FILE
        EXIT PARAGRAPH
    END-IF

    PERFORM UNTIL EOF = "Y"
        READ CONNECTION-FILE
            AT END
                MOVE "Y" TO EOF
            NOT AT END
                *> Compare case-insensitively, ignoring padding
                IF FUNCTION UPPER-CASE(FUNCTION TRIM(CR-SENDER))   = FUNCTION UPPER-CASE(FUNCTION TRIM(L-SENDER))
                   AND FUNCTION UPPER-CASE(FUNCTION TRIM(CR-RECEIVER)) = FUNCTION UPPER-CASE(FUNCTION TRIM(L-RECEIVER))
                    MOVE "Y" TO WS-EXISTS
                    MOVE "Y" TO EOF
                ELSE
                    *> Also consider reverse direction as a duplicate (optional but common)
                    IF FUNCTION UPPER-CASE(FUNCTION TRIM(CR-SENDER))   = FUNCTION UPPER-CASE(FUNCTION TRIM(L-RECEIVER))
                       AND FUNCTION UPPER-CASE(FUNCTION TRIM(CR-RECEIVER)) = FUNCTION UPPER-CASE(FUNCTION TRIM(L-SENDER))
                        MOVE "Y" TO WS-EXISTS
                        MOVE "Y" TO EOF
                    END-IF
                END-IF
        END-READ
    END-PERFORM

    CLOSE CONNECTION-FILE
    MOVE "N" TO EOF
    EXIT PARAGRAPH.



VIEW-REQUEST.
        MOVE "N" TO EOF
        OPEN INPUT CONNECTION-FILE

        PERFORM UNTIL EOF = "Y"
            READ CONNECTION-FILE
                AT END
                    MOVE "Y" TO EOF
                NOT AT END
                    IF FUNCTION TRIM(CR-RECEIVER) = FUNCTION TRIM(L-RECEIVER)
                        STRING "Connection Request from: " DELIMITED BY SIZE
                                   FUNCTION TRIM(CR-SENDER) DELIMITED BY SIZE
                               INTO WS-MESSAGE
                        END-STRING
                        MOVE WS-MESSAGE TO L-RESPONSE
                    END-IF
            END-READ
        END-PERFORM


        CLOSE CONNECTION-FILE
        MOVE "End of Connection Requests" TO L-RESPONSE

        EXIT PARAGRAPH.

