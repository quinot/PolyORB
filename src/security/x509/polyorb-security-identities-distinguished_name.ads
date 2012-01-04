------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--             POLYORB.SECURITY.IDENTITIES.DISTINGUISHED_NAME               --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2005-2012, Free Software Foundation, Inc.          --
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

with PolyORB.X509;

package PolyORB.Security.Identities.Distinguished_Name is

   type Distinguished_Name_Identity_Type is new Identity_Type with private;

   function Create (The_Name : PolyORB.X509.Name) return Identity_Access;

private

   type Distinguished_Name_Identity_Type is new Identity_Type with record
      Name : PolyORB.X509.Name;
   end record;

   --  Derived from Identity_Type

   function Get_Token_Type
     (Self : access Distinguished_Name_Identity_Type)
      return PolyORB.Security.Types.Identity_Token_Type;

   function Get_Printable_Name
     (Self : access Distinguished_Name_Identity_Type)
      return String;

   function Duplicate
     (Self : access Distinguished_Name_Identity_Type) return Identity_Access;

   procedure Release_Contents (Self : access Distinguished_Name_Identity_Type);

   function Encode
     (Self : access Distinguished_Name_Identity_Type)
      return Ada.Streams.Stream_Element_Array;

   procedure Decode
     (Self  : access Distinguished_Name_Identity_Type;
      Item  :        Ada.Streams.Stream_Element_Array;
      Error : in out PolyORB.Errors.Error_Container);

end PolyORB.Security.Identities.Distinguished_Name;
