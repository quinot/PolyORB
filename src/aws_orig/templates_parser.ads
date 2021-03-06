------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                     T E M P L A T E S _ P A R S E R                      --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 1999-2012, Free Software Foundation, Inc.          --
--                                                                          --
-- This is free software;  you can redistribute it  and/or modify it  under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  This software is distributed in the hope  that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License for  more details.                                               --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
--                  PolyORB is maintained by AdaCore                        --
--                     (email: sales@adacore.com)                           --
--                                                                          --
------------------------------------------------------------------------------

with Ada.Finalization;
with Ada.Strings.Unbounded;

package Templates_Parser is

   use Ada.Strings.Unbounded;

   Template_Error : exception;

   Default_Begin_Tag : constant String := "@_";
   Default_End_Tag   : constant String := "_@";

   Default_Separator : constant String := ", ";

   procedure Set_Tag_Separators
     (Start_With : String := Default_Begin_Tag;
      Stop_With  : String := Default_End_Tag);
   --  Set the tag separators for the whole session. This should be changed as
   --  the very first API call and should not be changed after.

   ----------------
   -- Vector Tag --
   ----------------

   type Vector_Tag is private;
   --  A vector tag is a set of strings. Note that this object is using a
   --  by-reference semantic. A reference counter is associated to it and
   --  the memory is realeased when there is no more reference to it.

   function "+" (Value : String) return Vector_Tag;
   --  Vector_Tag constructor.

   function "+" (Value : Character) return Vector_Tag;
   --  Vector_Tag constructor.

   function "+" (Value : Boolean) return Vector_Tag;
   --  Vector_Tag constructor.

   function "+" (Value : Unbounded_String) return Vector_Tag;
   --  Vector_Tag constructor.

   function "+" (Value : Integer) return Vector_Tag;
   --  Vector_Tag constructor.

   function "&"
     (Vect  : Vector_Tag;
      Value : String)
      return Vector_Tag;
   --  Add Value at the end of the vector tag set.

   function "&"
     (Vect  : Vector_Tag;
      Value : Character)
      return Vector_Tag;
   --  Add Value at the end of the vector tag set.

   function "&"
     (Vect  : Vector_Tag;
      Value : Boolean)
      return Vector_Tag;
   --  Add Value (either string TRUE or FALSE) at the end of the vector tag
   --  set.

   function "&"
     (Vect  : Vector_Tag;
      Value : Unbounded_String)
      return Vector_Tag;
   --  Add Value at the end of the vector tag set.

   function "&"
     (Vect  : Vector_Tag;
      Value : Integer)
      return Vector_Tag;
   --  Add Value (converted to a String) at the end of the vector tag set.

   procedure Clear (Vect : in out Vector_Tag);
   --  Removes all values in the vector tag. Current Vect is not released but
   --  the returned object is separated (not using the same reference) from
   --  the original one.

   function Size (Vect : Vector_Tag) return Natural;
   --  Returns the number of value into Vect.

   function Item (Vect : Vector_Tag; N : Positive) return String;
   --  Returns the Nth Vector Tag's item. Raises Constraint_Error if there is
   --  no such Item in the vector (i.e. vector length < N).

   ----------------
   -- Matrix Tag --
   ----------------

   type Matrix_Tag is private;
   --  A matrix tag is a set of vectors. Note that this object is using a
   --  by-reference semantic. A reference counter is associated to it and
   --  the memory is realeased when there is no more reference to it.

   function "+" (Vect : Vector_Tag) return Matrix_Tag;
   --  Matrix_Tag constructor. It returns a matrix with a single row whose
   --  value is Vect.

   function "&"
     (Matrix : Matrix_Tag;
      Vect   : Vector_Tag)
      return Matrix_Tag;
   --  Returns Matrix with Vect added to the end.

   function Size (Matrix : Matrix_Tag) return Natural;
   --  Returns the number of Vector_Tag (rows) inside the Matrix.

   function Vector (Matrix : Matrix_Tag; N : Positive) return Vector_Tag;
   --  Returns Nth Vector_Tag in the Matrix.

   -----------------------
   -- Association table --
   -----------------------

   type Association is private;

   type Translate_Table is array (Positive range <>) of Association;

   No_Translation : constant Translate_Table;

   function Assoc
     (Variable  : String;
      Value     : String)
      return Association;
   --  Build an Association (Variable = Value) to be added to a
   --  Translate_Table. This is a standard association, value is a string.

   function Assoc
     (Variable  : String;
      Value     : Unbounded_String)
      return Association;
   --  Build an Association (Variable = Value) to be added to a
   --  Translate_Table. This is a standard association, value is an
   --  Unbounded_String.

   function Assoc
     (Variable  : String;
      Value     : Integer)
      return Association;
   --  Build an Association (Variable = Value) to be added to a
   --  Translate_Table. This is a standard association, value is an Integer.
   --  It will be displayed without leading space if positive.

   function Assoc
     (Variable  : String;
      Value     : Boolean)
      return Association;
   --  Build an Association (Variable = Value) to be added to a
   --  Translate_Table. It set the variable to TRUE or FALSE depending on
   --  value.

   function Assoc
     (Variable  : String;
      Value     : Vector_Tag;
      Separator : String     := Default_Separator)
      return Association;
   --  Build an Association (Variable = Value) to be added to a
   --  Translate_Table. This is a vector tag association, value is a
   --  Vector_Tag. If the vector tag is found outside a table tag statement
   --  it is returned as a single string, each value being separated by the
   --  specified separator.

   function Assoc
     (Variable  : String;
      Value     : Matrix_Tag;
      Separator : String     := Default_Separator)
      return Association;
   --  Build an Association (Variable = Value) to be added to a
   --  Translate_Table. This is a matrix tag association, value is a
   --  Matrix_Tag. If the matrix tag is found outside of a 2nd level table tag
   --  statement, Separator is used to build string representation of the
   --  matrix tag's vectors.

   -----------------------------
   -- Parsing and Translating --
   -----------------------------

   function Parse
     (Filename          : String;
      Translations      : Translate_Table := No_Translation;
      Cached            : Boolean         := False;
      Keep_Unknown_Tags : Boolean         := False)
      return String;
   --  Parse the Template_File replacing variables' occurrences by the
   --  corresponding values. If Cached is set to True, Filename tree will be
   --  recorded into a cache for quick retrieval. If Keep_Unknown_Tags is set
   --  to True then tags that are not in the translate table are kept
   --  as-is if it is part of the template data. If this tags is part of a
   --  condition (in an IF statement tag), the condition will evaluate to
   --  False.

   function Parse
     (Filename          : String;
      Translations      : Translate_Table := No_Translation;
      Cached            : Boolean         := False;
      Keep_Unknown_Tags : Boolean         := False)
      return Unbounded_String;
   --  Idem as above but returns an Unbounded_String.

   function Translate
     (Template     : String;
      Translations : Translate_Table := No_Translation)
      return String;
   --  Just translate the discrete variables in the Template string using the
   --  Translations table. This function does not parse the command tag
   --  (TABLE, IF, INCLUDE). All Vector and Matrix tag are replaced by the
   --  empty string.

   procedure Print_Tree (Filename : String);
   --  Use for debugging purpose only, it will output the internal tree
   --  representation.

