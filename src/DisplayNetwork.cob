IDENTIFICATION DIVISION.
PROGRAM-ID. DISPLAYNETWORK.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT ESTABLISHED-FILE ASSIGN TO "../data/EstablishedConnections.txt"
        ORGANIZATION IS LINE SEQUENTIAL
        FILE STATUS IS EST-STATUS.
    SELECT PROFILE-FILE ASSIGN TO "../data/ProfileRecords.txt"
        ORGANIZATION IS LINE SEQUENTIAL
        FILE STATUS IS PROFILE-STATUS.
    SELECT OUTFILE ASSIGN TO "../data/InCollege-Output.txt"
        ORGANIZATION IS LINE SEQUENTIAL.

DATA DIVISION.
FILE SECTION.
FD  ESTABLISHED-FILE.
01  EST-RECORD.
    05  ER-USER-A        PIC X(40).
    05  ER-USER-B        PIC X(40).

FD  PROFILE-FILE.
01  PROFILE-RECORD       PIC X(5000).

FD  OUTFILE EXTERNAL.
01  OUT-REC             PIC X(200).

WORKING-STORAGE SECTION.
01  EST-STATUS          PIC XX VALUE SPACES.
01  PROFILE-STATUS      PIC XX VALUE SPACES.
01  EOF-FLAG            PIC X  VALUE "N".
01  FOUND-ANY           PIC X  VALUE "N".
01  WS-MESSAGE          PIC X(200).
01  WS-OTHER-USER       PIC X(50).
01  WS-PROFILE-DATA     PIC X(5000).
01  PROFILE-EOF         PIC X  VALUE "N".
01  WS-PR-USERNAME      PIC X(50).
01  WS-PR-DATA          PIC X(5000).
01  WS-FULL-NAME        PIC X(100).
01  WS-UNIVERSITY       PIC X(100).
01  WS-MAJOR            PIC X(100).
01  WS-FIRST-NAME       PIC X(100).
01  WS-LAST-NAME        PIC X(100).
01  WS-TEMP-FIELD       PIC X(100).
01  WS-DELIMITER        PIC X VALUE "|".
01  WS-FIELD-COUNT      PIC 99 VALUE 0.
01  WS-CURRENT-FIELD    PIC X(200).
01  WS-PIPE-POS         PIC 99 VALUE 0.
01  WS-USER-A           PIC X(40).
01  WS-USER-B           PIC X(40).

LINKAGE SECTION.
01  L-USERNAME          PIC X(50).

PROCEDURE DIVISION USING L-USERNAME.

    MOVE "N" TO EOF-FLAG
    MOVE "N" TO FOUND-ANY

    *> Display header
    MOVE "--- Your Network ---" TO WS-MESSAGE
    PERFORM DUAL-OUTPUT

    *> Open established connections file
    OPEN INPUT ESTABLISHED-FILE
    IF EST-STATUS = "35"
        MOVE "You have no established connections." TO WS-MESSAGE
        PERFORM DUAL-OUTPUT
        MOVE "--------------------" TO WS-MESSAGE
        PERFORM DUAL-OUTPUT
        GOBACK
    END-IF
    IF EST-STATUS NOT = "00"
        MOVE "Error: cannot open established connections file." TO WS-MESSAGE
        PERFORM DUAL-OUTPUT
        MOVE "--------------------" TO WS-MESSAGE
        PERFORM DUAL-OUTPUT
        GOBACK
    END-IF

    *> Scan through all established connections
    PERFORM UNTIL EOF-FLAG = "Y"
        READ ESTABLISHED-FILE
            AT END
                MOVE "Y" TO EOF-FLAG
            NOT AT END
                PERFORM CHECK-AND-DISPLAY-CONNECTION
        END-READ
    END-PERFORM

    CLOSE ESTABLISHED-FILE

    *> If no connections found, display appropriate message
    IF FOUND-ANY = "N"
        MOVE "You have no established connections." TO WS-MESSAGE
        PERFORM DUAL-OUTPUT
    END-IF

    *> Display footer
    MOVE "--------------------" TO WS-MESSAGE
    PERFORM DUAL-OUTPUT

    GOBACK.

        CHECK-AND-DISPLAY-CONNECTION.
            *> Check if current user is in this connection
            *> The record is already properly structured with ER-USER-A and ER-USER-B
            *> No need to parse manually - just use the record fields directly
            
            IF FUNCTION UPPER-CASE(FUNCTION TRIM(ER-USER-A)) =
               FUNCTION UPPER-CASE(FUNCTION TRIM(L-USERNAME))
                MOVE FUNCTION TRIM(ER-USER-B) TO WS-OTHER-USER
                MOVE "Y" TO FOUND-ANY
                PERFORM GET-AND-DISPLAY-PROFILE
            ELSE
                IF FUNCTION UPPER-CASE(FUNCTION TRIM(ER-USER-B)) =
                   FUNCTION UPPER-CASE(FUNCTION TRIM(L-USERNAME))
                    MOVE FUNCTION TRIM(ER-USER-A) TO WS-OTHER-USER
                    MOVE "Y" TO FOUND-ANY
                    PERFORM GET-AND-DISPLAY-PROFILE
                END-IF
            END-IF
            EXIT PARAGRAPH.

