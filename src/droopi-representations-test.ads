--  A dummy data representation method, just for show.

--  $Id$

with Droopi.Buffers; use Droopi.Buffers;

package Droopi.Representations.Test is

   type Rep_Test is new Representation with private;
   type Rep_Test_Access is access all Rep_Test;

   --  A real representation function should implement the
   --  following two subprograms.

   procedure Marshall_From_Any
     (R      : Rep_Test;
      Buffer : access Buffers.Buffer_Type;
      Data   : CORBA.Any);

   procedure Unmarshall_To_Any
     (R      : Rep_Test;
      Buffer : access Buffers.Buffer_Type;
      Data   : in out CORBA.Any);

   --  The following methods are specific to Rep_Test and are
   --  here only to facilitate testing of other parts of the ORB.

   procedure Marshall_String
     (R : access Rep_Test;
      B : access Buffer_Type;
      S : String);
   --  Marshall a string.

   function Unmarshall_String
     (R : access Rep_Test;
      B : access Buffer_Type)
     return String;
   --  Unmarshall a string terminated by a CR/LF sequence.

private

   type Rep_Test is new Representation with null record;

end Droopi.Representations.Test;
