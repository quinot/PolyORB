------------------------------------------------------------------------------
--                                                                          --
--                           POLYORB COMPONENTS                             --
--                                                                          --
--               POLYORB.SECURITY.BACKWARD_TRUST_EVALUATORS                 --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2005-2012, Free Software Foundation, Inc.          --
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

with PolyORB.Security.Identities;
with PolyORB.Types;

package PolyORB.Security.Backward_Trust_Evaluators is

   type Backward_Trust_Evaluator is tagged private;

   type Backward_Trust_Evaluator_Access is
     access all Backward_Trust_Evaluator'Class;

   procedure Evaluate_Trust
     (Evaluator         : access Backward_Trust_Evaluator;
      Client_Identity   :        PolyORB.Security.Identities.Identity_Access;
      Asserted_Identity :        PolyORB.Security.Identities.Identity_Access;
      Trusted           :    out Boolean);

   function Create_Backward_Trust_Evaluator
     (File : String) return Backward_Trust_Evaluator_Access;

private

   type Backward_Trust_Evaluator is tagged record
      File_Name : PolyORB.Types.String;
   end record;

end PolyORB.Security.Backward_Trust_Evaluators;
