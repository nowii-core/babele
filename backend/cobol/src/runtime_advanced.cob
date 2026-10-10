      * Babele COBOL advanced runtime
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BABELE-RUNTIME-ADVANCED.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-MESSAGE        PIC X(256).
       01 WS-COUNTER        PIC 9(4) COMP.
       01 WS-RESULT         PIC 9(10) COMP.
       01 WS-I              PIC 9(4) COMP.
       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           MOVE "Ciao, mondo!" TO WS-MESSAGE
           DISPLAY WS-MESSAGE
           PERFORM FACTORIAL-CALC
           DISPLAY "Fattoriale di 10: " WS-RESULT
           PERFORM FIBONACCI-CALC
           DISPLAY "Fibonacci di 10: " WS-RESULT
           STOP RUN.
       FACTORIAL-CALC.
           MOVE 1 TO WS-RESULT
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
               MULTIPLY WS-I BY WS-RESULT
           END-PERFORM.
       FIBONACCI-CALC.
           MOVE 0 TO WS-RESULT
           MOVE 0 TO WS-COUNTER
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
               ADD WS-I TO WS-RESULT
           END-PERFORM.
