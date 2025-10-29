*> This is free-form
IDENTIFICATION DIVISION.
PROGRAM-ID. INCOLLEGE.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT INFILE ASSIGN TO "../data/InCollege-Input.txt"
        ORGANIZATION IS LINE SEQUENTIAL.
    SELECT OUTFILE ASSIGN TO "../data/InCollege-Output.txt"
        ORGANIZATION IS LINE SEQUENTIAL
        FILE STATUS IS OUT-STATUS.
    SELECT ACCOUNT-FILE ASSIGN TO "../data/AccountRecords.txt"
        ORGANIZATION IS LINE SEQUENTIAL.
    SELECT JOB-FILE ASSIGN TO "../data/JobPostings.txt"
        ORGANIZATION IS LINE SEQUENTIAL
        FILE STATUS IS JOB-STATUS.
    SELECT APPLICATION-FILE ASSIGN TO "../data/applications.dat"
        ORGANIZATION IS LINE SEQUENTIAL
        FILE STATUS IS APPLICATION-STATUS.

DATA DIVISION.
FILE SECTION.
FD  INFILE.
01  IN-REC             PIC X(500).
FD  OUTFILE EXTERNAL.
01  OUT-REC            PIC X(200).
FD  ACCOUNT-FILE.
01  ACCOUNT-REC        PIC X(100).
FD  JOB-FILE.
01  JOB-REC            PIC X(500).
FD  APPLICATION-FILE.
01  APPLICATION-REC    PIC X(100).

WORKING-STORAGE SECTION.
COPY "AccountRecord.cpy".
COPY "ApplicationRecord.cpy".
01  EOF                PIC X(1) VALUE "N".
01  OUT-STATUS         PIC XX.
01  JOB-STATUS         PIC XX.
01  APPLICATION-STATUS PIC XX.
01  CREATE-RESPONSE    PIC X(100).
01  SEARCH-NAME        PIC X(205).
01  FOUND-FLAG         PIC X    VALUE "N".
01  FOUND-USERNAME     PIC X(50).
01  CREATE-STATUS      PIC X(1) VALUE "N".
01  LOGIN-RESPONSE     PIC X(100).
01  LOGIN-STATUS       PIC X(1) VALUE "N".
01  NUM-ACCOUNTS       PIC 9(1) VALUE 0.
01  MAX-ACCOUNTS       PIC 9(1) VALUE 5.
01  EOF-ACCT           PIC X(1) VALUE "N".
01  OUTPUT-BUFFER      PIC X(200).
01  NAV-ACTION         PIC X(20).
01  NAV-LINE           PIC X(100).
01  NAV-DONE           PIC X.
01  NAV-INDEX          PIC 99 VALUE 0.
01  CURRENT-MENU       PIC X(15) VALUE "MAIN".
01  PROFILE-DATA-STRING PIC X(5000).
01  TEMP-GRAD-YEAR     PIC X(4).
01  YEAR-LEN           PIC 99.
01  YEAR-NUMERIC       PIC X VALUE "N".
01  IDX                PIC 9 VALUE 0.
01  CONN-ACTION         PIC X(20).
01  CONN-RESPONSE       PIC X(200).
01  SEND_BOOL           PIC X(10).
01  SAVED-USERNAME      PIC X(50).
01  WS-EXISTS           PIC X VALUE "N".
01  WS-TEMP-FIRST       PIC X(50).
01  WS-TEMP-LAST        PIC X(50).
01  VIEW-MODE           PIC X(10).
01  REQUEST-COMMAND     PIC X(100).
01  REQUEST-NEEDS-COMMAND PIC X VALUE "N".
01  REQUEST-STATUS      PIC X VALUE "N".
01  REQUEST-RESPONSE1   PIC X(200).
01  REQUEST-RESPONSE2   PIC X(200).
01  WS-COMMAND          PIC X(100).
01  MENU-DISPLAYED      PIC X VALUE "N".
01  JOB-TITLE           PIC X(100).
01  JOB-DESCRIPTION     PIC X(200).
01  JOB-EMPLOYER        PIC X(100).
01  JOB-LOCATION        PIC X(100).
01  JOB-SALARY          PIC X(50).
01  JOB-STRING          PIC X(500).
01  JOB-DESC-LONG       PIC X(500).
01  JOB-DESC-TRUNC      PIC X VALUE "N".
01  JOB-IDX             PIC 9(3) VALUE 0.
01  WS-SALARY-TRIM      PIC X(50).
01  WS-SALARY-UPPER     PIC X(50).
01  JOB-ID-NUM          PIC 9(6) VALUE 0.
01  JOB-LINE-COUNT      PIC 9(9) VALUE 0.
01  JOB-EOF             PIC X VALUE "N".
01  JOB-ID-EDIT         PIC Z(6)9.
01  JOB-COUNT           PIC 9(3) VALUE 0.
01  JOB-DISPLAY-NUM     PIC 9(3) VALUE 0.
01  JOB-PARSED-TITLE    PIC X(100).
01  JOB-PARSED-EMPLOYER PIC X(100).
01  JOB-PARSED-LOCATION PIC X(100).
01  JOB-PARSED-DESC     PIC X(200).
01  JOB-PARSED-SALARY   PIC X(50).
01  JOB-PARSED-USERNAME PIC X(50).
01  JOB-PARSED-ID       PIC X(10).
01  JOB-DISPLAY-LINE    PIC X(200).
01  JOB-SELECTION       PIC X(10).
01  JOB-SELECTION-NUM   PIC 9(3).
01  JOB-SELECTION-VALID PIC X VALUE "N".
01  JOB-DETAILS-FOUND   PIC X VALUE "N".
01  JOB-DETAILS-LINE    PIC X(200).
01  JOB-DETAILS-TITLE   PIC X(100).
01  JOB-DETAILS-EMPLOYER PIC X(100).
01  JOB-DETAILS-LOCATION PIC X(100).
01  JOB-DETAILS-DESC    PIC X(200).
01  JOB-DETAILS-SALARY  PIC X(50).
01  JOB-DETAILS-USERNAME PIC X(50).
01  JOB-DETAILS-ID      PIC X(10).
01  JOB-DETAILS-NUM     PIC 9(3) VALUE 0.
01  JOB-DETAILS-CURRENT PIC 9(3) VALUE 0.

*> Job Summary Display Constants and Variables
01  JOB-SUMMARY-TEMPLATE PIC X(50) VALUE "n. <Job Title> at <Employer> (<Location>)".
01  JOB-DIVIDER PIC X(30) VALUE "----------------------------".
01  JOB-PROMPT PIC X(50) VALUE "Enter job number to view details, or 0 to go back:".
01  JOB-EMPTY-MESSAGE PIC X(60) VALUE "No job or internship listings are currently available.".
01  JOB-ERROR-MESSAGE PIC X(60) VALUE "Error: Unable to open job listings file.".
01  JOB-SKIP-MESSAGE PIC X(50) VALUE "Skipping invalid job record at JOB-ID ".
01  JOB-SUMMARY-LINE PIC X(200).
01  JOB-SUMMARY-BUFFER PIC X(200).
01  JOB-FIELD-TITLE PIC X(100).
01  JOB-FIELD-EMPLOYER PIC X(100).
01  JOB-FIELD-LOCATION PIC X(100).
01  JOB-FIELD-TITLE-TRIMMED PIC X(100).
01  JOB-FIELD-EMPLOYER-TRIMMED PIC X(100).
01  JOB-FIELD-LOCATION-TRIMMED PIC X(100).
01  JOB-SUMMARY-NUM PIC 9(3) VALUE 0.
01  JOB-SUMMARY-NUM-DISPLAY PIC Z(2)9.
01  JOB-SUMMARY-COUNT PIC 9(3) VALUE 0.
01  JOB-SUMMARY-EOF PIC X VALUE "N".
01  JOB-SUMMARY-STATUS PIC XX.
01  JOB-SUMMARY-REC PIC X(500).
01  JOB-SUMMARY-PARSED-ID PIC X(10).
01  JOB-SUMMARY-PARSED-USERNAME PIC X(50).
01  JOB-SUMMARY-PARSED-TITLE PIC X(100).
01  JOB-SUMMARY-PARSED-DESC PIC X(200).
01  JOB-SUMMARY-PARSED-EMPLOYER PIC X(100).
01  JOB-SUMMARY-PARSED-LOCATION PIC X(100).
01  JOB-SUMMARY-PARSED-SALARY PIC X(50).
01  JOB-SUMMARY-VALID-RECORD PIC X VALUE "Y".
01  JOB-SUMMARY-SKIP-ID PIC X(10).

*> Application-related variables
01  APPLICATION-STRING     PIC X(100).
01  APPLICATION-ID-NUM    PIC 9(6) VALUE 0.
01  APPLICATION-LINE-COUNT PIC 9(9) VALUE 0.
01  APPLICATION-EOF       PIC X VALUE "N".
01  APPLICATION-ID-EDIT   PIC Z(6)9.
01  DUPLICATE-FOUND       PIC X VALUE "N".
01  APPLICATION-PARSED-ID PIC X(10).
01  APPLICATION-PARSED-USERNAME PIC X(50).
01  APPLICATION-PARSED-JOB-ID PIC X(10).
*> Removed date field from application persistence
01  APPLICATION-CONFIRMATION PIC X(200).
01  APPLICATION-DUPLICATE-MSG PIC X(200).
01  APPLICATION-ERROR-MSG PIC X(200).

