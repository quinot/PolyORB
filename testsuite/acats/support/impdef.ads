-- IMPDEF.A
--
--                             Grant of Unlimited Rights
--
--     Under contracts F33600-87-D-0337, F33600-84-D-0280, MDA903-79-C-0687 and
--     F08630-91-C-0015, the U.S. Government obtained unlimited rights in the
--     software and documentation contained herein.  Unlimited rights are 
--     defined in DFAR 252.227-7013(a)(19).  By making this public release, 
--     the Government intends to confer upon all recipients unlimited rights
--     equal to those held by the Government.  These rights include rights to
--     use, duplicate, release or disclose the released technical data and
--     computer software in whole or in part, in any manner and for any purpose
--     whatsoever, and to have or permit others to do so.
--
--                                    DISCLAIMER
--
--     ALL MATERIALS OR INFORMATION HEREIN RELEASED, MADE AVAILABLE OR
--     DISCLOSED ARE AS IS.  THE GOVERNMENT MAKES NO EXPRESS OR IMPLIED 
--     WARRANTY AS TO ANY MATTER WHATSOEVER, INCLUDING THE CONDITIONS OF THE
--     SOFTWARE, DOCUMENTATION OR OTHER INFORMATION RELEASED, MADE AVAILABLE 
--     OR DISCLOSED, OR THE OWNERSHIP, MERCHANTABILITY, OR FITNESS FOR A
--     PARTICULAR PURPOSE OF SAID MATERIAL.
--*
--
-- DESCRIPTION:
--     This package provides tailorable entities for a particular
--     implementation.  Each entity may be modified to suit the needs
--     of the implementation.  Default values are provided to act as
--     a guide.
--
--     The entities in this package are those which are used in at least
--     one core test. Entities which are used exclusively in tests for
--     annexes C-H are located in annex-specific child units of this package.
--
-- CHANGE HISTORY:
--     12 DEC 93   SAIC    Initial PreRelease version
--     02 DEC 94   SAIC    Second  PreRelease version
--     16 May 95   SAIC    Added constants specific to tests of the random
--                         number generator.
--     16 May 95   SAIC    Added Max_RPC_Call_Time constant.
--     17 Jul 95   SAIC    Added Non_State_String constant.
--     21 Aug 95   SAIC    Created from existing IMPSPEC.ADA and IMPBODY.ADA
--                         files.
--     30 Oct 95   SAIC    Added external name string constants.
--     24 Jan 96   SAIC    Added alignment constants.
--     29 Jan 96   SAIC    Moved entities not used in core tests into annex-
--                         specific child packages. Adjusted commentary.
--                         Renamed Validating_System_Programming_Annex to
--                         Validating_Annex_C. Added similar Validating_Annex_?
--                         constants for the other non-core annexes (D-H).
--     01 Mar 96   SAIC    Added external name string constants.
--     21 Mar 96   SAIC    Added external name string constants.
--     02 May 96   SAIC    Removed constants for draft test CXA5014, which was
--                         removed from the tentative ACVC 2.1 suite.
--                         Added constants for use with FXACA00.
--     06 Jun 96   SAIC    Added constants for wide character test files.
--     11 Dec 96   SAIC    Updated constants for wide character test files.
--     13 Dec 96   SAIC    Added Address_Value_IO
--
--!
 
with Report;
with Ada.Text_IO;
with System.Storage_Elements;
 
package ImpDef is
 
--=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====--
 
   -- The following boolean constants indicate whether this validation will
   -- include any of annexes C-H. The values of these booleans affect the
   -- behavior of the test result reporting software.
   --
   --    True  means the associated annex IS included in the validation.
   --    False means the associated annex is NOT included.
 
   Validating_Annex_C : constant Boolean := True;
   --                                       ^^^^^ --- MODIFY HERE AS NEEDED
 
   Validating_Annex_D : constant Boolean := True;
   --                                       ^^^^^ --- MODIFY HERE AS NEEDED

   Validating_Annex_E : constant Boolean := True;
   --                                       ^^^^^ --- MODIFY HERE AS NEEDED

   Validating_Annex_F : constant Boolean := True;
   --                                       ^^^^^ --- MODIFY HERE AS NEEDED

   Validating_Annex_G : constant Boolean := True;
   --                                       ^^^^^ --- MODIFY HERE AS NEEDED

   Validating_Annex_H : constant Boolean := True;
   --                                       ^^^^^ --- MODIFY HERE AS NEEDED

