----------------------------------------------------------------------------
----                                                                    ----
----     This in an example which is hand-written                       ----
----     for the echo object                                            ----
----                                                                    ----
----                package echo                                        ----
----                                                                    ----
----                authors : Fabien Azavant, Sebastien Ponce           ----
----                                                                    ----
----------------------------------------------------------------------------


package Echo is

   --------------------------------------------------
   ----                spec                      ----
   --------------------------------------------------

   type Ref is new Corba.Object.Ref with null record ;

   function To_Ref(From: in Corba.Object.Ref'Class) return Ref ;

   function EchoString(Self: in Ref, Message: in Corba.String) return Corba.String ;


   --------------------------------------------------
   ----              not in  spec                ----
   --------------------------------------------------

   type OmniProxyCallDesc_Echo is new OmniProxyCallDesc with private ;

   function AlignedSize(Self: in OmniProxyCallDesc_Echo,
                          Size_In: in Corba.Unsigned_Long)
                        return Corba.Unsigned_Long ;

   procedure MarshalArguments(Self: in OmniProxyCallDesc_Echo,
                                Giop_Client: in out Giop_C) ;

   procedure UnmarshalReturnedValues(Self: in OmniProxyCallDesc_Echo,
                                       Giop_Client: in out Giop_C) ;


private

   type OmniProxyCallDesc_Echo is new OmniProxyCallDesc with record
      Arg : String ;
      Result : String ;
   end record ;


End Echo ;




