------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--       M O M A . P R O V I D E R . M E S S A G E _ P R O D U C E R        --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--         Copyright (C) 2002-2003 Free Software Foundation, Inc.           --
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

--  Message_Producer servant.

--  $Id$

with MOMA.Messages;

with PolyORB.Any;
with PolyORB.Any.NVList;
with PolyORB.Log;
with PolyORB.Types;
with PolyORB.Requests;
with PolyORB.Exceptions;

package body MOMA.Provider.Message_Producer is

   use MOMA.Messages;

   use PolyORB.Any;
   use PolyORB.Any.NVList;
   use PolyORB.Log;
   use PolyORB.Requests;
   use PolyORB.Types;

   package L is
     new PolyORB.Log.Facility_Log ("moma.provider.message_producer");
   procedure O (Message : in Standard.String; Level : Log_Level := Debug)
     renames L.Output;

   --  Actual function implemented by the servant.

   procedure Publish
     (Self    : in PolyORB.References.Ref;
      Message : in PolyORB.Any.Any);
   --  Publish a message.

   --  Accessors to servant interface.

   function Get_Parameter_Profile
     (Method : String)
     return PolyORB.Any.NVList.Ref;
   --  Parameters part of the interface description.

   function Get_Result_Profile
     (Method : String)
     return PolyORB.Any.Any;
   --  Result part of the interface description.

   ---------------------------
   -- Get_Parameter_Profile --
   ---------------------------

   function Get_Parameter_Profile
     (Method : String)
     return PolyORB.Any.NVList.Ref
   is
      use PolyORB.Any;
      use PolyORB.Any.NVList;
      use PolyORB.Types;

      Result : PolyORB.Any.NVList.Ref;
   begin
      pragma Debug (O ("Parameter profile for " & Method & " requested."));

      PolyORB.Any.NVList.Create (Result);

      if Method = "Publish" then
         Add_Item (Result,
                   (Name      => To_PolyORB_String ("Message"),
                    Argument  => Get_Empty_Any (TC_MOMA_Message),
                    Arg_Modes => ARG_IN));
      else
         raise Program_Error;
      end if;

      return Result;
   end Get_Parameter_Profile;

   --------------------
   -- Get_Remote_Ref --
   --------------------

   function Get_Remote_Ref
     (Self : Object)
     return PolyORB.References.Ref is
   begin
      return Self.Remote_Ref;
   end Get_Remote_Ref;

   ------------------------
   -- Get_Result_Profile --
   ------------------------

   function Get_Result_Profile
     (Method : String)
     return PolyORB.Any.Any
   is
      use PolyORB.Any;

   begin
      pragma Debug (O ("Result profile for " & Method & " requested."));
      if Method = "Publish" then
         return Get_Empty_Any (TypeCode.TC_Void);
      else
         raise Program_Error;
      end if;
   end Get_Result_Profile;

   -------------
   -- If_Desc --
   -------------

   function If_Desc
     return PolyORB.Obj_Adapters.Simple.Interface_Description is
   begin
      return
        (PP_Desc => Get_Parameter_Profile'Access,
         RP_Desc => Get_Result_Profile'Access);
   end If_Desc;

   ------------
   -- Invoke --
   ------------

   procedure Invoke
     (Self : access Object;
      Req  : in     PolyORB.Requests.Request_Access)
   is
      use PolyORB.Exceptions;

      Args  : PolyORB.Any.NVList.Ref;
      Error : Error_Container;
   begin
      pragma Debug (O ("The server is executing the request:"
                    & PolyORB.Requests.Image (Req.all)));

      Create (Args);

      if Req.all.Operation = To_PolyORB_String ("Publish") then

         --  Publish

         Add_Item (Args,
                   (Name => To_PolyORB_String ("Message"),
                    Argument => Get_Empty_Any (TC_MOMA_Message),
                    Arg_Modes => PolyORB.Any.ARG_IN));
         Arguments (Req, Args, Error);

         if Found (Error) then
            raise Program_Error;
            --  XXX We should do something more contructive

         end if;

         declare
            use PolyORB.Any.NVList.Internals;
            use PolyORB.Any.NVList.Internals.NV_Lists;
         begin
            Publish
              (Self.Remote_Ref,
               Value (First (List_Of (Args).all)).Argument);
         end;

      end if;
   end Invoke;

   -------------
   -- Publish --
   -------------

   procedure Publish
     (Self    : in PolyORB.References.Ref;
      Message : in PolyORB.Any.Any)
   is
      Request     : PolyORB.Requests.Request_Access;
      Arg_List    : PolyORB.Any.NVList.Ref;
      Result      : PolyORB.Any.NamedValue;

   begin
      pragma Debug (O ("Publishing Message " & Image (Message)));

      PolyORB.Any.NVList.Create (Arg_List);

      PolyORB.Any.NVList.Add_Item (Arg_List,
                                   To_PolyORB_String ("Message"),
                                   Message,
                                   PolyORB.Any.ARG_IN);

      Result := (Name      => To_PolyORB_String ("Result"),
                 Argument  => PolyORB.Any.Get_Empty_Any (PolyORB.Any.TC_Void),
                 Arg_Modes => 0);

      PolyORB.Requests.Create_Request
        (Target    => Self,
         Operation => "Publish",
         Arg_List  => Arg_List,
         Result    => Result,
         Req       => Request);

      PolyORB.Requests.Invoke (Request);

      PolyORB.Requests.Destroy_Request (Request);
   end Publish;

   --------------------
   -- Set_Remote_Ref --
   --------------------

   procedure Set_Remote_Ref
     (Self : in out Object;
      Ref  :        PolyORB.References.Ref)
   is
   begin
      Self.Remote_Ref := Ref;
   end Set_Remote_Ref;

end MOMA.Provider.Message_Producer;
