*> Profile Storage Module
IDENTIFICATION DIVISION.
PROGRAM-ID. PROFILE-STORAGE.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT ACCOUNT-FILE ASSIGN TO "../data/AccountRecords.txt"
        ORGANIZATION IS LINE SEQUENTIAL.

DATA DIVISION.
FILE SECTION.
FD ACCOUNT-FILE.
01 ACCOUNT-RECORD          PIC X(1000).

WORKING-STORAGE SECTION.
COPY "AccountRecord.cpy".

01  PROFILE-FILE-RECORD    PIC X(1000).
01  TEMP-PROFILE-DATA      PIC X(500).
01  EOF-PROFILE            PIC X VALUE "N".
01  PROFILE-FOUND          PIC X VALUE "N".
01  WS-INDEX               PIC 9.

LINKAGE SECTION.
01  L-USERNAME             PIC X(50).
01  L-PROFILE-DATA         PIC X(500).
01  L-OPERATION            PIC X(10).  *> "SAVE" or "LOAD"
01  L-STATUS               PIC X.
01  L-RESPONSE             PIC X(200).

PROCEDURE DIVISION USING L-USERNAME L-PROFILE-DATA L-OPERATION L-STATUS L-RESPONSE.
    MOVE "N" TO L-STATUS
    MOVE SPACES TO L-RESPONSE

    EVALUATE L-OPERATION
        WHEN "SAVE"
            PERFORM SAVE-PROFILE
        WHEN "LOAD"
            PERFORM LOAD-PROFILE
        WHEN OTHER
            MOVE "Invalid operation" TO L-RESPONSE
    END-EVALUATE

    GOBACK.

SAVE-PROFILE.
    *> Create profile record with username and profile data
    MOVE SPACES TO PROFILE-FILE-RECORD
    STRING L-USERNAME DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           L-PROFILE-DATA DELIMITED BY SIZE
           INTO PROFILE-FILE-RECORD
    END-STRING

    *> Write to profile file
    OPEN EXTEND ACCOUNT-FILE
    WRITE ACCOUNT-RECORD FROM PROFILE-FILE-RECORD
    CLOSE ACCOUNT-FILE

    MOVE "Y" TO L-STATUS
    MOVE "Profile saved successfully!" TO L-RESPONSE
    EXIT PARAGRAPH.

LOAD-PROFILE.
    *> Search for profile data by username
    MOVE "N" TO EOF-PROFILE
    MOVE "N" TO PROFILE-FOUND
    MOVE SPACES TO TEMP-PROFILE-DATA

    OPEN INPUT ACCOUNT-FILE
    PERFORM UNTIL EOF-PROFILE = "Y"
        READ ACCOUNT-FILE
            AT END
                MOVE "Y" TO EOF-PROFILE
            NOT AT END
                IF ACCOUNT-RECORD NOT = SPACES
                   *> Check if this record contains the username
                   IF ACCOUNT-RECORD(1:FUNCTION LENGTH(FUNCTION TRIM(L-USERNAME))) =
                      FUNCTION TRIM(L-USERNAME)
                       *> Extract profile data after the username
                       UNSTRING ACCOUNT-RECORD DELIMITED BY "|"
                           INTO TEMP-PROFILE-DATA
                       END-UNSTRING
                       MOVE TEMP-PROFILE-DATA TO L-PROFILE-DATA
                       MOVE "Y" TO PROFILE-FOUND
                       MOVE "Y" TO L-STATUS
                       MOVE "Profile loaded successfully!" TO L-RESPONSE
                       CLOSE ACCOUNT-FILE
                       EXIT PARAGRAPH
                   END-IF
                END-IF
        END-READ
    END-PERFORM
    CLOSE ACCOUNT-FILE

    IF PROFILE-FOUND = "N"
        MOVE "Profile not found for user" TO L-RESPONSE
    END-IF
    EXIT PARAGRAPH.
