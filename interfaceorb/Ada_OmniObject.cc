////////////////////////////////////////////////////////////////////////////
////                                                                    ////
////     This class is both a C class and an Ada Class (see             ////
////     omniObject.ads). It is wrapped around omniObject_C2Ada         ////
////     in order to avoid the presence of non default construc-        ////
////     tors.                                                          ////
////     So, it provides the same functions as omniObject_C2Ada         ////
////     except that constructors are replaced by Init functions.       ////
////     It has also a pointer on the underlining omniObject_C2Ada      ////
////     object                                                         ////
////                                                                    ////
////                                                                    ////
////                Date : 02/16/99                                     ////
////                                                                    ////
////                authors : Sebastien Ponce                           ////
////                                                                    ////
////////////////////////////////////////////////////////////////////////////


#include "Ada_OmniObject.hh"

Ada_OmniObject::Ada_OmniObject()
{
  Init_Ok = false;
};

Ada_OmniObject::~Ada_OmniObject()
{
  delete C_OmniObject ;
} ;

void
Ada_OmniObject::Init ()
{
  // Creation of the underlining omniobject_C2Ada object
  C_OmniObject = new omniObject_C2Ada (this);
  // updating of Init_OK flag
  Init_Ok = true;
  return;
}

void
Ada_OmniObject::Init (const char *repoId,
		      Rope *r,
		      _CORBA_Octet *key,
		      size_t keysize,
		      IOP::TaggedProfileList *profiles,
		      _CORBA_Boolean release)
{
  // Creation of the underlining omniobject_C2Ada object
  C_OmniObject = new omniObject_C2Ada (repoId,
				       r,
				       key,
				       keysize,
				       profiles,
				       release,
				       this);
  // updating of Init_OK flag
  Init_Ok = true;
  return;
};

void
Ada_OmniObject::Init (omniObject_C2Ada *omniobj)
{
  C_OmniObject = omniobj;
  Init_Ok = true;
  return;
}

 
void
Ada_OmniObject::setRopeAndKey(const omniRopeAndKey& l,_CORBA_Boolean keepIOP=1)
{
  if (Init_Ok) {
    // if Initialisation was made then call the corresponding
    // function on C_OmniObject
    C_OmniObject->setRopeAndKey(l,keepIOP);
    return;
  } else {
    // else raise an Ada Exception
    raise_ada_exception ("Call of Ada_OmniObject::setRopeAndKey without initialising object.");
  }
};

_CORBA_Boolean
Ada_OmniObject::getRopeAndKey(omniRopeAndKey& l) {
  if (Init_Ok) {
    // if Initialisation was made then call the corresponding
    // function on C_OmniObject
    return C_OmniObject->getRopeAndKey(l);
  } else {
    // else raise an Ada Exception
    raise_ada_exception ("Call of Ada_OmniObject::getRopeAndKey without initialising object.");
  }
}
      
  
void
Ada_OmniObject::assertObjectExistent() {
  if (Init_Ok) {
    // if Initialisation was made then call the corresponding
    // function on C_OmniObject
    C_OmniObject->assertObjectExistent();
    return;
  } else {
    // else raise an Ada Exception
    raise_ada_exception ("Call of Ada_OmniObject::assertObjectExistent without initialising object.");    
  }
}


_CORBA_Boolean
Ada_OmniObject::is_proxy() {
  if (Init_Ok) {
    // if Initialisation was made then call the corresponding
    // function on C_OmniObject
    return C_OmniObject->is_proxy();
  } else {
    // else raise an Ada Exception
   raise_ada_exception ("Call of Ada_OmniObject::is_proxy without initialising object.");    
  }
}

extern _CORBA_Boolean dispatch(GIOP_S &,
			       const char *operation,
			       _CORBA_Boolean response_expected);
// See implementation in omniobject.adb
  
omniObject_C2Ada *
Ada_OmniObject::getOmniObject() {
  return C_OmniObject ;
}



void
Ada_OmniObject::setRepositoryID(const char* repoId) {
  if (Init_Ok) {
    // if Initialisation was made then call the corresponding
    // function on C_OmniObject
    C_OmniObject->PR_IRRepositoryId(repoId);
    return;
  } else {
    // else raise an Ada Exception
    raise_ada_exception ("Call of Ada_OmniObject::setRepositoryId without initialising object.");
  }
}



const char*
Ada_OmniObject::getRepositoryID() {
  if (Init_Ok) {
    // if Initialisation was made then call the corresponding
    // function on C_OmniObject
    return C_OmniObject->NP_IRRepositoryId();
  } else {
    // else raise an Ada Exception
    raise_ada_exception ("Call of Ada_OmniObject::getRepositoryId without initialising object.");
  }
}
 