PROCEDURE DIVISION.
    *> Count existing accounts
    MOVE 0 TO NUM-ACCOUNTS.
    OPEN INPUT ACCOUNT-FILE
    PERFORM UNTIL EOF-ACCT = "Y"
        READ ACCOUNT-FILE
            AT END
                MOVE "Y" TO EOF-ACCT
            NOT AT END
                IF ACCOUNT-REC NOT = SPACES
                   ADD 1 TO NUM-ACCOUNTS
                END-IF
        END-READ
    END-PERFORM
    CLOSE ACCOUNT-FILE.

    *> Open output file once for entire program execution
    OPEN EXTEND OUTFILE.

    MOVE 'Welcome to InCollege!' TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT

    OPEN INPUT INFILE
    PERFORM UNTIL EOF = "Y"
        READ INFILE
            AT END
                MOVE "Y" TO EOF
            NOT AT END
                MOVE IN-REC TO WS-COMMAND
        END-READ

        IF EOF NOT = "Y"
            IF LOGIN-STATUS NOT = "Y"
               MOVE 'Log In' TO OUTPUT-BUFFER
               PERFORM DUAL-OUTPUT
               MOVE 'Create New Account' TO OUTPUT-BUFFER
               PERFORM DUAL-OUTPUT
               MOVE 'Enter your choice:' TO OUTPUT-BUFFER
               PERFORM DUAL-OUTPUT
            END-IF

        IF EOF NOT = "Y"
            EVALUATE WS-COMMAND
                    WHEN "Log Out"
                        IF LOGIN-STATUS = "Y"
                            MOVE "N" TO LOGIN-STATUS
                            MOVE "N" TO MENU-DISPLAYED
                            MOVE "MAIN" TO CURRENT-MENU
                            MOVE 0 TO NAV-INDEX
                            MOVE SPACES TO NAV-ACTION
                            MOVE 'Welcome to InCollege!' TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF

                    WHEN "Create New Account"
                        IF LOGIN-STATUS = "N"
                           IF NUM-ACCOUNTS < MAX-ACCOUNTS
                               MOVE "Please enter your username:" TO OUTPUT-BUFFER
                               PERFORM DUAL-OUTPUT
                               READ INFILE
                                   AT END
                                       MOVE "Y" TO EOF
                                   NOT AT END
                                       MOVE IN-REC TO AR-USERNAME
                               END-READ

                               MOVE "Please enter your password:" TO OUTPUT-BUFFER
                               PERFORM DUAL-OUTPUT
                               READ INFILE
                                   AT END
                                       MOVE "Y" TO EOF
                                   NOT AT END
                                       MOVE IN-REC TO AR-PASSWORD
                               END-READ

                               CALL 'CREATE-ACCOUNT' USING AR-USERNAME AR-PASSWORD CREATE-RESPONSE CREATE-STATUS

                               MOVE CREATE-RESPONSE TO OUTPUT-BUFFER
                               PERFORM DUAL-OUTPUT

                               IF CREATE-STATUS = "Y"
                                   ADD 1 TO NUM-ACCOUNTS
                               END-IF
                           ELSE
                               MOVE "Cannot create more than 5 accounts." TO OUTPUT-BUFFER
                               PERFORM DUAL-OUTPUT
                               *> discard two extra lines from input
                               IF EOF NOT = "Y"
                                   READ INFILE
                                       AT END MOVE "Y" TO EOF
                                   END-READ
                               END-IF
                               IF EOF NOT = "Y"
                                   READ INFILE
                                       AT END MOVE "Y" TO EOF
                                   END-READ
                               END-IF
                           END-IF
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF

                    WHEN "Log In"
                        IF LOGIN-STATUS = "N"
                            MOVE "Please enter your username:" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                            READ INFILE
                                AT END MOVE "Y" TO EOF
                                NOT AT END MOVE IN-REC TO AR-USERNAME
                            END-READ

                            MOVE "Please enter your password:" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                            READ INFILE
                                AT END MOVE "Y" TO EOF
                                NOT AT END MOVE IN-REC TO AR-PASSWORD
                            END-READ

                            CALL 'LOGIN' USING AR-USERNAME AR-PASSWORD LOGIN-RESPONSE LOGIN-STATUS

                            MOVE LOGIN-RESPONSE TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT

                            IF LOGIN-STATUS = "Y"
                                STRING 'Welcome, ' DELIMITED BY SIZE
                                       AR-USERNAME DELIMITED BY SIZE
                                       INTO OUTPUT-BUFFER
                                END-STRING
                                PERFORM DUAL-OUTPUT
                                MOVE "MAIN" TO CURRENT-MENU
                                MOVE 0            TO NAV-INDEX
                                MOVE "SHOW-MENU"  TO NAV-ACTION
                                PERFORM NAV-PRINT-LOOP
                            END-IF
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF

                    *> Navigation commands
                    WHEN "Menu"
                        IF LOGIN-STATUS = "Y"
                            MOVE 0            TO NAV-INDEX
                            MOVE "SHOW-MENU"  TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF

                    WHEN "Job"
                        IF LOGIN-STATUS = "Y"
                            MOVE "JOBS" TO CURRENT-MENU
                            MOVE 0            TO NAV-INDEX
                            MOVE "SHOW-JOBS"  TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF


                  WHEN "Find"
                   IF LOGIN-STATUS = "Y"
                       MOVE 0            TO NAV-INDEX
                       MOVE "FIND"       TO NAV-ACTION
                       PERFORM NAV-PRINT-LOOP
                       READ INFILE
                           AT END MOVE "Y" TO EOF
                           NOT AT END MOVE IN-REC TO SEARCH-NAME
                       END-READ

                       IF EOF NOT = "Y"
                           CALL 'SEARCHPROFILE' USING SEARCH-NAME FOUND-FLAG FOUND-USERNAME

                           IF FOUND-FLAG = "Y"
                               MOVE "---Found User Profile---" TO OUTPUT-BUFFER
                               PERFORM DUAL-OUTPUT

                               MOVE AR-USERNAME TO SAVED-USERNAME
                               MOVE FOUND-USERNAME TO AR-USERNAME
                               PERFORM PROFILE-LOAD

                               MOVE "SEARCH" TO VIEW-MODE
                               CALL 'VIEWPROFILE' USING AR-USERNAME PROFILE-DATA-STRING VIEW-MODE

                               MOVE "Send Connection Request? (Yes/No)" TO OUTPUT-BUFFER
                               PERFORM DUAL-OUTPUT

                               READ INFILE
                                   AT END MOVE "Y" TO EOF
                                   NOT AT END MOVE IN-REC TO SEND_BOOL
                               END-READ

                               IF EOF NOT = "Y"
                                   EVALUATE FUNCTION UPPER-CASE(FUNCTION TRIM(SEND_BOOL))
                                       WHEN "YES"
                                             MOVE "YES" TO CONN-ACTION
                                           CALL "CONNECTION" USING SAVED-USERNAME FOUND-USERNAME CONN-ACTION CONN-RESPONSE
                                           MOVE CONN-RESPONSE TO OUTPUT-BUFFER
                                           PERFORM DUAL-OUTPUT
                                       WHEN "NO"
                                           MOVE "Connection request cancelled." TO OUTPUT-BUFFER
                                           PERFORM DUAL-OUTPUT
                                       WHEN OTHER
                                           *> Silently ignore invalid response
                                           CONTINUE
                                   END-EVALUATE
                               END-IF

                               MOVE SAVED-USERNAME TO AR-USERNAME

                               *> Separator and return message
                               MOVE "--------------------" TO OUTPUT-BUFFER
                               PERFORM DUAL-OUTPUT
                               MOVE "Returning to Main Menu..." TO OUTPUT-BUFFER
                               PERFORM DUAL-OUTPUT

                               MOVE "MAIN" TO CURRENT-MENU
                               MOVE 0            TO NAV-INDEX
                               MOVE "SHOW-MENU"  TO NAV-ACTION
                               PERFORM NAV-PRINT-LOOP
                           ELSE
                               MOVE "No one by that name could be found." TO OUTPUT-BUFFER
                               PERFORM DUAL-OUTPUT

                               *> Separator and return message
                               MOVE "--------------------" TO OUTPUT-BUFFER
                               PERFORM DUAL-OUTPUT
                               MOVE "Returning to Main Menu..." TO OUTPUT-BUFFER
                               PERFORM DUAL-OUTPUT

                               MOVE "MAIN" TO CURRENT-MENU
                               MOVE 0            TO NAV-INDEX
                               MOVE "SHOW-MENU"  TO NAV-ACTION
                               PERFORM NAV-PRINT-LOOP
                           END-IF
                       END-IF
                   ELSE
                       MOVE "Invalid option" TO OUTPUT-BUFFER
                       PERFORM DUAL-OUTPUT
                   END-IF


                    WHEN "Skills"
                        IF LOGIN-STATUS = "Y"
                            MOVE "SKILLS" TO CURRENT-MENU
                            MOVE 0              TO NAV-INDEX
                            MOVE "SHOW-SKILLS"  TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF

                    WHEN "Post a Job/Internship"
                        IF LOGIN-STATUS = "Y" AND CURRENT-MENU = "JOBS"
                            PERFORM POST-JOB-FLOW
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF

                    WHEN "Browse Jobs/Internships"
                        IF LOGIN-STATUS = "Y" AND CURRENT-MENU = "JOBS"
                            PERFORM BROWSE-JOBS-SECTION
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF

                    WHEN "View My Applications"
                       IF LOGIN-STATUS = "Y" AND CURRENT-MENU = "JOBS"
                           PERFORM VIEW-MY-APPLICATIONS
                       ELSE
                           MOVE "Invalid option" TO OUTPUT-BUFFER
                           PERFORM DUAL-OUTPUT
                       END-IF


                    WHEN "Profile"
                        IF LOGIN-STATUS = "Y"
                            MOVE "CREATE-PROFILE" TO CURRENT-MENU
                            MOVE 0         TO NAV-INDEX
                            MOVE "SHOW-CREATE-PROFILE" TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                            PERFORM PROFILE-INPUT-PROCESS
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF

                   WHEN "View Profile"
                        IF LOGIN-STATUS = "Y"
                            PERFORM PROFILE-LOAD
                            MOVE "SELF" TO VIEW-MODE
                            CALL 'VIEWPROFILE' USING AR-USERNAME PROFILE-DATA-STRING VIEW-MODE
                            MOVE "MAIN" TO CURRENT-MENU
                            MOVE 0            TO NAV-INDEX
                            MOVE "SHOW-MENU"  TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF


                   WHEN "Requests"
                       IF LOGIN-STATUS = "Y"
                           CALL 'VIEWREQUESTS' USING AR-USERNAME
                           END-CALL
                           MOVE SPACES TO REQUEST-COMMAND
                           MOVE SPACES TO REQUEST-RESPONSE1
                           MOVE SPACES TO REQUEST-RESPONSE2
                           MOVE "N"    TO REQUEST-NEEDS-COMMAND
                           MOVE "N"    TO REQUEST-STATUS

                           CALL 'MANAGEREQUESTS' USING
                                AR-USERNAME
                                REQUEST-COMMAND
                                REQUEST-NEEDS-COMMAND
                                REQUEST-STATUS
                                REQUEST-RESPONSE1
                                REQUEST-RESPONSE2

                           IF REQUEST-NEEDS-COMMAND = "Y"
                               IF REQUEST-RESPONSE1 NOT = SPACES
                                   MOVE REQUEST-RESPONSE1 TO OUTPUT-BUFFER
                                   PERFORM DUAL-OUTPUT
                               END-IF

                               READ INFILE
                                   AT END
                                       MOVE "Y" TO EOF
                                   NOT AT END
                                       MOVE IN-REC TO REQUEST-COMMAND
                               END-READ

                               IF EOF NOT = "Y"
                                   MOVE SPACES TO REQUEST-RESPONSE1 REQUEST-RESPONSE2
                                   MOVE "N" TO REQUEST-NEEDS-COMMAND
                                   MOVE "N" TO REQUEST-STATUS

                                   CALL 'MANAGEREQUESTS' USING
                                        AR-USERNAME
                                        REQUEST-COMMAND
                                        REQUEST-NEEDS-COMMAND
                                        REQUEST-STATUS
                                        REQUEST-RESPONSE1
                                        REQUEST-RESPONSE2

                                   IF REQUEST-RESPONSE1 NOT = SPACES
                                       MOVE REQUEST-RESPONSE1 TO OUTPUT-BUFFER
                                       PERFORM DUAL-OUTPUT
                                   END-IF
                                   IF REQUEST-RESPONSE2 NOT = SPACES
                                       MOVE REQUEST-RESPONSE2 TO OUTPUT-BUFFER
                                       PERFORM DUAL-OUTPUT
                                   END-IF
                               END-IF
                           ELSE
                               IF REQUEST-RESPONSE1 NOT = SPACES
                                   MOVE REQUEST-RESPONSE1 TO OUTPUT-BUFFER
                                   PERFORM DUAL-OUTPUT
                               END-IF
                               IF REQUEST-RESPONSE2 NOT = SPACES
                                   MOVE REQUEST-RESPONSE2 TO OUTPUT-BUFFER
                                   PERFORM DUAL-OUTPUT
                               END-IF
                           END-IF
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF
                       MOVE 0            TO NAV-INDEX
                       MOVE "SHOW-MENU"  TO NAV-ACTION
                       PERFORM NAV-PRINT-LOOP

                   WHEN "View My Network"
                       IF LOGIN-STATUS = "Y"
                           CALL 'DISPLAYNETWORK' USING AR-USERNAME
                           MOVE 0            TO NAV-INDEX
                           MOVE "SHOW-MENU"  TO NAV-ACTION
                           PERFORM NAV-PRINT-LOOP
                       ELSE
                           MOVE "Invalid option" TO OUTPUT-BUFFER
                           PERFORM DUAL-OUTPUT
                       END-IF

                    WHEN "Skill-1"
                        IF LOGIN-STATUS = "Y" AND CURRENT-MENU = "SKILLS"
                            MOVE 0         TO NAV-INDEX
                            MOVE "SKILL-1" TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                            *> re-display skills menu
                            MOVE 0             TO NAV-INDEX
                            MOVE "SHOW-SKILLS" TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF

                    WHEN "Skill-2"
                        IF LOGIN-STATUS = "Y" AND CURRENT-MENU = "SKILLS"
                            MOVE 0         TO NAV-INDEX
                            MOVE "SKILL-2" TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                            MOVE 0              TO NAV-INDEX
                            MOVE "SHOW-SKILLS" TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF

                    WHEN "Skill-3"
                        IF LOGIN-STATUS = "Y" AND CURRENT-MENU = "SKILLS"
                            MOVE 0         TO NAV-INDEX
                            MOVE "SKILL-3" TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                            MOVE 0             TO NAV-INDEX
                            MOVE "SHOW-SKILLS" TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF

                    WHEN "Skill-4"
                        IF LOGIN-STATUS = "Y" AND CURRENT-MENU = "SKILLS"
                            MOVE 0         TO NAV-INDEX
                            MOVE "SKILL-4" TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                            MOVE 0             TO NAV-INDEX
                            MOVE "SHOW-SKILLS" TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF

                    WHEN "Skill-5"
                        IF LOGIN-STATUS = "Y" AND CURRENT-MENU = "SKILLS"
                            MOVE 0         TO NAV-INDEX
                            MOVE "SKILL-5" TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                            MOVE 0             TO NAV-INDEX
                            MOVE "SHOW-SKILLS" TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF

                    WHEN "1"
                        IF LOGIN-STATUS = "Y" AND CURRENT-MENU = "PROFILE"
                            MOVE "CREATE-PROFILE" TO CURRENT-MENU
                            MOVE 0         TO NAV-INDEX
                            MOVE "CREATE-PROFILE" TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF

                    WHEN "Create New Profile"
                        IF LOGIN-STATUS = "Y" AND CURRENT-MENU = "PROFILE"
                            MOVE "CREATE-PROFILE" TO CURRENT-MENU
                            MOVE 0         TO NAV-INDEX
                            MOVE "CREATE-PROFILE" TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF

                    WHEN "Save Profile"
                        IF LOGIN-STATUS = "Y" AND CURRENT-MENU = "CREATE-PROFILE"
                            PERFORM PROFILE-INPUT-PROCESS
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF

                    WHEN "Back"
                        IF LOGIN-STATUS = "Y"
                            MOVE "MAIN" TO CURRENT-MENU
                            MOVE 0            TO NAV-INDEX
                            MOVE "SHOW-MENU"  TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF

                    WHEN OTHER
                        MOVE "Invalid option" TO OUTPUT-BUFFER
                        PERFORM DUAL-OUTPUT
                END-EVALUATE
        END-IF
    END-PERFORM

    CLOSE INFILE.
    CLOSE OUTFILE.
    STOP RUN.

