------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--           A W S . S T A T U S . T R A N S L A T E _ T A B L E            --
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

function AWS.Status.Translate_Table
  (Status : Data)
   return Templates.Translate_Table
is
   use Templates;
begin
   return (Assoc ("PEERNAME",     To_String (Status.Peername)),
           Assoc ("METHOD",       Request_Method'Image (Status.Method)),
           Assoc ("URI",          URL.URL (Status.URI)),
           Assoc ("HTTP_VERSION", To_String (Status.HTTP_Version)),
           Assoc ("AUTH_MODE",    Authorization_Type'Image (Status.Auth_Mode)),
           Assoc ("SOAP_ACTION",  Status.SOAP_Action),
           Assoc ("PAYLOAD",      "soap_payload"));
end AWS.Status.Translate_Table;