--=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====--
 
   -- This is the minimum time required to allow another task to get
   -- control.  It is expected that the task is on the Ready queue.
   -- A duration of 0.0 would normally be sufficient but some number
   -- greater than that is expected.

   Minimum_Task_Switch : constant Duration := 0.1;
   --                                         ^^^ --- MODIFY HERE AS NEEDED
 
--=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====--
 
   -- This is the time required to activate another task and allow it
   -- to run to its first accept statement.  We are considering a simple task
   -- with very few Ada statements before the accept.  An implementation is
   -- free to specify a delay of several seconds, or even minutes if need be.
   -- The main effect of specifying a longer delay than necessary will be an
   -- extension of the time needed to run the associated tests.

   Switch_To_New_Task : constant Duration := 1.0;
   --                                        ^^^ -- MODIFY HERE AS NEEDED
 
--=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====--
 
   -- This is the time which will clear the queues of other tasks
   -- waiting to run.  It is expected that this will be about five
   -- times greater than Switch_To_New_Task.

   Clear_Ready_Queue : constant Duration := 5.0;
   --                                       ^^^ --- MODIFY HERE AS NEEDED
 
--=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====--
 
   -- Some implementations will boot with the time set to 1901/1/1/0.0
   -- When a delay of Delay_For_Time_Past is given, the implementation
   -- guarantees that a subsequent call to Ada.Calendar.Time_Of(1901,1,1)
   -- will yield a time that has already passed (for example, when used in
   -- a delay_until statement).

   Delay_For_Time_Past : constant Duration := 0.1;
   --                                         ^^^ --- MODIFY HERE AS NEEDED

--=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====--
 
   -- Minimum time interval between calls to the time dependent Reset
   -- procedures in Float_Random and Discrete_Random packages that is
   -- guaranteed to initiate different sequences.  See RM A.5.2(45).

   Time_Dependent_Reset : constant Duration := 0.3;
   --                                          ^^^ --- MODIFY HERE AS NEEDED
 
--=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====--
 
   -- Test CXA5013 will loop, trying to generate the required sequence
   -- of random numbers.  If the RNG is faulty, the required sequence
   -- will never be generated.  Delay_Per_Random_Test is a time-out value
   -- which allows the test to run for a period of time after which the
   -- test is failed if the required sequence has not been produced.
   -- This value should be the time allowed for the test to run before it
   -- times out.  It should be long enough to allow multiple (independent)
   -- runs of the testing code, each generating up to 1000 random
   -- numbers.

   Delay_Per_Random_Test : constant Duration := 1.0;
   --                                           ^^^ --- MODIFY HERE AS NEEDED
 
--=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====--
 
   -- The time required to execute this procedure must be greater than the
   -- time slice unit on implementations which use time slicing.  For
   -- implementations which do not use time slicing the body can be null.

   procedure Exceed_Time_Slice;

--=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====--
 
   -- This constant must not depict a random number generator state value.
   -- Using this string in a call to function Value from either the
   -- Discrete_Random or Float_Random packages will result in
   -- Constraint_Error (expected result in test CXA5012).

   Non_State_String : constant String := "By No Means A State";
   --           MODIFY HERE AS NEEDED --- ^^^^^^^^^^^^^^^^^^^
 
--=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====--
 
   -- This string constant must be a legal external tag value as used by
   -- CD10001 for the type Some_Tagged_Type in the representation
   -- specification for the value of 'External_Tag.
 
   External_Tag_Value : constant String := "implementation_defined";
   --             MODIFY HERE AS NEEDED --- ^^^^^^^^^^^^^^^^^^^^^^
 
