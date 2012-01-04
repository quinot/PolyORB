------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                        S E R V E R _ C O M M O N                         --
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

--  $Id: server_common.adb 6558 2004-06-21 10:24:28Z hugues $

with Ada.Text_IO;

with CORBA.Impl;
with CORBA.Object;
with CORBA.ORB;
with PortableServer;

with Harness.Impl;

with PolyORB.CORBA_P.Server_Tools;

package body Server_Common is

   -------------------
   -- Launch_Server --
   -------------------

   procedure Launch_Server is
      use PolyORB.CORBA_P.Server_Tools;
   begin

      Ada.Text_IO.Put_Line ("Server starting.");
      CORBA.ORB.Initialize ("ORB");

      declare
         Obj : constant CORBA.Impl.Object_Ptr := new Harness.Impl.Object;
         Ref : CORBA.Object.Ref;
      begin
         Initiate_Servant (PortableServer.Servant (Obj), Ref);

         --  Print IOR so that we can give it to a client

         Ada.Text_IO.Put_Line
           ("'"
            & CORBA.To_Standard_String (CORBA.Object.Object_To_String (Ref))
            & "'");

         --  Launch the server

         Initiate_Server;
      end;
   end Launch_Server;

end Server_Common;
