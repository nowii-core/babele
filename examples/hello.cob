      * Generato da Babele
       IDENTIFICATION DIVISION.
       PROGRAM-ID. HELLO.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 SALUTO PIC X(12) VALUE SPACES.
       01 X PIC X(32) VALUE SPACES.
       01 N PIC X(32) VALUE SPACES.
       01 SOMMA PIC X(32) VALUE SPACES.
       01 I PIC X(32) VALUE SPACES.
       PROCEDURE DIVISION.
                MOVE "Ciao, mondo!" TO SALUTO.
                DISPLAY SALUTO.
                MOVE (40 + 2) TO X.
                DISPLAY X.
                MOVE 10 TO N.
                MOVE 0 TO SOMMA.
                MOVE 1 TO I.
                PERFORM UNTIL (I < N)
                    MOVE (SOMMA + I) TO SOMMA.
                    MOVE (I + 1) TO I.
                END-PERFORM.
                DISPLAY SOMMA.
                IF (SOMMA > 50)
                DISPLAY "Maggiore di 50".
                ELSE
                DISPLAY "Minore o uguale a 50".
                END-IF.
           STOP RUN.
