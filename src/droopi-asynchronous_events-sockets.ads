--  An asynchrous event source that is a set of socket descriptors.

--  $Id$

with Droopi.Sockets;

package Droopi.Asynchronous_Events.Sockets is

   pragma Elaborate_Body;

   type Socket_Event_Monitor is new Asynchronous_Event_Monitor with private;

   procedure Create (AEM : out Socket_Event_Monitor);
   procedure Destroy (AEM : in out Socket_Event_Monitor);

   procedure Register_Source
     (AEM     : in out Socket_Event_Monitor;
      AES     : Asynchronous_Event_Source_Access;
      Success : out Boolean);

   procedure Unregister_Source
     (AEM : in out Socket_Event_Monitor;
      AES : Asynchronous_Event_Source_Access);

   function Check_Sources
     (AEM     : access Socket_Event_Monitor;
      Timeout : Duration)
     return AES_Array;

   procedure Abort_Check_Sources
     (AEM : Socket_Event_Monitor);

   function Create_Event_Source
     (Socket : Droopi.Sockets.Socket_Type)
     return Asynchronous_Event_Source_Access;

private

   type Socket_Event_Source is new Asynchronous_Event_Source
     with record
        Socket : Droopi.Sockets.Socket_Type;
     end record;

   type Socket_Event_Monitor is new Asynchronous_Event_Monitor
     with record
        Selector : Droopi.Sockets.Selector_Access;
     end record;

end Droopi.Asynchronous_Events.Sockets;
