--  An asynchrous event source that is a set of socket descriptors.

--  $Id$

with Ada.Unchecked_Deallocation;

with Droopi.Log;

package body Droopi.Asynchronous_Events.Sockets is

   use Droopi.Log;
   use Droopi.Sockets;

   package L is new Droopi.Log.Facility_Log
     ("droopi.asynchronous_events.sockets");
   procedure O (Message : in String; Level : Log_Level := Debug)
     renames L.Output;

   procedure Create (AEM : out Socket_Event_Monitor) is
   begin
      pragma Assert (AEM.Selector = null);
      AEM.Selector := new Droopi.Sockets.Selector_Type;
      pragma Assert (AEM.Selector /= null);
      Create_Selector (AEM.Selector.all);
   end Create;

   procedure Destroy (AEM : in out Socket_Event_Monitor)
   is
      procedure Free is new Ada.Unchecked_Deallocation
        (Selector_Type, Selector_Access);
   begin
      pragma Assert (AEM.Selector /= null);
      Close_Selector (AEM.Selector.all);
      Free (AEM.Selector);
   end Destroy;

   procedure Register_Source
     (AEM     : in out Socket_Event_Monitor;
      AES     : Asynchronous_Event_Source_Access;
      Success : out Boolean) is
   begin
      Success := False;
      if AES.all not in Socket_Event_Source then
         return;
      end if;

      Source_Seqs.Append (AEM.Sources, AES);
      Success := True;
   end Register_Source;

   procedure Unregister_Source
     (AEM : in out Socket_Event_Monitor;
      AES : Asynchronous_Event_Source_Access) is
   begin
      raise Not_Implemented;
      --  XXX unimplemented.
   end Unregister_Source;

   function Check_Sources
     (AEM     : access Socket_Event_Monitor;
      Timeout : Duration)
     return AES_Array
   is
      Monitored_Set : constant Source_Seqs.Element_Array
        := Source_Seqs.To_Element_Array (AEM.Sources);

      T : Duration := Timeout;

      S : Socket_Type;
      R_Set : Socket_Set_Type;
      W_Set : Socket_Set_Type;
      Status : Selector_Status;

      Event_Count : Natural;

   begin
      Empty (R_Set);
      for I in Monitored_Set'Range loop
         S := Socket_Event_Source (Monitored_Set (I).all).Socket;
         Set (R_Set, S);
         pragma Debug (O ("Monitoring socket" & Image (S)));
      end loop;
      Empty (W_Set);

      pragma Debug (O ("Checking selector..."));

      if T = Asynchronous_Events.Forever then
         --  Convert special value of Timeout.
         T := Droopi.Sockets.Forever;
      end if;

      Check_Selector
        (Selector     => AEM.Selector.all,
         R_Socket_Set => R_Set,
         W_Socket_Set => W_Set,
         Status       => Status,
         Timeout      => T);

      pragma Debug (O ("Selector returned status "
                       & Status'Img));

      Event_Count := 0;

      if Status = Completed then
         for I in Monitored_Set'Range loop
            if Is_Set (R_Set, Socket_Event_Source
                       (Monitored_Set (I).all).Socket) then
               pragma Debug
                 (O ("Got event on socket"
                     & Image (Socket_Event_Source
                              (Monitored_Set (I).all).Socket)));

               Event_Count := Event_Count + 1;
               Unregister_Source (AEM.all, Monitored_Set (I));
            end if;
         end loop;
      end if;

      declare
         Result : AES_Array (1 .. Event_Count);
      begin
         for I in Monitored_Set'Range loop
            if Is_Set (R_Set, Socket_Event_Source
                       (Monitored_Set (I).all).Socket) then
               Result (Event_Count) := Monitored_Set (I);
               Event_Count := Event_Count - 1;
            end if;
         end loop;

         return Result;
      end;
   end Check_Sources;

   procedure Abort_Check_Sources (AEM : Socket_Event_Monitor) is
   begin
      --  XXX check that selector is currently blocking!
      --  (and do it in a thread-safe manner, if applicable!)
      Abort_Selector (AEM.Selector.all);
   end Abort_Check_Sources;

   function Create_Event_Source
     (Socket : Droopi.Sockets.Socket_Type)
     return Asynchronous_Event_Source_Access
   is
      Result : constant Asynchronous_Event_Source_Access
        := new Socket_Event_Source;
   begin
      Socket_Event_Source (Result.all).Socket := Socket;
      return Result;
   end Create_Event_Source;

end Droopi.Asynchronous_Events.Sockets;
