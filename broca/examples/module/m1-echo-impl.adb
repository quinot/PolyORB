package body M1.Echo.Impl is

   function EchoMy_String (Self : access Object; Mesg : in My_String)
                        return CORBA.String is
   begin
      return CORBA.String (Mesg);
   end EchoString;

end M1.Echo.Impl;

