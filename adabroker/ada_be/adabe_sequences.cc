// File adabe_sequence.cc
#include <adabe.h>

void
adabe_sequence::produce_ads(dep_list with, string &body,
			    string &previous){
  string is_bounded;
  adabe_name *adabe_base_type;
  string type_name;
  // Adding the corba file for sequences
  
  if (max_size() == 0)
    is_bounded = "CORBA.Object.Sequences.Unbounded";
  else
    is_bounded = "CORBA.Object.Sequences.Bounded";
  with.add("CORBA.Object.Sequences." + is_bounded);

  if (max_size() == 0)
    is_bounded = "bounded";
  else
    is_bounded = "unbounded";

  // Writing the header :

  adabe_base_type =  adabe_name::narrow_from_decl (base_type());
  type_name =  adabe_base_type->dump_name(with, body, previous);
    
  body += "type IDL_SEQUENCE_" + type_name +"_Array is\n";
  body += "      array (Integer range <>) of CORBA." + type_name +";\n";
  body += "\n";
  body += "package  IDL_SEQUENCE_" + type_name +" is\n";
  body += "     CORBA.Sequences." + is_bounded + "\n";
  body += "       (CORBA." + type_name + ", IDL_SEQUENCE_" + type_name +"_Array);\n";
  body += "\n";
  body += "type " + get_ada_local_name() + " is new IDL_SEQUENCE_" + type_name + ".Sequence;";

}
void
adabe_sequence::produce_marshal_ads(dep_list with, string &body,string &previous)
{
}

void
adabe_sequence::produce_marshal_adb(dep_list with, string &body, string &previous)
{
}
string
adabe_sequence::dump_name(dep_list with,string &body, string &previous) 
{
  if (!is_imported(with))
    {
      if (!is_already_defined())
	{
	  string tmp = "";
	  produce_ads(with, tmp, previous);
	  previous += tmp;
	}
      return get_ada_local_name();
    }
  return get_ada_full_name();	   
}

IMPL_NARROW_METHODS1(adabe_sequence, AST_Sequence)
IMPL_NARROW_FROM_DECL(adabe_sequence)
IMPL_NARROW_FROM_SCOPE(adabe_sequence)

adabe_sequence::adabe_sequence(AST_Expression *v, AST_Type *t)
  : AST_Sequence(v, t),
    AST_Decl(AST_Decl::NT_sequence,NULL,NULL), //...
    adabe_name()
{
}
