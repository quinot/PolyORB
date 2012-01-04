------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                S O A P . M E S S A G E . R E S P O N S E                 --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2000-2012, Free Software Foundation, Inc.          --
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

--  with AWS.MIME;

--  with SOAP.Message.XML;

package body SOAP.Message.Response is

   ----------
   -- From --
   ----------

   function From (P : Message.Payload.Object) return Object is
      NP : Object;
   begin
      Set_Wrapper_Name (NP, Payload.Procedure_Name (P) & "Response");

      Set_Parameters   (NP, Parameters (P));

      Set_Name_Space (NP, Name_Space (P));

      return NP;
   end From;

   --------------
   -- Is_Error --
   --------------

   function Is_Error (R : Object) return Boolean is
      pragma Warnings (Off, R);
   begin
      return False;
   end Is_Error;

end SOAP.Message.Response;