*> SUBROUTINES
*> DUAL-OUTPUT: Write to both console and file
*> Note: OUTFILE is EXTERNAL and opened once at program start
DUAL-OUTPUT.
    DISPLAY OUTPUT-BUFFER
    WRITE OUT-REC FROM OUTPUT-BUFFER
    MOVE SPACES TO OUTPUT-BUFFER
    EXIT PARAGRAPH.

NAV-PRINT-LOOP.
    MOVE "N" TO NAV-DONE
    PERFORM UNTIL NAV-DONE = "Y"
        CALL 'NAVIGATION' USING
             BY CONTENT   NAV-ACTION
             BY REFERENCE NAV-INDEX
             BY REFERENCE NAV-LINE
             BY REFERENCE NAV-DONE
             BY REFERENCE CURRENT-MENU
        END-CALL
        IF NAV-LINE NOT = SPACES
            MOVE NAV-LINE TO OUTPUT-BUFFER
            PERFORM DUAL-OUTPUT
        END-IF
    END-PERFORM
    EXIT PARAGRAPH.

POST-JOB-FLOW.
    *> Prompt for job details
    MOVE "Please enter job title:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO JOB-TITLE
    END-READ
    IF EOF = "Y" EXIT PARAGRAPH END-IF

    IF JOB-TITLE = SPACES
        MOVE "Error: Job Title is required and cannot be empty." TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT
        MOVE "Y" TO EOF
        EXIT PARAGRAPH
    END-IF

    MOVE "Please enter job description:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO JOB-DESC-LONG
    END-READ
    IF EOF = "Y" EXIT PARAGRAPH END-IF

    IF JOB-DESC-LONG = SPACES
        MOVE "Error: Description is required and cannot be empty." TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT
        MOVE "Y" TO EOF
        EXIT PARAGRAPH
    END-IF

    *> Handle long description (truncate to 200 chars if needed)
    MOVE "N" TO JOB-DESC-TRUNC
    PERFORM VARYING JOB-IDX FROM 201 BY 1 UNTIL JOB-IDX > 500
        IF JOB-DESC-LONG(JOB-IDX:1) NOT = SPACE
            MOVE "Y" TO JOB-DESC-TRUNC
            EXIT PERFORM
        END-IF
    END-PERFORM
    MOVE JOB-DESC-LONG(1:200) TO JOB-DESCRIPTION
    IF JOB-DESC-TRUNC = "Y"
        MOVE "Note: Description truncated to 200 characters." TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT
    END-IF

    MOVE "Please enter employer:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO JOB-EMPLOYER
    END-READ
    IF EOF = "Y" EXIT PARAGRAPH END-IF

    IF JOB-EMPLOYER = SPACES
        MOVE "Error: Employer is required and cannot be empty." TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT
        MOVE "Y" TO EOF
        EXIT PARAGRAPH
    END-IF

    MOVE "Please enter location:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO JOB-LOCATION
    END-READ
    IF EOF = "Y" EXIT PARAGRAPH END-IF

    IF JOB-LOCATION = SPACES
        MOVE "Error: Location is required and cannot be empty." TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT
        MOVE "Y" TO EOF
        EXIT PARAGRAPH
    END-IF

    MOVE "Please enter salary (optional):" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO JOB-SALARY
    END-READ
    IF EOF = "Y" EXIT PARAGRAPH END-IF

    *> Normalize and format salary for persistence
    MOVE FUNCTION TRIM(JOB-SALARY) TO WS-SALARY-TRIM
    MOVE FUNCTION UPPER-CASE(WS-SALARY-TRIM) TO WS-SALARY-UPPER
    IF WS-SALARY-TRIM = SPACES OR WS-SALARY-UPPER = "NONE"
        MOVE "Salary: NONE" TO JOB-SALARY
    ELSE
        MOVE SPACES TO JOB-SALARY
        STRING "Salary: " DELIMITED BY SIZE
               WS-SALARY-TRIM DELIMITED BY SIZE
           INTO JOB-SALARY
        END-STRING
    END-IF

    *> Persist posting
    PERFORM SAVE-JOB-POSTING

    *> Confirmation and return to main menu
    MOVE "Job posted successfully!" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT

    MOVE "MAIN" TO CURRENT-MENU
    MOVE 0            TO NAV-INDEX
    MOVE "SHOW-MENU"  TO NAV-ACTION
    PERFORM NAV-PRINT-LOOP
    EXIT PARAGRAPH.

