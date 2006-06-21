------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                       P O R T A B L E S E R V E R                        --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2001-2006, Free Software Foundation, Inc.          --
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

with Ada.Streams;
with Ada.Tags;
with Ada.Unchecked_Conversion;

with PolyORB.CORBA_P.Names;
with PolyORB.CORBA_P.Interceptors_Hooks;

with PolyORB.Errors;
with PolyORB.Exceptions;
with PolyORB.Initialization;
with PolyORB.Log;
with PolyORB.Servants.Iface;
with PolyORB.Smart_Pointers;
with PolyORB.Tasking.Threads.Annotations;
with PolyORB.Utils.Chained_Lists;
with PolyORB.Utils.Strings;

package body PortableServer is

   use PolyORB.Log;

   package L is new PolyORB.Log.Facility_Log ("portableserver");
   procedure O (Message : Standard.String; Level : Log_Level := Debug)
     renames L.Output;
   function C (Level : Log_Level := Debug) return Boolean
     renames L.Enabled;
   pragma Unreferenced (C); --  For conditional pragma Debug

   ---------------------------------------
   -- Information about a skeleton unit --
   ---------------------------------------

   type Skeleton_Info is record
      Type_Id     : CORBA.RepositoryId;
      Is_A        : Internals.Servant_Class_Predicate;
      Target_Is_A : Internals.Servant_Class_Is_A_Operation;
      Dispatcher  : Internals.Request_Dispatcher;
   end record;

   function Find_Info
     (For_Servant : Servant)
     return Skeleton_Info;

   package Skeleton_Lists is new PolyORB.Utils.Chained_Lists
     (Skeleton_Info);

   All_Skeletons : Skeleton_Lists.List;

   Skeleton_Unknown : exception;

   type Dispatcher_Note is new PolyORB.Annotations.Note with record
      Skeleton : Internals.Request_Dispatcher;
   end record;

   Null_Dispatcher_Note : constant Dispatcher_Note
     := (PolyORB.Annotations.Note with Skeleton => null);

   procedure Default_Invoke
     (Servant : access PolyORB.Smart_Pointers.Entity'Class;
      Request : PolyORB.Requests.Request_Access;
      Profile : PolyORB.Binding_Data.Profile_Access);
   --  This is the default server side invocation handler.

   --------------------
   -- Default_Invoke --
   --------------------

   procedure Default_Invoke
     (Servant : access PolyORB.Smart_Pointers.Entity'Class;
      Request : PolyORB.Requests.Request_Access;
      Profile : PolyORB.Binding_Data.Profile_Access)
   is
      pragma Unreferenced (Profile);
   begin
      Invoke (DynamicImplementation'Class (Servant.all)'Access,
              Request);
      --  Redispatch
   end Default_Invoke;

   ---------------------
   -- Execute_Servant --
   ---------------------

   function Execute_Servant
     (Self : access DynamicImplementation;
      Msg  :        PolyORB.Components.Message'Class)
     return PolyORB.Components.Message'Class
   is
      use PolyORB.Servants.Iface;

   begin
      pragma Debug (O ("Execute_Servant: enter"));

      if Msg in Execute_Request then
         declare
            use CORBA.ServerRequest;
            use PolyORB.Annotations;
            use PolyORB.Binding_Data;
            use PolyORB.Errors;
            use PolyORB.Requests;
            use PolyORB.Tasking.Threads.Annotations;

            R         : constant Request_Access := Execute_Request (Msg).Req;
            P         : constant Profile_Access := Execute_Request (Msg).Pro;
            Error     : Error_Container;

         begin
            if PortableServer_Current_Registered then
               declare
                  Notepad   : constant Notepad_Access
                    := Get_Current_Thread_Notepad;
                  Save_Note : PortableServer_Current_Note;
                  Note      : constant PortableServer_Current_Note
                    := (PolyORB.Annotations.Note with Request => R,
                        Profile => P);

               begin
                  --  Save POA Current note

                  Get_Note (Notepad.all, Save_Note,
                            Null_PortableServer_Current_Note);

                  --  Set new POA Current note

                  Set_Note (Notepad.all, Note);

                  --  Process invocation

                  PolyORB.CORBA_P.Interceptors_Hooks.Server_Invoke
                    (DynamicImplementation'Class (Self.all)'Access, R, P);

                  --  Restore original POA Current note

                  Set_Note (Notepad.all, Save_Note);
               end;

            else
               --  Process invocation

               PolyORB.CORBA_P.Interceptors_Hooks.Server_Invoke
                 (DynamicImplementation'Class (Self.all)'Access, R, P);
            end if;

            if R.Arguments_Called then

               --  Implementation Note: As part of PortableInterceptors
               --  specifications, an interception point may raise an
               --  exception before Arguments is called.
               --
               --  As a consequence, set out arguments iff the
               --  skeleton called Arguments.

               pragma Debug
                 (O ("Execute_Servant: executed, setting out args"));
               Set_Out_Args (R, Error);

               if Found (Error) then
                  raise Program_Error;
                  --  XXX We should do something if we find a PolyORB exception

               end if;
            end if;

            pragma Debug (O ("Execute_Servant: leave"));
            return Executed_Request'(Req => R);
         end;

      else
         pragma Debug (O ("Execute_Servant: bad message, leave"));
         raise Program_Error;

      end if;
   end Execute_Servant;

   ------------
   -- Invoke --
   ------------

   procedure Invoke
     (Self    : access Servant_Base;
      Request : CORBA.ServerRequest.Object_Ptr)
   is
      use type Internals.Request_Dispatcher;

      P_Servant : constant PolyORB.Servants.Servant_Access :=
        CORBA.Impl.To_PolyORB_Servant
        (CORBA.Impl.Object (Servant (Self).all)'Access);

      Notepad : constant PolyORB.Annotations.Notepad_Access
        := PolyORB.Servants.Notepad_Of (P_Servant);

      Dispatcher : Dispatcher_Note;

   begin
      pragma Debug (O ("Invoke on a static skeleton: enter"));

      --  Information about servant's skeleton is cached in its notepad.

      PolyORB.Annotations.Get_Note
        (Notepad.all, Dispatcher, Null_Dispatcher_Note);

      if Dispatcher.Skeleton = null then
         pragma Debug (O ("Cacheing information about skeleton"));

         Dispatcher.Skeleton := Find_Info (Servant (Self)).Dispatcher;
         PolyORB.Annotations.Set_Note (Notepad.all, Dispatcher);
      end if;

      Dispatcher.Skeleton (Servant (Self), Request);

      pragma Debug (O ("Invoke on a static skeleton: leave"));
   end Invoke;

   package body Internals is

      -----------------
      -- Get_Type_Id --
      -----------------

      function Get_Type_Id
        (For_Servant : Servant)
        return CORBA.RepositoryId
      is
      begin
         return Find_Info (For_Servant).Type_Id;

      exception
         when Skeleton_Unknown =>
            return CORBA.To_CORBA_String
              (PolyORB.CORBA_P.Names.OMG_RepositoryId ("CORBA/OBJECT"));
      end Get_Type_Id;

      -----------------------
      -- Register_Skeleton --
      -----------------------

      procedure Register_Skeleton
        (Type_Id     : CORBA.RepositoryId;
         Is_A        : Servant_Class_Predicate;
         Target_Is_A : Servant_Class_Is_A_Operation;
         Dispatcher  : Request_Dispatcher := null)
      is
         use Skeleton_Lists;

      begin
         pragma Debug (O ("Register_Skeleton: Enter."));

         Prepend (All_Skeletons,
                  (Type_Id     => Type_Id,
                   Is_A        => Is_A,
                   Target_Is_A => Target_Is_A,
                   Dispatcher  => Dispatcher));

         pragma Debug (O ("Registered : type_id = " &
                          CORBA.To_Standard_String (Type_Id)));

      end Register_Skeleton;

      -----------------
      -- Target_Is_A --
      -----------------

      function Target_Is_A
        (For_Servant     : Servant;
         Logical_Type_Id : CORBA.RepositoryId)
        return CORBA.Boolean
      is
      begin
         return
           Find_Info (For_Servant).Target_Is_A
            (CORBA.To_Standard_String (Logical_Type_Id));
      end Target_Is_A;

      -----------------------------------
      -- Target_Most_Derived_Interface --
      -----------------------------------

      function Target_Most_Derived_Interface
        (For_Servant : Servant)
        return CORBA.RepositoryId
      is
      begin
         return Find_Info (For_Servant).Type_Id;
      end Target_Most_Derived_Interface;

      --------------------------
      -- To_PolyORB_Object_Id --
      --------------------------

      function To_PolyORB_Object_Id
        (Id : ObjectId)
        return PolyORB.Objects.Object_Id
      is
         use Ada.Streams;
         use CORBA.IDL_SEQUENCES.IDL_SEQUENCE_Octet;
         use PolyORB.Objects;

         Aux    : constant Element_Array := To_Element_Array (Id);
         Result : Object_Id (Stream_Element_Offset (Aux'First)
                               .. Stream_Element_Offset (Aux'Last));

      begin
         for J in Result'Range loop
            Result (J) := Stream_Element (Aux (Integer (J)));
         end loop;

         return Result;
      end To_PolyORB_Object_Id;

      --------------------------------
      -- To_PortableServer_ObjectId --
      --------------------------------

      function To_PortableServer_ObjectId
        (Id : PolyORB.Objects.Object_Id)
        return ObjectId
      is
         use Ada.Streams;
         use CORBA.IDL_SEQUENCES.IDL_SEQUENCE_Octet;

         Aux : Element_Array (Integer (Id'First) .. Integer (Id'Last));

      begin
         for J in Aux'Range loop
            Aux (J) := CORBA.Octet (Id (Stream_Element_Offset (J)));
         end loop;

         return To_Sequence (Aux);
      end To_PortableServer_ObjectId;

   end Internals;

   ---------------
   -- Find_Info --
   ---------------

   function Find_Info
     (For_Servant : Servant)
     return Skeleton_Info
   is
      use Skeleton_Lists;

      It : Iterator := First (All_Skeletons);

   begin
      pragma Debug
        (O ("Find_Info: servant of type "
            & Ada.Tags.External_Tag (For_Servant'Tag)));

      while not Last (It) loop
         pragma Debug (O ("... skeleton id: "
           & CORBA.To_Standard_String (Value (It).Type_Id)));
         exit when Value (It).Is_A (For_Servant);
         Next (It);
      end loop;

      if Last (It) then
         raise Skeleton_Unknown;
      end if;

      return Value (It).all;
   end Find_Info;

   ------------------------
   -- String_To_ObjectId --
   ------------------------

   function String_To_ObjectId (Id : String) return ObjectId is
      use CORBA.IDL_SEQUENCES.IDL_SEQUENCE_Octet;

      function To_Octet is
        new Ada.Unchecked_Conversion (Character, CORBA.Octet);

      Aux : Element_Array (Id'Range);

   begin
      for J in Aux'Range loop
         Aux (J) := To_Octet (Id (J));
      end loop;

      return To_Sequence (Aux);
   end String_To_ObjectId;

   ------------------------
   -- ObjectId_To_String --
   ------------------------

   function ObjectId_To_String (Id : ObjectId) return String is
      use CORBA.IDL_SEQUENCES.IDL_SEQUENCE_Octet;

      function To_Character is
        new Ada.Unchecked_Conversion (CORBA.Octet, Character);

      Aux    : constant Element_Array := To_Element_Array (Id);
      Result : String (Aux'Range);

   begin
      for J in Result'Range loop
         Result (J) := To_Character (Aux (J));
      end loop;

      return Result;
   end ObjectId_To_String;

   -----------------
   -- Get_Members --
   -----------------

   procedure Get_Members
     (From : Ada.Exceptions.Exception_Occurrence;
      To   : out ForwardRequest_Members)
   is
      use Ada.Exceptions;

   begin
      if Exception_Identity (From) /= ForwardRequest'Identity then
         CORBA.Raise_Bad_Param (CORBA.Default_Sys_Member);
      end if;

      PolyORB.Exceptions.User_Get_Members (From, To);
   end Get_Members;

   procedure Get_Members
     (From : Ada.Exceptions.Exception_Occurrence;
      To   : out NotAGroupObject_Members)
   is
      use Ada.Exceptions;

   begin
      if Exception_Identity (From) /= NotAGroupObject'Identity then
         CORBA.Raise_Bad_Param (CORBA.Default_Sys_Member);
      end if;

      To := NotAGroupObject_Members'
        (CORBA.IDL_Exception_Members with null record);
   end Get_Members;

   --------------------------
   -- Raise_ForwardRequest --
   --------------------------

   procedure Raise_ForwardRequest
     (Excp_Memb : ForwardRequest_Members)
   is
   begin
      PolyORB.Exceptions.User_Raise_Exception
        (PortableServer.ForwardRequest'Identity,
         Excp_Memb);
   end Raise_ForwardRequest;

   ---------------------------
   -- Raise_NotAGroupObject --
   ---------------------------

   procedure Raise_NotAGroupObject
     (Excp_Memb : NotAGroupObject_Members)
   is
      pragma Unreferenced (Excp_Memb);

   begin
      raise NotAGroupObject;
   end Raise_NotAGroupObject;

   --------------
   -- From_Any --
   --------------

   function From_Any
     (Item : CORBA.Any)
     return ThreadPolicyValue
   is
      Index : CORBA.Any :=
        CORBA.Internals.Get_Aggregate_Element (Item,
                                               CORBA.TC_Unsigned_Long,
                                               CORBA.Unsigned_Long (0));
      Position : constant CORBA.Unsigned_Long := CORBA.From_Any (Index);
   begin
      return ThreadPolicyValue'Val (Position);
   end From_Any;

   function From_Any
     (Item : CORBA.Any)
     return LifespanPolicyValue
   is
      Index : CORBA.Any :=
        CORBA.Internals.Get_Aggregate_Element (Item,
                                               CORBA.TC_Unsigned_Long,
                                               CORBA.Unsigned_Long (0));
      Position : constant CORBA.Unsigned_Long := CORBA.From_Any (Index);
   begin
      return LifespanPolicyValue'Val (Position);
   end From_Any;

   function From_Any
     (Item : CORBA.Any)
     return IdUniquenessPolicyValue
   is
      Index : CORBA.Any :=
        CORBA.Internals.Get_Aggregate_Element (Item,
                                               CORBA.TC_Unsigned_Long,
                                               CORBA.Unsigned_Long (0));
      Position : constant CORBA.Unsigned_Long := CORBA.From_Any (Index);
   begin
      return IdUniquenessPolicyValue'Val (Position);
   end From_Any;

   function From_Any
     (Item : CORBA.Any)
     return IdAssignmentPolicyValue
   is
      Index : CORBA.Any :=
        CORBA.Internals.Get_Aggregate_Element (Item,
                                               CORBA.TC_Unsigned_Long,
                                               CORBA.Unsigned_Long (0));
      Position : constant CORBA.Unsigned_Long := CORBA.From_Any (Index);
   begin
      return IdAssignmentPolicyValue'Val (Position);
   end From_Any;

   function From_Any
     (Item : CORBA.Any)
     return ImplicitActivationPolicyValue
   is
      Index : CORBA.Any :=
        CORBA.Internals.Get_Aggregate_Element (Item,
                                               CORBA.TC_Unsigned_Long,
                                               CORBA.Unsigned_Long (0));
      Position : constant CORBA.Unsigned_Long := CORBA.From_Any (Index);
   begin
      return ImplicitActivationPolicyValue'Val (Position);
   end From_Any;

   function From_Any
     (Item : CORBA.Any)
     return ServantRetentionPolicyValue
   is
      Index : CORBA.Any :=
        CORBA.Internals.Get_Aggregate_Element (Item,
                                               CORBA.TC_Unsigned_Long,
                                               CORBA.Unsigned_Long (0));
      Position : constant CORBA.Unsigned_Long := CORBA.From_Any (Index);
   begin
      return ServantRetentionPolicyValue'Val (Position);
   end From_Any;

   function From_Any
     (Item : CORBA.Any)
     return RequestProcessingPolicyValue
   is
      Index : CORBA.Any :=
        CORBA.Internals.Get_Aggregate_Element (Item,
                                               CORBA.TC_Unsigned_Long,
                                               CORBA.Unsigned_Long (0));
      Position : constant CORBA.Unsigned_Long := CORBA.From_Any (Index);
   begin
      return RequestProcessingPolicyValue'Val (Position);
   end From_Any;

   ------------
   -- To_Any --
   ------------

   function To_Any
     (Item : ThreadPolicyValue)
     return CORBA.Any
   is
      Result : CORBA.Any :=
        CORBA.Internals.Get_Empty_Any_Aggregate (TC_ThreadPolicyValue);

   begin
      CORBA.Internals.Add_Aggregate_Element
        (Result,
         CORBA.To_Any
         (CORBA.Unsigned_Long (ThreadPolicyValue'Pos (Item))));

      return Result;
   end To_Any;

   function To_Any
     (Item : LifespanPolicyValue)
     return CORBA.Any
   is
      Result : CORBA.Any :=
        CORBA.Internals.Get_Empty_Any_Aggregate (TC_LifespanPolicyValue);

   begin
      CORBA.Internals.Add_Aggregate_Element
        (Result,
         CORBA.To_Any
         (CORBA.Unsigned_Long (LifespanPolicyValue'Pos (Item))));

      return Result;
   end To_Any;

   function To_Any
     (Item : IdUniquenessPolicyValue)
     return CORBA.Any
   is
      Result : CORBA.Any :=
        CORBA.Internals.Get_Empty_Any_Aggregate (TC_IdUniquenessPolicyValue);

   begin
      CORBA.Internals.Add_Aggregate_Element
        (Result,
         CORBA.To_Any
         (CORBA.Unsigned_Long (IdUniquenessPolicyValue'Pos (Item))));

      return Result;
   end To_Any;

   function To_Any
     (Item : IdAssignmentPolicyValue)
     return CORBA.Any
   is
      Result : CORBA.Any :=
        CORBA.Internals.Get_Empty_Any_Aggregate (TC_IdAssignmentPolicyValue);

   begin
      CORBA.Internals.Add_Aggregate_Element
        (Result,
         CORBA.To_Any
         (CORBA.Unsigned_Long (IdAssignmentPolicyValue'Pos (Item))));

      return Result;
   end To_Any;

   function To_Any
     (Item : ImplicitActivationPolicyValue)
     return CORBA.Any
   is
      Result : CORBA.Any :=
        CORBA.Internals.Get_Empty_Any_Aggregate
        (TC_ImplicitActivationPolicyValue);

   begin
      CORBA.Internals.Add_Aggregate_Element
        (Result,
         CORBA.To_Any
         (CORBA.Unsigned_Long (ImplicitActivationPolicyValue'Pos (Item))));

      return Result;
   end To_Any;

   function To_Any
     (Item : ServantRetentionPolicyValue)
     return CORBA.Any
   is
      Result : CORBA.Any :=
        CORBA.Internals.Get_Empty_Any_Aggregate
        (TC_ServantRetentionPolicyValue);

   begin
      CORBA.Internals.Add_Aggregate_Element
        (Result,
         CORBA.To_Any
         (CORBA.Unsigned_Long (ServantRetentionPolicyValue'Pos (Item))));

      return Result;
   end To_Any;

   function To_Any
     (Item : RequestProcessingPolicyValue)
     return CORBA.Any
   is
      Result : CORBA.Any :=
        CORBA.Internals.Get_Empty_Any_Aggregate
        (TC_RequestProcessingPolicyValue);

   begin
      CORBA.Internals.Add_Aggregate_Element
        (Result,
         CORBA.To_Any
         (CORBA.Unsigned_Long (RequestProcessingPolicyValue'Pos (Item))));

      return Result;
   end To_Any;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize;

   procedure Initialize is
   begin
      PolyORB.CORBA_P.Interceptors_Hooks.Server_Invoke
        := Default_Invoke'Access;
   end Initialize;

   use PolyORB.Initialization;
   use PolyORB.Initialization.String_Lists;
   use PolyORB.Utils.Strings;

begin
   Register_Module
     (Module_Info'
      (Name      => +"portableserver",
       Conflicts => Empty,
       Depends   => Empty,
       Provides  => Empty,
       Implicit  => False,
       Init      => Initialize'Access));
end PortableServer;