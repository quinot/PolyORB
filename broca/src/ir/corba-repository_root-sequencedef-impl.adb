----------------------------------------------
--  This file has been generated automatically
--  by AdaBroker (http://adabroker.eu.org/)
----------------------------------------------

with Corba.Repository_Root; use Corba.Repository_Root;
with CORBA.Repository_Root.IDLType.Impl;
with CORBA.Repository_Root.IRObject.Impl;
with CORBA.Repository_Root.IDLType;
with CORBA.Repository_Root.SequenceDef.Skel;

package body CORBA.Repository_Root.SequenceDef.Impl is

   ----------------------
   --  Procedure init  --
   ----------------------
   procedure Init (Self : access Object;
                   Real_Object :
                     CORBA.Repository_Root.IRObject.Impl.Object_Ptr;
                   Def_Kind : CORBA.Repository_Root.DefinitionKind;
                   IDL_Type : CORBA.TypeCode.Object;
                   Bound : CORBA.Unsigned_Long;
                   Element_Type_Def : CORBA.Repository_Root.IDLType.Ref) is
   begin
      IDLType.Impl.Init (IDLType.Impl.Object_Ptr (Self),
                         Real_Object,
                         Def_Kind,
                         IDL_Type);
      Self.Bound := Bound;
      Self.Element_Type_Def := Element_Type_Def;
   end Init;





   function get_bound
     (Self : access Object)
     return CORBA.Unsigned_Long
   is
      Result : CORBA.Unsigned_Long;
   begin

      --  Insert implementation of get_bound

      return Result;
   end get_bound;


   procedure set_bound
     (Self : access Object;
      To : in CORBA.Unsigned_Long) is
   begin

      --  Insert implementation of set_bound

      null;
   end set_bound;


   function get_element_type
     (Self : access Object)
     return CORBA.TypeCode.Object
   is
   begin
      return IDLType.Impl.Get_Type
        (IDLType.Impl.Object_Ptr
         (IDLType.Object_Of
          (Self.Element_Type_Def)));
   end get_element_type;


   function get_element_type_def
     (Self : access Object)
     return CORBA.Repository_Root.IDLType.Ref
   is
      Result : CORBA.Repository_Root.IDLType.Ref;
   begin

      --  Insert implementation of get_element_type_def

      return Result;
   end get_element_type_def;


   procedure set_element_type_def
     (Self : access Object;
      To : in CORBA.Repository_Root.IDLType.Ref) is
   begin

      --  Insert implementation of set_element_type_def

      null;
   end set_element_type_def;

end CORBA.Repository_Root.SequenceDef.Impl;
