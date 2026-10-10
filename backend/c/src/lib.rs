//! Backend C di Babele

use std::fmt::Write;

pub struct CBackend;

impl CBackend {
    pub fn new() -> Self { Self }

    pub fn generate_hello(&self, name: &str) -> String {
        let mut out = String::new();
        writeln!(out, "#include <stdio.h>").unwrap();
        writeln!(out, "").unwrap();
        writeln!(out, "int main(void) {{").unwrap();
        writeln!(out, "    const char* name = \"{}\";", name).unwrap();
        writeln!(out, "    printf(\"Ciao, %s!\\n\", name);").unwrap();
        writeln!(out, "    return 0;").unwrap();
        writeln!(out, "}}").unwrap();
        out
    }
}

impl Default for CBackend {
    fn default() -> Self { Self::new() }
}
