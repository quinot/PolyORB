------------------------------------------------------------------------------
--                                                                          --
--                          ADABROKER COMPONENTS                            --
--                                                                          --
-- P O R T A B L E S E R V E R . A D A P T E R A C T I V A T O R . I M P L  --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--                            $Revision: 1.5 $
--                                                                          --
--         Copyright (C) 1999, 2000 ENST Paris University, France.          --
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

with CORBA;
with PortableServer.AdapterActivator;

package PortableServer.AdapterActivator.Impl is
   type Object is abstract new PortableServer.Servant_Base with private;

   --  FIXME
   --  This corresponds to _this in c++.
   type Object_Ptr is access all Object'Class;
   function To_Ref (Self : Object_Ptr)
                    return PortableServer.AdapterActivator.Ref;

   procedure Unknown_Adapter
     (Self   : in out Object;
      Parent : PortableServer.POA_Forward.Ref;
      Name   : CORBA.String;
      Returns : out Boolean) is abstract;
private
   type Object is abstract new PortableServer.Servant_Base with
     null record;
end PortableServer.AdapterActivator.Impl;
