------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--  P O L Y O R B . G I O P _ P . T R A N S P O R T _ M E C H A N I S M S   --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2005-2008, Free Software Foundation, Inc.          --
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

with Ada.Unchecked_Deallocation;

package body PolyORB.GIOP_P.Transport_Mechanisms is

   use PolyORB.GIOP_P.Tagged_Components;

   type Registry_Item is record
      Tag         : Tagged_Components.Tag_Value;
      Constructor : Transport_Mechanism_Constructor;
   end record;

   package Registry_Item_Lists is
     new PolyORB.Utils.Chained_Lists (Registry_Item);

   Registry : Registry_Item_Lists.List;

   ---------------------------------
   -- Create_Transport_Mechanisms --
   ---------------------------------

   procedure Create_Transport_Mechanisms
     (TC      : Tagged_Components.Tagged_Component_List;
      Profile : Binding_Data.Profile_Access;
      Mechs   : in out Transport_Mechanism_List)
   is
      use Registry_Item_Lists;
      Iter   : Registry_Item_Lists.Iterator := First (Registry);
   begin
      while not Last (Iter) loop
         declare
            SC : constant Tagged_Component_Array :=
                   Get_Components (TC, Value (Iter).Tag);
         begin
            for J in SC'Range loop
               Value (Iter).Constructor (SC (J), Profile, Mechs);
            end loop;
         end;

         Next (Iter);
      end loop;
   end Create_Transport_Mechanisms;

   ---------------
   -- Deep_Copy --
   ---------------

   function Deep_Copy
     (List : Transport_Mechanism_List)
     return Transport_Mechanism_List
   is
      use Transport_Mechanism_Lists;

      Result : Transport_Mechanism_List;
      Iter   : Iterator := First (List);

   begin
      while not Last (Iter) loop
         declare
            C : constant Transport_Mechanism'Class := Duplicate
              (Value (Iter).all.all);
            CC : constant Transport_Mechanism_Access
              := new Transport_Mechanism'Class'(C);

         begin
            Append (Result, CC);
         end;

         Next (Iter);
      end loop;

      return Result;
   end Deep_Copy;

   ------------------
   -- Is_Colocated --
   ------------------

   function Is_Colocated (Left, Right : Transport_Mechanism_List)
     return Boolean
   is
      use Transport_Mechanism_Lists;
      L_Iter : Iterator := First (Right);
      R_Iter : Iterator;
   begin
      Left_Iteration :
      while not Last (L_Iter) loop

         R_Iter := First (Left);

         Right_Iteration :
         while not Last (R_Iter) loop
            if Is_Colocated
                 (Value (L_Iter).all.all, Value (R_Iter).all.all) then
               return True;
            end if;
            Next (R_Iter);
         end loop Right_Iteration;

         Next (L_Iter);
      end loop Left_Iteration;

      return False;
   end Is_Colocated;

   --------------
   -- Register --
   --------------

   procedure Register
    (Tag         : Tagged_Components.Tag_Value;
     Constructor : Transport_Mechanism_Constructor)
   is
   begin
      Registry_Item_Lists.Append (Registry, (Tag, Constructor));
   end Register;

   ----------------------
   -- Release_Contents --
   ----------------------

   procedure Release_Contents (List : in out Transport_Mechanism_List) is
      procedure Free is new Ada.Unchecked_Deallocation
        (Transport_Mechanism'Class, Transport_Mechanism_Access);

      Component : Transport_Mechanism_Access;

   begin
      while List
              /= Transport_Mechanism_List (Transport_Mechanism_Lists.Empty)
      loop
         Extract_First (List, Component);
         Release_Contents (Component);
         Free (Component);
      end loop;
   end Release_Contents;

end PolyORB.GIOP_P.Transport_Mechanisms;
