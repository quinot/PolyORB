--  Abstract transport service access points and
--  communication endpoints.

--  $Id$

with Ada.Streams; use Ada.Streams;

with Droopi.Asynchronous_Events; use Droopi.Asynchronous_Events;
with Droopi.Buffers; use Droopi.Buffers;
with Droopi.Schedulers;

package Droopi.Transport is

   type Transport_Access_Point
      is abstract tagged limited private;
   type Transport_Access_Point_Access is
     access all Transport_Access_Point'Class;
   --  A listening transport service access point.

   function Create_Event_Source
     (TAP : Transport_Access_Point)
     return Asynchronous_Event_Source_Access
      is abstract;
   --  Create a view of TAP as an asyncrhonous event source.

   type Transport_Endpoint
      is abstract tagged limited private;
   type Transport_Endpoint_Access is access all Transport_Endpoint'Class;
   --  An opened transport endpoint.

   --  Primitive operations of Transport_Access_Point and
   --  Transport_Endpoint.

   --  These primitives are invoked from event-driven ORB
   --  threads, and /must not/ be blocking.

   procedure Accept_Connection
     (TAP : Transport_Access_Point;
      TE  : out Transport_Endpoint_Access)
      is abstract;
   --  Accept a pending new connection on TAP and create
   --  a new associated TE.

   --  function Address (TAP : Transport_Access_Point)
   --    return Binding_Data is abstract;

   Connection_Closed : exception;

   function Create_Event_Source
     (TE : Transport_Endpoint)
     return Asynchronous_Event_Source_Access
      is abstract;
   --  Create a view of TE as an asyncrhonous event source.

   procedure Read
     (TE     : Transport_Endpoint;
      Buffer : Buffer_Access;
      Size   : in out Stream_Element_Count)
      is abstract;
   --  Receive data from TE into Buffer. When Read is Called,
   --  Size is set to the maximum size of the data to be received.
   --  On return, Size is set to the effective amount of data received.

   procedure Write
     (TE     : Transport_Endpoint;
      Buffer : Buffer_Access)
      is abstract;
   --  Write out the contents of Buffer onto TE.

   procedure Close (TE : Transport_Endpoint) is abstract;

private

   type Transport_Access_Point
      is abstract tagged limited null record;

   type Transport_Endpoint
      is abstract tagged limited null record;

end Droopi.Transport;
