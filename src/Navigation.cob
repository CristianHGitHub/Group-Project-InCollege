*> This is free-form
IDENTIFICATION DIVISION.
PROGRAM-ID. NAVIGATION.

DATA DIVISION.
LINKAGE SECTION.
01  L-ACTION    PIC X(20).   *> BY CONTENT from caller
01  L-INDEX     PIC 99.      *> BY REFERENCE (caller-owned step)
01  L-OUT       PIC X(100).  *> BY REFERENCE
01  L-DONE      PIC X.       *> BY REFERENCE
01  L-MENU      PIC X(15).   *> BY REFERENCE (tracks current menu)

PROCEDURE DIVISION USING L-ACTION L-INDEX L-OUT L-DONE L-MENU.
    MOVE SPACES TO L-OUT
    MOVE FUNCTION TRIM(L-ACTION) TO L-ACTION

    EVALUATE L-ACTION
        WHEN "RESET"
            MOVE 0 TO L-INDEX
            MOVE "Y" TO L-DONE
            MOVE "MAIN" TO L-MENU

        WHEN "SHOW-MENU"
            MOVE "MAIN" TO L-MENU
            PERFORM SHOW-MENU

        WHEN "SHOW-SKILLS"
            MOVE "SKILLS" TO L-MENU
            PERFORM SHOW-SKILLS

        WHEN "SHOW-PROFILE"
            MOVE "PROFILE" TO L-MENU
            PERFORM SHOW-PROFILE

        WHEN "SHOW-CREATE-PROFILE"
            MOVE "CREATE-PROFILE" TO L-MENU
            PERFORM SHOW-CREATE-PROFILE

        WHEN "JOB"
            IF L-MENU = "MAIN"
                MOVE "Job search/internship is under construction." TO L-OUT
            ELSE
                MOVE "Invalid option" TO L-OUT
            END-IF
            MOVE "Y" TO L-DONE

        WHEN "FIND"
            IF L-MENU = "MAIN"
                MOVE "Enter the full name of the person you are looking for:" TO L-OUT
            ELSE
                MOVE "Invalid option" TO L-OUT
            END-IF
            MOVE "Y" TO L-DONE

        WHEN "SKILL-1" THRU "SKILL-5"
            IF L-MENU = "SKILLS"
                MOVE "This skill is under construction." TO L-OUT
            ELSE
                MOVE "Invalid option" TO L-OUT
            END-IF
            MOVE "Y" TO L-DONE

        WHEN "PROFILE"
            IF L-MENU = "MAIN"
                MOVE "PROFILE" TO L-MENU
                PERFORM SHOW-PROFILE
            ELSE
                MOVE "Invalid option" TO L-OUT
            END-IF
            MOVE "Y" TO L-DONE

        WHEN "CREATE-PROFILE"
            IF L-MENU = "PROFILE"
                MOVE "CREATE-PROFILE" TO L-MENU
                PERFORM SHOW-CREATE-PROFILE
            ELSE
                MOVE "Invalid option" TO L-OUT
            END-IF
            MOVE "Y" TO L-DONE

        WHEN "BACK"
            MOVE "MAIN" TO L-MENU
            MOVE 0 TO L-INDEX
            MOVE "SHOW-MENU" TO L-ACTION
            PERFORM SHOW-MENU
            MOVE "Y" TO L-DONE

        WHEN OTHER
            MOVE "Invalid option" TO L-OUT
            MOVE "Y" TO L-DONE
    END-EVALUATE
    GOBACK.

SHOW-MENU.
    MOVE "N" TO L-DONE
    EVALUATE L-INDEX
        WHEN 0  MOVE "Search for a job"      TO L-OUT
        WHEN 1  MOVE "Find someone you know" TO L-OUT
        WHEN 2  MOVE "Learn a new skill"     TO L-OUT
        WHEN 3  MOVE "Create/Edit Profile"   TO L-OUT
        WHEN 4  MOVE "View My Profile"       TO L-OUT
        WHEN 5  MOVE "Requests" TO L-OUT
        WHEN 6  MOVE "View My Network"       TO L-OUT
        WHEN 7  MOVE "Enter your choice:"    TO L-OUT
        WHEN OTHER
            MOVE "Y" TO L-DONE
            MOVE SPACES TO L-OUT
            EXIT PARAGRAPH
    END-EVALUATE
    ADD 1 TO L-INDEX
        END-ADD
    IF L-INDEX > 7
        MOVE "Y" TO L-DONE
    END-IF
    EXIT PARAGRAPH.

