------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                M O M A . M E S S A G E _ H A N D L E R S                 --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--             Copyright (C) 1999-2002 Free Software Fundation              --
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
--              PolyORB is maintained by ENST Paris University.             --
--                                                                          --
------------------------------------------------------------------------------

--  A Message_Consumer object is the client view of the message receiving
--  process. It is the facade to all communications carried out with
--  a message pool to receive messages; it contains the stub to access
--  'Message_Consumer' servants (see MOMA.Provider for more details).

--  NOTE: A MOMA client must use only this package to receive messages from a
--  message pool.

--  $Id: //droopi/main/src/moma/moma-message_handlers.ads

with MOMA.Messages;
with MOMA.Message_Consumers;
with MOMA.Sessions;
with MOMA.Types;

with PolyORB.References;

package MOMA.Message_Handlers is

   use MOMA.Types;

   type Message_Handler is private;
   --  Self_Ref
   --  Message_Cons
   --  Handler_Procedure
   --  Notifier_Procedure
   --  Behavior
   --  XXX Add comments about the various attributes.

   type Message_Handler_Acc is access Message_Handler;

   type Handler is access procedure (
      Self : access Message_Handler;
      Message : MOMA.Messages.Message'Class);
   --  The procedure to be called when a message is received, if the behavior
   --  is Handle.

   type Notifier is access procedure (
      Self : access Message_Handler);
   --  The procedure to be called when a message is received, if the behavior
   --  is Notify.

   procedure Initialize (
      Self                : in out Message_Handler_Acc;
      Message_Cons        : MOMA.Message_Consumers.Message_Consumer_Acc;
      Self_Ref            : PolyORB.References.Ref;
      Notifier_Procedure  : Notifier := null;
      Handler_Procedure   : Handler := null;
      Behavior            : MOMA.Types.Call_Back_Behavior := None);
   --  Initialize the Message_Handler and return its Reference.
   --  If the behavior is Handle and no Handler_Procedure is provided, the
   --  incoming messages will be lost.

   function Create_Handler
     (Session        : MOMA.Sessions.Session;
      Message_Cons   : MOMA.Message_Consumers.Message_Consumer_Acc)
      return MOMA.Message_Handlers.Message_Handler_Acc;
   --  Create a Message Handler associated to the specified Message consumer.
   --  Must set the Handler and Notifier procedures afterwards.

   function  Get_Handler (Self : access Message_Handler)
      return Handler;
   --  Get the Handler procedure.

   function Get_Notifier (Self : access Message_Handler)
      return Notifier;
   --  Get the Notifier procedure.

   procedure Set_Behavior (
      Self           : access Message_Handler;
      New_Behavior   : in MOMA.Types.Call_Back_Behavior);
   --  Set the Behavior. A request is sent to the actual servant if the
   --  behavior has changed.

   procedure Set_Handler (
      Self                    : access Message_Handler;
      New_Handler_Procedure   : in Handler;
      Handle_Behavior         : Boolean := False);
   --  Associate a Handler procedure to the Message Handler.
   --  Replace the current Handler procedure.
   --  The behavior is set to Handle if Handle_Behavior is true.

   procedure Set_Notifier (
      Self                    : access Message_Handler;
      New_Notifier_Procedure  : in Notifier;
      Notify_Behavior         : Boolean := False);
   --  Symmetric of Set_Handler.

   procedure Template_Handler (
      Self     : access Message_Handler;
      Message  : MOMA.Messages.Message'Class);

   procedure Template_Notifier (
      Self : access Message_Handler);
   --  Templates for handler and notifier procedures.

private
   type Message_Handler is record
      Servant_Ref          : PolyORB.References.Ref;
      Message_Cons         : MOMA.Message_Consumers.Message_Consumer_Acc;
      Handler_Procedure    : Handler := null;
      Notifier_Procedure   : Notifier := null;
      Behavior             : MOMA.Types.Call_Back_Behavior := None;
   end record;

   procedure Register_To_Servant (Self : access Message_Handler);
   --  Register the Message_Handler or change the Behavior,
   --  via a Request to the actual servant.

end MOMA.Message_Handlers;