private

   ------------------
   --  Vector Tags --
   ------------------

   type Vector_Tag_Node;
   type Vector_Tag_Node_Access is access Vector_Tag_Node;

   type Vector_Tag_Node is record
      Value : Unbounded_String;
      Next  : Vector_Tag_Node_Access;
   end record;

   type Integer_Access is access Integer;

   type Vector_Tag is new Ada.Finalization.Controlled with record
      Ref_Count : Integer_Access;
      Count     : Natural;
      Head      : Vector_Tag_Node_Access;
      Last      : Vector_Tag_Node_Access;
   end record;

   type Vector_Tag_Access is access Vector_Tag;

   procedure Initialize (V : in out Vector_Tag);
   procedure Finalize   (V : in out Vector_Tag);
   procedure Adjust     (V : in out Vector_Tag);

   ------------------
   --  Matrix Tags --
   ------------------

   type Matrix_Tag_Node;

   type Matrix_Tag_Node_Access is access Matrix_Tag_Node;

   type Matrix_Tag_Node is record
      Vect : Vector_Tag;
      Next : Matrix_Tag_Node_Access;
   end record;

   type Matrix_Tag_Int is new Ada.Finalization.Controlled with record
      Ref_Count : Integer_Access;
      Count     : Natural; -- Number of vector
      Min, Max  : Natural; -- Min/Max vector's sizes
      Head      : Matrix_Tag_Node_Access;
      Last      : Matrix_Tag_Node_Access;
   end record;

   type Matrix_Tag is record
      M : Matrix_Tag_Int;
   end record;

   procedure Initialize (M : in out Matrix_Tag_Int);
   procedure Finalize   (M : in out Matrix_Tag_Int);
   procedure Adjust     (M : in out Matrix_Tag_Int);

   ------------------
   --  Association --
   ------------------

   type Var_Kind is (Std, Vect, Matrix);

   type Association (Kind : Var_Kind := Std) is record
      Variable  : Unbounded_String;

      case Kind is
         when Std =>
            Value : Unbounded_String;

         when Vect =>
            Vect_Value : Vector_Tag;
            Separator  : Unbounded_String;

         when Matrix =>
            Mat_Value        : Matrix_Tag;
            Column_Separator : Unbounded_String;
      end case;
   end record;

   No_Translation : constant Translate_Table
     := (2 .. 1 => Association'(Std,
                                Null_Unbounded_String,
                                Null_Unbounded_String));

end Templates_Parser;
