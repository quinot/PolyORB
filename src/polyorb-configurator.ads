------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                 P O L Y O R B . C O N F I G U R A T O R                  --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--                Copyright (C) 2001 Free Software Fundation                --
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

--  Automatic configurator

--  $Id$

with PolyORB.Utils.Strings;
with PolyORB.Utils.Strings.Lists;
pragma Elaborate_All (PolyORB.Utils.Strings.Lists);

package PolyORB.Configurator is

   pragma Elaborate_Body;

   package String_Lists renames PolyORB.Utils.Strings.Lists;

   type Initializer is access procedure;

   type Module_Info is record
      Name : Utils.Strings.String_Ptr;
      Provides  : String_Lists.List;
      Depends   : String_Lists.List;
      Conflicts : String_Lists.List;

      Init : Initializer;
   end record;

   procedure Register_Module (Info : Module_Info);
   --  Register a module described by Info with
   --  the autoconfigurator.

   procedure Initialize_World;
   --  Initialize all modules, respecting the dependencies listed
   --  in each module descriptor.

   Already_Initialized : exception;
   Unresolved_Dependency : exception;
   Circular_Dependency : exception;
   Conflict : exception;

end PolyORB.Configurator;
