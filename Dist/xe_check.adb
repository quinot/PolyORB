------------------------------------------------------------------------------
--                                                                          --
--                          GNATDIST COMPONENTS                             --
--                                                                          --
--                            X E _ C H E C K                               --
--                                                                          --
--                                B o d y                                   --
--                                                                          --
--                           $Revision$                              --
--                                                                          --
--           Copyright (C) 1996 Free Software Foundation, Inc.              --
--                                                                          --
-- GNATDIST is  free software;  you  can redistribute  it and/or  modify it --
-- under terms of the  GNU General Public License  as published by the Free --
-- Software  Foundation;  either version 2,  or  (at your option) any later --
-- version. GNATDIST is distributed in the hope that it will be useful, but --
-- WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHANTABI- --
-- LITY or FITNESS  FOR A PARTICULAR PURPOSE.  See the  GNU General  Public --
-- License  for more details.  You should  have received a copy of the  GNU --
-- General Public License distributed with  GNATDIST; see file COPYING.  If --
-- not, write to the Free Software Foundation, 59 Temple Place - Suite 330, --
-- Boston, MA 02111-1307, USA.                                              --
--                                                                          --
--              GNATDIST is maintained by ACT Europe.                       --
--            (email:distribution@act-europe.gnat.com).                     --
--                                                                          --
------------------------------------------------------------------------------

