------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--   P O L Y O R B . U T I L S . S O C K E T _ A C C E S S _ P O I N T S    --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2007-2013, Free Software Foundation, Inc.          --
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

--  Common definitions for all socket-based access points

with PolyORB.Sockets;
with PolyORB.Transport;
with PolyORB.Utils.Sockets;

package PolyORB.Utils.Socket_Access_Points is

   use PolyORB.Sockets;
   use PolyORB.Transport;
   use PolyORB.Utils.Sockets;

   type Port_Interval is record
      Lo, Hi : Port_Type;
   end record;

   function To_Port_Interval (I : Interval) return Port_Interval;
   pragma Inline (To_Port_Interval);
   --  Convert an integer interval to a port interval

   type APs is array (Positive range <>) of Transport_Access_Point_Access;

   function Initialize_Access_Points
     (Listen_Spec   : String;
      Default_Ports : Port_Interval := (Any_Port, Any_Port);
      Initialize_AP : access function
        (Addr      : Inet_Addr_Type;
         Port_Hint : Port_Interval) return Transport_Access_Point_Access)
      return APs;
   --  Create one or more access points specified by Listen_Spec, using
   --  Default_Ports as a hint for the listening ports to use if not specified
   --  by Listen_Spec. Returns the newly initialized access points.

   --  The format of Listen_Spec is:
   --    <bind-addr>[<pub-addr]:<port-hint>

   --  Each component (and its associated delimiters) can be omitted.

   --  The default <bind-addr> is Any_Inet_Address. If <bind-addr> is specified
   --  as an IP address, bind to that address instead. If it is a host name,
   --  bind to all associated addresses.

   --  The default <pub-addr> is <bind-addr> if set to a non-default value.
   --  If <bind-addr> is Any_Inet_Address, then the default <pub-addr> is the
   --  first (if possible non-loopback) address of the local host.

   --  <port-hint> is either a single port number, or a range whose low and
   --  high bounds are separated by an hyphen, and defaults to the given
   --  Default_Ports.

   function Publish_Name
     (Publish : String;
      Addr    : Inet_Addr_Type) return String;
   --  Return Publish if set (non-empty string), else image of Addr if not
   --  Any_Inet_Addr, else primary (non-loopback) address for local host.

   procedure Set_Default_Publish_Name
     (Publish : in out Socket_Name_Ptr;
      Addr    : Sock_Addr_Type);
   --  If Publish is not set, provide a default value from Addr

end PolyORB.Utils.Socket_Access_Points;