SAVE-JOB-POSTING.
    *> Determine next JobID by counting existing non-empty lines
    PERFORM GET-NEXT-JOB-ID
    MOVE SPACES TO JOB-STRING
    MOVE JOB-ID-NUM TO JOB-ID-EDIT
    STRING
        FUNCTION TRIM(JOB-ID-EDIT)    DELIMITED BY SIZE "|"
        FUNCTION TRIM(AR-USERNAME)    DELIMITED BY SIZE "|"
        FUNCTION TRIM(JOB-TITLE)     DELIMITED BY SIZE "|"
        FUNCTION TRIM(JOB-DESCRIPTION) DELIMITED BY SIZE "|"
        FUNCTION TRIM(JOB-EMPLOYER)  DELIMITED BY SIZE "|"
        FUNCTION TRIM(JOB-LOCATION)  DELIMITED BY SIZE "|"
        FUNCTION TRIM(JOB-SALARY)    DELIMITED BY SIZE
        INTO JOB-STRING
    END-STRING

    OPEN EXTEND JOB-FILE
    IF JOB-STATUS = "35"
        *> File doesn't exist yet: create it and write first record
        OPEN OUTPUT JOB-FILE
        WRITE JOB-REC FROM JOB-STRING
        CLOSE JOB-FILE
    ELSE
        WRITE JOB-REC FROM JOB-STRING
        CLOSE JOB-FILE
    END-IF
    EXIT PARAGRAPH.

GET-NEXT-JOB-ID.
    MOVE 0 TO JOB-LINE-COUNT
    MOVE "N" TO JOB-EOF
    OPEN INPUT JOB-FILE
    IF JOB-STATUS = "35"
        MOVE 1 TO JOB-ID-NUM
        EXIT PARAGRAPH
    END-IF
    PERFORM UNTIL JOB-EOF = "Y"
        READ JOB-FILE
            AT END
                MOVE "Y" TO JOB-EOF
            NOT AT END
                IF JOB-REC NOT = SPACES
                    ADD 1 TO JOB-LINE-COUNT
                END-IF
        END-READ
    END-PERFORM
    CLOSE JOB-FILE
    ADD 1 TO JOB-LINE-COUNT GIVING JOB-ID-NUM
    EXIT PARAGRAPH.

PROFILE-INPUT-PROCESS.
    MOVE SPACES TO AR-FIRST-NAME
    MOVE SPACES TO AR-LAST-NAME
    MOVE SPACES TO AR-UNIVERSITY
    MOVE SPACES TO AR-MAJOR
    MOVE SPACES TO AR-ABOUT-ME
    MOVE ZERO   TO AR-GRADUATION-YEAR

    PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > 3
        MOVE SPACES TO AR-EXP-TITLE(IDX)
        MOVE SPACES TO AR-EXP-COMPANY(IDX)
        MOVE SPACES TO AR-EXP-DATES(IDX)
        MOVE SPACES TO AR-EXP-DESCRIPTION(IDX)
        MOVE SPACES TO AR-EDU-DEGREE(IDX)
        MOVE SPACES TO AR-EDU-SCHOOL(IDX)
        MOVE SPACES TO AR-EDU-YEARS(IDX)
    END-PERFORM

    PERFORM VALIDATE-FIRST-NAME
    IF EOF = "Y" EXIT PARAGRAPH END-IF

    PERFORM VALIDATE-LAST-NAME
    IF EOF = "Y" EXIT PARAGRAPH END-IF

    PERFORM VALIDATE-UNIVERSITY
    IF EOF = "Y" EXIT PARAGRAPH END-IF

    PERFORM VALIDATE-MAJOR
    IF EOF = "Y" EXIT PARAGRAPH END-IF

    PERFORM VALIDATE-GRADUATION-YEAR
    IF EOF = "Y" EXIT PARAGRAPH END-IF

    MOVE "Please enter about me (optional):" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-ABOUT-ME
    END-READ

    *> Collect experience data
    PERFORM COLLECT-EXPERIENCE-DATA

    *> Collect education data
    PERFORM COLLECT-EDUCATION-DATA

    *> Save profile data
    PERFORM SAVE-PROFILE-DATA

    *> Show completion
    PERFORM SHOW-PROFILE-COMPLETION-MENU
    EXIT PARAGRAPH.

SHOW-PROFILE-COMPLETION-MENU.
    MOVE "Profile saved successfully." TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT

    MOVE "MAIN" TO CURRENT-MENU
    MOVE 0            TO NAV-INDEX
    MOVE "SHOW-MENU"  TO NAV-ACTION
    PERFORM NAV-PRINT-LOOP
    EXIT PARAGRAPH.

COLLECT-EXPERIENCE-DATA.
    *> Exp 1
    MOVE "Experience #1 - Title (e.g., Software Intern):" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-TITLE(1).
    MOVE "Experience #1 - Company/Organization:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-COMPANY(1).
    MOVE "Experience #1 - Dates (e.g., Summer 2024 or Jan 2023 - May 2024):" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-DATES(1).
    MOVE "Experience #1 - Description:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-DESCRIPTION(1).

    *> Exp 2
    MOVE "Experience #2 - Title:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-TITLE(2).
    MOVE "Experience #2 - Company/Organization:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-COMPANY(2).
    MOVE "Experience #2 - Dates:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-DATES(2).
    MOVE "Experience #2 - Description:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-DESCRIPTION(2).

    *> Exp 3
    MOVE "Experience #3 - Title:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-TITLE(3).
    MOVE "Experience #3 - Company/Organization:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-COMPANY(3).
    MOVE "Experience #3 - Dates:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-DATES(3).
    MOVE "Experience #3 - Description:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-DESCRIPTION(3).
    EXIT PARAGRAPH.

