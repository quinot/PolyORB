------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                   P O L Y O R B . P A R A M E T E R S                    --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2002-2005 Free Software Foundation, Inc.           --
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
--                  PolyORB is maintained by AdaCore                        --
--                     (email: sales@adacore.com)                           --
--                                                                          --
------------------------------------------------------------------------------

--  PolyORB runtime configuration facility.

package PolyORB.Parameters is

   pragma Elaborate_Body;

   function Get_Conf
     (Section, Key : String;
      Default : String := "") return String;
   --  Return the value of the global variable Key or Default if this
   --  variable is not defined.

   function Get_Conf
     (Section, Key : String;
      Default : Boolean := False) return Boolean;
   --  Return the value of the global variable Key or Default if this
   --  variable is not defined, interpreting the value as a Boolean:
   --  * True if the value starts with '1' or 'Y' or 'y',
   --    or is "on" or "enable" or "true"
   --  * False if the value starts with '0' or 'n' or 'N',
   --    or is "off" or "disable" or "false" or empty.
   --  Constraint_Error is raised if the value is set to anything else.
   --  (see also PolyORB.Utils.Strings.To_Boolean).

   function Get_Conf
     (Section, Key : String;
      Default : Integer := 0) return Integer;
   --  Return the value of the global variable Key or Default if this
   --  variable is not defined, interpreting the value as the decimal
   --  representation of an integer number.
   --  Constraint_Error is raised if the value is set to anything else.

   function Make_Global_Key (Section, Key : String) return String;
   --  Build dynamic key from (Section, Key) tuple

private

   type Parameters_Source is abstract tagged limited null record;
   type Parameters_Source_Access is access all Parameters_Source'Class;

   function Get_Conf
     (Source       : access Parameters_Source;
      Section, Key : String) return String is abstract;
   --  Return the value of the global variable Key in the specified Section.
   --  For unknown (Section, Key) couples, an empty string shall be returned.

   procedure Register_Source (Source : Parameters_Source_Access);
   --  Register one source of configuration parameters. Sources are queried
   --  at run time in the order they were registered.

   type Fetch_From_File_T is access function (Key : String) return String;
   Fetch_From_File_Hook : Fetch_From_File_T := null;
   --  The fetch-from-file hook allows the value of a configuration parameter
   --  to be loaded indirectly from a file; this is independent of the use of a
   --  PolyORB configuration file as a source of configuration parameters (but
   --  both facilities are provided by the PolyORB.Parameters.File package).

end PolyORB.Parameters;
