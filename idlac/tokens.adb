--  idlac: IDL to Ada compiler.
--  Copyright (C) 1999 Tristan Gingold.
--
--  emails: gingold@enst.fr
--          adabroker@adabroker.eu.org
--
--  IDLAC is free software;  you can  redistribute it and/or modify it under
--  terms of the  GNU General Public License as published  by the Free Software
--  Foundation;  either version 2,  or (at your option) any later version.
--  IDLAC is distributed in the hope that it will be useful, but WITHOUT ANY
--  WARRANTY;  without even the  implied warranty of MERCHANTABILITY
--  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
--  for  more details.  You should have  received  a copy of the GNU General
--  Public License  distributed with IDLAC;  see file COPYING.  If not, write
--  to  the Free Software Foundation,  59 Temple Place - Suite 330,  Boston,
--  MA 02111-1307, USA.
--

with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Characters.Latin_1; use Ada.Characters.Latin_1;
with Ada.Characters.Handling;
with GNAT.Case_Util;
with GNAT.OS_Lib;
with Types; use Types;
with Errors;

package body Tokens is

   -----------------------------------
   --  low level string processing  --
   -----------------------------------

   --  The current token, set by next_token.
   Current_Token : Idl_Token := T_Error;

   --  The current location in the parsed file
   Current_Location : Errors.Location;

   --  The current_token location
   Current_Token_Location : Errors.Location;

   --  The length of the current line
   Current_Line_Len : Natural;

   --  The current line in the parsed file
   Line : String (1 .. 2047);

   --  The current offset on the line. (The offset is due to
   --  tabulations)
   Offset : Natural;

   --  The current position of the mark in the line. The mark
   --  is used to memorize the begining of an identifier for
   --  example.
   Mark_Pos : Natural;

   -------------------------
   --  Set_Token_Location --
   -------------------------
   procedure Set_Token_Location is
   begin
      Current_Token_Location.Filename := Current_Location.Filename;
      Current_Token_Location.Line := Current_Location.Line;
      Current_Token_Location.Col := Current_Location.Col + Offset - Line'First;
   end Set_Token_Location;

   ------------------------
   --  Get_Real_Location --
   ------------------------
   function Get_Real_Location return Errors.Location is
   begin
      return (Filename => Current_Location.Filename,
              Line => Current_Location.Line,
              Col => Current_Location.Col + Offset - Line'First);
   end Get_Real_Location;

   ----------------
   --  Read_Line --
   ----------------
   procedure Read_Line is
   begin
      --  Get next line and append a LF at the end.
      Ada.Text_IO.Get_Line (Line, Current_Line_Len);
      Current_Line_Len := Current_Line_Len + 1;
      Line (Current_Line_Len) := LF;
      Current_Location.Line := Current_Location.Line + 1;
      Current_Location.Col := Line'First;
      Offset := 0;
      Mark_Pos := Current_Location.Col;
   end Read_Line;

   -----------------
   --  Skip_Char  --
   -----------------
   procedure Skip_Char is
   begin
      Current_Location.Col := Current_Location.Col + 1;
      if Current_Location.Col > Current_Line_Len then
         Read_Line;
      end if;
   end Skip_Char;

   ----------------
   --  Skip_Line --
   ----------------
   procedure Skip_Line is
   begin
      Read_Line;
      Current_Location.Col := Current_Location.Col - 1;
   end Skip_Line;

   -----------------
   --  Next_Char  --
   -----------------
   function Next_Char return Character is
   begin
      Skip_Char;
      return Line (Current_Location.Col);
   end Next_Char;

   ----------------------
   --  View_Next_Char  --
   ----------------------
   function View_Next_Char return Character is
   begin
      if Current_Location.Col = Current_Line_Len then
         return LF;
      else
         return Line (Current_Location.Col + 1);
      end if;
   end View_Next_Char;

   ---------------------------
   --  View_Next_Next_Char  --
   ---------------------------
   function View_Next_Next_Char return Character is
   begin
      if Current_Location.Col > Current_Line_Len - 2 then
         return LF;
      else
         return Line (Current_Location.Col + 2);
      end if;
   end View_Next_Next_Char;

   ------------------------
   --  Get_Current_Char  --
   ------------------------
   function Get_Current_Char return Character is
   begin
      return Line (Current_Location.Col);
   end Get_Current_Char;

   ----------------------
   --  Refresh_Offset  --
   ----------------------
   procedure Refresh_Offset is
   begin
      Offset := Offset + 8 - (Current_Location.Col + Offset) mod 8;
   end Refresh_Offset;

   -------------------
   --  Skip_Spaces  --
   -------------------
   procedure Skip_Spaces is
   begin
      loop
         case View_Next_Char is
            when Space | CR | VT | FF | HT =>
               Skip_Char;
            when others =>
               return;
         end case;
      end loop;
   end Skip_Spaces;

   -------------------
   --  Skip_Comment --
   -------------------
   procedure Skip_Comment is
   begin
      loop
         while Next_Char /= '*' loop
            null;
         end loop;
         if Next_Char = '/' then
            return;
         end if;
      end loop;
   end Skip_Comment;

   ----------------
   --  Set_Mark  --
   ----------------
   procedure Set_Mark is
   begin
      Mark_Pos := Current_Location.Col;
   end Set_Mark;

   -----------------------
   --  Get_Marked_Text  --
   -----------------------
   function Get_Marked_Text return String is
   begin
      return Line (Mark_Pos .. Current_Location.Col);
   end Get_Marked_Text;

   -------------------------
   --  Go_To_End_Of_Char  --
   -------------------------
   procedure Go_To_End_Of_Char is
   begin
      while View_Next_Char /= '''
        and View_Next_Char /= LF loop
         Skip_Char;
      end loop;
   end Go_To_End_Of_Char;

   ---------------------------
   --  Go_To_End_Of_String  --
   ---------------------------
   procedure Go_To_End_Of_String is
   begin
      while View_Next_Char /= Quotation loop
         Skip_Char;
      end loop;
      Skip_Char;
   end Go_To_End_Of_String;


   ---------------------------------
   --  low level char processing  --
   ---------------------------------

   -------------------------------
   --  Is_Alphabetic_Character  --
   -------------------------------
   function Is_Alphabetic_Character (C : Standard.Character) return Boolean is
   begin
      case C is
         when 'A' .. 'Z'
           | LC_A .. LC_Z
           | UC_A_Grave .. UC_I_Diaeresis
           | LC_A_Grave .. LC_I_Diaeresis
           | UC_N_Tilde .. UC_O_Diaeresis
           | LC_N_Tilde .. LC_O_Diaeresis
           | UC_O_Oblique_Stroke .. UC_U_Diaeresis
           | LC_O_Oblique_Stroke .. LC_U_Diaeresis
           | LC_German_Sharp_S
           | LC_Y_Diaeresis =>
            return True;
         when others =>
            return False;
      end case;
   end Is_Alphabetic_Character;

   --------------------------
   --  Is_Digit_Character  --
   --------------------------
   function Is_Digit_Character (C : Standard.Character) return Boolean is
   begin
      case C is
         when '0' .. '9' =>
            return True;
         when others =>
            return False;
      end case;
   end Is_Digit_Character;

   --------------------------------
   --  Is_Octal_Digit_Character  --
   --------------------------------
   function Is_Octal_Digit_Character (C : Standard.Character) return Boolean is
   begin
      case C is
         when '0' .. '7' =>
            return True;
         when others =>
            return False;
      end case;
   end Is_Octal_Digit_Character;

   -------------------------------
   --  Is_Hexa_Digit_Character  --
   -------------------------------
   function Is_Hexa_Digit_Character (C : Standard.Character) return Boolean is
   begin
      case C is
         when '0' .. '9' | 'A' .. 'F' | LC_A .. LC_F =>
            return True;
         when others =>
            return False;
      end case;
   end Is_Hexa_Digit_Character;

   -------------------------------
   --  Is_Identifier_Character  --
   -------------------------------
   function Is_Identifier_Character (C : Standard.Character) return Boolean is
   begin
      case C is
         when 'A' .. 'Z'
           | LC_A .. LC_Z
           | UC_A_Grave .. UC_I_Diaeresis
           | LC_A_Grave .. LC_I_Diaeresis
           | UC_N_Tilde .. UC_O_Diaeresis
           | LC_N_Tilde .. LC_O_Diaeresis
           | UC_O_Oblique_Stroke .. UC_U_Diaeresis
           | LC_O_Oblique_Stroke .. LC_U_Diaeresis
           | LC_German_Sharp_S
           | LC_Y_Diaeresis
           | Low_Line
           | '0' .. '9'
           | ''' =>
            return True;
         when others =>
            return False;
      end case;
   end Is_Identifier_Character;


   -----------------------------
   --  idl string processing  --
   -----------------------------

   ----------------------------
   --  Idl_Identifier_Equal  --
   ----------------------------
   function Idl_Identifier_Equal (Left, Right : String)
                                  return Ident_Equality is
      use GNAT.Case_Util;
   begin
      if Left'Length /= Right'Length then
         return Differ;
      end if;
      for I in Left'Range loop
         if To_Lower (Left (I))
           /= To_Lower (Right (Right'First + I - Left'First))
         then
            return Differ;
         end if;
      end loop;
      if Left /= Right then
         return Case_Differ;
      else
         return Equal;
      end if;
   end Idl_Identifier_Equal;

   ----------------------
   --  Is_Idl_Keyword  --
   ----------------------
   procedure Is_Idl_Keyword (S : in String;
                             Is_A_Keyword : out Idl_Keyword_State;
                             Tok : out Idl_Token) is
      Result : Ident_Equality;
      Pos : Natural := 0;
   begin
      for I in All_Idl_Keywords'Range loop
         Pos := Pos + 1;
         Result := Idl_Identifier_Equal (S, All_Idl_Keywords (I).all);
         case Result is
            when Differ =>
               null;
            when Case_Differ =>
               Is_A_Keyword := Idl_Keyword_State (Bad_Case);
               Tok := Idl_Token'Val (Pos);
               return;
            when Equal =>
               Is_A_Keyword := Idl_Keyword_State (Is_Keyword);
               Tok := Idl_Token'Val (Pos);
               return;
         end case;
      end loop;
      Is_A_Keyword := Idl_Keyword_State (Is_Identifier);
      Tok := Idl_Token (T_Error);
      return;
   end Is_Idl_Keyword;


   ----------------------------------------
   --  scanners for chars, identifiers,  --
   --    numeric, string literals and    --
   --      preprocessor directives.      --
   ----------------------------------------

   -----------------
   --  Scan_Char  --
   -----------------
   function Scan_Char return Idl_Token is
   begin
      if Next_Char = '\' then
         Set_Mark;
         case View_Next_Char is
            when 'n' | 't' | 'v' | 'b' | 'r' | 'f'
              | 'a' | '\' | '?' | Quotation =>
               Skip_Char;
               return T_Lit_Escape_Char;
            when ''' =>
               if View_Next_Next_Char /= ''' then
                  Errors.Lexer_Error ("Invalid character : '\', "
                                      & "it should probably be '\\'",
                                      Errors.Error,
                                      Get_Real_Location);
                  return T_Error;
               else
                  Skip_Char;
                  return T_Lit_Escape_Char;
               end if;
            when '0' .. '7' =>
               Skip_Char;
               if Is_Octal_Digit_Character (View_Next_Char) then
                  Skip_Char;
               end if;
               if Is_Octal_Digit_Character (View_Next_Char) then
                  Skip_Char;
               end if;
               if Is_Octal_Digit_Character (View_Next_Char) then
                  Go_To_End_Of_Char;
                  Errors.Lexer_Error ("Too much octal digits in "
                                      & "character "
                                      & Get_Marked_Text
                                      & ", maximum is 3 in a char "
                                      & "definition",
                                      Errors.Error,
                                      Get_Real_Location);
                  --  skip the '
                  Skip_Char;
                  return T_Error;
               else
                  return T_Lit_Octal_Char;
               end if;
            when 'x' =>
               Skip_Char;
               if Is_Hexa_Digit_Character (Next_Char) then
                  if Is_Hexa_Digit_Character (View_Next_Char) then
                     Skip_Char;
                  end if;
                  if Is_Hexa_Digit_Character (View_Next_Char) then
                     Go_To_End_Of_Char;
                     Errors.Lexer_Error ("Too much hexadecimal digits in "
                                         & "character "
                                         & Get_Marked_Text
                                         & ", maximum is 2 in a char "
                                         & "definition",
                                         Errors.Error,
                                         Get_Real_Location);
                     --  skip the '
                     Skip_Char;
                     return T_Error;
                  else
                     return T_Lit_Hexa_Char;
                  end if;
               else
                  Go_To_End_Of_Char;
                  Errors.Lexer_Error ("Invalid hexadecimal character code : "
                                      & Get_Marked_Text,
                                      Errors.Error,
                                      Get_Real_Location);
                  --  skip the '
                  Skip_Char;
                  return T_Error;
               end if;
            when 'u' =>
               Skip_Char;
               if Is_Hexa_Digit_Character (Next_Char) then
                  if Is_Hexa_Digit_Character (View_Next_Char) then
                     Skip_Char;
                  end if;
                  if Is_Hexa_Digit_Character (View_Next_Char) then
                     Skip_Char;
                  end if;
                  if Is_Hexa_Digit_Character (View_Next_Char) then
                     Skip_Char;
                  end if;
                  if Is_Hexa_Digit_Character (View_Next_Char) then
                     Go_To_End_Of_Char;
                     Errors.Lexer_Error ("Too much hexadecimal digits in "
                                         & "character "
                                         & Get_Marked_Text
                                         & ", maximum is 4 in a unicode "
                                         & "char definition",
                                         Errors.Error,
                                         Get_Real_Location);
                     --  skip the '
                     Skip_Char;
                     return T_Error;
                  else
                     return T_Lit_Unicode_Char;
                  end if;
               else
                  Go_To_End_Of_Char;
                  Errors.Lexer_Error ("Invalid unicode character code : "
                                      & Get_Marked_Text,
                                      Errors.Error,
                                      Get_Real_Location);
                  --  skip the '
                  Skip_Char;
                  return T_Error;
               end if;
            when '8' | '9' | 'A' .. 'F' | LC_C .. LC_E =>
               Go_To_End_Of_Char;
               Errors.Lexer_Error ("Invalid octal character code : "
                                   & Get_Marked_Text
                                   & ". For hexadecimal codes, use \xhh",
                                   Errors.Error,
                                   Get_Real_Location);
               --  skip the '
               Skip_Char;
               return T_Error;
            when others =>
               Go_To_End_Of_Char;
               Errors.Lexer_Error ("Invalid definition of character : "
                                   & Get_Marked_Text,
                                   Errors.Error,
                                   Get_Real_Location);
               --  skip the '
               Skip_Char;
               return T_Error;
         end case;
      elsif Get_Current_Char = ''' then
         Set_Mark;
         if View_Next_Char = ''' then
            Errors.Lexer_Error ("Invalid character : ''', "
                                & "it should probably be '\''",
                                Errors.Error,
                                Get_Real_Location);
            return T_Error;
         else
            return T_Lit_Simple_Char;
         end if;
      else
         Set_Mark;
         return T_Lit_Simple_Char;
      end if;
      if Next_Char /= ''' then
         Go_To_End_Of_Char;
         Errors.Lexer_Error ("Invalid character : "
                             & Get_Marked_Text,
                             Errors.Error,
                             Get_Real_Location);
         --  skip the '
         Skip_Char;
         return T_Error;
      end if;
      raise Errors.Internal_Error;
   end Scan_Char;


   -------------------
   --  Scan_String  --
   -------------------
   function Scan_String return Idl_Token is
      Several_Lines : Boolean := False;
   begin
      Set_Mark;
      loop
         case Next_Char is
            when Quotation =>
               if View_Next_Char = Quotation then
                  Skip_Char;
               else
                  return T_Lit_String;
               end if;
            when '\' =>
               case View_Next_Char is
                  when LC_N | LC_T | LC_V | LC_B | LC_R
                    | LC_F | LC_A | '\' | '?' | ''' | Quotation =>
                     Skip_Char;
                  when '0' =>
                     if Is_Octal_Digit_Character
                       (View_Next_Next_Char) then
                        Skip_Char;
                     else
                        Go_To_End_Of_String;
                        Errors.Lexer_Error
                          ("A string literal may not contain"
                           & " the character '\0'",
                           Errors.Error,
                           Get_Real_Location);
                        return T_Error;
                     end if;
                  when '1' .. '7' =>
                     Skip_Char;
                  when LC_X =>
                     if Is_Hexa_Digit_Character
                       (View_Next_Next_Char) then
                        Skip_Char;
                     else
                        Go_To_End_Of_String;
                        Errors.Lexer_Error
                          ("bad hexadecimal character in string",
                           Errors.Error,
                           Get_Real_Location);
                        return T_Error;
                     end if;
                  when LC_U =>
                     if Is_Hexa_Digit_Character
                       (View_Next_Next_Char) then
                        Skip_Char;
                     else
                        Go_To_End_Of_String;
                        Errors.Lexer_Error
                          ("bad unicode character in string",
                           Errors.Error,
                           Get_Real_Location);
                        return T_Error;
                     end if;
                  when others =>
                     Go_To_End_Of_String;
                     Errors.Lexer_Error
                       ("bad escape sequence in string",
                        Errors.Error,
                        Get_Real_Location);
                     return T_Error;
               end case;
            when LF =>
               if Several_Lines = False then
                  Errors.Lexer_Error
                    ("This String goes over several lines",
                     Errors.Warning,
                     Get_Real_Location);
                  Several_Lines := True;
               end if;
            when others =>
               null;
         end case;
      end loop;
   exception
      when Ada.Text_IO.End_Error =>
         Errors.Lexer_Error ("unexpected end of file in the middle "
                             & "of a string, you probably forgot the "
                             & Quotation
                             & " at the end of a string",
                             Errors.Fatal,
                             Get_Real_Location);
         --  This last line will never be reached
         raise Errors.Fatal_Error;
   end Scan_String;


   -----------------------
   --  Scan_Identifier  --
   -----------------------
   function Scan_Identifier return Idl_Token is
      Is_A_Keyword : Idl_Keyword_State;
      Tok : Idl_Token;
   begin
      Set_Mark;
      if Get_Current_Char = 'L'
        and View_Next_Char = ''' then
         Skip_Char;
         case Scan_Char is
            when T_Lit_Simple_Char =>
               return T_Lit_Wide_Simple_Char;
            when T_Lit_Escape_Char =>
               return T_Lit_Wide_Escape_Char;
            when T_Lit_Octal_Char =>
               return T_Lit_Wide_Octal_Char;
            when T_Lit_Hexa_Char =>
               return T_Lit_Wide_Hexa_Char;
            when T_Lit_Unicode_Char =>
               return T_Lit_Wide_Unicode_Char;
            when T_Error  =>
               return T_Error;
            when others =>
               raise Errors.Internal_Error;
         end case;
      elsif Get_Current_Char = 'L'
        and View_Next_Char = Quotation then
         Skip_Char;
         case Scan_String is
            when T_Lit_String =>
               return T_Lit_Wide_String;
            when T_Error  =>
               return T_Error;
            when others =>
               raise Errors.Internal_Error;
         end case;
      else
         while Is_Identifier_Character (View_Next_Char)
         loop
            Skip_Char;
         end loop;
         Is_Idl_Keyword (Get_Marked_Text,
                         Is_A_Keyword,
                         Tok);
         case Is_A_Keyword is
            when Idl_Keyword_State (Is_Keyword) =>
               return Tok;
            when Idl_Keyword_State (Is_Identifier) =>
               return T_Identifier;
            when Idl_Keyword_State (Bad_Case) =>
               Errors.Lexer_Error ("Bad identifier or bad case"
                                   & "for idl keyword."
                                   & " I Supposed you meant the keyword.",
                                   Errors.Error,
                                   Get_Real_Location);
               return Tok;
         end case;
      end if;
   end Scan_Identifier;


   --------------------
   --  Scan_Numeric  --
   --------------------
   function Scan_Numeric return Idl_Token is
   begin
      Set_Mark;
      if Get_Current_Char = '0' and then View_Next_Char /= '.' then
         if View_Next_Char = 'x' or View_Next_Char = 'X' then
            Skip_Char;
            while Is_Hexa_Digit_Character (View_Next_Char) loop
               Skip_Char;
            end loop;
            return T_Lit_Hexa_Integer;
         elsif Is_Octal_Digit_Character (View_Next_Char) then
            while Is_Octal_Digit_Character (View_Next_Char) loop
               Skip_Char;
            end loop;
            return T_Lit_Octal_Integer;
         else
            --  This is only a digit.
            return T_Lit_Decimal_Integer;
         end if;
      else
         if Get_Current_Char /= '.' then
            while Is_Digit_Character (View_Next_Char) loop
               Skip_Char;
            end loop;
         end if;
         if Get_Current_Char /= '.' and View_Next_Char = '.' then
            Skip_Char;
         end if;
         if Get_Current_Char = '.' then
            while Is_Digit_Character (View_Next_Char) loop
               Skip_Char;
            end loop;
            if View_Next_Char = 'D' or else View_Next_Char = 'd' then
               Skip_Char;
               return T_Lit_Floating_Fixed_Point;
            elsif View_Next_Char = 'E' or else View_Next_Char = 'e' then
               Skip_Char;
               if View_Next_Char = '+' or else View_Next_Char = '-' then
                  Skip_Char;
               end if;
               while Is_Digit_Character (View_Next_Char) loop
                  Skip_Char;
               end loop;
               return T_Lit_Exponent_Floating_Point;
            else
               return T_Lit_Simple_Floating_Point;
            end if;
         elsif View_Next_Char = 'E' or else View_Next_Char = 'e' then
            Skip_Char;
            if View_Next_Char = '+' or else View_Next_Char = '-' then
               Skip_Char;
            end if;
            while Is_Digit_Character (View_Next_Char) loop
               Skip_Char;
            end loop;
            return T_Lit_Pure_Exponent_Floating_Point;
         elsif View_Next_Char = 'D' or else View_Next_Char = 'd' then
            Skip_Char;
            return T_Lit_Simple_Fixed_Point;
         else
            return T_Lit_Decimal_Integer;
         end if;
      end if;
   end Scan_Numeric;


   -----------------------
   --  Scan_Underscore  --
   -----------------------
   function Scan_Underscore return Idl_Token is
   begin
      if Is_Alphabetic_Character (View_Next_Char) then
         Skip_Char;
         return Scan_Identifier;
         if Current_Token = T_Identifier then
            Errors.Lexer_Error
              ("Invalid identifier name. An identifier cannot begin" &
               " with '_', except if the end is an idl keyword",
               Errors.Error,
               Get_Real_Location);
            return T_Error;
         else
            return T_Identifier;
         end if;
      else
         Errors.Lexer_Error ("Invalid character '_'",
                             Errors.Error,
                             Get_Real_Location);
         return T_Error;
      end if;
   end Scan_Underscore;


   -------------------------
   --  Scan_Preprocessor  --
   -------------------------
   function Scan_Preprocessor return Boolean is
      use Ada.Characters.Handling;
   begin
      Skip_Spaces;
      case View_Next_Char is
         when 'A' .. 'Z'
           | LC_A .. LC_Z
           | UC_A_Grave .. UC_I_Diaeresis
           | LC_A_Grave .. LC_I_Diaeresis
           | UC_N_Tilde .. UC_O_Diaeresis
           | LC_N_Tilde .. LC_O_Diaeresis
           | UC_O_Oblique_Stroke .. UC_U_Diaeresis
           | LC_O_Oblique_Stroke .. LC_U_Diaeresis
           | LC_German_Sharp_S
           | LC_Y_Diaeresis =>
            --  This is a preprocessor directive
            Skip_Char;
            Set_Mark;
            while Is_Identifier_Character (View_Next_Char)
            loop
               Skip_Char;
            end loop;
            if To_Lower (Get_Marked_Text) = "if"
                 or To_Lower (Get_Marked_Text) = "elif"
                 or To_Lower (Get_Marked_Text) = "else"
                 or To_Lower (Get_Marked_Text) = "endif"
                 or To_Lower (Get_Marked_Text) = "define"
                 or To_Lower (Get_Marked_Text) = "undef"
                 or To_Lower (Get_Marked_Text) = "ifdef"
                 or To_Lower (Get_Marked_Text) = "ifndef"
                 or To_Lower (Get_Marked_Text) = "include"
                 or To_Lower (Get_Marked_Text) = "error" then
               Errors.Lexer_Error
                 ("cannot handle preprocessor directive in "
                  & "lexer, use -p",  --  FIXME : -p ???
                  Errors.Error,
                  Get_Real_Location);
               Skip_Line;
            elsif To_Lower (Get_Marked_Text) = "pragma" then
               Skip_Spaces;
               Skip_Char;
               Set_Mark;
               while View_Next_Char /= LF loop
                  Skip_Char;
               end loop;
               return True;
            else
               Errors.Lexer_Error
                 ("unknow preprocessor directive : "
                  & Get_Marked_Text & ".",
                  Errors.Error,
                  Get_Real_Location);
               Skip_Line;
            end if;
         when  '0' .. '9' =>
            --  here line number and maybe file name must be changed
            declare
               New_Line_Number : Natural;
               Last : Positive;
               package Natural_IO is new Ada.Text_IO.Integer_IO (Natural);
            begin
               Natural_IO.Get (Line (Current_Location.Col .. Line'Last),
                               New_Line_Number,
                               Last);
               Current_Location.Col := Last;
               Current_Location.Line := New_Line_Number - 1;
               Skip_Spaces;
               case View_Next_Char is
                  when Quotation =>
                     --  there is a filename
                     Skip_Char;
                     Set_Mark;
                     Go_To_End_Of_String;
                     Errors.Free (Current_Location.Filename);
                     Current_Location.Filename
                       := new String'(Get_Marked_Text);
                     Skip_Spaces;
                     while View_Next_Char /= LF loop
                        --  there is a flag
                        case Next_Char is
                           when '1' | '2' | '3' | '4' =>
                              --  not taken into account
                              null;
                           when others =>
                              --  the preprocessor should not
                              --  give anything else
                              raise Errors.Internal_Error;
                        end case;
                        Skip_Spaces;
                     end loop;
                  when LF =>
                     --  end of preprocessor directive
                     null;
                  when others =>
                     --  the preprocessor should not give anything else
                     raise Errors.Internal_Error;
               end case;
            end;
         when LF =>
            --  This is an end of line.
            return False;
         when others =>
            Errors.Lexer_Error ("bad preprocessor line",
                                Errors.Error,
                                Get_Real_Location);
            Skip_Line;
      end case;
      return False;
   end Scan_Preprocessor;



   -----------------------------------------------------
   --  Tools and constants for the preprocessor call  --
   -----------------------------------------------------

   --  If true then keep temporary files;
   Keep_Temporary_Files : Boolean := False;

   --  Name of the temporary file to be created if the
   --  preprocessor is used.
   Tmp_File_Name : GNAT.OS_Lib.Temp_File_Name;

   --  Manipulation of an array of strings for
   --  the arguments to be given to the preprocessor
   Args : GNAT.OS_Lib.Argument_List (1 .. 64);
   Arg_Count : Positive := 1;


   --------------------
   --  Add_Argument  --
   --------------------
   procedure Add_Argument (Str : String) is
   begin
      Args (Arg_Count) := new String'(Str);
      Arg_Count := Arg_Count + 1;
   end Add_Argument;


   ----------------------------------------------------
   --  The main methods : initialize and next_token  --
   ----------------------------------------------------

   ------------------
   --  Initialize  --
   ------------------
   procedure Initialize (Filename : in String;
                         Preprocess : in Boolean;
                         Keep_Temporary_Files : in Boolean) is
      Idl_File : Ada.Text_IO.File_Type;
   begin
      if Filename'Length = 0 then
         Errors.Lexer_Error ("Missing idl file as argument",
                             Errors.Fatal,
                             Get_Real_Location);
      end if;
      Tokens.Keep_Temporary_Files := Keep_Temporary_Files;
      if Preprocess then
         declare
            use GNAT.OS_Lib;
            Spawn_Result : Boolean;
            Fd : File_Descriptor;
         begin
            --  Use default options:
            --  -E           only preprocess
            --  -C           do not discard comments
            --  -x c++       use c++ preprocessor semantic
            Add_Argument ("-E");
            Add_Argument ("-C");
            Add_Argument ("-x");
            Add_Argument ("c++");
            Add_Argument ("-ansi");
            Create_Temp_File (Fd, Tmp_File_Name);
            if Fd = Invalid_FD then
               Errors.Lexer_Error (Ada.Command_Line.Command_Name &
                                   ": cannot create temporary file name",
                                   Errors.Fatal,
                                   Get_Real_Location);
            end if;
            --  We don't need the fd.
            Close (Fd);

            Add_Argument ("-o");
            Add_Argument (Tmp_File_Name);
            Args (Arg_Count) := new String'(Filename);
            Spawn (Locate_Exec_On_Path ("gnatgcc").all,
                   Args (1 .. Arg_Count),
                   Spawn_Result);
            if not Spawn_Result then
               Errors.Lexer_Error (Ada.Command_Line.Command_Name &
                                   ": preprocessor failed",
                                   Errors.Fatal,
                                   Get_Real_Location);
            end if;
            Ada.Text_IO.Open (Idl_File,
                              Ada.Text_IO.In_File,
                              Tmp_File_Name);
         end;
      else
         Ada.Text_IO.Open (Idl_File,
                           Ada.Text_IO.In_File,
                           Filename);
      end if;
      Ada.Text_IO.Set_Input (Idl_File);
   end Initialize;

   ----------------------
   --  Get_Next_Token  --
   ----------------------
   function Get_Next_Token return Idl_Token is
   begin
      loop
         case Next_Char is
            when Space | CR | VT | FF | LF =>
               null;
            when HT =>
               Refresh_Offset;
            when ';' =>
               Set_Token_Location;
               return T_Semi_Colon;
            when '{' =>
               Set_Token_Location;
               return T_Left_Cbracket;
            when '}' =>
               Set_Token_Location;
               return T_Right_Cbracket;
            when ':' =>
               Set_Token_Location;
               if View_Next_Char = ':' then
                  Skip_Char;
                  return T_Colon_Colon;
               else
                  return T_Colon;
               end if;
            when ',' =>
               Set_Token_Location;
               return T_Comma;
            when '(' =>
               Set_Token_Location;
               return T_Left_Paren;
            when ')' =>
               Set_Token_Location;
               return T_Right_Paren;
            when '=' =>
               Set_Token_Location;
               return T_Equal;
            when '|' =>
               Set_Token_Location;
               return T_Bar;
            when '^' =>
               Set_Token_Location;
               return T_Circumflex;
            when '&' =>
               Set_Token_Location;
               return T_Ampersand;
            when '<' =>
               Set_Token_Location;
               if View_Next_Char = '<' then
                  Skip_Char;
                  return T_Less_Less;
               else
                  return T_Less;
               end if;
            when '>' =>
               Set_Token_Location;
               if View_Next_Char = '>' then
                  Skip_Char;
                  return T_Greater_Greater;
               else
                  return T_Greater;
               end if;
            when '+' =>
               Set_Token_Location;
               return T_Plus;
            when '-' =>
               Set_Token_Location;
               return T_Minus;
            when '*' =>
               Set_Token_Location;
               return T_Star;
            when '/' =>
               if View_Next_Char = '/' then
                  --  This is a line comment.
                  Skip_Line;
               elsif View_Next_Char = '*' then
                  --  This is the beginning of a comment
                  Skip_Char;
                  Skip_Comment;
               else
                  return T_Slash;
               end if;
            when '%' =>
               Set_Token_Location;
               return T_Percent;
            when '~' =>
               Set_Token_Location;
               return T_Tilde;
            when '[' =>
               Set_Token_Location;
               return T_Left_Sbracket;
            when ']' =>
               Set_Token_Location;
               return T_Right_Sbracket;
            when '0' .. '9' =>
               Set_Token_Location;
               return Scan_Numeric;
            when '.' =>
               Set_Token_Location;
               return Scan_Numeric;
            when 'A' .. 'Z'
              | LC_A .. LC_Z
              | UC_A_Grave .. UC_I_Diaeresis
              | LC_A_Grave .. LC_I_Diaeresis
              | UC_N_Tilde .. UC_O_Diaeresis
              | LC_N_Tilde .. LC_O_Diaeresis
              | UC_O_Oblique_Stroke .. UC_U_Diaeresis
              | LC_O_Oblique_Stroke .. LC_U_Diaeresis
              | LC_German_Sharp_S
              | LC_Y_Diaeresis =>
               Set_Token_Location;
               return Scan_Identifier;
            when '_' =>
               Set_Token_Location;
               return Scan_Underscore;
            when ''' =>
               Set_Token_Location;
               return Scan_Char;
            when Quotation =>
               Set_Token_Location;
               return Scan_String;
            when Number_Sign =>
               Set_Token_Location;
               if Scan_Preprocessor then
                  return T_Pragma;
               end if;
            when others =>
               if Get_Current_Char >= ' ' then
                  Errors.Lexer_Error ("Invalid character '"
                                      & Get_Current_Char
                                      & "'",
                                      Errors.Error,
                                      Get_Real_Location);
               else
                  Errors.Lexer_Error
                    ("Invalid character, ASCII code "
                     & Natural'Image (Character'Pos (Get_Current_Char)),
                     Errors.Error,
                     Get_Real_Location);
               end if;
               return T_Error;
         end case;
      end loop;
      exception
         when Ada.Text_IO.End_Error =>
            if not Keep_Temporary_Files then
               declare
                  use GNAT.OS_Lib;
                  Spawn_Result : Boolean;
               begin
                  Delete_File (Tmp_File_Name'Address, Spawn_Result);
               end;
            end if;
            return T_Eof;
   end Get_Next_Token;


   -------------------------------------
   --  methods useful for the parser  --
   -------------------------------------

   --------------------------
   --  Get_Lexer_Location  --
   --------------------------
   function Get_Lexer_Location return Errors.Location is
   begin
      return Current_Token_Location;
   end Get_Lexer_Location;

   ------------------------
   --  Get_Lexer_String  --
   ------------------------
   function Get_Lexer_String return String renames Get_Marked_Text;


   -------------------------
   --  Maybe useless ???  --
   -------------------------

--    --  compares two idl words
--    function Idl_Compare (Left, Right : String) return Boolean is
--       use Gnat.Case_Util;
--    begin
--       if Left'Length /= Right'Length then
--          return False;
--       end if;
--       for I in Left'Range loop
--          if To_Lower (Left (I))
--            /= To_Lower (Right (Right'First + I - Left'First))
--          then
--             return False;
--          end if;
--       end loop;
--       return True;
--    end Idl_Compare;

--    --  returns an image of the current identifier
--    function Image (Tok : Idl_Token) return String is
--    begin
--       case Tok is
--          when T_Identifier =>
--             if Tok = Token then
--                return "identifier `" & Get_Identifier & ''';
--             else
--                return "identifier";
--             end if;
--          when others =>
--             return '`' & Idl_Token'Image (Token) & ''';
--       end case;
--    end Image;

end Tokens;

