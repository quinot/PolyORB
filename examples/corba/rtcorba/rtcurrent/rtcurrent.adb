------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                            R T C U R R E N T                             --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--            Copyright (C) 2003 Free Software Foundation, Inc.             --
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
--                PolyORB is maintained by ACT Europe.                      --
--                    (email: sales@act-europe.fr)                          --
--                                                                          --
------------------------------------------------------------------------------

--  $Id$

with Ada.Exceptions;
with Ada.Text_IO;

with CORBA.ORB;

with RTCORBA.Current;

--  with PolyORB.Setup.No_Tasking_Server;
--  pragma Elaborate_All (PolyORB.Setup.No_Tasking_Server);
--  pragma Warnings (Off, PolyORB.Setup.No_Tasking_Server);

with PolyORB.Setup.Thread_Pool_Server;
pragma Elaborate_All (PolyORB.Setup.Thread_Pool_Server);
pragma Warnings (Off, PolyORB.Setup.Thread_Pool_Server);

procedure RTCurrent is

   use Ada.Text_IO;
   use CORBA.ORB;

begin
   CORBA.ORB.Initialize ("ORB");

   declare
      Current : RTCORBA.Current.Ref
        := RTCORBA.Current.To_Ref
        (Resolve_Initial_References
         (To_CORBA_String ("RTCurrent")));

   begin
      RTCORBA.Current.Set_The_Priority (Current, 42);

      Put_Line ("Current priority:"
                & RTCORBA.Current.Get_The_Priority (Current)'Img);
   exception
      when E : others =>
         Put_Line ("Got exception: "
                   & Ada.Exceptions.Exception_Information (E));
   end;

end RTCurrent;
