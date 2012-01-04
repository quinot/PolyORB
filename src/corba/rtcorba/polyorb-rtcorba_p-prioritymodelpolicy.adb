------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                  POLYORB.RTCORBA_P.PRIORITYMODELPOLICY                   --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2003-2012, Free Software Foundation, Inc.          --
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

package body PolyORB.RTCORBA_P.PriorityModelPolicy is

   ------------
   -- Create --
   ------------

   function Create
     (Priority_Model  : RTCORBA.PriorityModel;
      Server_Priority : RTCORBA.Priority)
     return PolyORB.Smart_Pointers.Entity_Ptr
   is
      Result : constant PolyORB.CORBA_P.Policy.Policy_Object_Ptr
        := new PriorityModelPolicy_Type;

      TResult : PriorityModelPolicy_Type
        renames PriorityModelPolicy_Type (Result.all);

   begin
      Set_Policy_Type (TResult, RTCORBA.PRIORITY_MODEL_POLICY_TYPE);

      TResult.Priority_Model := Priority_Model;
      TResult.Server_Priority := Server_Priority;

      return PolyORB.Smart_Pointers.Entity_Ptr (Result);
   end Create;

   ------------------------
   -- Get_Priority_Model --
   ------------------------

   function Get_Priority_Model
     (Self : PriorityModelPolicy_Type)
     return RTCORBA.PriorityModel is
   begin
      return Self.Priority_Model;
   end Get_Priority_Model;

   -------------------------
   -- Get_Server_Priority --
   -------------------------

   function Get_Server_Priority
     (Self : PriorityModelPolicy_Type)
     return RTCORBA.Priority is
   begin
      return Self.Server_Priority;
   end Get_Server_Priority;

end PolyORB.RTCORBA_P.PriorityModelPolicy;
