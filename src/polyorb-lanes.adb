------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                        P O L Y O R B . L A N E S                         --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2004-2006, Free Software Foundation, Inc.          --
--                                                                          --
-- PolyORB is free software; you  can  redistribute  it and/or modify it    --
-- under terms of the  GNU General Public License as published by the  Free --
-- Software Foundation;  either version 2,  or (at your option)  any  later --
-- version. PolyORB is distributed  in the hope that it will be  useful,    --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License  for more details.  You should have received  a copy of the GNU  --
-- General Public License distributed with PolyORB; see file COPYING. If    --
-- not, write to the Free Software Foundation, 51 Franklin Street, Fifth    --
-- Floor, Boston, MA 02111-1301, USA.                                       --
--                                                                          --
-- As a special exception,  if other files  instantiate  generics from this --
-- unit, or you link  this unit with other files  to produce an executable, --
-- this  unit  does not  by itself cause  the resulting  executable  to  be --
-- covered  by the  GNU  General  Public  License.  This exception does not --
-- however invalidate  any other reasons why  the executable file  might be --
-- covered by the  GNU Public License.                                      --
--                                                                          --
--                  PolyORB is maintained by AdaCore                        --
--                     (email: sales@adacore.com)                           --
--                                                                          --
------------------------------------------------------------------------------

with PolyORB.Log;
with PolyORB.ORB;
with PolyORB.QoS.Priority;
with PolyORB.Request_QoS;