with Osint;            use Osint;
with Namet;            use Namet;
with Opt;
with Output;           use Output;
with Fname;            use Fname;
with ALI;              use ALI;
with Types;            use Types;
with XE_Utils;         use XE_Utils;
with XE;               use XE;
with Make;             use Make;
with GNAT.Os_Lib;      use GNAT.Os_Lib;
package body XE_Check is

   --  Once this procedure called, we have the following properties:
   --
   --  * Key of CUnit.Table (U).CUname corresponds to its ALI_Id
   --    ie ali index corresponding to ada unit CUnit.Table (U).CUname.
   --
   --  * Key of Unit.Table  (U).Uname  corresponds to its CUID_Id
   --    ie mapped unit index corresponding to ada unit Unit.Table (U).Uname
   --    if this unit has been mapped.
   --
   --  * Key of Partitions.Table (P).Name correpsonds to its PID.

   procedure Check is

      Inconsistent : Boolean := False;
      PID  : PID_Type;
      Ali  : ALI_Id;

      Compiled  : Name_Id;
      Obj       : Name_Id;
      Args      : Argument_List (Gcc_Switches.First .. Gcc_Switches.Last);
      Main      : Boolean;
      Full_Name : File_Name_Type;
      Stamp     : Time_Stamp_Type;
      Internal  : Boolean;

      procedure Recompile (Name : File_Name_Type);
      procedure Recompile (Name : File_Name_Type) is
      begin
         if not Already_Loaded (Name) then

            --  Taken from Gnatmake.

            Look_For_Full_File_Name :
            begin
               Full_Name := Get_File_Name (Name & Body_Suffix);
               if Full_Source_Name (Full_Name) = No_File then
                  Full_Name := Get_File_Name (Name & Spec_Suffix);
                  if Full_Source_Name (Full_Name) = No_File then
                     Osint.Write_Program_Name;
                     Write_Str (": """);
                     Write_Name (Name);
                     Write_Str (""" cannot be found");
                     Write_Eol;
                     Exit_Program (E_Fatal);
                  end if;
               end if;
               Internal := Is_Predefined_File_Name (Full_Name);
            end Look_For_Full_File_Name;

            --  Taken from Gnatmake.

            Compile_Sources
              (Main_Source           => Full_Name,
               Args                  => Args,
               First_Compiled_File   => Compiled,
               Most_Recent_Obj_File  => Obj,
               Most_Recent_Obj_Stamp => Stamp,
               Main_Unit             => Main,
               Check_Internal_Files  => Internal,
               Dont_Execute          => False,
               Force_Compilations    => Opt.Force_Compilations and
               not Internal,
               Initialize_Ali_Data   => False,
               Max_Process           => 1);

            --  Use later on to avoid unnecessary bind + link phases.

            if Compiled = No_File then
               Maybe_Most_Recent_Stamp (Stamp);
            end if;

         end if;
      end Recompile;


   begin

      for U in CUnit.First .. CUnit.Last loop
         Set_Name_Table_Info (CUnit.Table (U).CUname, 0);
      end loop;

      --  Set future Ada names to null. Compile (or load) all Ada units and
      --  check later on that these are not already used.
      Set_Name_Table_Info (Configuration, 0);

      --  Recompile the non-distributed application.

      if not No_Recompilation then

         Maybe_Most_Recent_Stamp (Source_File_Stamp (Configuration_File));

         Display_Commands (Verbose_Mode or Building_Script);
         for Switch in Gcc_Switches.First .. Gcc_Switches.Last loop
            Args (Switch) := Gcc_Switches.Table (Switch);
         end loop;

      end if;

      for U in CUnit.First .. CUnit.Last loop

         if No_Recompilation then
            --  We except ali files to be present. Load them.
            Load_All_Units (CUnit.Table (U).CUname);

         else
            --  Recompile all the configured units to check that
            --  they are present. It is also a way to load the ali files
            --  in the ALIs table.
            Recompile (CUnit.Table (U).CUname);

         end if;

      end loop;

      for H in Hosts.First .. Hosts.Last loop
         if not Hosts.Table (H).Static and then
            Hosts.Table (H).Import = Ada_Import then

            if No_Recompilation then
               Load_All_Units (Hosts.Table (H).External);

            else
               Recompile (Hosts.Table (H).External);

            end if;

         end if;
      end loop;

      --  Set configured unit name key to No_Ali_Id.       (1)

      for U in CUnit.First .. CUnit.Last loop
         Set_ALI_Id (CUnit.Table (U).CUname, No_ALI_Id);
      end loop;

      --  Set ada unit name key to null.                   (2)
      --  Set configured unit name key to the ali file id. (3)

      for U in Unit.First .. Unit.Last loop
         Set_CUID (Unit.Table (U).Uname, Null_CUID);
         Get_Name_String (Unit.Table (U).Uname);
         Name_Len := Name_Len - 2;
         Set_ALI_Id (Name_Find, Unit.Table (U).My_ALI);
      end loop;

      --  Set partition name key to Null_PID.              (4)

      for P in Partitions.First .. Partitions.Last loop
         Set_PID (Partitions.Table (P).Name, Null_PID);
      end loop;

      --  GNATDIST needs some Ada unit names to build the partition
      --  main subprogram, for instance. We check these names are not
      --  already used.

      if Get_Name_Table_Info (Configuration) /= 0 then
         Write_Program_Name;
         Write_Str  (": configuration name """);
         Write_Name (Configuration);
         Write_Str  (""" conflicts with an Ada unit name");
         Write_Eol;
         raise Parsing_Error;
      end if;

      if not Quiet_Output then
         Write_Program_Name;
         Write_Str (": checking configuration consistency");
         Write_Eol;
      end if;

      --  Check that the main program is really a main program.

      if ALIs.Table (Get_ALI_Id (Main_Subprogram)).Main_Program = None then
         Write_Program_Name;
         Write_Str (": ");
         Write_Name (Main_Subprogram);
         Write_Str (" is not a main program");
         Write_Eol;
         raise Partitioning_Error;
      end if;

      --  Check mapped unit name key to detect non-Ada unit.

      for U in CUnit.First .. CUnit.Last loop
         Ali := Get_ALI_Id (CUnit.Table (U).CUname);

         --  Use (3) and (1). If null, then there is no ali
         --  file associated to this configured unit name.
         --  The configured unit is not an Ada unit.

         if Ali = No_ALI_Id then

            --  This unit is not an ada unit
            --  as no ali file has been found.

            Write_Program_Name;
            Write_Str (": unit from configuration file ");
            Write_Name (CUnit.Table (U).CUname);
            Write_Str (" is not an Ada unit");
            Write_Eol;
            Inconsistent := True;

         else
            for I in ALIs.Table (Ali).First_Unit ..
                     ALIs.Table (Ali).Last_Unit loop

               if Unit.Table (I).RCI then

                  --  If not null, we have already set this
                  --  configured rci unit name to a partition.

                  if Get_CUID (Unit.Table (I).Uname) /= Null_CUID  then
                     Write_Program_Name;
                     Write_Str  (": RCI unit ");
                     Write_Name (CUnit.Table (U).CUname);
                     Write_Str  (" has been assigned twice");
                     Write_Eol;
                     Inconsistent := True;
                  end if;

                  --  This RCI has been assigned                  (5)
                  --  and it won't be assigned again.

                  Set_CUID (Unit.Table (I).Uname, U);

               end if;

               --  If there is no body, reference the spec.

               if Unit.Table (I).Utype /= Is_Body then
                  CUnit.Table (U).My_Unit := I;
               end if;

            end loop;

            CUnit.Table (U).My_ALI := Ali;

            --  Set partition name to its index value.             (7)
            --  This way we confirm that the partition is not
            --  empty as it contains at least one unit.

            PID := CUnit.Table (U).Partition;
            Set_PID (Partitions.Table (PID).Name, PID);

         end if;
      end loop;

      --  Use (5) and (2). To check all RCI units are configured.

      for U in Unit.First .. Unit.Last loop
         if Unit.Table (U).RCI and then
            Get_CUID (Unit.Table (U).Uname) = Null_CUID then
            Write_Program_Name;
            Write_Str (": RCI Ada unit ");
            Write_Unit_Name (Unit.Table (U).Uname);
            Write_Str (" has not been assigned to a partition");
            Write_Eol;
            Inconsistent := True;
         end if;
      end loop;

      --  Use (7). Check that no partition is empty.

      for P in Partitions.First .. Partitions.Last loop
         PID := Get_PID (Partitions.Table (P).Name);
         if PID = Null_PID and then
           Partitions.Table (P).Main_Subprogram = No_Name then
            Write_Program_Name;
            Write_Str  (": partition ");
            Write_Name (Partitions.Table (P).Name);
            Write_Str  (" is empty");
            Write_Eol;
            Inconsistent := True;
         end if;
      end loop;

      for U in Unit.First .. Unit.Last loop
         Set_PID (Unit.Table (U).Uname, Null_PID);
      end loop;

      --  Is it still used ?

      for U in CUnit.First .. CUnit.Last loop
         Set_ALI_Id (CUnit.Table (U).CUname, CUnit.Table (U).My_ALI);
      end loop;

      if Inconsistent then
         raise Partitioning_Error;
      end if;

   end Check;

   procedure Initialize is
   begin
      Initialize_ALI;
   end Initialize;

end XE_Check;


