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
01  ACCOUNT-REC        PIC X(100).

WORKING-STORAGE SECTION.
COPY "AccountRecord.cpy".
01  EOF                PIC X(1) VALUE "N".
01  CREATE-RESPONSE    PIC X(100).
01  CREATE-STATUS      PIC X(1) VALUE "N".
01  LOGIN-RESPONSE     PIC X(100).
01  LOGIN-STATUS       PIC X(1) VALUE "N".
01  NUM-ACCOUNTS       PIC 9(1) VALUE 0.
01  MAX-ACCOUNTS       PIC 9(1) VALUE 5.
01  EOF-ACCT           PIC X(1) VALUE "N".
01  OUTPUT-BUFFER      PIC X(100).

01  NAV-ACTION         PIC X(20).
01  NAV-LINE           PIC X(100).
01  NAV-DONE           PIC X.
01  NAV-INDEX          PIC 99 VALUE 0.

01  CURRENT-MENU       PIC X(15) VALUE "MAIN".
01  PROFILE-DATA-STRING PIC X(1000).
01  TEMP-GRAD-YEAR     PIC X(10).
01  YEAR-LEN           PIC 99.
01  YEAR-NUMERIC       PIC X VALUE "N".

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
                        MOVE "N" TO LOGIN-STATUS
                        MOVE "MAIN" TO CURRENT-MENU
                        MOVE 0 TO NAV-INDEX
                        MOVE SPACES TO NAV-ACTION
                        MOVE 'Welcome to InCollege!' TO OUTPUT-BUFFER
                        PERFORM DUAL-OUTPUT

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
                        MOVE 0            TO NAV-INDEX
                        MOVE "SHOW-MENU"  TO NAV-ACTION
                        PERFORM NAV-PRINT-LOOP

                    WHEN "Job"
                        MOVE 0        TO NAV-INDEX
                        MOVE "JOB"    TO NAV-ACTION
                        PERFORM NAV-PRINT-LOOP
                        *> re-display main menu
                        MOVE 0            TO NAV-INDEX
                        MOVE "SHOW-MENU"  TO NAV-ACTION
                        PERFORM NAV-PRINT-LOOP

                    WHEN "Find"
                        MOVE 0        TO NAV-INDEX
                        MOVE "FIND"   TO NAV-ACTION
                        PERFORM NAV-PRINT-LOOP
                        *> re-display main menu
                        MOVE 0            TO NAV-INDEX
                        MOVE "SHOW-MENU"  TO NAV-ACTION
                        PERFORM NAV-PRINT-LOOP

                    WHEN "Skills"
                        MOVE "SKILLS" TO CURRENT-MENU
                        MOVE 0              TO NAV-INDEX
                        MOVE "SHOW-SKILLS"  TO NAV-ACTION
                        PERFORM NAV-PRINT-LOOP

                    WHEN "Profile"
                        MOVE "CREATE-PROFILE" TO CURRENT-MENU
                        MOVE 0         TO NAV-INDEX
                        MOVE "SHOW-CREATE-PROFILE" TO NAV-ACTION
                        PERFORM NAV-PRINT-LOOP
                        PERFORM PROFILE-INPUT-PROCESS

                    WHEN "Skill-1"
                        IF CURRENT-MENU = "SKILLS"
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
                        IF CURRENT-MENU = "SKILLS"
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
                        IF CURRENT-MENU = "SKILLS"
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
                        IF CURRENT-MENU = "SKILLS"
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
                        IF CURRENT-MENU = "SKILLS"
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
                        IF CURRENT-MENU = "PROFILE"
                            MOVE "CREATE-PROFILE" TO CURRENT-MENU
                            MOVE 0         TO NAV-INDEX
                            MOVE "CREATE-PROFILE" TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF

                    WHEN "Create New Profile"
                        IF CURRENT-MENU = "PROFILE"
                            MOVE "CREATE-PROFILE" TO CURRENT-MENU
                            MOVE 0         TO NAV-INDEX
                            MOVE "CREATE-PROFILE" TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF


                    WHEN "Save Profile"
                        IF CURRENT-MENU = "CREATE-PROFILE"
                            PERFORM PROFILE-INPUT-PROCESS
                        ELSE
                            MOVE "Invalid option" TO OUTPUT-BUFFER
                            PERFORM DUAL-OUTPUT
                        END-IF

                    WHEN "Back"
                        MOVE "MAIN" TO CURRENT-MENU
                        MOVE 0            TO NAV-INDEX
                        MOVE "SHOW-MENU"  TO NAV-ACTION
                        PERFORM NAV-PRINT-LOOP

                    WHEN OTHER
                        MOVE "Invalid option" TO OUTPUT-BUFFER
                        PERFORM DUAL-OUTPUT
                END-EVALUATE
        END-READ
    END-PERFORM

    CLOSE INFILE.
    STOP RUN.

