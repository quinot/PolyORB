with GNAT.Table;
with Idl_Fe.Errors;
with Ada.Unchecked_Deallocation;

package Idl_Fe.Types is

   -------------------------------
   --  simple type definitions  --
   -------------------------------

   type Node_Id is new Integer;
   No_Node : constant Node_Id := 0;

   --  used for the identifiers
   type String_Cacc is access constant String;
   --  all the possible kind of constants
   --  These types are used in the evaluation of constants to check
   --  that each subexpression of an expression does not exceed the
   --  precision of the final expression. In this context, there's
   --  no use to distinguish signed and unsigned integers (see CORBA
   --  V2.3 - 3.9.2), so C_Short for example could be a short or an
   --  unsigned short.
   --  The distinction is kept for long long due to the special way
   --  to code it : see idl_fe.tree.ads.

   type Const_Kind is
     (C_Short,
      C_Long,
      C_LongLong,
--      C_UShort,
--      C_ULong,
      C_ULongLong,
      C_Char,
      C_WChar,
      C_Boolean,
      C_Float,
      C_Double,
      C_LongDouble,
      C_Fixed,
      C_String,
      C_WString,
      C_Octet,
      C_Enum);

   --  type of a constant
   type Idl_Fixed_Digits_Nb is new Long_Long_Integer range 0 .. 31;
   type Idl_Fixed_Scale is new Long_Long_Integer range 0 .. 31;
   type Const_Type (Kind : Const_Kind) is record
      case Kind is
         when C_Fixed =>
            Digits_Nb : Idl_Fixed_Digits_Nb;
            Scale : Idl_Fixed_Scale;
         when others =>
            null;
      end case;
   end record;
   type Const_Type_Ptr is access Const_Type;

   --  to deallocate a const_type_ptr
   procedure Free is new Ada.Unchecked_Deallocation
     (Const_Type, Const_Type_Ptr);


   --  Identifiers are numbered, in order to make comparaison
   --  easier and static. Each number is unique.
   type Uniq_Id is new Natural;
   Nil_Uniq_Id : constant Uniq_Id := 0;

   type Param_Mode is (Mode_In, Mode_Inout, Mode_Out);

   ----------------------------------
   --  Management of const values  --
   ----------------------------------

   --  generic type for constant values (except floating ones)
   --  This type is used for all values (short as well as long long)
   --  in order to have operations between longs and shorts for
   --  example. The way it is used for long long and unsigned long
   --  long is a bit strange : both use the whole 64 bits and you
   --  can not add a long long and an unsigned long long without
   --  care.
   type Idl_Value is mod (2 ** 64);

   --  These are the limits for each Idl type.
   Idl_Short_Min : constant Idl_Value := (-2 ** 15);
   Idl_Short_Max : constant Idl_Value := (2 ** 15) - 1;
   Idl_Long_Min : constant Idl_Value := (-2 ** 31);
   Idl_Long_Max : constant Idl_Value := (2 ** 31) - 1;
   Idl_LongLong_Min : constant Idl_Value := (-2 ** 63);
   Idl_LongLong_Max : constant Idl_Value := (2 ** 63) - 1;
   Idl_UShort_Min : constant Idl_Value := 0;
   Idl_UShort_Max : constant Idl_Value := (2 ** 16) - 1;
   Idl_ULong_Min : constant Idl_Value := 0;
   Idl_ULong_Max : constant Idl_Value := (2 ** 32) - 1;
   Idl_ULongLong_Min : constant Idl_Value := 0;
   Idl_ULongLong_Max : constant Idl_Value := (2 ** 64) - 1;

   Idl_Enum_Max : constant Idl_Value := (2 ** 32) - 1;

   --  To manipulate the location of a node
   subtype Location is Idl_Fe.Errors.Location;
   procedure Set_Location (N : Node_Id;
                           Loc : Location);
   function Get_Location (N : Node_Id) return Location;

   ---------------------------------
   -- A useful list of root nodes --
   ---------------------------------

   --  Definition in a lisp like style of a node list
   type Node_List_Cell;
   type Node_List is access Node_List_Cell;
   type Node_List_Cell is record
      Car : Node_Id;
      Cdr : Node_List;
   end record;

   --  Definition of the iterator on a node list
   type Node_Iterator is new Node_List;

   --  the empty list
   Nil_List : constant Node_List := null;

   --  Simple way to iterate over a node_list.
   --  NODE_ITERATOR is a type representing an iterator, which must
   --  be initialiazed by INIT.
   --  End of list is detected by IS_END.
   --  Until the end of list is reached, the node can be extracted
   --  with GET_NODE and the iterator can be incremented with NEXT.
   --  Therefore, usual way to use an iterator is:
   --  declare
   --    it: node_iterator;
   --    node: node_id;
   --  begin
   --    init (it, rep.contents);
   --    while not is_end (it) loop
   --      node := get_node (it);
   --      ...
   --      next (it);
   --    end loop;
   procedure Init (It : out Node_Iterator; List : Node_List);
   function Get_Node (It : Node_Iterator) return Node_Id;
   procedure Next (It : in out Node_Iterator);
   function Is_End (It : Node_Iterator) return Boolean;

   --  Appends a node at the end of a list.
   procedure Append_Node (List : in out Node_List;
                          Node : in Node_Id);

   --  Appends a node at the end of a list.
   function Append_Node (List : in Node_List;
                         Node : Node_Id) return Node_List;

   --  Look whether node is in list or not
   function Is_In_List (List : Node_List; Node : Node_Id) return Boolean;

   --  Removes a node from the list. Actually only removes the first
   --  occurence of the node or does nothing if the node was not in
   --  the list.
   procedure Remove_Node (List : in out Node_List; Node : Node_Id);

   --  Frees all the list
   procedure Free (List : in out Node_List);

   --  computes the length of the list
   function Get_Length (List : in Node_List) return Integer;

   --  Function that take a node list and remove all the redondant items
   --  returns the resulting node list
   --  usefull for the inheritance treatement
   function Simplify_Node_List (In_List : Node_List) return Node_List;

   ----------------------------------------
   --  Type of an identifier definition  --
   ----------------------------------------

   --  An identifier definition contains the following :
   --    - the name of the identifier
   --    - the uniq_id of the identifier
   --    - the node in which it was defined
   --    - the previous definition of the same identifier (if overloaded)
   --    - a pointer on the parent scope of the node
   type Identifier_Definition;
   type Identifier_Definition_Acc is access Identifier_Definition;
   type Identifier_Definition is record
      Name : String_Cacc := null;
      Id : Uniq_Id;
      Node : Node_Id;
      Previous_Definition : Identifier_Definition_Acc;
      Parent_Scope : Node_Id;
   end record;

   --  Definition of a list of identifier_definition
   type Identifier_Definition_List is private;

   --  Return the named node corresponding to the identifier
   --  definition.
   --  Raises fatal_error if Cell is a null pointer
   function Get_Node
     (Definition : Identifier_Definition_Acc)
     return Node_Id;

   ----------------------
   --  scope handling  --
   ----------------------

   --  Scopes are stacked and create an identifier space.
   --  In a scope, an identifier has at most one meaning.

   --  Get the root (the oldest) and current (the newest) scope.
   function Get_Root_Scope return Node_Id;
   function Get_Current_Scope return Node_Id;

   --  Get the scope of the current scope
   function Get_Previous_Scope return Node_Id;

   --  Create a new scope, defined by a Scope node, add it in
   --  the current scope, and activate it.
   procedure Push_Scope (Scope : Node_Id);

   --  Unstack the current scope.
   procedure Pop_Scope;

   --  In order to ensure that each forward definition of a value
   --  or an interface is implemented in the same scope, here are
   --  some methods to take forward declarations and implementations
   --  into account

   --  To add a forward declaration in the list
   procedure Add_Int_Val_Forward (Node : in Node_Id);

   --  To take an implementation into account and remove the
   --  corresponding forward declaration from the list.
   procedure Add_Int_Val_Definition (Node : in Node_Id);

   ----------------------------
   --  identifiers handling  --
   ----------------------------

   --  Check if the name is redefinable in the current scope
   --  If result is false, means that find_identifier_definition
   --  has a NOT NULL result!
   function Is_Redefinable (Name : String) return Boolean;

   --  Check if the  uniq_id from an identifier is already defined
   --  return it or Nil_Uniq_Id
   function Check_Identifier_Index (Identifier : String) return Uniq_Id;

   --  Create the uniq_id entry for an identifier if it doesn't exist
   --  return it
   function Create_Identifier_Index (Identifier : String) return Uniq_Id;

   --  Find the current identifier definition.
   --  The current identifier is the one just scanned by the lexer
   --  If this identifier is not defined, returns a null pointer.
   function Find_Identifier_Definition (Name : String)
                                        return Identifier_Definition_Acc;

   --  Find the node corresponding to the current identifier.
   --  The current identifier is the one just scanned by the lexer
   --  If this identifier is not defined, returns a null pointer.
   function Find_Identifier_Node (Name : String) return Node_Id;

