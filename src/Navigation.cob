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

        WHEN "JOB"
            IF L-MENU = "MAIN"
                MOVE "Job search/internship is under construction." TO L-OUT
            ELSE
                MOVE "Invalid option" TO L-OUT
            END-IF
            MOVE "Y" TO L-DONE

        WHEN "FIND"
            IF L-MENU = "MAIN"
                MOVE "Find someone you know is under construction." TO L-OUT
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

        WHEN "ADD-EXPERIENCE"
            IF L-MENU = "CREATE-PROFILE"
                MOVE "EXPERIENCE" TO L-MENU
                PERFORM SHOW-EXPERIENCE-PROMPTS
            ELSE
                MOVE "Invalid option" TO L-OUT
            END-IF
            MOVE "Y" TO L-DONE

        WHEN "ADD-EDUCATION"
            IF L-MENU = "CREATE-PROFILE"
                MOVE "EDUCATION" TO L-MENU
                PERFORM SHOW-EDUCATION-PROMPTS
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
        WHEN 4  MOVE "Enter your choice:"    TO L-OUT
        WHEN OTHER
            MOVE "Y" TO L-DONE
            MOVE SPACES TO L-OUT
            GOBACK
    END-EVALUATE
    ADD 1 TO L-INDEX
    IF L-INDEX > 4
        MOVE "Y" TO L-DONE
    END-IF
.

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
            GOBACK
    END-EVALUATE
    ADD 1 TO L-INDEX
    IF L-INDEX > 7
        MOVE "Y" TO L-DONE
    END-IF
.

SHOW-PROFILE.
    MOVE "N" TO L-DONE
    EVALUATE L-INDEX
        WHEN 0  MOVE "Profile Management:" TO L-OUT
        WHEN 1  MOVE "Create New Profile" TO L-OUT
        WHEN 2  MOVE "Edit Existing Profile" TO L-OUT
        WHEN 3  MOVE "Go Back"           TO L-OUT
        WHEN 4  MOVE "Enter your choice:" TO L-OUT
        WHEN OTHER
            MOVE "Y" TO L-DONE
            MOVE SPACES TO L-OUT
            GOBACK
    END-EVALUATE
    ADD 1 TO L-INDEX
    IF L-INDEX > 4
        MOVE "Y" TO L-DONE
    END-IF
.

SHOW-CREATE-PROFILE.
    MOVE "N" TO L-DONE
    EVALUATE L-INDEX
        WHEN 0  MOVE "=== CREATE PROFILE ===" TO L-OUT
        WHEN 1  MOVE "Required Fields:" TO L-OUT
        WHEN 2  MOVE "1. First Name (Required)" TO L-OUT
        WHEN 3  MOVE "2. Last Name (Required)" TO L-OUT
        WHEN 4  MOVE "3. University/College (Required)" TO L-OUT
        WHEN 5  MOVE "4. Major (Required)" TO L-OUT
        WHEN 6  MOVE "5. Graduation Year (Required - 4 digits)" TO L-OUT
        WHEN 7  MOVE "Optional Fields:" TO L-OUT
        WHEN 8  MOVE "6. About Me (Optional)" TO L-OUT
        WHEN 9  MOVE "7. Experience (Optional - up to 3 entries)" TO L-OUT
        WHEN 10 MOVE "   - Title (e.g., Software Intern)" TO L-OUT
        WHEN 11 MOVE "   - Company/Organization" TO L-OUT
        WHEN 12 MOVE "   - Dates (e.g., Summer 2024)" TO L-OUT
        WHEN 13 MOVE "   - Description (Optional)" TO L-OUT
        WHEN 14 MOVE "8. Education (Optional - up to 3 entries)" TO L-OUT
        WHEN 15 MOVE "   - Degree (e.g., Master of Science)" TO L-OUT
        WHEN 16 MOVE "   - University/College" TO L-OUT
        WHEN 17 MOVE "   - Years Attended (e.g., 2023-2025)" TO L-OUT
        WHEN 18 MOVE "Enter your choice:" TO L-OUT
        WHEN OTHER
            MOVE "Y" TO L-DONE
            MOVE SPACES TO L-OUT
            GOBACK
    END-EVALUATE
    ADD 1 TO L-INDEX
    IF L-INDEX > 18
        MOVE "Y" TO L-DONE
    END-IF
.

SHOW-EXPERIENCE-PROMPTS.
    MOVE "N" TO L-DONE
    EVALUATE L-INDEX
        WHEN 0  MOVE "=== ADD EXPERIENCE ===" TO L-OUT
        WHEN 1  MOVE "Experience Entry (up to 3 total):" TO L-OUT
        WHEN 2  MOVE "1. Job Title:" TO L-OUT
        WHEN 3  MOVE "   (e.g., Software Intern, Marketing Assistant)" TO L-OUT
        WHEN 4  MOVE "2. Company/Organization:" TO L-OUT
        WHEN 5  MOVE "   (e.g., Tech Solutions Inc., ABC Corp)" TO L-OUT
        WHEN 6  MOVE "3. Dates:" TO L-OUT
        WHEN 7  MOVE "   (e.g., Summer 2024, Jan 2023 - May 2024)" TO L-OUT
        WHEN 8  MOVE "4. Description (Optional):" TO L-OUT
        WHEN 9  MOVE "   (Responsibilities, achievements, etc.)" TO L-OUT
        WHEN 10 MOVE "Enter your choice:" TO L-OUT
        WHEN OTHER
            MOVE "Y" TO L-DONE
            MOVE SPACES TO L-OUT
            GOBACK
    END-EVALUATE
    ADD 1 TO L-INDEX
    IF L-INDEX > 10
        MOVE "Y" TO L-DONE
    END-IF
.

SHOW-EDUCATION-PROMPTS.
    MOVE "N" TO L-DONE
    EVALUATE L-INDEX
        WHEN 0  MOVE "=== ADD EDUCATION ===" TO L-OUT
        WHEN 1  MOVE "Education Entry (up to 3 total):" TO L-OUT
        WHEN 2  MOVE "1. Degree:" TO L-OUT
        WHEN 3  MOVE "   (e.g., Master of Science, Bachelor of Arts)" TO L-OUT
        WHEN 4  MOVE "2. University/College:" TO L-OUT
        WHEN 5  MOVE "   (e.g., State University, Community College)" TO L-OUT
        WHEN 6  MOVE "3. Years Attended:" TO L-OUT
        WHEN 7  MOVE "   (e.g., 2023-2025, 2020-2024)" TO L-OUT
        WHEN 8  MOVE "Enter your choice:" TO L-OUT
        WHEN OTHER
            MOVE "Y" TO L-DONE
            MOVE SPACES TO L-OUT
            GOBACK
    END-EVALUATE
    ADD 1 TO L-INDEX
    IF L-INDEX > 8
        MOVE "Y" TO L-DONE
    END-IF
.
