------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                A D A _ B E . S O U R C E _ S T R E A M S                 --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2001-2004 Free Software Foundation, Inc.           --
--                                                                          --
-- PolyORB is free software; you  can  redistribute  it and/or modify it    --
-- under terms of the  GNU General Public License as published by the  Free --
-- Software Foundation;  either version 2,  or (at your option)  any  later --
-- version. PolyORB is distributed  in the hope that it will be  useful,    --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License  for more details.  You should have received  a copy of the GNU  --
-- General Public License distributed with PolyORB; see file COPYING. If    --
-- not, write to the Free Software Foundation, 59 Temple Place - Suite 330, --
-- Boston, MA 02111-1307, USA.                                              --
--                                                                          --
-- As a special exception,  if other files  instantiate  generics from this --
-- unit, or you link  this unit with other files  to produce an executable, --
-- this  unit  does not  by itself cause  the resulting  executable  to  be --
-- covered  by the  GNU  General  Public  License.  This exception does not --
-- however invalidate  any other reasons why  the executable file  might be --
-- covered by the  GNU Public License.                                      --
--                                                                          --
--                PolyORB is maintained by ACT Europe.                      --
--                    (email: sales@act-europe.fr)                          --
--                                                                          --
------------------------------------------------------------------------------

with Ada.Characters.Handling; use Ada.Characters.Handling;
with Ada.Characters.Latin_1; use Ada.Characters.Latin_1;
with Ada.Text_IO;

with Ada_Be.Debug;
pragma Elaborate_All (Ada_Be.Debug);

