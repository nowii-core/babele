//! Backend COBOL di Babele

pub struct CobolBackend;

impl CobolBackend {
    pub fn new() -> Self { Self }

    pub fn generate_hello(&self, name: &str) -> String {
        format!(
"       IDENTIFICATION DIVISION.
       PROGRAM-ID. HELLO.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 NAME PIC X({}) VALUE \"{}\".

       PROCEDURE DIVISION.
           DISPLAY \"Ciao, \" NAME \"!\".
           STOP RUN.
", name.len(), name)
    }
}

impl Default for CobolBackend {
    fn default() -> Self { Self::new() }
}
