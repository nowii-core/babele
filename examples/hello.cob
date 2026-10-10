      * Generato da Babele
       IDENTIFICATION DIVISION.
       PROGRAM-ID. HELLO.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 SALUTO PIC X(12).
       PROCEDURE DIVISION.
           MOVE "Ciao, mondo!" TO SALUTO.
           DISPLAY SALUTO.
           STOP RUN.
