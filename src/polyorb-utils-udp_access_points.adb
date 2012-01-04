------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--      P O L Y O R B . U T I L S . U D P _ A C C E S S _ P O I N T S       --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2003-2012, Free Software Foundation, Inc.          --
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

--  Helper subprograms to set up access points based on UDP sockets

with Ada.Exceptions;

with PolyORB.Components;
with PolyORB.Log;
with PolyORB.Platform;
with PolyORB.Setup;
with PolyORB.Transport.Datagram.Sockets;

package body PolyORB.Utils.UDP_Access_Points is

   use PolyORB.Binding_Data;
   use PolyORB.Log;
   use PolyORB.Sockets;

   package L is new PolyORB.Log.Facility_Log
     ("polyorb.utils.udp_access_points");
   procedure O (Message : String; Level : Log_Level := Debug)
     renames L.Output;
   --  function C (Level : Log_Level := Debug) return Boolean
   --    renames L.Enabled;

   procedure Initialize_Socket (AP_Info : in out UDP_Access_Point_Info);
   pragma Inline (Initialize_Socket);
   --  Shared part between Initialize_Unicast_Socket and
   --  Initialize_Multicast_Socket.

   -----------------------
   -- Initialize_Socket --
   -----------------------

   procedure Initialize_Socket (AP_Info : in out UDP_Access_Point_Info) is
   begin
      Create_Socket (AP_Info.Socket, Family_Inet, Socket_Datagram);

      --  Allow reuse of local addresses

      Set_Socket_Option (AP_Info.Socket, Socket_Level, (Reuse_Address, True));
   end Initialize_Socket;

   ---------------------------------
   -- Initialize_Multicast_Socket --
   ---------------------------------

   procedure Initialize_Multicast_Socket
     (AP_Info : in out UDP_Access_Point_Info;
      Address : Inet_Addr_Type;
      Port    : Port_Type)
   is
      use PolyORB.Transport.Datagram.Sockets;
      Bind_Address : Sock_Addr_Type;
   begin
      Initialize_Socket (AP_Info);

      AP_Info.Address :=
        Sock_Addr_Type'(Addr   => Address,
                        Port   => Port,
                        Family => Family_Inet);

      Bind_Address := AP_Info.Address;

      --  Bind socket: for UNIX it needs to be bound to the group address;
      --  for Windows to INADDR_ANY.

      if PolyORB.Platform.Windows_On_Target then
         Bind_Address.Addr := Any_Inet_Addr;
      end if;

      Init_Socket
        (Socket_Access_Point (AP_Info.SAP.all),
         AP_Info.Socket,
         Address      => AP_Info.Address,
         Bind_Address => Bind_Address,
         Update_Addr  => False);

      --  Join multicast group on the appropriate interface (note that under
      --  Windows, this is possible only after the socket is bound).

      Set_Socket_Option
        (AP_Info.Socket,
         IP_Protocol_For_IP_Level,
         (Name              => Add_Membership,
          Multicast_Address => Address,
          Local_Interface   => Any_Inet_Addr));

      --  Allow local multicast operation

      Set_Socket_Option
        (AP_Info.Socket,
         IP_Protocol_For_IP_Level,
         (Multicast_Loop, True));

      if AP_Info.PF /= null then
         Create_Factory
           (AP_Info.PF.all,
            AP_Info.SAP,
            PolyORB.Components.Component_Access (Setup.The_ORB));
      end if;
   end Initialize_Multicast_Socket;

   -------------------------------
   -- Initialize_Unicast_Socket --
   -------------------------------

   procedure Initialize_Unicast_Socket
     (AP_Info   : in out UDP_Access_Point_Info;
      Port_Hint : Port_Interval;
      Address   : Inet_Addr_Type := Any_Inet_Addr)
   is
      use PolyORB.Transport.Datagram.Sockets;

   begin
      --  Create Socket

      Initialize_Socket (AP_Info);

      AP_Info.Address :=
        Sock_Addr_Type'(Addr   => Address,
                        Port   => Port_Hint.Lo,
                        Family => Family_Inet);

      loop
         begin
            Init_Socket
              (Socket_Access_Point (AP_Info.SAP.all),
               AP_Info.Socket,
               AP_Info.Address);
            exit;
         exception
            when E : Socket_Error =>

               --  If a specific port range was given, try next port in range

               if AP_Info.Address.Port /= Any_Port
                 and then AP_Info.Address.Port < Port_Hint.Hi
               then
                  AP_Info.Address.Port := AP_Info.Address.Port + 1;
               else
                  O ("bind failed: " & Ada.Exceptions.Exception_Message (E),
                     Notice);
                  raise;
               end if;
         end;
      end loop;

      --  Create profile factory

      if AP_Info.PF /= null then
         Create_Factory
           (AP_Info.PF.all,
            AP_Info.SAP,
            Components.Component_Access (Setup.The_ORB));
      end if;
   end Initialize_Unicast_Socket;

end PolyORB.Utils.UDP_Access_Points;
