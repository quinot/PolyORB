with CORBA.POA_Types;     use CORBA.POA_Types;

package CORBA.Policy.Id_Assignement_Policy is

   type IdAssignementPolicy is abstract new Policy with null record;
   subtype Id_Assignement_Policy is IdAssignementPolicy;
   type IdAssignementPolicy_Access is access all IdAssignementPolicy'Class;
   subtype Id_Assignement_Policy_Access is IdAssignementPolicy_Access;

   function Create return IdAssignementPolicy_Access is abstract;
   --  The real creation function that has to be implemented for each
   --  possible Policy

   function Is_System (P : IdAssignementPolicy) return Boolean
      is abstract;
   --  Checks if the current policy is able to create ObjectIds
   --  (System_Id policy)

   function Activate_Object
     (Self   : IdAssignementPolicy;
      OA     : CORBA.POA_Types.Obj_Adapter_Access;
      Object : Servant_Access) return Object_Id_Access
      is abstract;
   --  Add an object to the Active Object Map, and return a new
   --  Object_Id

   procedure Activate_Object_With_Id
     (Self   : IdAssignementPolicy;
      OA     : CORBA.POA_Types.Obj_Adapter_Access;
      Object : Servant_Access;
      Oid    : Object_Id)
      is abstract;
   --  Add an object to the Active Object Map, and return a new
   --  Object_Id

   procedure Ensure_Oid_Origin
     (Self  : IdAssignementPolicy;
      U_Oid : Unmarshalled_Oid_Access)
      is abstract;
   --  Checks if the given Oid has been generated by the system
   --  Case SYSTEM_ID:
   --    raise the Bad_Param exception is the Object_Id has been generated
   --    by the user
   --  Case USER_ID:
   --    does nothing;

   procedure Ensure_Oid_Uniqueness
     (Self  : IdAssignementPolicy;
      OA    : CORBA.POA_Types.Obj_Adapter_Access;
      U_Oid : Unmarshalled_Oid_Access)
      is abstract;
   --  Checks if the Object_Id is not yet in use.
   --  Case SYSTEM_ID:
   --    Checks that the element in the map whose index is the Id
   --    is free.
   --  Case USER_ID:
   --    Loop through the map to check that the U_Oid is not yet used

   procedure Remove_Entry
     (Self  : IdAssignementPolicy;
      OA    : CORBA.POA_Types.Obj_Adapter_Access;
      U_Oid : Unmarshalled_Oid_Access)
      is abstract;
   --  Removes an entry from the Active Object Map

   function Id_To_Servant (Self  : IdAssignementPolicy;
                           OA    : CORBA.POA_Types.Obj_Adapter_Access;
                           U_Oid : Unmarshalled_Oid_Access)
                          return Servant_Access
      is abstract;
   --  Look in the Active Object Map for the given U_Oid. If found,
   --  returns the associated Servant. Otherwise, returns null.

   procedure Free
     (P   : in     IdAssignementPolicy;
      Ptr : in out Policy_Access) is abstract;

end CORBA.Policy.Id_Assignement_Policy;
