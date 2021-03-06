------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                              A W S . L O G                               --
--                                                                          --
--                                 B o d y                                  --
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

--  @@@ uses ada.calendar

with Ada.Calendar;
with Ada.Command_Line;
with Ada.Strings.Fixed;
with Ada.Strings.Maps;

with GNAT.Calendar.Time_IO;

with AWS.OS_Lib;
with AWS.Utils;

package body AWS.Log is

   function Log_Prefix (Prefix : String) return String;
   --  Returns the prefix to be added before the log filename. The returned
   --  value is the executable name without directory and filetype if Prefix
   --  is No_Prefix otherwise Prefix is returned.

   procedure Write_Log
     (Log  : in out Object;
      Now  : Calendar.Time;
      Data : String);
   --  Write data into the log file, change log file depending on the log file
   --  split mode and Now.

   --------------
   -- Filename --
   --------------

   function Filename (Log : Object) return String is
   begin
      if Text_IO.Is_Open (Log.File) then
         return Text_IO.Name (Log.File);
      else
         return "";
      end if;
   end Filename;

   ---------------
   -- Is_Active --
   ---------------

   function Is_Active (Log : Object) return Boolean is
   begin
      return Text_IO.Is_Open (Log.File);
   end Is_Active;

   ----------------
   -- Log_Prefix --
   ----------------

   function Log_Prefix (Prefix : String) return String is

      function Prog_Name return String;
      --  Return current program name

      ---------------
      -- Prog_Name --
      ---------------

      function Prog_Name return String is
         Name  : constant String := Ada.Command_Line.Command_Name;
         First : Natural;
         Last  : Natural;
      begin
         First := Strings.Fixed.Index
           (Name, Strings.Maps.To_Set ("/\"), Going => Strings.Backward);

         if First = 0 then
            First := Name'First;
         else
            First := First + 1;
         end if;

         Last := Strings.Fixed.Index
           (Name (First .. Name'Last), ".", Strings.Backward);

         if Last = 0 then
            Last := Name'Last;
         else
            Last := Last - 1;
         end if;

         return Name (First .. Last);
      end Prog_Name;

   begin
      if Prefix = Not_Specified then
         return "";

      else
         declare
            K : constant Natural := Strings.Fixed.Index (Prefix, "@");
         begin
            if K = 0 then
               return Prefix & '-';
            else
               return Prefix (Prefix'First .. K - 1)
                 & Prog_Name & Prefix (K + 1 .. Prefix'Last) & '-';
            end if;
         end;
      end if;
   end Log_Prefix;

   ----------
   -- Mode --
   ----------

   function Mode (Log : Object) return Split_Mode is
   begin
      return Log.Split;
   end Mode;

   -----------
   -- Start --
   -----------

   procedure Start
     (Log             : in out Object;
      Split           : Split_Mode := None;
      File_Directory  : String     := Not_Specified;
      Filename_Prefix : String     := Not_Specified)
   is
      Now      : constant Calendar.Time := Calendar.Clock;
      Filename : Unbounded_String;
      use GNAT;
   begin
      Log.Filename_Prefix := To_Unbounded_String (Filename_Prefix);
      Log.File_Directory  := To_Unbounded_String (File_Directory);
      Log.Split           := Split;

      Filename := To_Unbounded_String
        (File_Directory
         & Log_Prefix (Filename_Prefix)
         & GNAT.Calendar.Time_IO.Image (Now, "%Y-%m-%d.log"));

      case Split is
         when None =>
            null;

         when Each_Run =>
            for K in 1 .. 86_400 loop
               --  no more than one run per second during a full day.

               exit when not OS_Lib.Is_Regular_File (To_String (Filename));

               Filename := To_Unbounded_String
                 (File_Directory
                  & Log_Prefix (Filename_Prefix)
                  & GNAT.Calendar.Time_IO.Image (Now, "%Y-%m-%d-")
                  & Utils.Image (K) & ".log");
            end loop;

         when Daily =>
            Log.Current_Tag := Ada.Calendar.Day (Now);

         when Monthly =>
            Log.Current_Tag := Ada.Calendar.Month (Now);
      end case;

      Text_IO.Open (Log.File, Text_IO.Append_File, To_String (Filename));

   exception
      when Text_IO.Name_Error =>
         Text_IO.Create (Log.File, Text_IO.Out_File, To_String (Filename));
   end Start;

   ----------
   -- Stop --
   ----------

   procedure Stop (Log : in out Object) is
   begin
      if Text_IO.Is_Open (Log.File) then
         Text_IO.Close (Log.File);
      end if;
   end Stop;

   -----------
   -- Write --
   -----------

   --  Here is the log format compatible with Apache:
   --
   --  127.0.0.1 - - [25/Apr/1998:15:37:29 +0200] "GET / HTTP/1.0" 200 1363

   procedure Write
     (Log          : in out Object;
      Connect_Stat : Status.Data;
      Answer       : Response.Data) is
   begin
      Write (Log, Connect_Stat,
             Response.Status_Code (Answer),
             Response.Content_Length (Answer));
   end Write;

   procedure Write
     (Log            : in out Object;
      Connect_Stat   : Status.Data;
      Status_Code    : Messages.Status_Code;
      Content_Length : Natural) is
   begin
      Write (Log, Connect_Stat,
             Messages.Image (Status_Code)
               & ' '
               & Utils.Image (Content_Length));
   end Write;

   procedure Write
     (Log          : in out Object;
      Connect_Stat : Status.Data;
      Data         : String)
   is
      Now : constant Calendar.Time := Calendar.Clock;
   begin
      Write_Log
        (Log, Now,
         AWS.Status.Peername (Connect_Stat)
           & " - "
           & Status.Authorization_Name (Connect_Stat)
           & " - ["
           & GNAT.Calendar.Time_IO.Image (Now, "%d/%b/%Y:%T")
           & "] """
           & Status.Request_Method'Image (Status.Method (Connect_Stat))
           & ' '
           & Status.URI (Connect_Stat) & " "
           & Status.HTTP_Version (Connect_Stat) & """ "
           & Data);
   end Write;

   procedure Write
     (Log  : in out Object;
      Data : String)
   is
      Now : constant Calendar.Time := Calendar.Clock;
   begin
      Write_Log (Log, Now,
                 "[" & GNAT.Calendar.Time_IO.Image (Now, "%d/%b/%Y:%T") & "] "
                   & Data);
   end Write;

   ---------------
   -- Write_Log --
   ---------------

   procedure Write_Log
     (Log  : in out Object;
      Now  : Calendar.Time;
      Data : String) is
   begin
      if Text_IO.Is_Open (Log.File) then

         if (Log.Split = Daily
             and then Log.Current_Tag /= Calendar.Day (Now))
           or else
            (Log.Split = Monthly
             and then Log.Current_Tag /= Calendar.Month (Now))
         then
            Stop (Log);
            Start (Log,
                   Log.Split,
                   To_String (Log.File_Directory),
                   To_String (Log.Filename_Prefix));
         end if;

         Text_IO.Put_Line (Log.File, Data);

         Text_IO.Flush (Log.File);
      end if;
   end Write_Log;

end AWS.Log;
