package body CORBA.Policy.Implicit_Activation_Policy.No_Activation is

   use CORBA.Policy_Values;

   ------------
   -- Create --
   ------------

   function Create return No_Activation_Policy_Access
   is
      Policy : No_Activation_Policy_Access;
   begin
      Policy
        := new No_Activation_Policy'(Policy_Type =>
                                       IMPLICIT_ACTIVATION_POLICY_ID,
                                     Value =>
                                       CORBA.Policy_Values.
                                       NO_IMPLICIT_ACTIVATION);
      return Policy;
   end Create;

   -------------------------
   -- Check_Compatibility --
   -------------------------

   procedure Check_Compatibility (Self : No_Activation_Policy;
                                  OA   : CORBA.POA_Types.Obj_Adapter_Access)
   is
   begin
      null;
   end Check_Compatibility;

end CORBA.Policy.Implicit_Activation_Policy.No_Activation;