SHOW-SKILLS.
    MOVE "N" TO L-DONE
    EVALUATE L-INDEX
        WHEN 0  MOVE "Learn a New Skill:" TO L-OUT
        WHEN 1  MOVE "Skill 1"            TO L-OUT
        WHEN 2  MOVE "Skill 2"            TO L-OUT
        WHEN 3  MOVE "Skill 3"            TO L-OUT
        WHEN 4  MOVE "Skill 4"            TO L-OUT
        WHEN 5  MOVE "Skill 5"            TO L-OUT
        WHEN 6  MOVE "Go Back"            TO L-OUT
        WHEN 7  MOVE "Enter your choice:" TO L-OUT
        WHEN OTHER
            MOVE "Y" TO L-DONE
            MOVE SPACES TO L-OUT
            EXIT PARAGRAPH
    END-EVALUATE
    ADD 1 TO L-INDEX
        END-ADD
    IF L-INDEX > 7
        MOVE "Y" TO L-DONE
    END-IF
    EXIT PARAGRAPH.

SHOW-PROFILE.
    *> No submenu needed for Profile (handled directly in INCOLLEGE)
    MOVE "Y" TO L-DONE
    MOVE SPACES TO L-OUT
    EXIT PARAGRAPH.

SHOW-CREATE-PROFILE.
    MOVE "N" TO L-DONE
    EVALUATE L-INDEX
        WHEN 0  MOVE "=== EDIT/CREATE PROFILE ===" TO L-OUT
        WHEN 1  MOVE "Required Fields:" TO L-OUT
        WHEN 2  MOVE "First Name:" TO L-OUT
        WHEN 3  MOVE "Last Name:" TO L-OUT
        WHEN 4  MOVE "University/College:" TO L-OUT
        WHEN 5  MOVE "Major:" TO L-OUT
        WHEN 6  MOVE "Graduation Year (4 digits):" TO L-OUT
        WHEN 7  MOVE "Optional Fields:" TO L-OUT
        WHEN 8  MOVE "About Me:" TO L-OUT
        WHEN 9  MOVE "Experience (up to 3 entries):" TO L-OUT
        WHEN 10 MOVE "Experience #1 - Title (e.g., Software Intern):" TO L-OUT
        WHEN 11 MOVE "Experience #1 - Company/Organization:" TO L-OUT
        WHEN 12 MOVE "Experience #1 - Dates (e.g., Summer 2024 or Jan 2023 - May 2024):" TO L-OUT
        WHEN 13 MOVE "Experience #1 - Description:" TO L-OUT
        WHEN 14 MOVE "Experience #2 - Title:" TO L-OUT
        WHEN 15 MOVE "Experience #2 - Company/Organization:" TO L-OUT
        WHEN 16 MOVE "Experience #2 - Dates:" TO L-OUT
        WHEN 17 MOVE "Experience #2 - Description:" TO L-OUT
        WHEN 18 MOVE "Experience #3 - Title:" TO L-OUT
        WHEN 19 MOVE "Experience #3 - Company/Organization:" TO L-OUT
        WHEN 20 MOVE "Experience #3 - Dates:" TO L-OUT
        WHEN 21 MOVE "Experience #3 - Description:" TO L-OUT
        WHEN 22 MOVE "Education (up to 3 entries):" TO L-OUT
        WHEN 23 MOVE "Education #1 - Degree (e.g., Bachelor of Science):" TO L-OUT
        WHEN 24 MOVE "Education #1 - University/College:" TO L-OUT
        WHEN 25 MOVE "Education #1 - Years Attended (e.g., 2020-2024):" TO L-OUT
        WHEN 26 MOVE "Education #2 - Degree:" TO L-OUT
        WHEN 27 MOVE "Education #2 - University/College:" TO L-OUT
        WHEN 28 MOVE "Education #2 - Years Attended:" TO L-OUT
        WHEN 29 MOVE "Education #3 - Degree:" TO L-OUT
        WHEN 30 MOVE "Education #3 - University/College:" TO L-OUT
        WHEN 31 MOVE "Education #3 - Years Attended:" TO L-OUT
        WHEN 32 MOVE "Enter your choice:" TO L-OUT
        WHEN OTHER
            MOVE "Y" TO L-DONE
            MOVE SPACES TO L-OUT
            EXIT PARAGRAPH
    END-EVALUATE
    ADD 1 TO L-INDEX
        END-ADD
    IF L-INDEX > 32
        MOVE "Y" TO L-DONE
    END-IF
    EXIT PARAGRAPH.
