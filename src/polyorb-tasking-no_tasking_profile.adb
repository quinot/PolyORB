------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--   P O L Y O R B - T A S K I N G - N O _ T A S K I N G _ P R O F I L E    --
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
--  Set up a no tasking profile

--  //droopi/main/design/tasking/polyorb-tasking-no_tasking_profile.ads

pragma Warnings (Off);
with PolyORB.No_Tasking_Profile.Threads;
pragma Warnings (On);
pragma Elaborate_All (PolyORB.No_Tasking_Profile.Threads);
pragma Warnings (Off);
with PolyORB.No_Tasking_Profile.Monitors;
pragma Warnings (On);
pragma Elaborate_All (PolyORB.No_Tasking_Profile.Monitors);

package body PolyORB.Tasking.No_Tasking_Profile is
begin
   null;
end PolyORB.Tasking.No_Tasking_Profile;
