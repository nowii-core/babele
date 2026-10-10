-- Babele Ada advanced runtime
with Ada.Text_IO;
with Ada.Integer_Text_IO;

package body Babele_Runtime_Advanced is

   function Fibonacci (N : Natural) return Natural is
   begin
      if N < 2 then
         return N;
      else
         return Fibonacci (N - 1) + Fibonacci (N - 2);
      end if;
   end Fibonacci;

   function Fattoriale (N : Natural) return Natural is
      Result : Natural := 1;
   begin
      for I in 2 .. N loop
         Result := Result * I;
      end loop;
      return Result;
   end Fattoriale;

   function Is_Primo (N : Natural) return Boolean is
   begin
      if N < 2 then
         return False;
      end if;
      for I in 2 .. Natural (Float'Floor (Float (N) ** 0.5)) loop
         if N mod I = 0 then
            return False;
         end if;
      end loop;
      return True;
   end Is_Primo;

   function MCD (A, B : Natural) return Natural is
   begin
      if B = 0 then
         return A;
      else
         return MCD (B, A mod B);
      end if;
   end MCD;

   procedure Main is
      Msg : constant String := "Ciao, mondo!";
   begin
      Ada.Text_IO.Put_Line (Msg);
      Ada.Integer_Text_IO.Put (Fibonacci (10));
      Ada.Text_IO.New_Line;
      Ada.Integer_Text_IO.Put (Fattoriale (5));
      Ada.Text_IO.New_Line;
   end Main;

end Babele_Runtime_Advanced;
