------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--       M O M A . P R O V I D E R . M E S S A G E _ P R O D U C E R        --
--                                                                          --
--                                 S p e c                                  --
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

--  Actual implementation of the Message_Producer object. It is
--  derived from PolyORB's Minimal_Servant. This package contains
--  Message_Producer skeleton and implementation subroutines. By
--  construction, its implementation subroutines contain parts of a
--  stub for the Message_Pool object.

--  $Id$

with PolyORB.Minimal_Servant;
with PolyORB.Requests;
with PolyORB.Obj_Adapters.Simple;
with PolyORB.References;

package MOMA.Provider.Message_Producer is

   type Object is new PolyORB.Minimal_Servant.Servant with private;
   --  Remote_Ref : Reference to the remote object to which send messages.

   type Object_Acc is access Object;

   procedure Invoke
     (Self : access Object;
      Req  : in     PolyORB.Requests.Request_Access);
   --  Message_Producer servant skeleton.

   function If_Desc
     return PolyORB.Obj_Adapters.Simple.Interface_Description;
   pragma Inline (If_Desc);
   --  Interface description for SOA object adapter.

   --  Accessors to Object internals.

   function Get_Remote_Ref (Self : Object)
      return PolyORB.References.Ref;

   procedure Set_Remote_Ref (Self : in out Object;
                             Ref  : PolyORB.References.Ref);

private

   type Object is new PolyORB.Minimal_Servant.Servant with record
      Remote_Ref : PolyORB.References.Ref;
   end record;

end MOMA.Provider.Message_Producer;