package body Ada_Be.Source_Streams is

   Flag : constant Natural := Ada_Be.Debug.Is_Active ("ada_be.source_streams");
   procedure O is new Ada_Be.Debug.Output (Flag);

   --  User-defined diversion identifiers are allocated on a system-wide basis.

   Diversions_Allocation : array (Diversion) of Boolean
     := (Predefined_Diversions'Range => True, others => False);

   --  Semantic dependencies

   type Dependency_Node is record
      Library_Unit : String_Ptr;
      Use_It : Boolean;
      Elab_Control : Elab_Control_Pragma := None;
      No_Warnings : Boolean;
      Next : Dependency;
   end record;

   -----------------------
   -- Local subprograms --
   -----------------------

   function Is_Empty (Unit : Compilation_Unit) return Boolean;
   --  True if, and only if, all of Unit's diversions are empty

   function Is_Ancestor
     (U1 : String;
      U2 : String)
     return Boolean;
   --  True if library unit U1 is an ancestor of U2.

   -----------------
   -- Is_Ancestor --
   -----------------

   function Is_Ancestor (U1 : String; U2 : String) return Boolean is
      use Ada.Characters.Handling;

      LU1 : constant String := To_Lower (U1) & ".";
      LU2 : constant String := To_Lower (U2);
   begin
      return True
        and then LU1'Length <= LU2'Length
        and then LU1 = LU2
        (LU2'First .. LU2'First + LU1'Length - 1);
   end Is_Ancestor;

   --------------
   -- Add_With --
   --------------

   procedure Add_With
     (Unit         : in out Compilation_Unit;
      Dep          :        String;
      Use_It       :        Boolean             := False;
      Elab_Control :        Elab_Control_Pragma := None;
      No_Warnings  :        Boolean             := False)
   is
      Dep_Node : Dependency := Unit.Context_Clause;
      LU_Name : constant String
        := Unit.Library_Unit_Name.all;
   begin
      if False
        or else Dep = "Standard"
        or else Dep = LU_Name
      then
         --  No need to with oneself. If Dep is an ancestor of Unit, register
         --  it (even though no 'with' clause will be emitted) for the sake of
         --  elaboration control.
         return;
      end if;

      pragma Debug (O ("Adding depend of " & LU_Name
                       & " (" & Unit_Kind'Image (Unit.Kind) & ")"
                       & " upon " & Dep));

      if True
        and then Unit.Kind = Unit_Spec
        and then Is_Ancestor (LU_Name, Dep)
      then
         --  All hope abandon he who trieth to make a package spec depend upon
         --  its child.
         pragma Debug (O ("The declaration of " & LU_Name
                          & " cannot depend on " & Dep));

         raise Program_Error;
      end if;

      while Dep_Node /= null and then Dep_Node.Library_Unit.all /= Dep loop
         Dep_Node := Dep_Node.Next;
      end loop;

      if Dep_Node = null then
         Dep_Node := new Dependency_Node'
           (Library_Unit => new String'(Dep),
            Use_It => Use_It,
            Elab_Control => Elab_Control,
            No_Warnings => No_Warnings,
            Next => Unit.Context_Clause);
         Unit.Context_Clause := Dep_Node;
      else
         Dep_Node.Use_It
           := Dep_Node.Use_It or else Use_It;
         Dep_Node.No_Warnings
           := Dep_Node.No_Warnings and then No_Warnings;
         if Elab_Control = Elaborate_All
           or else Dep_Node.Elab_Control = Elaborate_All then
            Dep_Node.Elab_Control := Elaborate_All;
         elsif Elab_Control = Elaborate
           or else Dep_Node.Elab_Control = Elaborate then
            Dep_Node.Elab_Control := Elaborate;
         else
            Dep_Node.Elab_Control := None;
         end if;
      end if;

   end Add_With;

   ------------------------
   -- Add_Elaborate_Body --
   ------------------------

   procedure Add_Elaborate_Body
     (U_Spec : in out Compilation_Unit;
      U_Body : Compilation_Unit) is
   begin
      pragma Assert (U_Spec.Kind = Unit_Spec);
      if not Is_Empty (U_Body) then
         U_Spec.Diversions (Visible_Declarations).Empty := False;
         U_Spec.Elaborate_Body := True;
      end if;
   end Add_Elaborate_Body;

   ------------------------------
   -- Suppress_Warning_Message --
   ------------------------------

   procedure Suppress_Warning_Message (Unit : in out Compilation_Unit) is
   begin
      Unit.No_Warning := True;
   end Suppress_Warning_Message;

   ----------
   -- Name --
   ----------

   function Name (CU : Compilation_Unit) return String is
   begin
      return CU.Library_Unit_Name.all;
   end Name;

   -----------------------------
   -- Allocate_User_Diversion --
   -----------------------------

   function Allocate_User_Diversion
     return Diversion is
   begin
      for I in User_Diversions'Range loop
         if not Diversions_Allocation (I) then
            Diversions_Allocation (I) := True;
            return I;
         end if;
      end loop;

      --  Too many diversions open

      raise Program_Error;
   end Allocate_User_Diversion;

   -----------------------
   -- Current_Diversion --
   -----------------------

   function Current_Diversion (CU : Compilation_Unit) return Diversion is
   begin
      return CU.Current_Diversion;
   end Current_Diversion;

   ------------
   -- Divert --
   ------------

   procedure Divert
     (CU     : in out Compilation_Unit;
      Whence : Diversion) is
   begin
      if not
        (Diversions_Allocation (Whence)
         and then (False
           or else Whence in User_Diversions'Range
           or else Whence = Visible_Declarations
           or else (Whence = Private_Declarations and then CU.Kind = Unit_Spec)
           or else (Whence = Elaboration and then CU.Kind = Unit_Body)
           or else (Whence = Generic_Formals and then CU.Kind = Unit_Spec)))
      then
         raise Program_Error;
      end if;

      CU.Current_Diversion := Whence;
   end Divert;

   --------------
   -- Undivert --
   --------------

   procedure Undivert
     (CU : in out Compilation_Unit;
      D  : Diversion)
   is
      Div : Diversion_Data renames CU.Diversions (D);
      Empty_Diversion : Diversion_Data;
      pragma Warnings (Off, Empty_Diversion);
      --  Use default initialization
   begin
      if not Diversions_Allocation (D) then
         raise Program_Error;
      end if;

      if Length (Div.Library_Item) > 0 then
         if not CU.Diversions (CU.Current_Diversion).At_BOL then
            New_Line (CU);
         end if;

         --  Now we are actually at BOL

         Put (CU, To_String (Div.Library_Item));
         CU.Diversions (CU.Current_Diversion).At_BOL := Div.At_BOL;
      end if;

      if not Div.Empty then
         --  Undivert might be performed in template mode, so we need to
         --  carry manually the non-Empty status from D to Current_Diversion.

         CU.Diversions (CU.Current_Diversion).Empty := False;
      end if;

      --  Reset diversion D to empty state

      CU.Diversions (D) := Empty_Diversion;
   end Undivert;

   -----------------
   -- New_Package --
   -----------------

   function New_Package
     (Name : String;
      Kind : Unit_Kind)
     return Compilation_Unit
   is
      The_Package : Compilation_Unit (Kind => Kind);
   begin
      The_Package.Library_Unit_Name := new String'(Name);
      for D in Predefined_Diversions loop
         The_Package.Diversions (D).Indent_Level := 1;
      end loop;
      return The_Package;
   end New_Package;

   --------------
   -- Generate --
   --------------

   procedure Generate
     (Unit : in Compilation_Unit;
      Is_Generic_Instanciation : Boolean := False;
      To_Stdout : Boolean := False)
   is

      function Ada_File_Name
        (Full_Name : String;
         Part      : Unit_Kind := Unit_Spec)
        return String;
      --  Name of the source file for Unit

      -------------------
      -- Ada_File_Name --
      -------------------

      function Ada_File_Name
        (Full_Name : String;
         Part      : Unit_Kind := Unit_Spec)
        return String
      is
         Extension : constant array (Unit_Kind) of Character
           := (Unit_Spec => 's',
               Unit_Body => 'b');
         Result : String := Full_Name & ".ad?";
      begin
         for I in Result'First .. Result'Last - 4 loop
            if Result (I) = '.' then
               Result (I) := '-';
            else
               Result (I) := To_Lower (Result (I));
            end if;
         end loop;

         Result (Result'Last) := Extension (Part);
         return Result;
      end Ada_File_Name;

      use Ada.Text_IO;

      procedure Emit_Standard_Header
        (File        : in File_Type;
         User_Edited : in Boolean := False);
      --  Generate boilerplate header. If User_Edited is False, include a
      --  warning that the file is generated automatically and should not
      --  be modified by hand.

      procedure Emit_Source_Code (File : in File_Type);
      --  Generate the source text

      --------------------------
      -- Emit_Standard_Header --
      --------------------------

      procedure Emit_Standard_Header
        (File        : in File_Type;
         User_Edited : in Boolean := False)
      is
      begin
         Put_Line (File, "-------------------------------------------------");
         Put_Line (File, "--  This file has been generated automatically");
         Put_Line (File, "--  by IDLAC (http://libre.adacore.com/polyorb/)");
         if not User_Edited then
            Put_Line (File, "--");
            Put_Line (File, "--  Do NOT hand-modify this file, as your");
            Put_Line (File, "--  changes will be lost when you re-run the");
            Put_Line (File, "--  IDL to Ada compiler.");
         end if;
         Put_Line (File, "-------------------------------------------------");

         --  XXX To be removed later on
         Put_Line (File, "pragma Style_Checks (Off);");
         New_Line (File);
      end Emit_Standard_Header;

      ----------------------
      -- Emit_Source_Code --
      ----------------------

      procedure Emit_Source_Code (File : in File_Type) is
         Dep_Node : Dependency := Unit.Context_Clause;

      begin
         while Dep_Node /= null loop
            if (not Is_Ancestor
                (Dep_Node.Library_Unit.all,
                 Unit.Library_Unit_Name.all))
              or else Dep_Node.Elab_Control /= None
            then
               Put_Line (File, "with " & Dep_Node.Library_Unit.all & ";");
            end if;

            if Dep_Node.Use_It then
               Put_Line (File, " use " & Dep_Node.Library_Unit.all & ";");
            end if;

            case Dep_Node.Elab_Control is
               when Elaborate_All =>
                  Put_Line (File, "pragma Elaborate_All ("
                            & Dep_Node.Library_Unit.all & ");");
               when Elaborate =>
                  Put_Line (File, "pragma Elaborate ("
                            & Dep_Node.Library_Unit.all & ");");
               when None =>
                  null;
            end case;

            if Dep_Node.No_Warnings then
               Put_Line (File, "pragma Warnings (Off, "
                         & Dep_Node.Library_Unit.all & ");");
            end if;
            Dep_Node := Dep_Node.Next;
         end loop;

         if Unit.Context_Clause /= null then
            New_Line (File);
         end if;

         if not Unit.Diversions (Generic_Formals).Empty then
            Put_Line (File, "generic");
            Put (File, To_String
                 (Unit.Diversions (Generic_Formals).Library_Item));
            New_Line (File);
         end if;

         Put (File, "package ");
         if Unit.Kind = Unit_Body then
            Put (File, "body ");
         end if;
         Put_Line (File, Unit.Library_Unit_Name.all & " is");

         if Unit.Kind = Unit_Spec and then Unit.Elaborate_Body then
            New_Line (File);
            Put_Line (File, "   pragma Elaborate_Body;");
         end if;

         if not Unit.Diversions (Visible_Declarations).Empty then
            Put (File, To_String
                 (Unit.Diversions (Visible_Declarations).Library_Item));
         end if;

         if not Unit.Diversions (Private_Declarations).Empty then
            New_Line (File);
            Put_Line (File, "private");
            Put (File, To_String
                 (Unit.Diversions (Private_Declarations).Library_Item));
         end if;

         if not Unit.Diversions (Elaboration).Empty then
            New_Line (File);
            Put_Line (File, "begin");
            Put (File, To_String (Unit.Diversions (Elaboration).Library_Item));
         end if;

         if not Is_Generic_Instanciation then
            New_Line (File);
            Put_Line (File, "end " & Unit.Library_Unit_Name.all & ";");
         end if;
      end Emit_Source_Code;

      --  Start of processing for Generate

   begin
      if Is_Empty (Unit) then
         return;
      end if;

      if To_Stdout then
         Emit_Standard_Header (Current_Output, Unit.No_Warning);
         Emit_Source_Code (Current_Output);
      else
         declare
            File_Name : constant String
              := Ada_File_Name (Unit.Library_Unit_Name.all, Unit.Kind);
            File : File_Type;
         begin
            Create (File, Out_File, File_Name);
            Emit_Standard_Header (File, Unit.No_Warning);
            Emit_Source_Code (File);
            Close (File);
         end;
      end if;
   end Generate;

   ---------
   -- Put --
   ---------

   procedure Put
     (Unit : in out Compilation_Unit;
      Text : String)
   is
      Indent_String : constant String
        (1 .. Indent_Size
         * Unit.Diversions (Unit.Current_Diversion).Indent_Level)
        := (others => ' ');
      LF_Pos : Integer;
   begin
      if not Unit.Template_Mode then
         Unit.Diversions (Unit.Current_Diversion).Empty := False;
      end if;
      if Unit.Diversions (Unit.Current_Diversion).At_BOL then
         Append
           (Unit.Diversions (Unit.Current_Diversion).Library_Item,
            Indent_String);
         Unit.Diversions (Unit.Current_Diversion).At_BOL := False;
      end if;

      LF_Pos := Text'First;
      while LF_Pos <= Text'Last
        and then Text (LF_Pos) /= ASCII.LF
      loop
         LF_Pos := LF_Pos + 1;
      end loop;

      Append
        (Unit.Diversions (Unit.Current_Diversion).Library_Item,
         Text (Text'First .. LF_Pos - 1));

      --  LF seen?

      if LF_Pos <= Text'Last then
         New_Line (Unit);
      end if;

      --  More?

      if LF_Pos + 1 <= Text'Last then
         Put (Unit, Text (LF_Pos + 1 .. Text'Last));
      end if;
   end Put;

   --------------
   -- Put_Line --
   --------------

   procedure Put_Line
     (Unit : in out Compilation_Unit;
      Line : String) is
   begin
      Put (Unit, Line & ASCII.LF);
   end Put_Line;

   --------------
   -- New_Line --
   --------------

   procedure New_Line (Unit : in out Compilation_Unit) is
   begin
      Append (Unit.Diversions (Unit.Current_Diversion).Library_Item, LF);
      Unit.Diversions (Unit.Current_Diversion).At_BOL := True;
   end New_Line;

   ----------------
   -- Inc_Indent --
   ----------------

   procedure Inc_Indent (Unit : in out Compilation_Unit) is
   begin
      Unit.Diversions (Unit.Current_Diversion).Indent_Level
      := Unit.Diversions (Unit.Current_Diversion).Indent_Level + 1;
   end Inc_Indent;

   ----------------
   -- Dec_Indent --
   ----------------

   procedure Dec_Indent (Unit : in out Compilation_Unit) is
   begin
      Unit.Diversions (Unit.Current_Diversion).Indent_Level
      := Unit.Diversions (Unit.Current_Diversion).Indent_Level - 1;
   end Dec_Indent;

   -----------------------------
   -- Current_Diversion_Empty --
   -----------------------------

   function Current_Diversion_Empty (CU : Compilation_Unit) return Boolean is
   begin
      return CU.Diversions (CU.Current_Diversion).Empty;
   end Current_Diversion_Empty;

   --------------
   -- Is_Empty --
   --------------

   function Is_Empty (Unit : Compilation_Unit) return Boolean is
   begin
      for I in Unit.Diversions'Range loop
         if not Unit.Diversions (I).Empty then
            return False;
         end if;
      end loop;
      return True;
   end Is_Empty;

   -----------------------
   -- Set_Template_Mode --
   -----------------------

   procedure Set_Template_Mode
     (Unit : in out Compilation_Unit;
      Mode : Boolean)
   is
   begin
      Unit.Template_Mode := Mode;
   end Set_Template_Mode;

end Ada_Be.Source_Streams;