-----------------------------------------------------------------------
----                                                               ----
----                  AdaBroker                                    ----
----                                                               ----
----                  package body CORBA                           ----
----                                                               ----
----   authors : Sebastien Ponce, Fabien Azavant                   ----
----   date    : 02/10/99                                          ----
----                                                               ----
----                                                               ----
-----------------------------------------------------------------------



package body Corba is



   -----------------------------------------------------------
   ----           Exceptions in spec                       ---
   -----------------------------------------------------------

   -- GetMembers
   -------------
   procedure Get_Members (From : in Ada.Exceptions.Exception_Occurrence;
                          To : out System_Exception_Members) is
   begin
      Ada.Exceptions.Raise_Exception(Corba.AdaBroker_Not_Implemented_Yet'Identity,
                                     "Corba.Get_Members");
   end ;

   -- Raise_Corba_Exception
   ------------------------
   procedure Raise_Corba_Exception(Excp : in Ada.Exceptions.Exception_Id ;
                                   Excp_Memb: in Idl_Exception_Members'class) is
   begin
      Ada.Exceptions.Raise_Exception(Corba.AdaBroker_Not_Implemented_Yet'Identity,
                                     "Raise_Corba_Exception") ;
   end ;


   -----------------------------------------------------------
   ----        not in spec, AdaBroker specific             ---
   -----------------------------------------------------------

   -- To_Corba_String
   ------------------
    function To_Corba_String(S: in Standard.String) return Corba.String is

    begin
       return Corba.String(Ada.Strings.Unbounded.To_Unbounded_String(S)) ;
    end ;


    -- To_Standard_String
    ---------------------
    function To_Standard_String(S: in Corba.String) return Standard.String is
    begin
       return Ada.Strings.Unbounded.To_String(Ada.Strings.Unbounded.Unbounded_String(S)) ;
    end;

    -- Length
    ---------
    function Length(Str : in Corba.String) return Corba.Unsigned_Long is
    begin
       return Corba.Unsigned_Long(Ada.Strings.Unbounded.
                                  Length(Ada.Strings.Unbounded.
                                         Unbounded_String(Str))) ;
    end ;



   -----------------------------------------------------------
   ----           not in spec  omniORB2 specific           ---
   -----------------------------------------------------------


    function Omni_CallTransientExceptionHandler return CORBA.Boolean is
    begin
      Ada.Exceptions.Raise_Exception(Corba.AdaBroker_Not_Implemented_Yet'Identity,
                                     "Omni_CallTransientExceptionHandler") ;
      return False ;
    end ;


    function Omni_CallCommFailureExceptionHandler return CORBA.Boolean is
    begin
       Ada.Exceptions.Raise_Exception(Corba.AdaBroker_Not_Implemented_Yet'Identity,
                                      "Omni_CallCommFailureExceptionHandler") ;
       return False ;
    end ;


    function Omni_CallSystemExceptionHandler return CORBA.Boolean is
    begin
       Ada.Exceptions.Raise_Exception(Corba.AdaBroker_Not_Implemented_Yet'Identity,
                                      "Omni_CallSystemExceptionHandler") ;
       return False ;
    end ;






end Corba ;
