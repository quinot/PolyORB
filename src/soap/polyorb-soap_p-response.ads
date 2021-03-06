------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--              P O L Y O R B . S O A P _ P . R E S P O N S E               --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2000-2012, Free Software Foundation, Inc.          --
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

--  This package is to be used to build answer to be sent to the client
--  browser.

with Ada.Strings.Unbounded;
with Ada.Streams;

with PolyORB.Filters.HTTP;

--  with AWS.Status;
--  with AWS.Messages;
with PolyORB.Web.MIME;

package PolyORB.SOAP_P.Response is

   use Ada;
   use PolyORB.Filters.HTTP;

   type Data is private;

   type Data_Mode is (Header, Message);
   --  , File, Socket_Taken);

   Default_Moved_Message : constant String :=
     "Page moved<br><a href=""_@_"">Click here</a>";
   --  This is a template message, _@_ will be replaced by the Location (see
   --  function Build with Location below).

   ------------------
   -- Constructors --
   ------------------

   function Build
     (Content_Type : String;
      Message_Body : String;
      Status_Code  : HTTP_Status_Code := S_200_OK)
     return Data;

   function Build
     (Content_Type    : String;
      UString_Message : Strings.Unbounded.Unbounded_String;
      Status_Code     : HTTP_Status_Code := S_200_OK)
     return Data;
   --  Return a message whose body is passed into Message_Body. The
   --  Content_Type parameter is the MIME type for the message
   --  body. Status_Code is the response status (see HTTP_Status_Code
   --  definition).

   function Build
     (Content_Type : String;
      Message_Body : Streams.Stream_Element_Array;
      Status_Code  : HTTP_Status_Code := S_200_OK)
     return Data;
   --  Idem above, but the message body is a stream element array.

   function URL (Location : String)
     return Data;
   --  This ask the server for a redirection to the specified URL.

   function Moved
     (Location : String;
      Message  : String := Default_Moved_Message)
     return Data;
   --  This send back a moved message (S_301) with the specified
   --  message body.

   function Acknowledge
     (Status_Code  : HTTP_Status_Code;
      Message_Body : String := "";
      Content_Type : String := PolyORB.Web.MIME.Text_HTML)
     return Data;
   --  Returns a message to the Web browser. This routine must be used to
   --  send back an error message to the Web browser. For example if a
   --  requested resource cannot be served a message with status code S404
   --  must be sent.

   function Authenticate (Realm : String) return Data;
   --  Returns an authentification message (S_401), the Web browser
   --  will then ask for an authentification. Realm string will be displayed
   --  by the Web Browser in the authentification dialog box.

   --  function File (Content_Type : String;
   --                 Filename     : String) return Data;
   --  Returns a message whose message body is the content of the file. The
   --  Content_Type must indicate the MIME type for the file.

   --  function Socket_Taken return Data;
   --  Must be used to say that the connection socket has been taken by user
   --  inside of user callback. No operations should be performed on this
   --  socket, and associated slot should be released for further operations.

   ---------------
   -- Other API --
   ---------------

   function Mode           (D : Data) return Data_Mode;
   --  Returns the data mode, either Header, Message or File.

   function Status_Code    (D : Data) return HTTP_Status_Code;
   --  Returns the status code.

   function Content_Length (D : Data) return Natural;
   --  Returns the content length (i.e. the message body length). A value of 0
   --  indicate that there is no message body.

   function Content_Type   (D : Data) return String;
   --  Returns the MIME type for the message body.

   function Location       (D : Data) return String;
   --  Returns the location for the new page in the case of a moved
   --  message. See Moved constructor above.

   function Message_Body   (D : Data) return String;
   --  Returns the message body content as a string.

   function Message_Body   (D : Data)
       return Strings.Unbounded.Unbounded_String;
   --  Returns the message body content as a unbounded_string.

   function Realm          (D : Data) return String;
   --  Returns the Realm for the current authentification request.

   function Binary         (D : Data) return Streams.Stream_Element_Array;
   --  Returns the binary message body content.

   --  type Callback is access function (Request : Status.Data) return Data;
   --  This is the Web Server Callback procedure. A client must declare and
   --  pass such procedure to the HTTP record.

private

   use Ada.Strings.Unbounded;

   type Stream_Element_Array_Access is access Streams.Stream_Element_Array;

   type Data is record
      Mode           : Data_Mode;
      Status_Code    : HTTP_Status_Code;
      Content_Length : Natural;
      Content_Type   : Unbounded_String;
      Message_Body   : Unbounded_String;
      Location       : Unbounded_String;
      Realm          : Unbounded_String;
      Elements       : Stream_Element_Array_Access;
   end record;

end PolyORB.SOAP_P.Response;
