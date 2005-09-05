------------------------------------------------------------------------------
--                                                                          --
--                            POLYORB COMPONENTS                            --
--                                   IAC                                    --
--                                                                          --
--                              B A C K E N D                               --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--                           Copyright (c) 2005                             --
--            Ecole Nationale Superieure des Telecommunications             --
--                                                                          --
-- IAC is free software; you  can  redistribute  it and/or modify it under  --
-- terms of the GNU General Public License  as published by the  Free Soft- --
-- ware  Foundation;  either version 2 of the liscence or (at your option)  --
-- any  later version.                                                      --
-- IAC is distributed  in the hope that it will be  useful, but WITHOUT ANY --
-- WARRANTY; without even the implied warranty of MERCHANTABILITY or        --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for --
-- more details.                                                            --
-- You should have received a copy of the GNU General Public License along  --
-- with this program; if not, write to the Free Software Foundation, Inc.,  --
-- 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.            --
--                                                                          --
------------------------------------------------------------------------------

with Types; use Types;

package Backend is

   procedure Set_Current_Language (Language : String);
   --  Reset the current language.

   function Current_Language return String;
   --  Return language previously set. Null string when uninitialized.

   type Configure_Procedure is access procedure;
   procedure Configure;
   --  Configure backend with specific flags. To do so scan flags
   --  using Getopt from GNAT.Command_Line.

   type Generate_Procedure is access procedure (IDL_Spec : Node_Id);
   procedure Generate (IDL_Spec : Node_Id);
   --  Generate code for the current language.

   type Usage_Procedure is access procedure (Indent : Natural);

   procedure Register
     (Generate  : Generate_Procedure;
      Configure : Configure_Procedure;
      Usage     : Usage_Procedure;
      Language  : String;
      Comments  : String);
   --  Register a new language with its code generation procedure, its
   --  name and a comment associated to it (for usage output).
   --  The current language is set to this last language.

   function Is_Valid_Language (L : String) return Boolean;
   --  Return True when there is a backend corresponding to L

   procedure Write_Languages (L, C : Natural);
   --  For each language backend avaible write at column L the name
   --  and at column C the comments associated to a language.

end Backend;