package body PolyORB.Lanes is

   use PolyORB.Log;
   use PolyORB.Tasking.Condition_Variables;
   use PolyORB.Tasking.Mutexes;

   package L is new PolyORB.Log.Facility_Log ("polyorb.lanes");
   procedure O (Message : String; Level : Log_Level := Debug)
     renames L.Output;
   function C (Level : Log_Level := Debug) return Boolean
     renames L.Enabled;
   pragma Unreferenced (C); --  For conditional pragma Debug

   ---------
   -- Run --
   ---------

   procedure Run (R : access Lane_Runnable) is
   begin
      pragma Debug (O ("Entering lane's main loop"));

      Enter (R.L.Lock);
      loop
         pragma Debug (O ("Inside lane's main loop"));

         --  Process queued jobs

         while not Is_Empty (R.L.Job_Queue) loop
            pragma Debug (O ("Thread from lane at priority ("
                             & R.L.ORB_Priority'Img & ","
                             & R.L.Ext_Priority'Img & ")"
                             & " will execute a job"));
            declare
               Job : constant Job_Access := Fetch_Job (R.L.Job_Queue);

            begin
               Leave (R.L.Lock);
               PolyORB.ORB.Run (PolyORB.ORB.Request_Job (Job.all)'Access);
               Enter (R.L.Lock);
            end;
         end loop;

         --  Test wether the task shall exit

         exit when R.L.Clean_Up_In_Progress or else R.Dynamically_Allocated;

         --  else go idle

         pragma Debug (O ("No job to process, go idle"));

         R.L.Idle_Tasks := R.L.Idle_Tasks + 1;
         PTCV.Wait (R.L.CV, R.L.Lock);
         R.L.Idle_Tasks := R.L.Idle_Tasks - 1;

      end loop;

      Leave (R.L.Lock);
      pragma Debug (O ("Exiting from lane's main loop"));
   end Run;

   --------------
   -- Add_Lane --
   --------------

   procedure Add_Lane
     (Set   : in out Lanes_Set;
      L     :        Lane_Access;
      Index :        Positive)
   is
   begin
      Set.Set (Index) := L;
   end Add_Lane;

   -------------------
   -- Attach_Thread --
   -------------------

   procedure Attach_Thread (EL : in out Extensible_Lane; T : Thread_Access) is
   begin
      --  XXX hummm, should be some consistency tests to ensure EL's
      --  priority is compatible with T priority

      Thread_Lists.Append (EL.Additional_Threads, T);
   end Attach_Thread;

   ------------
   -- Create --
   ------------

   function Create
     (ORB_Priority              : ORB_Component_Priority;
      Ext_Priority              : External_Priority;
      Base_Number_Of_Threads    : Natural;
      Dynamic_Number_Of_Threads : Natural;
      Stack_Size                : Natural;
      Buffer_Request            : Boolean;
      Max_Buffered_Requests     : PolyORB.Types.Unsigned_Long;
      Max_Buffer_Size           : PolyORB.Types.Unsigned_Long)
    return Lane_Access
   is
      Result : constant Lane_Access
        := new Lane (ORB_Priority => ORB_Priority,
                     Ext_Priority => Ext_Priority,
                     Base_Number_Of_Threads => Base_Number_Of_Threads,
                     Dynamic_Number_Of_Threads => Dynamic_Number_Of_Threads,
                     Stack_Size => Stack_Size,
                     Buffer_Request => Buffer_Request,
                     Max_Buffered_Requests => Max_Buffered_Requests,
                     Max_Buffer_Size => Max_Buffer_Size);

   begin
      pragma Debug (O ("Creating lane with"
                       & Positive'Image (Base_Number_Of_Threads)
                       & " threads at priority ("
                       & ORB_Priority'Img & ","
                       & Ext_Priority'Img & ")"));

      Create (Result.Lock);
      Create (Result.CV);

      Result.Job_Queue := Create_Queue;

      for J in 1 .. Base_Number_Of_Threads loop
         declare
            New_Runnable : constant Lane_Runnable_Access := new Lane_Runnable;

         begin
            New_Runnable.L := Result;
            New_Runnable.Dynamically_Allocated := False;

            declare
               T : constant Thread_Access :=
                 Run_In_Task
                 (TF               => Get_Thread_Factory,
                  Name             => "",
                  Default_Priority => ORB_Priority,
                  Storage_Size     => Stack_Size,
                  R                => Runnable_Access (New_Runnable),
                  C                => new Runnable_Controller);
               pragma Unreferenced (T);
            begin
               null;
            end;
         end;
      end loop;

      return Result;
   end Create;

   -------------
   -- Destroy --
   -------------

   procedure Destroy (L : access Lane) is
   begin
      L.Clean_Up_In_Progress := True;

      Broadcast (L.CV);
   end Destroy;

   procedure Destroy (L : access Lanes_Set) is
   begin
      for J in L.Set'Range loop
         Destroy (L.Set (J));
      end loop;
   end Destroy;

   ---------------
   -- Queue_Job --
   ---------------

   procedure Queue_Job
     (L             : access Lane;
      J             :        Job_Access;
      Hint_Priority :        External_Priority := Invalid_Priority)
   is
      pragma Unreferenced (Hint_Priority);

   begin
      pragma Debug (O ("Queue job in lane at priority ("
                       & L.ORB_Priority'Img & ","
                       & L.Ext_Priority'Img & ")"));

      Enter (L.Lock);

      --  Queue job in common job queue

      if (not L.Buffer_Request
          and then Length (L.Job_Queue) < L.Base_Number_Of_Threads)
        or else
        (L.Buffer_Request
         and then Length (L.Job_Queue) < Natural (L.Max_Buffered_Requests))
      then
         pragma Debug (O ("Queue job on job queue"));

         Queue_Job (L.Job_Queue, J);

         if L.Idle_Tasks > 0 then

            --  If there are idle tasks, awake one

            Signal (L.CV);
            Leave (L.Lock);
            return;

         elsif L.Dynamic_Threads_Created < L.Dynamic_Number_Of_Threads then

            --  Eventually, create a new task

            declare
               New_Runnable : constant Lane_Runnable_Access
                 := new Lane_Runnable;

            begin
               New_Runnable.L := Lane_Access (L);
               New_Runnable.Dynamically_Allocated := True;

               declare
                  T : constant Thread_Access :=
                    Run_In_Task
                    (TF               => Get_Thread_Factory,
                     Name             => "",
                     Default_Priority => L.ORB_Priority,
                     Storage_Size     => L.Stack_Size,
                     R                => Runnable_Access (New_Runnable),
                     C                => new Runnable_Controller);
                  pragma Unreferenced (T);
               begin
                  null;
               end;
            end;

            L.Dynamic_Threads_Created := L.Dynamic_Threads_Created + 1;
         end if;

         Leave (L.Lock);
         return;

      else
         --  Cannot queue job

         Leave (L.Lock);
         pragma Debug (O ("Cannot queue job"));
         raise Program_Error;
      end if;
   end Queue_Job;

   procedure Queue_Job
     (L             : access Lanes_Set;
      J             :        Job_Access;
      Hint_Priority :        External_Priority := Invalid_Priority)
   is
      use PolyORB.QoS;
      use PolyORB.QoS.Priority;
      use PolyORB.Request_QoS;

      RJ : PolyORB.ORB.Request_Job renames PolyORB.ORB.Request_Job (J.all);

      Parameter : constant QoS_Parameter_Access
        := Extract_Request_Parameter (Static_Priority, RJ.Request);

      Queuing_Priority : External_Priority;

   begin
      if Parameter /= null then
         pragma Debug (O ("About to queue a job at priority"
                          & QoS_Static_Priority (Parameter.all).EP'Img));

         Queuing_Priority := QoS_Static_Priority (Parameter.all).EP;

         Add_Reply_QoS
           (RJ.Request,
            Static_Priority,
            new QoS_Parameter'Class'(Parameter.all));

      elsif Hint_Priority /= Invalid_Priority then
         pragma Debug (O ("About to queue a job at priority"
                          & Hint_Priority'Img));
         Queuing_Priority := Hint_Priority;

      else
         pragma Debug (O ("No priority information !"));
         raise Program_Error;
      end if;

      for K in L.Set'Range loop
         pragma Debug (O ("Testing lane, priority"
                          & ORB_Priority'Image (L.Set (K).ORB_Priority)));

         if L.Set (K).Ext_Priority = Queuing_Priority then
            Queue_Job (L.Set (K), J);

            return;
         end if;
      end loop;

      pragma Debug
        (O ("Cannot queue job, no lane matches request priority"));
      raise Program_Error;
   end Queue_Job;

   -----------------------
   -- Is_Valid_Priority --
   -----------------------

   function Is_Valid_Priority
     (L        : access Lane;
      Priority :        External_Priority)
     return Boolean
   is
   begin
      return L.Ext_Priority = Priority;
   end Is_Valid_Priority;

   function Is_Valid_Priority
     (L        : access Lanes_Set;
      Priority :        External_Priority)
     return Boolean
   is
   begin
      for J in L.Set'Range loop
         if L.Set (J).all.Ext_Priority = Priority then
            return True;
         end if;
      end loop;

      return False;
   end Is_Valid_Priority;

end PolyORB.Lanes;
