------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--           T E S T 0 0 1 _ R E Q U E S T _ I N F O _ T E S T S            --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--            Copyright (C) 2004 Free Software Foundation, Inc.             --
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

with PortableInterceptor.RequestInfo;

with Test001_Globals;

package Test001_Request_Info_Tests is

   procedure Test_Request_Id
     (Point : in Test001_Globals.Interception_Point;
      Info  : in PortableInterceptor.RequestInfo.Local_Ref'Class);

   procedure Test_Operation
     (Point : in Test001_Globals.Interception_Point;
      Info  : in PortableInterceptor.RequestInfo.Local_Ref'Class);

   procedure Test_Arguments
     (Point : in Test001_Globals.Interception_Point;
      Info  : in PortableInterceptor.RequestInfo.Local_Ref'Class);

   procedure Test_Exceptions
     (Point : in Test001_Globals.Interception_Point;
      Info  : in PortableInterceptor.RequestInfo.Local_Ref'Class);

   procedure Test_Contexts
     (Point : in Test001_Globals.Interception_Point;
      Info  : in PortableInterceptor.RequestInfo.Local_Ref'Class);

   procedure Test_Operation_Context
     (Point : in Test001_Globals.Interception_Point;
      Info  : in PortableInterceptor.RequestInfo.Local_Ref'Class);

   procedure Test_Result
     (Point : in Test001_Globals.Interception_Point;
      Info  : in PortableInterceptor.RequestInfo.Local_Ref'Class);

   procedure Test_Response_Expected
     (Point : in Test001_Globals.Interception_Point;
      Info  : in PortableInterceptor.RequestInfo.Local_Ref'Class);

   procedure Test_Sync_Scope
     (Point : in Test001_Globals.Interception_Point;
      Info  : in PortableInterceptor.RequestInfo.Local_Ref'Class);

   procedure Test_Reply_Status
     (Point : in Test001_Globals.Interception_Point;
      Info  : in PortableInterceptor.RequestInfo.Local_Ref'Class);

   procedure Test_Forward_Reference
     (Point : in Test001_Globals.Interception_Point;
      Info  : in PortableInterceptor.RequestInfo.Local_Ref'Class);

   procedure Test_Get_Slot
     (Point : in Test001_Globals.Interception_Point;
      Info  : in PortableInterceptor.RequestInfo.Local_Ref'Class);

   procedure Test_Get_Request_Service_Context
     (Point : in Test001_Globals.Interception_Point;
      Info  : in PortableInterceptor.RequestInfo.Local_Ref'Class);

   procedure Test_Get_Reply_Service_Context
     (Point : in Test001_Globals.Interception_Point;
      Info  : in PortableInterceptor.RequestInfo.Local_Ref'Class);

end Test001_Request_Info_Tests;
