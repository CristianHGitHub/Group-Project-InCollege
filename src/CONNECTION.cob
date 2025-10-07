       IDENTIFICATION DIVISION.
       PROGRAM-ID. CONNECTION.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CONNECTION-FILE
               ASSIGN TO "../data/ConnectionRecords.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS CONN-STAT.
           SELECT ESTABLISHED-FILE
               ASSIGN TO "../data/EstablishedConnections.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS EST-STAT.

       DATA DIVISION.
       FILE SECTION.
       FD  CONNECTION-FILE.
       01  CONNECTION-RECORD.
           05  CR-SENDER           PIC X(40).
           05  CR-RECEIVER         PIC X(40).

       FD  ESTABLISHED-FILE.
       01  ESTABLISHED-RECORD.
           05  ER-USER-A          PIC X(40).
           05  ER-USER-B          PIC X(40).

       WORKING-STORAGE SECTION.
       01  CONN-STAT               PIC XX   VALUE SPACES.
       01  EST-STAT                PIC XX   VALUE SPACES.
       01  WS-MSG                  PIC X(120) VALUE SPACES.
       01  WS-ACTION               PIC X(3)  VALUE SPACES.

       *> validation helpers copied from your uploaded file’s approach
       01  WS-EXISTS               PIC X     VALUE "N".
       01  EOF-FLAG                PIC X     VALUE "N".

       LINKAGE SECTION.
       01  L-SENDER                PIC X(40).
       01  L-RECEIVER              PIC X(40).
       01  L-ACTION                PIC X(20).
       01  L-RESPONSE              PIC X(200).

       PROCEDURE DIVISION USING L-SENDER L-RECEIVER L-ACTION L-RESPONSE.

      *> normalize the action like your code: only proceed on YES
           MOVE FUNCTION UPPER-CASE(L-ACTION) TO WS-ACTION.
           MOVE WS-ACTION(1:3)                TO WS-ACTION.

           IF WS-ACTION NOT = "YES"
              MOVE "Connection request canceled." TO L-RESPONSE
              GOBACK
           END-IF.

      *> ========== VALIDATIONS (mirroring your uploaded file) ==========
      *> 1) Disallow self-connection (case/space-insensitive)
           IF FUNCTION UPPER-CASE(FUNCTION TRIM(L-SENDER))
              = FUNCTION UPPER-CASE(FUNCTION TRIM(L-RECEIVER))
              MOVE "You cannot connect with yourself." TO L-RESPONSE
              GOBACK
           END-IF.

      *> 2) Duplicate check in BOTH directions (A->B or B->A already exists)
           PERFORM CHECK-REQUEST-EXISTS
           IF WS-EXISTS = "Y"
              MOVE "You are already connected with this user." TO L-RESPONSE
              GOBACK
           END-IF.
      *> ================================================================

      *>> Try to open for append; create if missing, same behavior as before
           OPEN EXTEND CONNECTION-FILE
           EVALUATE CONN-STAT
             WHEN "00"
               CONTINUE
             WHEN "35"
               OPEN OUTPUT CONNECTION-FILE
               IF CONN-STAT NOT = "00"
                  MOVE "Error: cannot create connection file (status="
                       TO WS-MSG
                  STRING WS-MSG CONN-STAT ")" DELIMITED BY SIZE
                         INTO L-RESPONSE
                  GOBACK
               END-IF
               CLOSE CONNECTION-FILE
               OPEN EXTEND CONNECTION-FILE
               IF CONN-STAT NOT = "00"
                  MOVE "Error: cannot reopen connection file (status="
                       TO WS-MSG
                  STRING WS-MSG CONN-STAT ")" DELIMITED BY SIZE
                         INTO L-RESPONSE
                  GOBACK
               END-IF
             WHEN OTHER
               MOVE "Error: cannot open connection file (status="
                    TO WS-MSG
               STRING WS-MSG CONN-STAT ")" DELIMITED BY SIZE
                      INTO L-RESPONSE
               GOBACK
           END-EVALUATE.

      *>> Write the record once validations pass
           MOVE L-SENDER   TO CR-SENDER
           MOVE L-RECEIVER TO CR-RECEIVER
           WRITE CONNECTION-RECORD

           CLOSE CONNECTION-FILE
           MOVE "Connection Request Sent to New Student" TO L-RESPONSE

           GOBACK.

      *>> ===================== SUPPORT PARAGRAPHS =======================

       CHECK-REQUEST-EXISTS.
           MOVE "N" TO WS-EXISTS
           PERFORM CHECK-PENDING-DUPLICATES
           IF WS-EXISTS = "Y"
              EXIT PARAGRAPH
           END-IF

           PERFORM CHECK-ESTABLISHED-DUPLICATES
           EXIT PARAGRAPH.

       CHECK-PENDING-DUPLICATES.
           MOVE "N" TO EOF-FLAG

           OPEN INPUT CONNECTION-FILE
           IF CONN-STAT = "35"
              EXIT PARAGRAPH
           END-IF
           IF CONN-STAT NOT = "00"
              EXIT PARAGRAPH
           END-IF

           PERFORM UNTIL EOF-FLAG = "Y"
              READ CONNECTION-FILE
                 AT END
                    MOVE "Y" TO EOF-FLAG
                 NOT AT END
                    PERFORM COMPARE-PAIR
              END-READ
           END-PERFORM

           CLOSE CONNECTION-FILE
           MOVE "N" TO EOF-FLAG
           EXIT PARAGRAPH.

       CHECK-ESTABLISHED-DUPLICATES.
           MOVE "N" TO EOF-FLAG

           OPEN INPUT ESTABLISHED-FILE
           IF EST-STAT = "35"
              EXIT PARAGRAPH
           END-IF
           IF EST-STAT NOT = "00"
              EXIT PARAGRAPH
           END-IF

           PERFORM UNTIL EOF-FLAG = "Y"
              READ ESTABLISHED-FILE INTO ESTABLISHED-RECORD
                 AT END
                    MOVE "Y" TO EOF-FLAG
                 NOT AT END
                    PERFORM COMPARE-ESTABLISHED
              END-READ
           END-PERFORM

           CLOSE ESTABLISHED-FILE
           MOVE "N" TO EOF-FLAG
           EXIT PARAGRAPH.

       COMPARE-PAIR.
           IF FUNCTION UPPER-CASE(FUNCTION TRIM(CR-SENDER)) =
              FUNCTION UPPER-CASE(FUNCTION TRIM(L-SENDER))
              AND
              FUNCTION UPPER-CASE(FUNCTION TRIM(CR-RECEIVER)) =
              FUNCTION UPPER-CASE(FUNCTION TRIM(L-RECEIVER))
              MOVE "Y" TO WS-EXISTS
              MOVE "Y" TO EOF-FLAG
           ELSE
              IF FUNCTION UPPER-CASE(FUNCTION TRIM(CR-SENDER)) =
                 FUNCTION UPPER-CASE(FUNCTION TRIM(L-RECEIVER))
                 AND
                 FUNCTION UPPER-CASE(FUNCTION TRIM(CR-RECEIVER)) =
                 FUNCTION UPPER-CASE(FUNCTION TRIM(L-SENDER))
                 MOVE "Y" TO WS-EXISTS
                 MOVE "Y" TO EOF-FLAG
              END-IF
           END-IF
           EXIT PARAGRAPH.

       COMPARE-ESTABLISHED.
           IF FUNCTION UPPER-CASE(FUNCTION TRIM(ER-USER-A)) =
              FUNCTION UPPER-CASE(FUNCTION TRIM(L-SENDER))
              AND
              FUNCTION UPPER-CASE(FUNCTION TRIM(ER-USER-B)) =
              FUNCTION UPPER-CASE(FUNCTION TRIM(L-RECEIVER))
              MOVE "Y" TO WS-EXISTS
              MOVE "Y" TO EOF-FLAG
           ELSE
              IF FUNCTION UPPER-CASE(FUNCTION TRIM(ER-USER-A)) =
                 FUNCTION UPPER-CASE(FUNCTION TRIM(L-RECEIVER))
                 AND
                 FUNCTION UPPER-CASE(FUNCTION TRIM(ER-USER-B)) =
                 FUNCTION UPPER-CASE(FUNCTION TRIM(L-SENDER))
                 MOVE "Y" TO WS-EXISTS
                 MOVE "Y" TO EOF-FLAG
              END-IF
           END-IF
           EXIT PARAGRAPH.
