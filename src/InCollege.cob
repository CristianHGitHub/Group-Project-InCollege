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
01  NAV-INDEX          PIC 9 VALUE 0.

01  CURRENT-MENU       PIC X(10) VALUE "MAIN".

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
                        MOVE "PROFILE" TO CURRENT-MENU
                        MOVE 0              TO NAV-INDEX
                        MOVE "SHOW-PROFILE"  TO NAV-ACTION
                        PERFORM NAV-PRINT-LOOP

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

                    WHEN "Create Profile"
                        IF CURRENT-MENU = "PROFILE"
                            MOVE 0         TO NAV-INDEX
                            MOVE "CREATE-PROFILE" TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
                            *> re-display profile menu
                            MOVE 0              TO NAV-INDEX
                            MOVE "SHOW-PROFILE" TO NAV-ACTION
                            PERFORM NAV-PRINT-LOOP
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
