
FLAGS = $(ADABROKER_FLAGS) $(CORBA_LIB) $(IMPORT_LIBRARY_FLAGS)

all:: $(CORBA_LIB_DEPEND) $(ADABROKER_LIB_DEPEND) all_functions.ads
	gnatmake -gnatf -gnata -m -i client $(FLAGS)
	gnatmake -gnatf -gnata -m -i server $(FLAGS)

IDL_INTERFACE = all_functions

GENERATED_FILES = $(IDL_INTERFACE).ad*
GENERATED_FILES += $(IDL_INTERFACE)-proxies.ad*
GENERATED_FILES += $(IDL_INTERFACE)-marshal.ad*
GENERATED_FILES += $(IDL_INTERFACE)-skeleton.ad*
GENERATED_FILES += $(IDL_INTERFACE)_idl_file.ad*
GENERATED_FILES += $(IDL_INTERFACE)_idl_file-marshal.ad*

clean::
	rm *.o *.ali *~ server client $(GENERATED_FILES)

all_functions.ads: all_functions.idl
	omniidl2 -b ada all_functions.idl
