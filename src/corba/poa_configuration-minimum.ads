package POA_Configuration.Minimum is

   type Minimum_Configuration is new Configuration_Type with private;

   procedure Initialize
     (C : Minimum_Configuration;
      F : Droopi.POA_Policies.Policy_Repository);

   function Default_Policies
     (C : Minimum_Configuration)
     return Droopi.POA_Policies.PolicyList_Access;

private

   type Minimum_Configuration is new Configuration_Type
     with null record;

end POA_Configuration.Minimum;
