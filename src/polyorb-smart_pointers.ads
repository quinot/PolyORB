------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--               P O L Y O R B . S M A R T _ P O I N T E R S                --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2001-2007, Free Software Foundation, Inc.          --
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

with Ada.Finalization;

with PolyORB.Tasking.Mutexes;

package PolyORB.Smart_Pointers is

   pragma Preelaborate;

   ------------------------
   -- Task-unsafe entity --
   ------------------------

   type Unsafe_Entity is abstract tagged limited private;

   procedure Finalize (X : in out Unsafe_Entity);
   --  Unsafe_Entity is the base type of all objects that can be
   --  referenced. It contains a Counter, which is the number of
   --  references to this object, and is automatically destroyed when
   --  the counter reaches 0. Before the entity is destroyed,
   --  the Finalize operation is called. NOTE however that
   --  Unsafe_Entity is *not* a controlled type: Finalize
   --  is *only* called when an Entity is destroyed as a result
   --  of its reference counter dropping to 0.

   type Entity_Ptr is access all Unsafe_Entity'Class;

   procedure Entity_Lock (X : in out Unsafe_Entity);
   procedure Entity_Unlock (X : in out Unsafe_Entity);
   --  Lock/unlock operations to be overloaded by derived types
   --  if they need to be made task-safe. These operations must
   --  guarantee mutual exclusion on accesses to the reference
   --  counter.

   function Reference_Counter (Obj : Unsafe_Entity) return Integer;
   --  Return the value of Obj's reference counter.
   --  This function is not task safe, and must not be used for anything but
   --  debugging and the checking of assertions.

   ----------------------
   -- Task-safe entity --
   ----------------------

   type Non_Controlled_Entity is abstract new Unsafe_Entity with private;
   --  Same as Unsafe_Entity, but accesses to the reference counter are
   --  made task safe through calls to the Entity_Lock and Entity_Unlock
   --  operations.

   procedure Entity_Lock (X : in out Non_Controlled_Entity);
   procedure Entity_Unlock (X : in out Non_Controlled_Entity);
   --  Mutex operations

   ---------------------------------
   -- Controlled task-safe entity --
   ---------------------------------

   type Entity is abstract new Non_Controlled_Entity with private;

   procedure Initialize (X : in out Entity);
   --  An entity that is a controlled object. Contrary to
   --  Non_Controlled_Entity, the Finalize operation is called
   --  whenever the entity is finalized.

   ---------
   -- Ref --
   ---------

   type Ref is new Ada.Finalization.Controlled with private;
   --  The base type of all references. This type is often derived
   --  but never extended. It contains one field, which designates
   --  the referenced object.

   procedure Adjust     (The_Ref : in out Ref);
   procedure Finalize   (The_Ref : in out Ref);

   procedure Set
     (The_Ref    : in out Ref;
      The_Entity : Entity_Ptr);
   --  Make The_Ref designate The_Entity, and increment The_Entity's usage
   --  counter. The_Entity's reference counter is allowed to be 0 only when
   --  creating the first reference to it.

   procedure Reuse_Entity
     (The_Ref    : in out Ref;
      The_Entity : Entity_Ptr);
   --  Equivalent to Set (The_Ref, The_Entity) if The_Entity's usage counter
   --  is strictly greater than 0. Otherwise, The_Ref is left unchanged.
   --  It is the caller's responsibility to ensure that The_Entity points
   --  to a valid Entity object (even in the latter case). This allows a
   --  reference to be reconstructed from a saved Entity_Ptr value, ensuring
   --  that the designated entity is not being finalized.

   procedure Unref (The_Ref : in out Ref)
     renames Finalize;

   function Is_Nil (The_Ref : Ref) return Boolean;
   --  True iff The_Ref is a nil reference

   function Is_Null (The_Ref : Ref) return Boolean
     renames Is_Nil;

   procedure Duplicate (The_Ref : in out Ref)
     renames Adjust;
   pragma Unreferenced (Duplicate);

   procedure Release (The_Ref : in out Ref);
   --  Reset The_Ref to nil

   function Entity_Of (The_Ref : Ref) return Entity_Ptr;
   --  Return the entity designated by The_Ref

   function Same_Entity (Left, Right : Ref) return Boolean;
   --  True if Left and Right designate the same entity

   --  The following two low-level functions are exposed for cases where
   --  controlled types cannot be directly used in a personality. Great care
   --  must be taken when using them outside of this unit!

   procedure Inc_Usage (Obj : Entity_Ptr);
   --  Increment Obj's reference counter

   procedure Dec_Usage (Obj : in out Entity_Ptr);
   --  Decremement Obj's reference counter; if it drops to zero, deallocate
   --  the designated object, and reset Obj to null.

private

   ------------------------
   -- Task-unsafe entity --
   ------------------------

   type Unsafe_Entity is abstract tagged limited record
      Counter : Integer := 0;
      --  Reference counter.
   end record;

   ----------------------
   -- Task-safe entity --
   ----------------------

   Counter_Lock : Tasking.Mutexes.Mutex_Access;
   --  Global mutex used to guarantee consistency of concurrent accesses to
   --  entity reference counters. To be created by a child unit during
   --  PolyORB initialization.

   type Non_Controlled_Entity is abstract new Unsafe_Entity with null record;

   type Entity_Controller (E : access Entity'Class)
      is new Ada.Finalization.Limited_Controlled with null record;

   procedure Initialize (X : in out Entity_Controller);
   procedure Finalize   (X : in out Entity_Controller);

   type Entity is abstract new Non_Controlled_Entity with record
      Controller : Entity_Controller (Entity'Access);
      --  Controller component used to trigger a call to the Entity's
      --  Finalize primitive operation when it is Finalized (note that
      --  Entity itself is not a controlled type).
   end record;

   type Ref is new Ada.Finalization.Controlled with record
      A_Ref : Entity_Ptr := null;
      --  The entity designated by this reference
   end record;

   ---------------------
   -- Debugging hooks --
   ---------------------

   --  For debugging purposes, the body of this unit needs to call
   --  Ada.Tags.External_Tag for entities and references. However, we do not
   --  want any dependence on Ada.Tags, because that would prevent this unit
   --  from being preelaborable. So, we call External_Tag indirectly through
   --  a hook that is set during PolyORB initialization.

   type Entity_External_Tag_Hook is access
     function (X : Unsafe_Entity'Class) return String;
   --  A function returning External_Tag (X'Tag)

   type Ref_External_Tag_Hook is access
     function (X : Ref'Class) return String;
   --  A function returning External_Tag (Entity_Of (X)'Tag)

   Entity_External_Tag : Entity_External_Tag_Hook := null;
   Ref_External_Tag    : Ref_External_Tag_Hook := null;
   --  Hooks to be set up by a child unit during PolyORB initialization

   --  Determination of whether to trace smart pointers event for a specific
   --  entity type: in [smart_pointers] section, whether type T is traced
   --  is determined by parameter T.trace, or if not set, by default.trace.
   --  By default event is traced.

   Trace_Section : constant String := "smart_pointers";
   Trace_Suffix  : constant String := ".trace";

   Default_Trace : Boolean := True;

   function Get_Trace (Entity_Type : String) return Boolean;
   --  Return indication of whether to trace events for the given entity type

end PolyORB.Smart_Pointers;
