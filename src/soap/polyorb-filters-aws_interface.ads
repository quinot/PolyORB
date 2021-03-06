------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--        P O L Y O R B . F I L T E R S . A W S _ I N T E R F A C E         --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2001-2012, Free Software Foundation, Inc.          --
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

--  Messages exchanged by AWS-based filters and components.

with PolyORB.SOAP_P.Response;

with PolyORB.Filters.Iface;
with PolyORB.HTTP_Methods;
with PolyORB.Types;

package PolyORB.Filters.AWS_Interface is

   use PolyORB.Filters.Iface;

   type AWS_Get_SOAP_Action is new Root_Data_Unit with null record;
   type AWS_SOAP_Action is new Root_Data_Unit with record
      SOAP_Action : Types.String;
   end record;

   type AWS_Request_Out is new Root_Data_Unit with record
      Request_Method : PolyORB.HTTP_Methods.Method;
      Relative_URI   : Types.String;
      Data           : Types.String;
      SOAP_Action    : Types.String;
--       User : ;
--       Passwd : ;
--       Proxy : ;
--       Proxy_User : ;
--       Proxy_Passwd : ;
   end record;

   type AWS_Response_Out is new Root_Data_Unit with record
      --  Direction: from upper to lower.
      --  Semantics: send AWS response out.
      Data : PolyORB.SOAP_P.Response.Data;
   end record;

end PolyORB.Filters.AWS_Interface;