COLLECT-EDUCATION-DATA.
    *> Edu 1
    MOVE "Education #1 - Degree (e.g., Bachelor of Science):" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EDU-DEGREE(1).
    MOVE "Education #1 - University/College:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EDU-SCHOOL(1).
    MOVE "Education #1 - Years Attended (e.g., 2020-2024):" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EDU-YEARS(1).

    *> Edu 2
    MOVE "Education #2 - Degree:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EDU-DEGREE(2).
    MOVE "Education #2 - University/College:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EDU-SCHOOL(2).
    MOVE "Education #2 - Years Attended:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EDU-YEARS(2).

    *> Edu 3
    MOVE "Education #3 - Degree:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EDU-DEGREE(3).
    MOVE "Education #3 - University/College:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EDU-SCHOOL(3).
    MOVE "Education #3 - Years Attended:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EDU-YEARS(3).
    EXIT PARAGRAPH.

VALIDATE-FIRST-NAME.
    MOVE "Please enter your first name:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-FIRST-NAME
    END-READ

    IF EOF NOT = "Y"
        IF AR-FIRST-NAME = SPACES
            MOVE "Error: First name is required and cannot be empty." TO OUTPUT-BUFFER
            PERFORM DUAL-OUTPUT
            MOVE "Please re-enter your first name:" TO OUTPUT-BUFFER
            PERFORM DUAL-OUTPUT
            MOVE "Y" TO EOF
        END-IF
    END-IF
    EXIT PARAGRAPH.

VALIDATE-LAST-NAME.
    MOVE "Please enter your last name:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-LAST-NAME
    END-READ

    IF EOF NOT = "Y"
        IF AR-LAST-NAME = SPACES
            MOVE "Error: Last name is required and cannot be empty." TO OUTPUT-BUFFER
            PERFORM DUAL-OUTPUT
            MOVE "Please re-enter your last name:" TO OUTPUT-BUFFER
            PERFORM DUAL-OUTPUT
            MOVE "Y" TO EOF
        END-IF
    END-IF
    EXIT PARAGRAPH.

VALIDATE-UNIVERSITY.
    MOVE "Please enter your university:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-UNIVERSITY
    END-READ

    IF EOF NOT = "Y"
        IF AR-UNIVERSITY = SPACES
            MOVE "Error: University is required and cannot be empty." TO OUTPUT-BUFFER
            PERFORM DUAL-OUTPUT
            MOVE "Please re-enter your university:" TO OUTPUT-BUFFER
            PERFORM DUAL-OUTPUT
            MOVE "Y" TO EOF
        END-IF
    END-IF
    EXIT PARAGRAPH.

VALIDATE-MAJOR.
    MOVE "Please enter your major:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-MAJOR
    END-READ

    IF EOF NOT = "Y"
        IF AR-MAJOR = SPACES
            MOVE "Error: Major is required and cannot be empty." TO OUTPUT-BUFFER
            PERFORM DUAL-OUTPUT
            MOVE "Please re-enter your major:" TO OUTPUT-BUFFER
            PERFORM DUAL-OUTPUT
            MOVE "Y" TO EOF
        END-IF
    END-IF
    EXIT PARAGRAPH.

VALIDATE-GRADUATION-YEAR.
    MOVE "Please enter your graduation year (4 digits):" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC (1:4) TO TEMP-GRAD-YEAR
    END-READ

    IF EOF NOT = "Y"

        IF TEMP-GRAD-YEAR IS NUMERIC
            MOVE TEMP-GRAD-YEAR TO AR-GRADUATION-YEAR
        ELSE
            MOVE "Error: Graduation year must be a valid 4-digit year." TO OUTPUT-BUFFER
            PERFORM DUAL-OUTPUT
            MOVE "Please re-enter your graduation year (4 digits):" TO OUTPUT-BUFFER
            PERFORM DUAL-OUTPUT
            MOVE "Y" TO EOF
        END-IF
    END-IF
    EXIT PARAGRAPH.

SAVE-PROFILE-DATA.
    MOVE SPACES TO PROFILE-DATA-STRING
    STRING
           FUNCTION TRIM(AR-FIRST-NAME)        DELIMITED BY SIZE "|"
           FUNCTION TRIM(AR-LAST-NAME)         DELIMITED BY SIZE "|"
           FUNCTION TRIM(AR-UNIVERSITY)        DELIMITED BY SIZE "|"
           FUNCTION TRIM(AR-MAJOR)             DELIMITED BY SIZE "|"
           AR-GRADUATION-YEAR                  DELIMITED BY SIZE "|"
           FUNCTION TRIM(AR-ABOUT-ME)          DELIMITED BY SIZE "|"

           FUNCTION TRIM(AR-EXP-TITLE(1))      DELIMITED BY SIZE "|"
           FUNCTION TRIM(AR-EXP-COMPANY(1))    DELIMITED BY SIZE "|"
           FUNCTION TRIM(AR-EXP-DATES(1))      DELIMITED BY SIZE "|"
           FUNCTION TRIM(AR-EXP-DESCRIPTION(1)) DELIMITED BY SIZE "|"

           FUNCTION TRIM(AR-EXP-TITLE(2))      DELIMITED BY SIZE "|"
           FUNCTION TRIM(AR-EXP-COMPANY(2))    DELIMITED BY SIZE "|"
           FUNCTION TRIM(AR-EXP-DATES(2))      DELIMITED BY SIZE "|"
           FUNCTION TRIM(AR-EXP-DESCRIPTION(2)) DELIMITED BY SIZE "|"

           FUNCTION TRIM(AR-EXP-TITLE(3))      DELIMITED BY SIZE "|"
           FUNCTION TRIM(AR-EXP-COMPANY(3))    DELIMITED BY SIZE "|"
           FUNCTION TRIM(AR-EXP-DATES(3))      DELIMITED BY SIZE "|"
           FUNCTION TRIM(AR-EXP-DESCRIPTION(3)) DELIMITED BY SIZE "|"

           FUNCTION TRIM(AR-EDU-DEGREE(1))     DELIMITED BY SIZE "|"
           FUNCTION TRIM(AR-EDU-SCHOOL(1))     DELIMITED BY SIZE "|"
           FUNCTION TRIM(AR-EDU-YEARS(1))      DELIMITED BY SIZE "|"

           FUNCTION TRIM(AR-EDU-DEGREE(2))     DELIMITED BY SIZE "|"
           FUNCTION TRIM(AR-EDU-SCHOOL(2))     DELIMITED BY SIZE "|"
           FUNCTION TRIM(AR-EDU-YEARS(2))      DELIMITED BY SIZE "|"

           FUNCTION TRIM(AR-EDU-DEGREE(3))     DELIMITED BY SIZE "|"
           FUNCTION TRIM(AR-EDU-SCHOOL(3))     DELIMITED BY SIZE "|"
           FUNCTION TRIM(AR-EDU-YEARS(3))      DELIMITED BY SIZE
        INTO PROFILE-DATA-STRING
    END-STRING

    CALL 'PROFILE-STORAGE'
         USING AR-USERNAME PROFILE-DATA-STRING CREATE-STATUS CREATE-RESPONSE
    EXIT PARAGRAPH.

*> PROFILE LOADER
PROFILE-LOAD.
    MOVE SPACES TO PROFILE-DATA-STRING
    CALL 'PROFILE-STORAGE-LOAD'
         USING AR-USERNAME PROFILE-DATA-STRING
    EXIT PARAGRAPH.

BROWSE-JOBS-SECTION.
    *> Use the new BUILD-JOB-SUMMARIES routine
    PERFORM BUILD-JOB-SUMMARIES

    *> Read user selection
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO JOB-SELECTION
    END-READ

    IF EOF NOT = "Y"
        PERFORM HANDLE-JOB-SELECTION
    END-IF
    EXIT PARAGRAPH.

PARSE-JOB-RECORD.
    *> Parse pipe-separated job record: ID|USERNAME|TITLE|DESC|EMPLOYER|LOCATION|SALARY
    MOVE SPACES TO JOB-PARSED-ID
    MOVE SPACES TO JOB-PARSED-USERNAME
    MOVE SPACES TO JOB-PARSED-TITLE
    MOVE SPACES TO JOB-PARSED-DESC
    MOVE SPACES TO JOB-PARSED-EMPLOYER
    MOVE SPACES TO JOB-PARSED-LOCATION
    MOVE SPACES TO JOB-PARSED-SALARY

    *> Find first pipe delimiter
    UNSTRING JOB-REC DELIMITED BY "|"
        INTO JOB-PARSED-ID
             JOB-PARSED-USERNAME
             JOB-PARSED-TITLE
             JOB-PARSED-DESC
             JOB-PARSED-EMPLOYER
             JOB-PARSED-LOCATION
             JOB-PARSED-SALARY
    END-UNSTRING
    EXIT PARAGRAPH.

