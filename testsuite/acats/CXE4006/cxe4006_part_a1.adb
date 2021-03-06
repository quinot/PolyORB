------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--                      C X E 4 0 0 6 _ P A R T _ A 1                       --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--           Copyright (C) 2012, Free Software Foundation, Inc.             --
--                                                                          --
-- This is free software;  you can redistribute it  and/or modify it  under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  This software is distributed in the hope  that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License for  more details.                                               --
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

-----------------------------------------------------------------------------

with Report;
with CXE4006_Part_A2;
with CXE4006_Part_B;
with CXE4006_Normal;
package body CXE4006_Part_A1 is

  ---------  partition termination coordination ----------
  -- use a task to prevent the partition from completing its execution
  -- until the main procedure in partition B tells it to quit, and to insure
  -- that Report.Result is not called until after the partition is started.

  task Wait_For_Quit is
    entry Can_Quit;
    entry Quit;
  end Wait_For_Quit;

  task body Wait_For_Quit is
  begin
    accept Can_Quit;
    accept Quit;
    Report.Result;
  end Wait_For_Quit;

  procedure Can_Quit is
  begin
    Wait_For_Quit.Can_Quit;
  end Can_Quit;

  procedure Quit is
  begin
    Wait_For_Quit.Quit;
  end Quit;

  ----------

  procedure Single_Controlling_Operand (
      RTT         : in out A1_Tagged_Type_1;
      Test_Number : in     Integer;
      Callee      :    out Type_Decl_Location) is
    Expected : Integer := 0;
  begin
    case Test_Number is
      when 1002   => Expected := 110;
      when 2002   => Expected := 210;
      when others => Report.Failed ("CXE4006_Part_A1(1) bad test number" &
                                    Integer'Image (Test_Number));
    end case;

    if RTT.Common_Record_Field /= Expected then
      Report.Failed ("CXE4006_Part_A1(1) expected" &
                     Integer'Image (Expected) &
                     " but received" &
                     Integer'Image (RTT.Common_Record_Field) &
                     " in test" &
                     Integer'Image (Test_Number));
    end if;

    RTT.Common_Record_Field := Expected + 6;
    Callee := Part_A1_1_Spec;
  end Single_Controlling_Operand;

  procedure Single_Controlling_Operand (
      RTT         : in out A1_Tagged_Type_2;
      Test_Number : in     Integer;
      Callee      :    out Type_Decl_Location) is
    Expected : Integer := 0;
  begin
    case Test_Number is
      when 1003   => Expected := 120;
      when 2003   => Expected := 220;
      when others => Report.Failed ("CXE4006_Part_A1(2) bad test number" &
                                    Integer'Image (Test_Number));
    end case;

    if RTT.Common_Record_Field /= Expected then
      Report.Failed ("CXE4006_Part_A1(2) expected" &
                     Integer'Image (Expected) &
                     " but received" &
                     Integer'Image (RTT.Common_Record_Field) &
                     " in test" &
                     Integer'Image (Test_Number));
    end if;

    RTT.Common_Record_Field := Expected + 7;
    Callee := Part_A1_2_Spec;
  end Single_Controlling_Operand;

  ----------

  procedure Make_Dispatching_Call_With (
      X           : in out Root_Tagged_Type'Class;
      Test_Number : in     Integer;
      Callee      :    out Type_Decl_Location) is
  begin
    Single_Controlling_Operand (X, Test_Number, Callee);
  end Make_Dispatching_Call_With;

end CXE4006_Part_A1;
