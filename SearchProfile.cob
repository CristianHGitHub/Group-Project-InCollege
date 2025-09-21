*> Free-form COBOL
IDENTIFICATION DIVISION.
PROGRAM-ID. SEARCHPROFILE.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT PROFILE-FILE ASSIGN TO "../data/ProfileRecords.txt"
        ORGANIZATION IS LINE SEQUENTIAL.

DATA DIVISION.
FILE SECTION.
FD  PROFILE-FILE.
01  PROFILE-RECORD              PIC X(5000).

WORKING-STORAGE SECTION.
01  EOF-PROFILE                 PIC X VALUE "N".
01  PTR                         PIC 9(8) VALUE 1.
01  R-USERNAME                  PIC X(50).
01  R-DATA-REST                 PIC X(4950).
01  R-FN                        PIC X(100).
01  R-LN                        PIC X(100).
01  BUILT-FULL                  PIC X(205).

LINKAGE SECTION.
01  L-FULLNAME-IN               PIC X(205).  *> input: "First Last"
01  L-FOUND-FLAG                PIC X.       *> output: "Y" / "N"
01  L-FOUND-USERNAME            PIC X(50).   *> output: username (if found)

PROCEDURE DIVISION USING L-FULLNAME-IN L-FOUND-FLAG L-FOUND-USERNAME.
    MOVE "N" TO L-FOUND-FLAG
    MOVE SPACES TO L-FOUND-USERNAME
    MOVE "N" TO EOF-PROFILE

    OPEN INPUT PROFILE-FILE
    PERFORM UNTIL EOF-PROFILE = "Y" OR L-FOUND-FLAG = "Y"
        READ PROFILE-FILE
            AT END
                MOVE "Y" TO EOF-PROFILE
            NOT AT END
                MOVE 1 TO PTR
                MOVE SPACES TO R-USERNAME R-DATA-REST R-FN R-LN BUILT-FULL

                *> Split: username|First|Last|...
                UNSTRING PROFILE-RECORD DELIMITED BY "|"
                    INTO R-USERNAME
                    WITH POINTER PTR
                END-UNSTRING

                IF FUNCTION TRIM(R-USERNAME) = SPACES
                    CONTINUE
                END-IF

                MOVE PROFILE-RECORD(PTR:) TO R-DATA-REST

                *> First two fields after username are FirstName and LastName
                MOVE 1 TO PTR
                UNSTRING R-DATA-REST DELIMITED BY "|"
                    INTO R-FN R-LN
                    WITH POINTER PTR
                END-UNSTRING

                STRING FUNCTION TRIM(R-FN) DELIMITED BY SIZE
                       " "                 DELIMITED BY SIZE
                       FUNCTION TRIM(R-LN) DELIMITED BY SIZE
                    INTO BUILT-FULL
                END-STRING

                IF FUNCTION TRIM(BUILT-FULL) = FUNCTION TRIM(L-FULLNAME-IN)
                    MOVE "Y" TO L-FOUND-FLAG
                    MOVE FUNCTION TRIM(R-USERNAME) TO L-FOUND-USERNAME
                END-IF
        END-READ
    END-PERFORM
    CLOSE PROFILE-FILE
    GOBACK.