HANDLE-JOB-SELECTION.
    *> Validate and process job selection
    MOVE FUNCTION TRIM(JOB-SELECTION) TO JOB-SELECTION
    MOVE "N" TO JOB-SELECTION-VALID

    *> Check if selection is numeric (after trimming)
    IF FUNCTION TRIM(JOB-SELECTION) IS NUMERIC
        MOVE FUNCTION TRIM(JOB-SELECTION) TO JOB-SELECTION-NUM
        IF JOB-SELECTION-NUM = 0
            *> Go back to main menu
            MOVE "MAIN" TO CURRENT-MENU
            MOVE 0 TO NAV-INDEX
            MOVE "SHOW-MENU" TO NAV-ACTION
            PERFORM NAV-PRINT-LOOP
            MOVE "Y" TO JOB-SELECTION-VALID
        ELSE
            IF JOB-SELECTION-NUM > 0 AND JOB-SELECTION-NUM <= JOB-SUMMARY-COUNT
                *> Valid job number - show details
                PERFORM SHOW-JOB-DETAILS
                MOVE "Y" TO JOB-SELECTION-VALID
            END-IF
        END-IF
    END-IF

    *> If invalid selection, show error and return to jobs menu
    IF JOB-SELECTION-VALID = "N"
        MOVE "Invalid job number. Please select a valid job from the list." TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT
        MOVE "JOBS" TO CURRENT-MENU
        MOVE 0 TO NAV-INDEX
        MOVE "SHOW-JOBS" TO NAV-ACTION
        PERFORM NAV-PRINT-LOOP
    END-IF
    EXIT PARAGRAPH.

SHOW-JOB-DETAILS.
    *> Find and display the selected job details
    MOVE "N" TO JOB-EOF
    MOVE 0 TO JOB-DETAILS-CURRENT
    MOVE "N" TO JOB-DETAILS-FOUND

    OPEN INPUT JOB-FILE
    IF JOB-STATUS = "35"
        *> File doesn't exist - show error message
        MOVE "Error: Unable to open job listings file." TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT
        EXIT PARAGRAPH
    END-IF

    PERFORM UNTIL JOB-EOF = "Y" OR JOB-DETAILS-FOUND = "Y"
        READ JOB-FILE
            AT END
                MOVE "Y" TO JOB-EOF
            NOT AT END
                IF JOB-REC NOT = SPACES
                    ADD 1 TO JOB-DETAILS-CURRENT
                    IF JOB-DETAILS-CURRENT = JOB-SELECTION-NUM
                        *> Found the selected job
                        PERFORM PARSE-JOB-RECORD
                        MOVE JOB-PARSED-ID TO JOB-DETAILS-ID
                        MOVE JOB-PARSED-USERNAME TO JOB-DETAILS-USERNAME
                        MOVE JOB-PARSED-TITLE TO JOB-DETAILS-TITLE
                        MOVE JOB-PARSED-DESC TO JOB-DETAILS-DESC
                        MOVE JOB-PARSED-EMPLOYER TO JOB-DETAILS-EMPLOYER
                        MOVE JOB-PARSED-LOCATION TO JOB-DETAILS-LOCATION
                        MOVE JOB-PARSED-SALARY TO JOB-DETAILS-SALARY
                        MOVE "Y" TO JOB-DETAILS-FOUND
                    END-IF
                END-IF
        END-READ
    END-PERFORM
    CLOSE JOB-FILE

    *> Display job details in exact format specified
    IF JOB-DETAILS-FOUND = "Y"
        MOVE "--- Job Details ---" TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT

        MOVE SPACES TO JOB-DETAILS-LINE
        STRING "Title: " DELIMITED BY SIZE
               FUNCTION TRIM(JOB-DETAILS-TITLE) DELIMITED BY SIZE
               INTO JOB-DETAILS-LINE
        END-STRING
        MOVE JOB-DETAILS-LINE TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT

        MOVE SPACES TO JOB-DETAILS-LINE
        STRING "Description: " DELIMITED BY SIZE
               FUNCTION TRIM(JOB-DETAILS-DESC) DELIMITED BY SIZE
               INTO JOB-DETAILS-LINE
        END-STRING
        MOVE JOB-DETAILS-LINE TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT

        MOVE SPACES TO JOB-DETAILS-LINE
        STRING "Employer: " DELIMITED BY SIZE
               FUNCTION TRIM(JOB-DETAILS-EMPLOYER) DELIMITED BY SIZE
               INTO JOB-DETAILS-LINE
        END-STRING
        MOVE JOB-DETAILS-LINE TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT

        MOVE SPACES TO JOB-DETAILS-LINE
        STRING "Location: " DELIMITED BY SIZE
               FUNCTION TRIM(JOB-DETAILS-LOCATION) DELIMITED BY SIZE
               INTO JOB-DETAILS-LINE
        END-STRING
        MOVE JOB-DETAILS-LINE TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT

        *> Handle salary display - show N/A if not present
        MOVE SPACES TO JOB-DETAILS-LINE
        IF JOB-DETAILS-SALARY = SPACES OR JOB-DETAILS-SALARY = "Salary: NONE"
            MOVE "Salary: N/A" TO JOB-DETAILS-LINE
        ELSE
            MOVE FUNCTION TRIM(JOB-DETAILS-SALARY) TO JOB-DETAILS-LINE
        END-IF
        MOVE JOB-DETAILS-LINE TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT

        MOVE "-------------------" TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT

        *> Show job detail menu options
        MOVE "Apply for this Job" TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT

        MOVE "Back to Job List" TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT

        MOVE "Enter your choice:" TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT

        *> Read user's choice for job detail menu
        READ INFILE
            AT END MOVE "Y" TO EOF
            NOT AT END MOVE IN-REC TO WS-COMMAND
        END-READ

        IF EOF NOT = "Y"
            PERFORM HANDLE-JOB-DETAIL-MENU
        END-IF
    ELSE
        *> Job not found - show error message
        MOVE "Error: Job record not found for selection " TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT
        MOVE JOB-SELECTION-NUM TO JOB-DETAILS-LINE
        MOVE JOB-DETAILS-LINE TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT

        *> Return to jobs menu
        MOVE "JOBS" TO CURRENT-MENU
        MOVE 0 TO NAV-INDEX
        MOVE "SHOW-JOBS" TO NAV-ACTION
        PERFORM NAV-PRINT-LOOP
    END-IF
    EXIT PARAGRAPH.

HANDLE-JOB-DETAIL-MENU.
    *> Handle user choice from job detail menu
    MOVE FUNCTION TRIM(WS-COMMAND) TO WS-COMMAND

    EVALUATE WS-COMMAND
        WHEN "Apply for this Job"
            *> Call apply routine
            PERFORM APPLY-JOB-ROUTINE

        WHEN "Back to Job List"
            *> Return to job list
            PERFORM BROWSE-JOBS-SECTION

        WHEN OTHER
            *> Invalid choice - show error and return to jobs menu
            MOVE "Invalid choice. Returning to Job Search/Internship menu." TO OUTPUT-BUFFER
            PERFORM DUAL-OUTPUT

            MOVE "JOBS" TO CURRENT-MENU
            MOVE 0 TO NAV-INDEX
            MOVE "SHOW-JOBS" TO NAV-ACTION
            PERFORM NAV-PRINT-LOOP
    END-EVALUATE
    EXIT PARAGRAPH.

*> OUTPUT-LINE-TO-SCREEN-AND-FILE: Helper for job summary output
*> Ensures identical output to both screen and file
OUTPUT-LINE-TO-SCREEN-AND-FILE.
    DISPLAY JOB-SUMMARY-BUFFER
    WRITE OUT-REC FROM JOB-SUMMARY-BUFFER
    MOVE SPACES TO JOB-SUMMARY-BUFFER
    EXIT PARAGRAPH.

*> BUILD-JOB-SUMMARIES: Main routine for displaying job summaries
BUILD-JOB-SUMMARIES.
    *> Initialize counters and flags
    MOVE 0 TO JOB-SUMMARY-COUNT
    MOVE 0 TO JOB-SUMMARY-NUM
    MOVE "N" TO JOB-SUMMARY-EOF
    MOVE "Y" TO JOB-SUMMARY-VALID-RECORD

    *> Open JOB-FILE for input
    OPEN INPUT JOB-FILE
    IF JOB-STATUS = "35"
        *> File doesn't exist - show error message
        MOVE JOB-ERROR-MESSAGE TO JOB-SUMMARY-BUFFER
        PERFORM OUTPUT-LINE-TO-SCREEN-AND-FILE
        EXIT PARAGRAPH
    END-IF

    *> Read and process job records
    PERFORM UNTIL JOB-SUMMARY-EOF = "Y"
        READ JOB-FILE
            AT END
                MOVE "Y" TO JOB-SUMMARY-EOF
            NOT AT END
                IF JOB-REC NOT = SPACES
                    ADD 1 TO JOB-SUMMARY-COUNT
                    ADD 1 TO JOB-SUMMARY-NUM
                    PERFORM PARSE-JOB-SUMMARY-RECORD
                    IF JOB-SUMMARY-VALID-RECORD = "Y"
                        PERFORM FORMAT-JOB-SUMMARY-LINE
                        MOVE JOB-SUMMARY-LINE TO JOB-SUMMARY-BUFFER
                        PERFORM OUTPUT-LINE-TO-SCREEN-AND-FILE
                    ELSE
                        *> Skip invalid record and show message
                        MOVE SPACES TO JOB-SUMMARY-BUFFER
                        STRING JOB-SKIP-MESSAGE DELIMITED BY SIZE
                               FUNCTION TRIM(JOB-SUMMARY-SKIP-ID) DELIMITED BY SIZE
                               INTO JOB-SUMMARY-BUFFER
                        END-STRING
                        PERFORM OUTPUT-LINE-TO-SCREEN-AND-FILE
                    END-IF
                END-IF
        END-READ
    END-PERFORM
    CLOSE JOB-FILE

    *> Handle empty list case
    IF JOB-SUMMARY-COUNT = 0
        MOVE JOB-EMPTY-MESSAGE TO JOB-SUMMARY-BUFFER
        PERFORM OUTPUT-LINE-TO-SCREEN-AND-FILE
    END-IF

    *> Output divider and prompt
    MOVE JOB-DIVIDER TO JOB-SUMMARY-BUFFER
    PERFORM OUTPUT-LINE-TO-SCREEN-AND-FILE
    MOVE JOB-PROMPT TO JOB-SUMMARY-BUFFER
    PERFORM OUTPUT-LINE-TO-SCREEN-AND-FILE
    EXIT PARAGRAPH.