--=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====--
 
   -- The following address constant must be a valid address to locate
   -- the C program CD30005_1.  It is shown here as a named number;
   -- the implementation may choose to type the constant as appropriate.
 
   CD30005_1_Foreign_Address : constant System.Address:= 
                System.Storage_Elements.To_Address ( 16#0000_0000# );
   --                    MODIFY HERE AS REQUIRED --- ^^^^^^^^^^^^^
 
--=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====--
 
   -- The following string constant must be the external name resulting
   -- from the C compilation of CD30005_1.  The string will be used as an
   -- argument to pragma Import.
 
   CD30005_1_External_Name : constant String := "CD30005_1";
   --                  MODIFY HERE AS NEEDED --- ^^^^^^^^^
 
--=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====--
 
   -- The following constants should represent the largest default alignment
   -- value and the largest alignment value supported by the linker.
   -- See RM 13.3(35).
 
   Max_Default_Alignment : constant := 0;
   --                                  ^ --- MODIFY HERE AS NEEDED
 
   Max_Linker_Alignment  : constant := 0;
   --                                  ^ --- MODIFY HERE AS NEEDED
 
--=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====--

   -- The following string constants must be the external names resulting
   -- from the C compilation of CXB30130.C and CXB30131.C.  The strings 
   -- will be used as arguments to pragma Import.
 
   CXB30130_External_Name : constant String := "CXB30130";
   --                 MODIFY HERE AS NEEDED --- ^^^^^^^^
 
   CXB30131_External_Name : constant String := "CXB30131";
   --                 MODIFY HERE AS NEEDED --- ^^^^^^^^
 
--=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====--

   -- The following string constants must be the external names resulting
   -- from the COBOL compilation of CXB40090.CBL, CXB40091.CBL, and 
   -- CXB40092.CBL.  The strings will be used as arguments to pragma Import.
 
   CXB40090_External_Name : constant String := "CXB40090";
   --                 MODIFY HERE AS NEEDED --- ^^^^^^^^
 
   CXB40091_External_Name : constant String := "CXB40091";
   --                 MODIFY HERE AS NEEDED --- ^^^^^^^^
 
   CXB40092_External_Name : constant String := "CXB40092";
   --                 MODIFY HERE AS NEEDED --- ^^^^^^^^
 
--=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====--

   -- The following string constants must be the external names resulting
   -- from the Fortran compilation of CXB50040.FTN, CXB50041.FTN,
   -- CXB50050.FTN, and CXB50051.FTN.
   --
   -- The strings will be used as arguments to pragma Import.
   --
   -- Note that the use of these four string constants will be split between 
   -- two tests, CXB5004 and CXB5005.

   CXB50040_External_Name : constant String := "CXB50040";
   --                 MODIFY HERE AS NEEDED --- ^^^^^^^^
 
   CXB50041_External_Name : constant String := "CXB50041";
   --                 MODIFY HERE AS NEEDED --- ^^^^^^^^
 
   CXB50050_External_Name : constant String := "CXB50050";
   --                 MODIFY HERE AS NEEDED --- ^^^^^^^^

   CXB50051_External_Name : constant String := "CXB50051";
   --                 MODIFY HERE AS NEEDED --- ^^^^^^^^
 
--=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====--

   -- The following constants have been defined for use with the 
   -- representation clause in FXACA00 of type Sales_Record_Type.  
   -- 
   -- Char_Bits should be an integer at least as large as the number
   -- of bits needed to hold a character in an array.  
   -- A value of 6 * Char_Bits will be used in a representation clause 
   -- to reserve space for a six character string.
   -- 
   -- Next_Storage_Slot should indicate the next storage unit in the record
   -- representation clause that does not overlap the storage designated for
   -- the six character string.

   Char_Bits         : constant := 8;
   --     MODIFY HERE AS NEEDED ---^

   Next_Storage_Slot : constant := 6;
   --     MODIFY HERE AS NEEDED ---^

--=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====--

   -- The following string constant must be the path name for the .AW
   -- files that will be processed by the Wide Character processor to
   -- create the C250001 and C250002 tests.  The Wide Character processor
   -- will expect to find the files to process at this location.

   Test_Path_Root : constant String :=
     "/data/ftp/public/AdaIC/testing/acvc/95acvc/";
   -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ --- MODIFY HERE AS NEEDED

   -- The following two strings must not be modified unless the .AW file
   -- names have been changed.  The Wide Character processor will use
   -- these strings to find the .AW files used in creating the C250001
   -- and C250002 tests.

  Wide_Character_Test : constant String := Test_Path_Root & "c250001";
  Upper_Latin_Test    : constant String := Test_Path_Root & "c250002";

--=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====--

   -- The following instance of Integer_IO or Modular_IO must be supplied
   -- in order for test CD72A02 to compile correctly.
   -- Depending on the choice of base type used for the type
   -- System.Storage_Elements.Integer_Address; one of the two instances will
   -- be correct.  Comment out the incorrect instance.

   --M package Address_Value_IO is
   --M      new Ada.Text_IO.Integer_IO(System.Storage_Elements.Integer_Address);

   package Address_Value_IO is
         new Ada.Text_IO.Modular_IO(System.Storage_Elements.Integer_Address);

--=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====-=====--

end ImpDef;
