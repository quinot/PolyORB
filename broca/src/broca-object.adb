------------------------------------------------------------------------------
--                                                                          --
--                          ADABROKER COMPONENTS                            --
--                                                                          --
--                         B R O C A . O B J E C T                          --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--          Copyright (C) 1999-2000 ENST Paris University, France.          --
--                                                                          --
-- AdaBroker is free software; you  can  redistribute  it and/or modify it  --
-- under terms of the  GNU General Public License as published by the  Free --
-- Software Foundation;  either version 2,  or (at your option)  any  later --
-- version. AdaBroker  is distributed  in the hope that it will be  useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License  for more details.  You should have received  a copy of the GNU  --
-- General Public License distributed with AdaBroker; see file COPYING. If  --
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
--             AdaBroker is maintained by ENST Paris University.            --
--                     (email: broker@inf.enst.fr)                          --
--                                                                          --
------------------------------------------------------------------------------

with Ada.Unchecked_Deallocation;

with CORBA;

with Broca.IOP;
with Broca.Buffers; use Broca.Buffers;
with Broca.Exceptions;

package body Broca.Object is

   --------------
   -- Finalize --
   --------------

   procedure Finalize
     (O : in out Object_Type)
   is
      use Broca.IOP;

      procedure Free is
         new Ada.Unchecked_Deallocation
        (Profile_Type'Class, Profile_Ptr);
      procedure Free is
         new Ada.Unchecked_Deallocation
        (Profile_Ptr_Array, Profile_Ptr_Array_Ptr);

   begin
      for I in O.Profiles'Range loop
         --  FIXME: Should finalize the profile
         --    (eg close any associated connection
         --    that won't be reused.)
         --    This job should be perform by the profile's
         --    Finalize operation (profiles are controlled).
         Free (O.Profiles (I));
      end loop;
      Free (O.Profiles);
   end Finalize;

   --------------
   -- Marshall --
   --------------

   procedure Marshall
     (Buffer : access Buffer_Type;
      Value  : in Broca.Object.Object_Type) is
   begin
      Broca.IOP.Encapsulate_IOR (Buffer, Value.Type_Id, Value.Profiles);
   end Marshall;

   ----------------
   -- Unmarshall --
   ----------------

   procedure Unmarshall
     (Buffer : access Buffer_Type;
      Result : out Broca.Object.Object_Type)
   is
   begin
      Broca.IOP.Decapsulate_IOR (Buffer, Result.Type_Id, Result.Profiles);
   end Unmarshall;

   ------------------
   -- Find_Profile --
   ------------------

   function Find_Profile
     (Object : Object_Ptr)
     return IOP.Profile_Ptr
   is
      use CORBA;
      use Broca.IOP;

   begin
      pragma Assert (Object /= null);

      --  FIXME: Knowledge about what transport
      --     protocols are supported should not
      --     be embedded here. For now, only IIOP
      --     is supported.

      for I in Object.Profiles'Range loop
         if Get_Profile_Tag (Object.Profiles (I).all)
           = Tag_Internet_IOP then
            return Object.Profiles (I);
         end if;
      end loop;

      Broca.Exceptions.Raise_Bad_Param;
      return null;
   end Find_Profile;

end Broca.Object;