DUAL-OUTPUT.
    DISPLAY OUTPUT-BUFFER
    OPEN EXTEND OUTFILE
    WRITE OUT-REC FROM OUTPUT-BUFFER
    CLOSE OUTFILE
    MOVE SPACES TO OUTPUT-BUFFER
    EXIT PARAGRAPH.

*> Navigation helper
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
    *> Interactive profile input process with validation
    PERFORM VALIDATE-FIRST-NAME
    IF EOF = "Y" EXIT PARAGRAPH END-IF

    MOVE "Please enter your last name:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-LAST-NAME
    END-READ

    MOVE "Please enter your university:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-UNIVERSITY
    END-READ

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

    *> Collect experience data (up to 3 entries)
    PERFORM COLLECT-EXPERIENCE-DATA

    *> Collect education data (up to 3 entries)
    PERFORM COLLECT-EDUCATION-DATA

    *> Save profile data
    PERFORM SAVE-PROFILE-DATA

    *> Show custom profile completion menu
    PERFORM SHOW-PROFILE-COMPLETION-MENU

    EXIT PARAGRAPH.

SHOW-PROFILE-COMPLETION-MENU.
    MOVE "DONE" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT

    MOVE "Profile saved successfully!" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT

    MOVE "1. Create/Edit My Profile" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT

    MOVE "2. View My Profile" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT

    MOVE "3. Search for User" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT

    MOVE "4. Learn a New Skill" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT

    MOVE "Enter your choice:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT

    *> Stop the program here - don't continue reading input
    MOVE "Y" TO EOF

    EXIT PARAGRAPH.

COLLECT-EXPERIENCE-DATA.
    *> Experience #1
    MOVE "Experience #1 - Title (e.g., Software Intern):" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-TITLE(1)
    END-READ

    MOVE "Experience #1 - Company/Organization:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-COMPANY(1)
    END-READ

    MOVE "Experience #1 - Dates (e.g., Summer 2024):" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-START-DATE(1)
    END-READ

    MOVE "Experience #1 - Description:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-DESCRIPTION(1)
    END-READ

    *> Experience #2
    MOVE "Experience #2 - Title:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-TITLE(2)
    END-READ

    MOVE "Experience #2 - Company/Organization:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-COMPANY(2)
    END-READ

    MOVE "Experience #2 - Dates:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-START-DATE(2)
    END-READ

    MOVE "Experience #2 - Description:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-DESCRIPTION(2)
    END-READ

    *> Experience #3
    MOVE "Experience #3 - Title:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-TITLE(3)
    END-READ

    MOVE "Experience #3 - Company/Organization:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-COMPANY(3)
    END-READ

    MOVE "Experience #3 - Dates:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-START-DATE(3)
    END-READ

    MOVE "Experience #3 - Description:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EXP-DESCRIPTION(3)
    END-READ

    EXIT PARAGRAPH.

COLLECT-EDUCATION-DATA.
    *> Education #1
    MOVE "Education #1 - Degree (e.g., Master of Science):" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EDU-DEGREE(1)
    END-READ

    MOVE "Education #1 - University/College:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EDU-SCHOOL(1)
    END-READ

    MOVE "Education #1 - Years Attended (e.g., 2023-2025):" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EDU-START-DATE(1)
    END-READ

    *> Education #2
    MOVE "Education #2 - Degree:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EDU-DEGREE(2)
    END-READ

    MOVE "Education #2 - University/College:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EDU-SCHOOL(2)
    END-READ

    MOVE "Education #2 - Years Attended:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EDU-START-DATE(2)
    END-READ

    *> Education #3
    MOVE "Education #3 - Degree:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EDU-DEGREE(3)
    END-READ

    MOVE "Education #3 - University/College:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EDU-SCHOOL(3)
    END-READ

    MOVE "Education #3 - Years Attended:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-EDU-START-DATE(3)
    END-READ

    EXIT PARAGRAPH.

