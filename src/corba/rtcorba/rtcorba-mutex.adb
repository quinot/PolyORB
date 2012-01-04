------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                        R T C O R B A . M U T E X                         --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2004-2012, Free Software Foundation, Inc.          --
--                                                                          --
-- This is free software;  you can redistribute it  and/or modify it  under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  This software is distributed in the hope  that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License for  more details.                                               --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
--                  PolyORB is maintained by AdaCore                        --
--                     (email: sales@adacore.com)                           --
--                                                                          --
------------------------------------------------------------------------------

with PolyORB.Tasking.Mutexes;
with PolyORB.RTCORBA_P.Mutex;

package body RTCORBA.Mutex is

   ----------
   -- Lock --
   ----------

   procedure Lock (Self : Local_Ref) is
   begin
      PolyORB.Tasking.Mutexes.Enter
        (PolyORB.RTCORBA_P.Mutex.Mutex_Entity (Entity_Of (Self).all).Mutex);
   end Lock;

   ------------
   -- Unlock --
   ------------

   procedure Unlock (Self : Local_Ref) is
   begin
      PolyORB.Tasking.Mutexes.Leave
        (PolyORB.RTCORBA_P.Mutex.Mutex_Entity (Entity_Of (Self).all).Mutex);
   end Unlock;

end RTCORBA.Mutex;
