------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--            P O L Y O R B . R A V E N S C A R . T H R E A D S             --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--             Copyright (C) 1999-2002 Free Software Fundation              --
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

--  Implementation of Threads under the Ravenscar profile.

--  $Id$

with Unchecked_Deallocation;

with PolyORB.Ravenscar.Index_Manager;
with PolyORB.Ravenscar.Configuration;
with Ada.Task_Identification;

with PolyORB.Initialization;
with PolyORB.Utils.Strings;

package body PolyORB.Ravenscar.Threads is

   package PTT renames PolyORB.Tasking.Threads;

   ---------
   -- Ids --
   ---------

   --  Id are associated to the tasks created from this package.
   --  The first Id is reserved to the main context, which
   --  is the task that execute the Initialize procedure of this package.
   --  In this package, it is called the main task, and the Thread object
   --  associated to it is called the main Thread.


   package My_Index_Manager is
      new PolyORB.Ravenscar.Index_Manager
     (PolyORB.Ravenscar.Configuration.Number_Of_Threads - 1);

   subtype Task_Index_Type is My_Index_Manager.Index_Type;
   --  Type of the Ids of the Threads that are not the one of the main task.

   subtype Thread_Index_Type is Integer
     range Task_Index_Type'First .. Task_Index_Type'Last + 1;
   --  Type of the Ids of all the Threads, including the one
   --  of the main task


   --  paramaters associated to this main task :

   Main_Task_Id     : constant Integer := Thread_Index_Type'Last;

   Main_Task_Tid    : Ada.Task_Identification.Task_Id;

   -------------------
   -- Tasking Types --
   -------------------

   --  Tasking type used in the pools preallocated by this package:

   task type Simple_Task;
   --  Type of the task that run the submitted threads
   --  XXX We should use a facade package to some pools.
   --      The pool packages will generated from the configuration
   --      file.

   protected type Barrier is
      --  Type of the internal synchronisation object of the tasks
      --  allocated through this package.
      --  A call to Suspend will result in a call to Wait;
      --  a call to Resume will result in a call to Signal.

      entry Wait;
      --  Wait until it is signaled.

      procedure Signal;
      --  Signal the Suspension_Object

   private
      Signaled : Boolean := False;
      Count    : Integer := 0;
   end Barrier;

   -----------
   -- Pools --
   -----------

   --  Every object used in this package is preallocated at initialisation
   --  time, in a pool.

   type Task_Id_Arr is array (Thread_Index_Type)
     of Ada.Task_Identification.Task_Id;
   --  Table of the Task_Id of the task of the pool.

   protected Pool_Manager is
      --  Protected manager for the pool.

      procedure Initialize_Id
        (Tid : Ada.Task_Identification.Task_Id;
         Id  : out Thread_Index_Type);
      --  This procedure is called at iniatialisation time
      --  by the tasks, to get a unique id.

      procedure Create_Thread
        (Id  : Thread_Index_Type;
         Run : access Runnable'Class;
         T   : out Thread_Access);
      --  This is the protected section of the Create_Thread procedure.

      function Lookup (Tid : Ada.Task_Identification.Task_Id)
                      return Integer;
      --  Get the Thread_Access associated to the given Task_Id.

      procedure Initialize;
      --  Initialisation procedure of Pool_Manager.

   private
      Current        : Integer := Task_Index_Type'First;
      My_Task_Id_Arr : Task_Id_Arr;
   end Pool_Manager;

   type Thread_Arr is array (Thread_Index_Type)
     of aliased Ravenscar_Thread_Type;

   My_Thread_Arr  : Thread_Arr;
   --  Pool of Threads.

   Task_Pool : array (Task_Index_Type) of Simple_Task;
   pragma Warnings (Off);
   pragma Unreferenced (Task_Pool);
   pragma Warnings (On);
   --  Pool of preallocated tasks.

   type Barrier_Arr is array (Thread_Index_Type)
     of Barrier;

   Sync_Pool : Barrier_Arr;
   --  Pool of Barrier.

   ----------
   -- Free --
   ----------

   procedure Free is new Unchecked_Deallocation
     (Runnable'Class, Runnable_Access);

   ---------
   -- "=" --
   ---------

   function "="
     (T1 : Ravenscar_Thread_Id;
      T2 : Ravenscar_Thread_Id)
     return Boolean is
   begin
      return T1.Id = T2.Id;
   end "=";


   -------------
   -- Barrier --
   -------------

   protected body Barrier is

      ------------
      -- Signal --
      ------------

      procedure Signal is
      begin
         Count := Count + 1;
         Signaled := True;
      end Signal;

      ----------
      -- Wait --
      ----------

      entry Wait when Signaled is
      begin
         Count := Count - 1;

         if Count = 0 then
            Signaled := False;
         end if;
      end Wait;

   end Barrier;

   --------------------
   -- Copy_Thread_Id --
   --------------------

   procedure Copy_Thread_Id
     (TF     : access Ravenscar_Thread_Factory_Type;
      Source : Thread_Id'Class;
      Target : Thread_Id_Access) is
      pragma Warnings (Off);
      pragma Unreferenced (TF);
      pragma Warnings (On);
      Result  : constant Ravenscar_Thread_Id_Access
        := Ravenscar_Thread_Id_Access (Target);
      Content : constant Ravenscar_Thread_Id
        := Ravenscar_Thread_Id (Source);
   begin
      Result.Id := Content.Id;
   end Copy_Thread_Id;

   -----------------
   -- Create_Task --
   -----------------

   procedure Create_Task
     (TF : in out  Ravenscar_Thread_Factory_Type;
      T  : access Thread_Type'Class) is
      pragma Warnings (Off);
      pragma Unreferenced (TF);
      pragma Warnings (On);
      RT : constant Ravenscar_Thread_Access := Ravenscar_Thread_Access (T);
   begin
      pragma Assert (RT.Id.Id /= Main_Task_Id);
      Sync_Pool (RT.Id.Id).Signal;
   end Create_Task;

   -------------------
   -- Create_Thread --
   -------------------

   function Create_Thread
     (TF   : access Ravenscar_Thread_Factory_Type;
      Name : String := "";
      Default_Priority : System.Any_Priority := System.Default_Priority;
      R    : access Runnable'Class)
     return Thread_Access is
      pragma Warnings (Off);
      pragma Unreferenced (TF);
      pragma Unreferenced (Name);
      pragma Unreferenced (Default_Priority);
      pragma Warnings (On);
      --  XXX The use of names and prioritiesis not implemented yet.
      Id : Thread_Index_Type;
      T  : Thread_Access;
   begin
      --  The following call should not be executed in a protected
      --  object, because it can be blocking.
      My_Index_Manager.Get (Id);
      Pool_Manager.Create_Thread (Id, R, T);
      return T;
   end Create_Thread;

   ---------------------------
   -- Get_Current_Thread_Id --
   ---------------------------

   function Get_Current_Thread_Id
     (TF : access Ravenscar_Thread_Factory_Type)
     return Thread_Id'Class is
      pragma Warnings (Off);
      pragma Unreferenced (TF);
      pragma Warnings (On);
      Task_Id : constant Ada.Task_Identification.Task_Id
        := Ada.Task_Identification.Current_Task;
      Result  : Ravenscar_Thread_Id;
   begin
      Result.Id := Pool_Manager.Lookup (Task_Id);
      return Thread_Id'Class (Result);
   end Get_Current_Thread_Id;

   -------------------
   -- Get_Thread_Id --
   -------------------

   function Get_Thread_Id (T : access Ravenscar_Thread_Type)
                          return Thread_Id_Access is
   begin
      return T.Id'Access;
   end Get_Thread_Id;

   ----------------------
   -- Get_Thread_Index --
   ----------------------

   function Get_Thread_Index (T : Ravenscar_Thread_Id)
                             return Integer is
   begin
      return T.Id;
   end Get_Thread_Index;

   -----------
   -- Image --
   -----------

   function Image (T : Ravenscar_Thread_Id) return String is
   begin
      return Integer'Image (T.Id);
   end Image;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      Pool_Manager.Initialize;
      PTT.Register_Thread_Factory (PTT.Thread_Factory_Access
                                   (The_Thread_Factory));
   end Initialize;

   ------------------
   -- Pool_Manager --
   ------------------

   protected body Pool_Manager is

      --------------------------------
      -- Pool_Manager.Create_Thread --
      --------------------------------

      procedure Create_Thread
        (Id  : Thread_Index_Type;
         Run : access Runnable'Class;
         T   : out Thread_Access) is
         Result : Ravenscar_Thread_Access;
      begin
         My_Thread_Arr (Id).Run := new Runnable'Class'(Run.all);
         Result := My_Thread_Arr (Id)'Access;
         T := Thread_Access (Result);
      end Create_Thread;

      -----------------------------
      -- Pool_Manager.Initialize --
      -----------------------------

      procedure Initialize is
      begin
         My_Index_Manager.Initialize;
         Main_Task_Tid := Ada.Task_Identification.Current_Task;
         My_Task_Id_Arr (Main_Task_Id) := Main_Task_Tid;
         My_Thread_Arr (Main_Task_Id).Id.Id := Main_Task_Id;
      end Initialize;

      --------------------------------
      -- Pool_Manager.Initialize_Id --
      --------------------------------

      procedure Initialize_Id
        (Tid : Ada.Task_Identification.Task_Id;
         Id  : out Thread_Index_Type) is
      begin
         pragma Assert (Current <= Thread_Index_Type'Last);
         Id := Current;
         My_Thread_Arr (Id).Id.Id := Id;
         My_Task_Id_Arr (Current) := Tid;
         Current := Current + 1;
      end Initialize_Id;

      -------------------------
      -- Pool_Manager.Lookup --
      -------------------------

      function Lookup (Tid : Ada.Task_Identification.Task_Id)
                      return Integer is
         J : Integer := Thread_Index_Type'First;
         use Ada.Task_Identification;
         --  Result : Ravenscar_Thread_Access;
      begin
         while My_Task_Id_Arr (J) /= Tid loop
            pragma Assert (J /= Thread_Index_Type'Last);
            J := J + 1;
         end loop;
         --  Result :=  My_Thread_Arr (J)'Access;
         return J;
         --  Thread_Access (Result);
      end Lookup;

   end Pool_Manager;

   ---------
   -- Run --
   ---------

   procedure Run (T : access Ravenscar_Thread_Type) is
   begin
      PTT.Run (T.Run);
   end Run;

   -----------------
   -- Simple_Task --
   -----------------

   task body Simple_Task is
      Id    : Integer;
      Tid   : constant Ada.Task_Identification.Task_Id
        := Ada.Task_Identification.Current_Task;
      Th_Id : Ravenscar_Thread_Id;
   begin
      Pool_Manager.Initialize_Id (Tid, Id);
      Th_Id.Id := Id;
      loop
         Suspend (Th_Id);
         Run (My_Thread_Arr (Id)'Access);
         Free (My_Thread_Arr (Id).Run);
         My_Index_Manager.Release (Id);
      end loop;
   end Simple_Task;

   ------------
   -- Resume --
   ------------

   procedure Resume (T : Ravenscar_Thread_Id) is
   begin
      Sync_Pool (T.Id).Signal;
   end Resume;

   -------------
   -- Suspend --
   -------------

   procedure Suspend (T : Ravenscar_Thread_Id) is
   begin
      Sync_Pool (T.Id).Wait;
   end Suspend;

   use PolyORB.Initialization;
   use PolyORB.Initialization.String_Lists;
   use PolyORB.Utils.Strings;

begin
   Register_Module
     (Module_Info'
      (Name => +"ravenscar-threads",
       Conflicts => Empty,
       Depends => Empty,
       Provides => +"tasking-threads",
       Init => Initialize'Access));
end PolyORB.Ravenscar.Threads;