GET-AND-DISPLAY-PROFILE.
    *> Initialize profile data fields
    MOVE SPACES TO WS-PROFILE-DATA
    MOVE SPACES TO WS-FULL-NAME
    MOVE SPACES TO WS-UNIVERSITY
    MOVE SPACES TO WS-MAJOR

    *> Open profile file and find the user's profile
    OPEN INPUT PROFILE-FILE
    IF PROFILE-STATUS NOT = "00"
        *> If can't open profile file, just show username
        STRING "Connected with: " FUNCTION TRIM(WS-OTHER-USER)
               " (Profile not available)"
            DELIMITED BY SIZE
            INTO WS-MESSAGE
        END-STRING
        PERFORM DUAL-OUTPUT
        GOBACK
    END-IF

    MOVE "N" TO PROFILE-EOF
    PERFORM UNTIL PROFILE-EOF = "Y"
        READ PROFILE-FILE
            AT END
                MOVE "Y" TO PROFILE-EOF
            NOT AT END
                MOVE SPACES TO WS-PR-USERNAME WS-PR-DATA
                UNSTRING PROFILE-RECORD DELIMITED BY "|"
                    INTO WS-PR-USERNAME WS-PR-DATA
                END-UNSTRING
                IF FUNCTION UPPER-CASE(FUNCTION TRIM(WS-PR-USERNAME)) =
                   FUNCTION UPPER-CASE(FUNCTION TRIM(WS-OTHER-USER))
                    MOVE WS-PR-DATA TO WS-PROFILE-DATA
                    MOVE "Y" TO PROFILE-EOF
                END-IF
        END-READ
    END-PERFORM

    CLOSE PROFILE-FILE

    *> Parse profile data to extract name, university, major
    PERFORM PARSE-PROFILE-DATA

    *> Display the connection information
    STRING "Connected with: " FUNCTION TRIM(WS-FULL-NAME)
           " (University: " FUNCTION TRIM(WS-UNIVERSITY)
           ", Major: " FUNCTION TRIM(WS-MAJOR) ")"
        DELIMITED BY SIZE
        INTO WS-MESSAGE
    END-STRING
    PERFORM DUAL-OUTPUT
    EXIT PARAGRAPH.

PARSE-PROFILE-DATA.
    *> Profile data format in WS-PROFILE-DATA: FirstName|LastName|University|Major|...
    MOVE SPACES TO WS-FULL-NAME WS-UNIVERSITY WS-MAJOR
    MOVE SPACES TO WS-FIRST-NAME WS-LAST-NAME

    UNSTRING WS-PROFILE-DATA DELIMITED BY "|"
        INTO WS-FIRST-NAME WS-LAST-NAME WS-UNIVERSITY WS-MAJOR
    END-UNSTRING

    IF FUNCTION TRIM(WS-FIRST-NAME) NOT = SPACES
        STRING FUNCTION TRIM(WS-FIRST-NAME) " " FUNCTION TRIM(WS-LAST-NAME)
            DELIMITED BY SIZE
            INTO WS-FULL-NAME
        END-STRING
    END-IF

    *> If we couldn't parse properly, just use username and defaults
    IF WS-FULL-NAME = SPACES
        MOVE FUNCTION TRIM(WS-OTHER-USER) TO WS-FULL-NAME
    END-IF
    IF WS-UNIVERSITY = SPACES
        MOVE "Unknown" TO WS-UNIVERSITY
    END-IF
    IF WS-MAJOR = SPACES
        MOVE "Unknown" TO WS-MAJOR
    END-IF

    EXIT PARAGRAPH.

DUAL-OUTPUT.
    DISPLAY WS-MESSAGE
    WRITE OUT-REC FROM WS-MESSAGE
    EXIT PARAGRAPH.

END PROGRAM DISPLAYNETWORK.