--   function Find_Identifier_Node (Scope : Node_Id; Name : String)
--                                  return Node_Id;


   --  Change the definition (associed node) of CELL.
   --  only used in the case of a forward interface definition
   procedure Redefine_Identifier
     (A_Definition : Identifier_Definition_Acc;
      Node : Node_Id);

   --  Creates an identifier definition for the current identifier
   --  and add it to the current scope.
   --  Node is the node where the identifier is defined.
   --  Returns true if successfull, false if the identifier was
   --  already in this scope.
   function Add_Identifier (Node : Node_Id;
                            Name : String) return Boolean;


   --  Check if the  uniq_id from an identifier is already defined
   --  in the scope and return it or Nil_Uniq_Id
   function Check_Identifier_In_Storage
     (Scope : Node_Id;
      Identifier : String)
     return Uniq_Id;

   --  Find the identifier definition in Scope.
   --  If this identifier is not defined, returns a null pointer.
   function Find_Identifier_In_Storage
     (Scope : Node_Id; Name : String)
     return Identifier_Definition_Acc;

   --  Create the uniq_id entry for an identifier in the storage table
   --  at the end of the scope parsing
   --  return it
   function Create_Identifier_In_Storage
     (Identifier : String)
     return Uniq_Id;

   --  add the definition to the current scope storage table.
   --  It is done at the end of the scope parsing (called by pop_scope)
   procedure Add_Definition_To_Storage
     (Definition : in Identifier_Definition_Acc);

   --  Check if the  uniq_id from an identifier is already defined
   --  in the imported table.
   --  return it or Nil_Uniq_Id
   function Check_Imported_Identifier_Index (Identifier : String)
                                             return Uniq_Id;

   --  Find the identifier definition in the imported table.
   --  If this identifier is not defined, returns a null pointer.
   function Find_Imported_Identifier_Definition (Name : String)
                                          return Identifier_Definition_Acc;

   --  Create the uniq_id entry for an identifier in the imported table of
   --  the given scope
   --  return it
   function Create_Identifier_In_Imported (Identifier : String;
                                           Scope : Node_Id)
                                           return Uniq_Id;


   --  add the imported definition to the given scope imported table.
   procedure Add_Definition_To_Imported
     (Definition : in Identifier_Definition_Acc; Scope : in Node_Id);

   --  Find the identifier in the scope's parents (in each one recursively)
   --  add the different definitions to the node list
   --  it is usefull for looking in the inherited interfaces or value types
   procedure Find_Identifier_In_Inheritance (Name : in String;
                                             Scope : in Node_Id;
                                             List : in out Node_List);

   --  Find the identifier definition in the inherited interface.
   --  If this identifier is not defined, returns a null pointer.
   function Find_Inherited_Identifier_Definition (Name : String)
                                          return Identifier_Definition_Acc;

   ----------------------------
   --  identifiers handling  --
   ----------------------------

   --  Each identifier is given a unique id number. This number is
   --  its location in the table of all the identifiers definitions :
   --  the id_table.
   --  In order to find easily a given identifier in this id_table,
   --  an hashtable of the position of the identifiers in the
   --  id_table is maintained : the Hash_table. This one keeps the
   --  position in the id_table of the first identifier defined for
   --  each possible hash value. All the identifiers having the same
   --  hash_value are then linked : each one has a pointer on the
   --  next defined.

   --  dimension of the hashtable
   type Hash_Value_Type is mod 2**32;

   --  dimension of the hashtable
   Hash_Mod : constant Hash_Value_Type := 2053;

   --  The hash table of the location of the identifiers in the
   --  id_table
   type Hash_Table_Type is array (0 .. Hash_Mod - 1) of Uniq_Id;
   Hash_Table : Hash_Table_Type := (others => Nil_Uniq_Id);

   --  Type of an entry in the id_table.
   --  it contains the following :
   --    - the identifier_definition,
   --    - a pointer on the entry correponding to the definition
   --  of an identifier with the same hash value.
   type Hash_Entry is record
      Definition : Identifier_Definition_Acc := null;
      Next : Uniq_Id;
   end record;

   ----------------------------------
   --  The Gnat_Table adapted type --
   ----------------------------------
   --  This section provides an implementation of dynamically resizable one
   --  dimensional array type.The idea is to mimic the normal Ada semantics for
   --  arrays as closely as possible with the one additional capability of
   --  dynamically modifying the value of the Last attribute.


   --  we are defining the type of the table
   type Table_Type is
      array (Uniq_Id range <>) of Hash_Entry;

   subtype Big_Table_Type is
     Table_Type (Nil_Uniq_Id + 1 .. Uniq_Id'Last);

   --  The table is actually represented as a pointer to allow reallocation
   type Table_Ptr is access all Big_Table_Type;

   --  the table type that will be instanciated
   type Table is record
      --  the table
      Table : Table_Ptr := null;
      --  Subscript of the maximum entry in the currently allocated table
      Max : Integer := Integer (Nil_Uniq_Id);
      --  Number of entries in currently allocated table. The value of zero
      --  ensures that we initially allocate the table.
      Length : Integer := 0;
      --  Current value of Last.
      Last_Val : Integer := Integer (Nil_Uniq_Id);
   end record;

   --  the location of the first element of the table (it is constant)
   First : constant Uniq_Id := Nil_Uniq_Id + 1;

   --  Table expansion is permitted only if this switch is set to False. A
   --  client may set Locked to True, in which case any attempt to expand
   --  the table will cause an assertion failure. Note that while a table
   --  is locked, its address in memory remains fixed and unchanging.
   Locked : Boolean := False;

   --  This procedure allocates a new table of size Initial (freeing any
   --  previously allocated larger table). It is not necessary to call
   --  Init when a table is first instantiated (since reallocate works
   --  with a null table). However, it is harmless to do so, and
   --  Init is convenient in reestablishing a table for new use.
   procedure Init (T : in out Table);

   --  Returns the current value of the last used entry in the table, which
   --  can then be used as a subscript for Table. Note that the only way to
   --  modify Last is to call the Set_Last procedure. Last must always be
   --  used to determine the logically last entry.
   function Last (T : Table) return Uniq_Id;

   --  Storage is allocated in chunks according to the values given in the
   --  Initial and Increment parameters. A call to Release releases all
   --  storage that is allocated, but is not logically part of the current
   --  array value. Current array values are not affected by this call.
   procedure Release (T : in out Table);

   --  This procedure sets Last to the indicated value. If necessary the
   --  table is reallocated to accomodate the new value (i.e. on return
   --  the allocated table has an upper bound of at least Last). If Set_Last
   --  reduces the size of the table, then logically entries are removed
   --  from the table. If Set_Last increases the size of the table, then
   --  new entries are logically added to the table.
   procedure Set_Last (T : in out Table; New_Val : in Uniq_Id);

   --  Adds 1 to Last (same as Set_Last (Last + 1).
   procedure Increment_Last (T : in out Table);

   --  Subtracts 1 from Last (same as Set_Last (Last - 1).
   procedure Decrement_Last (T : in out Table);

   --  Adds Num to T.Last_val, and returns the old value of T.Last_Val + 1.
   procedure Allocate (T : in out Table;
                       Num : in Integer := 1;
                       Result : out Uniq_Id);

   -------------------------------------------------
   --  the structure used for storing identifiers --
   -------------------------------------------------
   type Storage is record
      Hash_Table : Hash_Table_Type := (others => Nil_Uniq_Id);
      Content_Table : Table;
   end record;


private

   ----------------------------------------
   --  Type of an identifier definition  --
   ----------------------------------------

   --  classical definition of a list for the identifier_definition_list
   type Identifier_Definition_Cell;
   type Identifier_Definition_List is access Identifier_Definition_Cell;
   type Identifier_Definition_Cell is record
      Definition : Identifier_Definition;
      Next : Identifier_Definition_List;
   end record;

   --  Adds an identifier definition to a scope
   procedure Add_Identifier_Definition
     (Scope : Node_Id;
      Identifier : in Identifier_Definition_Acc);

   --  The hashing function. Takes an identifier and return its hash
   --  value
   function Hash (Str : in String) return Hash_Value_Type;

end Idl_Fe.Types;