VALIDATE-FIRST-NAME.
    MOVE "Please enter your first name:" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO AR-FIRST-NAME
    END-READ

    IF EOF NOT = "Y"
        *> Check if first name is empty or only spaces
        IF AR-FIRST-NAME = SPACES
            MOVE "Error: First name is required and cannot be empty." TO OUTPUT-BUFFER
            PERFORM DUAL-OUTPUT
            MOVE "Please re-enter your first name:" TO OUTPUT-BUFFER
            PERFORM DUAL-OUTPUT
            *> Stop processing after validation error
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
        *> Check if major is empty or only spaces
        IF AR-MAJOR = SPACES
            MOVE "Error: Major is required and cannot be empty." TO OUTPUT-BUFFER
            PERFORM DUAL-OUTPUT
            MOVE "Please re-enter your major:" TO OUTPUT-BUFFER
            PERFORM DUAL-OUTPUT
            *> Stop processing after validation error
            MOVE "Y" TO EOF
        END-IF
    END-IF
    EXIT PARAGRAPH.

VALIDATE-GRADUATION-YEAR.
    MOVE "Please enter your graduation year (4 digits):" TO OUTPUT-BUFFER
    PERFORM DUAL-OUTPUT
    READ INFILE
        AT END MOVE "Y" TO EOF
        NOT AT END MOVE IN-REC TO TEMP-GRAD-YEAR
    END-READ

    IF EOF NOT = "Y"
        *> Check if graduation year is exactly 4 digits and numeric
        MOVE "N" TO YEAR-NUMERIC
        INSPECT TEMP-GRAD-YEAR TALLYING YEAR-LEN FOR CHARACTERS BEFORE INITIAL SPACE
        IF YEAR-LEN = 4
            IF TEMP-GRAD-YEAR (1:4) IS NUMERIC
                MOVE "Y" TO YEAR-NUMERIC
            END-IF
        END-IF

        IF YEAR-NUMERIC = "N"
            MOVE "Error: Graduation year must be a valid 4-digit year." TO OUTPUT-BUFFER
            PERFORM DUAL-OUTPUT
            MOVE "Please re-enter your graduation year (4 digits):" TO OUTPUT-BUFFER
            PERFORM DUAL-OUTPUT
            *> Stop processing after validation error
            MOVE "Y" TO EOF
        ELSE
            MOVE TEMP-GRAD-YEAR (1:4) TO AR-GRADUATION-YEAR
        END-IF
    END-IF
    EXIT PARAGRAPH.

SAVE-PROFILE-DATA.
    *> Create profile data string from all collected information
    MOVE SPACES TO PROFILE-DATA-STRING
    STRING AR-FIRST-NAME DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-LAST-NAME DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-UNIVERSITY DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-MAJOR DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-GRADUATION-YEAR DELIMITED BY SIZE
           "|" DELIMITED BY SIZE
           AR-ABOUT-ME DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-EXP-TITLE(1) DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-EXP-COMPANY(1) DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-EXP-START-DATE(1) DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-EXP-DESCRIPTION(1) DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-EXP-TITLE(2) DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-EXP-COMPANY(2) DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-EXP-START-DATE(2) DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-EXP-DESCRIPTION(2) DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-EXP-TITLE(3) DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-EXP-COMPANY(3) DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-EXP-START-DATE(3) DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-EXP-DESCRIPTION(3) DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-EDU-DEGREE(1) DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-EDU-SCHOOL(1) DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-EDU-START-DATE(1) DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-EDU-DEGREE(2) DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-EDU-SCHOOL(2) DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-EDU-START-DATE(2) DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-EDU-DEGREE(3) DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-EDU-SCHOOL(3) DELIMITED BY SPACE
           "|" DELIMITED BY SIZE
           AR-EDU-START-DATE(3) DELIMITED BY SPACE
           INTO PROFILE-DATA-STRING
    END-STRING

    *> Call profile storage module
    CALL 'PROFILE-STORAGE' USING AR-USERNAME PROFILE-DATA-STRING CREATE-STATUS CREATE-RESPONSE

    EXIT PARAGRAPH.
