-----------------------------------------------------------------------
----                                                               ----
----                  AdaBroker                                    ----
----                                                               ----
----                  package omniProxyCallDesc                    ----
----                                                               ----
----   authors : Sebastien Ponce, Fabien Azavant                   ----
----   date    :                                                   ----
----                                                               ----
----                                                               ----
-----------------------------------------------------------------------


package omniProxyCallDesc is

   type Object is abstract tagged limited private;

   -- all the following funcitions correspond
   -- to omniORB's OmniProxyCallDesc
   -- In proxyCall.h L33
   procedure Init (Self : in out Object,
                     ...
                  );

   function AlignedSize(Size_In: in Corba.Unsigned_Long)
     return Corba.Unsigned_Long is abstract ;

   procedure MarshalArguments (Giop_Client: in out Giop_C) is abstract ;

   procedure UnmarshalReturnedValues (Giop_Client: in out Giop_C) is abstract ;

   procedure UserException (Giop_Client : in Giop_C, RepoId : in CORBA::String);

   function Has_User_Exceptions (Self : in Object) return CORBA::Boolean;

   function Operation_Len (Self : in Object) return Size_T;

   function Operation (Self : in Object) return CORBA::String;

private


end omniproxyCallDesc ;

