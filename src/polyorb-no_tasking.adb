------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                   P O L Y O R B . N O _ T A S K I N G                    --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--                Copyright (C) 2001 Free Software Fundation                --
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
--              PolyORB is maintained by ENST Paris University.             --
--                                                                          --
------------------------------------------------------------------------------

--  $Id$

with Ada.Unchecked_Deallocation;

with PolyORB.Initialization;
with PolyORB.Utils.Strings;

package body PolyORB.No_Tasking is

   use PolyORB.Soft_Links;

   ------------
   -- Create --
   ------------

   function Create return Watcher_Access is
      W : Unprotected_Watcher_Type;
   begin
      W.X := new Unprotected_Watcher_Data;
      pragma Assert (W.X /= null);

      return new Unprotected_Watcher_Type'(W);
   end Create;

   ------------
   -- Create --
   ------------

   function Create return Adv_Mutex_Access is
   begin
      return new Unprotected_Adv_Mutex_Type;
   end Create;

   ------------
   -- Create --
   ------------

   function Create return Mutex_Access is
   begin
      return new Unprotected_Mutex_Type;
   end Create;

   -------------
   -- Destroy --
   -------------

   procedure Free is new Ada.Unchecked_Deallocation
     (Unprotected_Watcher_Data, Unprotected_Watcher_Data_Access);
   procedure Destroy (W : in out Unprotected_Watcher_Type) is
   begin
      Free (W.X);
   end Destroy;

   -------------
   -- Destroy --
   -------------

   procedure Destroy (M : in out Unprotected_Adv_Mutex_Type) is
   begin
      pragma Warnings (Off);
      pragma Unreferenced (M);
      pragma Warnings (On);
      null;
   end Destroy;

   -------------
   -- Destroy --
   -------------

   procedure Destroy (M : in out Unprotected_Mutex_Type) is
   begin
      pragma Warnings (Off);
      pragma Unreferenced (M);
      pragma Warnings (On);
      null;
   end Destroy;

   ----------------------------
   -- Enter_Critical_Section --
   ----------------------------

   procedure Enter_Critical_Section is
   begin
      null;
   end Enter_Critical_Section;

   ----------------------------
   -- Leave_Critical_Section --
   ----------------------------

   procedure Leave_Critical_Section is
   begin
      null;
   end Leave_Critical_Section;

   ------------
   -- Differ --
   ------------

   procedure Differ (W : in Unprotected_Watcher_Type; V : in Version_Id) is
   begin
      if W.X.Version = V then
         --  Dead lock!
         raise Program_Error;
      end if;
   end Differ;

   -----------
   -- Enter --
   -----------

   procedure Enter (M : in Unprotected_Mutex_Type) is
   begin
      pragma Warnings (Off);
      pragma Unreferenced (M);
      pragma Warnings (On);
      null;
   end Enter;

   -----------
   -- Enter --
   -----------

   procedure Enter (M : in Unprotected_Adv_Mutex_Type) is
   begin
      pragma Warnings (Off);
      pragma Unreferenced (M);
      pragma Warnings (On);
      null;
   end Enter;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      Register_Enter_Critical_Section (Enter_Critical_Section'Access);
      Register_Leave_Critical_Section (Leave_Critical_Section'Access);
      Register_Watcher_Creation_Function (Create'Access);
      Register_Mutex_Creation_Function (Create'Access);
      Register_Adv_Mutex_Creation_Function (Create'Access);
      Register_Task_Identification
        (Task_Id_Function'(Get_Current_Task'Access),
         Task_Id_Function'(Get_Null_Task'Access));
   end Initialize;

   -----------
   -- Leave --
   -----------

   procedure Leave (M : in Unprotected_Adv_Mutex_Type) is
   begin
      pragma Warnings (Off);
      pragma Unreferenced (M);
      pragma Warnings (On);
      null;
   end Leave;

   -----------
   -- Leave --
   -----------

   procedure Leave (M : in Unprotected_Mutex_Type) is
   begin
      pragma Warnings (Off);
      pragma Unreferenced (M);
      pragma Warnings (On);
      null;
   end Leave;

   ------------
   -- Lookup --
   ------------

   procedure Lookup (W : in Unprotected_Watcher_Type; V : out Version_Id) is
   begin
      pragma Assert (W.X /= null);

      V := W.X.Version;
   end Lookup;

   ------------
   -- Update --
   ------------

   procedure Update (W : in Unprotected_Watcher_Type) is
   begin
      pragma Assert (W.X /= null);

      W.X.Version := W.X.Version + 1;
   end Update;

   ------------------
   -- Current_Task --
   ------------------

   function Get_Current_Task return Soft_Links.Task_Id'Class is
   begin
      return No_Task_Id'(Is_Null => False);
   end Get_Current_Task;

   ---------------
   -- Null_Task --
   ---------------

   function Get_Null_Task return Soft_Links.Task_Id'Class is
   begin
      return No_Task_Id'(Is_Null => True);
   end Get_Null_Task;

   -----------
   -- Image --
   -----------

   function Image (T : No_Task_Id) return String is
   begin
      if T.Is_Null then
         return "null_task";
      else
         return "environment_task";
      end if;
   end Image;

   ----------------
   -- To_Integer --
   ----------------

   function To_Integer (T : No_Task_Id) return Integer is
   begin
      pragma Warnings (Off);
      pragma Unreferenced (T);
      pragma Warnings (On);
      return 0;
   end To_Integer;

   use PolyORB.Initialization;
   use PolyORB.Initialization.String_Lists;
   use PolyORB.Utils.Strings;

begin
   Register_Module
     (Module_Info'
      (Name => +"no_tasking",
       Conflicts => Empty,
       Depends => Empty,
       Provides => +"soft_links",
       Init => Initialize'Access));
end PolyORB.No_Tasking;
