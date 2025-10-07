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

DATA DIVISION.
FILE SECTION.
FD  INFILE.
01  IN-REC             PIC X(100).
FD  OUTFILE EXTERNAL.
01  OUT-REC            PIC X(200).
FD  ACCOUNT-FILE.
01  ACCOUNT-REC        PIC X(100).

WORKING-STORAGE SECTION.
COPY "AccountRecord.cpy".
01  EOF                PIC X(1) VALUE "N".
01  OUT-STATUS         PIC XX.
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
                IF LOGIN-STATUS NOT = "Y"
                   MOVE 'Log In' TO OUTPUT-BUFFER
                   PERFORM DUAL-OUTPUT
                   MOVE 'Create New Account' TO OUTPUT-BUFFER
                   PERFORM DUAL-OUTPUT
                   MOVE 'Enter your choice:' TO OUTPUT-BUFFER
                   PERFORM DUAL-OUTPUT
                END-IF

                EVALUATE IN-REC
                    WHEN "Log Out"
                        IF LOGIN-STATUS = "Y"
                            MOVE "N" TO LOGIN-STATUS
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
                            MOVE 0        TO NAV-INDEX
                            MOVE "JOB"    TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                            *> re-display main menu
                            MOVE 0            TO NAV-INDEX
                            MOVE "SHOW-MENU"  TO NAV-ACTION
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


                    WHEN "Skill-1"
                        IF LOGIN-STATUS = "Y" AND CURRENT-MENU = "SKILLS"
                            MOVE 0         TO NAV-INDEX
                            MOVE "SKILL-1" TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                            *> re-display skills menu
                            MOVE 0              TO NAV-INDEX
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
                            MOVE 0              TO NAV-INDEX
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
                            MOVE 0              TO NAV-INDEX
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
                            MOVE 0              TO NAV-INDEX
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
        END-READ
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
        IF NAV-LINE NOT = SPACES
            MOVE NAV-LINE TO OUTPUT-BUFFER
            PERFORM DUAL-OUTPUT
        END-IF
    END-PERFORM
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
