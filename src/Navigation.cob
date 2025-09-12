*> This is free-form
IDENTIFICATION DIVISION.
PROGRAM-ID. NAVIGATION.

DATA DIVISION.
LINKAGE SECTION.
01  L-ACTION    PIC X(20).   *> BY CONTENT from caller
01  L-INDEX     PIC 9.       *> BY REFERENCE (caller-owned step)
01  L-OUT       PIC X(100).  *> BY REFERENCE
01  L-DONE      PIC X.       *> BY REFERENCE
01  L-MENU      PIC X(10).   *> BY REFERENCE (tracks current menu)

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
        WHEN 9  MOVE "Enter your choice:" TO L-OUT
        WHEN OTHER
            MOVE "Y" TO L-DONE
            MOVE SPACES TO L-OUT
            GOBACK
    END-EVALUATE
    ADD 1 TO L-INDEX
    IF L-INDEX > 9
        MOVE "Y" TO L-DONE
    END-IF
.