*> PARSE-JOB-SUMMARY-RECORD: Parse pipe-separated job record
PARSE-JOB-SUMMARY-RECORD.
    *> Initialize parsed fields
    MOVE SPACES TO JOB-SUMMARY-PARSED-ID
    MOVE SPACES TO JOB-SUMMARY-PARSED-USERNAME
    MOVE SPACES TO JOB-SUMMARY-PARSED-TITLE
    MOVE SPACES TO JOB-SUMMARY-PARSED-DESC
    MOVE SPACES TO JOB-SUMMARY-PARSED-EMPLOYER
    MOVE SPACES TO JOB-SUMMARY-PARSED-LOCATION
    MOVE SPACES TO JOB-SUMMARY-PARSED-SALARY
    MOVE "Y" TO JOB-SUMMARY-VALID-RECORD

    *> Parse pipe-separated record: ID|USERNAME|TITLE|DESC|EMPLOYER|LOCATION|SALARY
    UNSTRING JOB-REC DELIMITED BY "|"
        INTO JOB-SUMMARY-PARSED-ID
             JOB-SUMMARY-PARSED-USERNAME
             JOB-SUMMARY-PARSED-TITLE
             JOB-SUMMARY-PARSED-DESC
             JOB-SUMMARY-PARSED-EMPLOYER
             JOB-SUMMARY-PARSED-LOCATION
             JOB-SUMMARY-PARSED-SALARY
    END-UNSTRING

    *> Validate required fields
    IF FUNCTION TRIM(JOB-SUMMARY-PARSED-TITLE) = SPACES OR FUNCTION TRIM(JOB-SUMMARY-PARSED-EMPLOYER) = SPACES OR FUNCTION TRIM(JOB-SUMMARY-PARSED-LOCATION) = SPACES
        MOVE "N" TO JOB-SUMMARY-VALID-RECORD
        MOVE JOB-SUMMARY-PARSED-ID TO JOB-SUMMARY-SKIP-ID
    END-IF
    EXIT PARAGRAPH.

*> FORMAT-JOB-SUMMARY-LINE: Format job summary line with proper truncation
FORMAT-JOB-SUMMARY-LINE.
    *> Trim and truncate fields
    MOVE FUNCTION TRIM(JOB-SUMMARY-PARSED-TITLE) TO JOB-FIELD-TITLE-TRIMMED
    MOVE FUNCTION TRIM(JOB-SUMMARY-PARSED-EMPLOYER) TO JOB-FIELD-EMPLOYER-TRIMMED
    MOVE FUNCTION TRIM(JOB-SUMMARY-PARSED-LOCATION) TO JOB-FIELD-LOCATION-TRIMMED

    *> Truncate fields if too long (with ellipsis for display)
    PERFORM TRUNCATE-FIELD-TITLE
    PERFORM TRUNCATE-FIELD-EMPLOYER
    PERFORM TRUNCATE-FIELD-LOCATION

    *> Format: n. <Job Title> at <Employer> (<Location>)
    MOVE SPACES TO JOB-SUMMARY-LINE
    MOVE JOB-SUMMARY-NUM TO JOB-SUMMARY-NUM-DISPLAY
    STRING
        FUNCTION TRIM(JOB-SUMMARY-NUM-DISPLAY) DELIMITED BY SIZE ". "
        FUNCTION TRIM(JOB-FIELD-TITLE-TRIMMED) DELIMITED BY SIZE " at "
        FUNCTION TRIM(JOB-FIELD-EMPLOYER-TRIMMED) DELIMITED BY SIZE " ("
        FUNCTION TRIM(JOB-FIELD-LOCATION-TRIMMED) DELIMITED BY SIZE ")"
        INTO JOB-SUMMARY-LINE
    END-STRING
    EXIT PARAGRAPH.

*> TRUNCATE-FIELD-TITLE: Truncate title field with ellipsis if too long
TRUNCATE-FIELD-TITLE.
    *> Check if title is longer than 50 characters
    IF FUNCTION LENGTH(FUNCTION TRIM(JOB-FIELD-TITLE-TRIMMED)) > 50
        MOVE JOB-FIELD-TITLE-TRIMMED(1:47) TO JOB-FIELD-TITLE-TRIMMED
        MOVE "..." TO JOB-FIELD-TITLE-TRIMMED(48:3)
    END-IF
    EXIT PARAGRAPH.

*> TRUNCATE-FIELD-EMPLOYER: Truncate employer field with ellipsis if too long
TRUNCATE-FIELD-EMPLOYER.
    *> Check if employer is longer than 30 characters
    IF FUNCTION LENGTH(FUNCTION TRIM(JOB-FIELD-EMPLOYER-TRIMMED)) > 30
        MOVE JOB-FIELD-EMPLOYER-TRIMMED(1:27) TO JOB-FIELD-EMPLOYER-TRIMMED
        MOVE "..." TO JOB-FIELD-EMPLOYER-TRIMMED(28:3)
    END-IF
    EXIT PARAGRAPH.

*> TRUNCATE-FIELD-LOCATION: Truncate location field with ellipsis if too long
TRUNCATE-FIELD-LOCATION.
    *> Check if location is longer than 30 characters
    IF FUNCTION LENGTH(FUNCTION TRIM(JOB-FIELD-LOCATION-TRIMMED)) > 30
        MOVE JOB-FIELD-LOCATION-TRIMMED(1:27) TO JOB-FIELD-LOCATION-TRIMMED
        MOVE "..." TO JOB-FIELD-LOCATION-TRIMMED(28:3)
    END-IF
    EXIT PARAGRAPH.

*> TRUNCATE-FIELD: Truncate field with ellipsis if too long
TRUNCATE-FIELD.
    *> This is a placeholder - COBOL doesn't support dynamic field truncation easily
    *> For now, we'll rely on the STRING operation to handle truncation
    *> In a real implementation, you'd need to check field lengths and add ellipsis
    EXIT PARAGRAPH.

*> APPLY-JOB-ROUTINE: Handle job application with duplicate checking
APPLY-JOB-ROUTINE.
    *> Validate that user is logged in
    IF LOGIN-STATUS NOT = "Y"
        MOVE "Please log in to apply for jobs." TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT
        EXIT PARAGRAPH
    END-IF

    *> Check for duplicate application
    PERFORM CHECK-DUPLICATE-APPLICATION

    IF DUPLICATE-FOUND = "Y"
        *> User has already applied for this job
        MOVE SPACES TO APPLICATION-DUPLICATE-MSG
        STRING "You have already applied for " DELIMITED BY SIZE
               FUNCTION TRIM(JOB-DETAILS-TITLE) DELIMITED BY SIZE
               " at " DELIMITED BY SIZE
               FUNCTION TRIM(JOB-DETAILS-EMPLOYER) DELIMITED BY SIZE
               "." DELIMITED BY SIZE
               INTO APPLICATION-DUPLICATE-MSG
        END-STRING
        MOVE APPLICATION-DUPLICATE-MSG TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT

        *> Return to job details menu
        MOVE "JOBS" TO CURRENT-MENU
        MOVE 0 TO NAV-INDEX
        MOVE "SHOW-JOBS" TO NAV-ACTION
        PERFORM NAV-PRINT-LOOP
        EXIT PARAGRAPH
    END-IF

    *> Create new application record
    PERFORM CREATE-APPLICATION-RECORD

    *> Save application to file
    PERFORM SAVE-APPLICATION

    *> Show confirmation message
    MOVE SPACES TO APPLICATION-CONFIRMATION
    STRING "Your application for " DELIMITED BY SIZE
           FUNCTION TRIM(JOB-DETAILS-TITLE) DELIMITED BY SIZE
           " at " DELIMITED BY SIZE
           FUNCTION TRIM(JOB-DETAILS-EMPLOYER) DELIMITED BY SIZE
           " has been submitted." DELIMITED BY SIZE
           INTO APPLICATION-CONFIRMATION
    END-STRING
    MOVE APPLICATION-CONFIRMATION TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT

    *> Return to job details menu
    MOVE "JOBS" TO CURRENT-MENU
    MOVE 0 TO NAV-INDEX
    MOVE "SHOW-JOBS" TO NAV-ACTION
    PERFORM NAV-PRINT-LOOP
    EXIT PARAGRAPH.

