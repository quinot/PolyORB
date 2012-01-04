------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                P O L Y O R B . C O R B A _ P . N A M E S                 --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2001-2012, Free Software Foundation, Inc.          --
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

--  String constants defined by OMG specifications.

package body PolyORB.CORBA_P.Names is

   Prefix  : constant String := "omg.org";
   Version : constant String := "1.0";

   ----------------
   -- OMG_Prefix --
   ----------------

   function OMG_Prefix
     return String is
   begin
      return Prefix;
   end OMG_Prefix;

   ----------------------
   -- OMG_RepositoryId --
   ----------------------

   function OMG_RepositoryId
     (Name : String)
     return String is
   begin
      return "IDL:" & Prefix & "/" & Name & ":" & Version;
   end OMG_RepositoryId;

   -----------------
   -- OMG_Version --
   -----------------

   function OMG_Version
     return String is
   begin
      return Version;
   end OMG_Version;

end PolyORB.CORBA_P.Names;
