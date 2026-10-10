-- Runtime di Babele in Ada
with Ada.Text_IO;
with Ada.Strings.Unbounded;

package body Runtime is
   use Ada.Text_IO;

   procedure Print (S : String) is
   begin
      Put_Line (S);
   end Print;

   function Concat (A, B : String) return String is
   begin
      return A & B;
   end Concat;

end Runtime;
