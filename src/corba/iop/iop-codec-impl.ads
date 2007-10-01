------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                       I O P . C O D E C . I M P L                        --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2004-2007, Free Software Foundation, Inc.          --
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

with CORBA.Local;
with PolyORB.Representations.CDR;

package IOP.Codec.Impl is

   type Object is new CORBA.Local.Object with private;

   type Object_Ptr is access all Object'Class;

   function Encode
     (Self : access Object;
      Data : CORBA.Any)
     return CORBA.IDL_SEQUENCES.OctetSeq;

   function Decode
     (Self : access Object;
      Data : CORBA.IDL_SEQUENCES.OctetSeq)
     return CORBA.Any;

   function Encode_Value
     (Self : access Object;
      Data : CORBA.Any)
     return CORBA.IDL_SEQUENCES.OctetSeq;

   function Decode_Value
     (Self : access Object;
      Data : CORBA.IDL_SEQUENCES.OctetSeq;
      TC   : CORBA.TypeCode.Object)
     return CORBA.Any;

   procedure Init
     (Self           : access Object;
      Representation :
        PolyORB.Representations.CDR.CDR_Representation_Access);
   --  Internal initialization subprogram

private

   type Object is new CORBA.Local.Object with record
      Representation : PolyORB.Representations.CDR.CDR_Representation_Access;
   end record;

   function Is_A
     (Self            : access Object;
      Logical_Type_Id : Standard.String)
     return Boolean;

   --  Derived from PolyORB.Smart_Pointers.Entity

   procedure Finalize (Self : in out Object);

end IOP.Codec.Impl;