*> CHECK-DUPLICATE-APPLICATION: Check if user has already applied for this job
CHECK-DUPLICATE-APPLICATION.
    MOVE "N" TO DUPLICATE-FOUND
    MOVE "N" TO APPLICATION-EOF

    OPEN INPUT APPLICATION-FILE
    IF APPLICATION-STATUS = "35"
        *> File doesn't exist yet - no duplicates possible
        CLOSE APPLICATION-FILE
        EXIT PARAGRAPH
    END-IF

    PERFORM UNTIL APPLICATION-EOF = "Y"
        READ APPLICATION-FILE
            AT END
                MOVE "Y" TO APPLICATION-EOF
            NOT AT END
                IF APPLICATION-REC NOT = SPACES
                    PERFORM PARSE-APPLICATION-RECORD
                    IF APPLICATION-PARSED-USERNAME = AR-USERNAME AND
                       APPLICATION-PARSED-JOB-ID = JOB-DETAILS-ID
                        MOVE "Y" TO DUPLICATE-FOUND
                        MOVE "Y" TO APPLICATION-EOF
                    END-IF
                END-IF
        END-READ
    END-PERFORM
    CLOSE APPLICATION-FILE
    EXIT PARAGRAPH.

*> PARSE-APPLICATION-RECORD: Parse application record
PARSE-APPLICATION-RECORD.
    MOVE SPACES TO APPLICATION-PARSED-ID
    MOVE SPACES TO APPLICATION-PARSED-USERNAME
    MOVE SPACES TO APPLICATION-PARSED-JOB-ID

    UNSTRING APPLICATION-REC DELIMITED BY "|"
        INTO APPLICATION-PARSED-ID
             APPLICATION-PARSED-USERNAME
             APPLICATION-PARSED-JOB-ID
    END-UNSTRING
    EXIT PARAGRAPH.

*> CREATE-APPLICATION-RECORD: Create new application record
CREATE-APPLICATION-RECORD.
    *> Get next application ID
    PERFORM GET-NEXT-APPLICATION-ID

    *> Build application record string without date
    MOVE SPACES TO APPLICATION-STRING
    MOVE APPLICATION-ID-NUM TO APPLICATION-ID-EDIT
    STRING
        FUNCTION TRIM(APPLICATION-ID-EDIT) DELIMITED BY SIZE "|"
        FUNCTION TRIM(AR-USERNAME)         DELIMITED BY SIZE "|"
        FUNCTION TRIM(JOB-DETAILS-ID)      DELIMITED BY SIZE
        INTO APPLICATION-STRING
    END-STRING
    EXIT PARAGRAPH.


*> GET-NEXT-APPLICATION-ID: Get next available application ID
GET-NEXT-APPLICATION-ID.
    MOVE 0 TO APPLICATION-LINE-COUNT
    MOVE "N" TO APPLICATION-EOF

    OPEN INPUT APPLICATION-FILE
    IF APPLICATION-STATUS = "35"
        MOVE 1 TO APPLICATION-ID-NUM
        CLOSE APPLICATION-FILE
        EXIT PARAGRAPH
    END-IF

    PERFORM UNTIL APPLICATION-EOF = "Y"
        READ APPLICATION-FILE
            AT END
                MOVE "Y" TO APPLICATION-EOF
            NOT AT END
                IF APPLICATION-REC NOT = SPACES
                    ADD 1 TO APPLICATION-LINE-COUNT
                END-IF
        END-READ
    END-PERFORM
    CLOSE APPLICATION-FILE
    ADD 1 TO APPLICATION-LINE-COUNT GIVING APPLICATION-ID-NUM
    EXIT PARAGRAPH.

*> SAVE-APPLICATION: Save application record to file
SAVE-APPLICATION.
    OPEN EXTEND APPLICATION-FILE
    IF APPLICATION-STATUS = "35"
        *> File doesn't exist yet: create it and write first record
        OPEN OUTPUT APPLICATION-FILE
        WRITE APPLICATION-REC FROM APPLICATION-STRING
        CLOSE APPLICATION-FILE
    ELSE
        WRITE APPLICATION-REC FROM APPLICATION-STRING
        CLOSE APPLICATION-FILE
    END-IF

    *> Check for write errors
    IF APPLICATION-STATUS NOT = "00" AND APPLICATION-STATUS NOT = "35"
        MOVE "Error: Unable to record application at this time. Please try again later." TO APPLICATION-ERROR-MSG
        MOVE APPLICATION-ERROR-MSG TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT
    END-IF
    EXIT PARAGRAPH.

*> VIEW-MY-APPLICATIONS: Display all applications for current user
VIEW-MY-APPLICATIONS.
    MOVE 0 TO JOB-COUNT
    MOVE "N" TO APPLICATION-EOF

    MOVE "--- Your Job Applications ---" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    STRING "Application Summary for " DELIMITED BY SIZE
           FUNCTION TRIM(AR-USERNAME) DELIMITED BY SIZE
           INTO OUTPUT-BUFFER
    END-STRING
    PERFORM DUAL-OUTPUT
    MOVE "------------------------------" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT

    OPEN INPUT APPLICATION-FILE
    IF APPLICATION-STATUS = "35"
        MOVE "You have not applied for any jobs yet." TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT
        CLOSE APPLICATION-FILE
        GO TO VIEW-MY-APPLICATIONS-EXIT
    END-IF

    PERFORM UNTIL APPLICATION-EOF = "Y"
        READ APPLICATION-FILE
            AT END
                MOVE "Y" TO APPLICATION-EOF
            NOT AT END
                IF APPLICATION-REC NOT = SPACES
                    PERFORM PARSE-APPLICATION-RECORD
                    IF APPLICATION-PARSED-USERNAME = AR-USERNAME
                        ADD 1 TO JOB-COUNT
                        MOVE APPLICATION-PARSED-JOB-ID TO JOB-ID-NUM
                        PERFORM DISPLAY-APPLICATION-JOB
                    END-IF
                END-IF
        END-READ
    END-PERFORM
    CLOSE APPLICATION-FILE

    MOVE JOB-COUNT TO JOB-SUMMARY-NUM-DISPLAY
    MOVE SPACES TO OUTPUT-BUFFER
    STRING "Total Applications: " DELIMITED BY SIZE
       FUNCTION TRIM(JOB-SUMMARY-NUM-DISPLAY) DELIMITED BY SIZE
       INTO OUTPUT-BUFFER
    END-STRING
    PERFORM DUAL-OUTPUT

    MOVE "------------------------------" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT



    MOVE "JOBS" TO CURRENT-MENU
    MOVE 0 TO NAV-INDEX
    MOVE "SHOW-JOBS" TO NAV-ACTION
    PERFORM NAV-PRINT-LOOP
    EXIT PARAGRAPH.



VIEW-MY-APPLICATIONS-EXIT.
    MOVE "JOBS" TO CURRENT-MENU
    MOVE 0 TO NAV-INDEX
    MOVE "SHOW-JOBS" TO NAV-ACTION
    PERFORM NAV-PRINT-LOOP
    EXIT PARAGRAPH.

*> DISPLAY-APPLICATION-JOB: Find and show job title, employer, and location
DISPLAY-APPLICATION-JOB.
    MOVE "N" TO JOB-EOF
    OPEN INPUT JOB-FILE
    IF JOB-STATUS = "35"
        MOVE "Error: Unable to open job listings file." TO OUTPUT-BUFFER
        PERFORM DUAL-OUTPUT
        EXIT PARAGRAPH
    END-IF

    PERFORM UNTIL JOB-EOF = "Y"
        READ JOB-FILE
            AT END
                MOVE "Y" TO JOB-EOF
            NOT AT END
                IF JOB-REC NOT = SPACES
                    PERFORM PARSE-JOB-RECORD
                    MOVE JOB-ID-NUM TO JOB-ID-EDIT
                    IF FUNCTION TRIM(JOB-PARSED-ID) = FUNCTION TRIM(JOB-ID-EDIT)
                        MOVE SPACES TO OUTPUT-BUFFER
                        STRING "Job Title: " DELIMITED BY SIZE
                               FUNCTION TRIM(JOB-PARSED-TITLE) DELIMITED BY SIZE
                               INTO OUTPUT-BUFFER
                        END-STRING
                        PERFORM DUAL-OUTPUT

                        MOVE SPACES TO OUTPUT-BUFFER
                        STRING "Employer: " DELIMITED BY SIZE
                               FUNCTION TRIM(JOB-PARSED-EMPLOYER) DELIMITED BY SIZE
                               INTO OUTPUT-BUFFER
                        END-STRING
                        PERFORM DUAL-OUTPUT

                        MOVE SPACES TO OUTPUT-BUFFER
                        STRING "Location: " DELIMITED BY SIZE
                               FUNCTION TRIM(JOB-PARSED-LOCATION) DELIMITED BY SIZE
                               INTO OUTPUT-BUFFER
                        END-STRING
                        PERFORM DUAL-OUTPUT

                        MOVE "---" TO OUTPUT-BUFFER
                        PERFORM DUAL-OUTPUT

                        MOVE "Y" TO JOB-EOF
                    END-IF
                END-IF
        END-READ
    END-PERFORM
    CLOSE JOB-FILE
    EXIT PARAGRAPH.
