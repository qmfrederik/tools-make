#
#   Instance/clibrary.make
#
#   Instance Makefile rules to build C libraries.
#   Warning/TODO - this makefile is not really finished, because it 
#   still uses the LIB_LINK_CMD used for normal ObjC libraries.
#   The main difference from library.make, currently, is that it 
#   installs outside the library_combo dir.
#
#   Copyright (C) 1997, 2001 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#	     Ovidiu Predescu <ovidiu@net-community.com>
#            Nicola Pero     <nicola@brainstorm.co.uk>
#
#   This file is part of the GNUstep Makefile Package.
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your option) any later version.
#   
#   You should have received a copy of the GNU General Public
#   License along with this library; see the file COPYING.LIB.
#   If not, write to the Free Software Foundation,
#   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

#
# The name of the library is in the CLIBRARY_NAME variable.
# The Objective-C files that gets included in the library are in
# xxx_OBJC_FILES (you normally don't have these - they are used - it's
# sort of a hack - by gnustep-objc though)
# The C files are in xxx_C_FILES
# The pswrap files are in xxx_PSWRAP_FILES
# The header files are in xxx_HEADER_FILES
# The directory where the header files are located is xxx_HEADER_FILES_DIR
# The directory where to install the header files inside the library
# installation directory is xxx_HEADER_FILES_INSTALL_DIR
# The DLL export file is in xxx_DLL_DEF
#
#	Where xxx is the name of the library
#

.PHONY: internal-clibrary-all \
        internal-clibrary-install \
        internal-clibrary-uninstall \
        before-$(GNUSTEP_INSTANCE)-all \
        after-$(GNUSTEP_INSTANCE)-all \
        internal-install-lib \
        internal-install-dirs \
        internal-install-headers \
        internal-uninstall-lib \
        internal-uninstall-headers 

# This is the directory where the lib get installed. 
ifeq ($(CLIBRARY_INSTALL_DIR),)
  CLIBRARY_INSTALL_DIR = $(GNUSTEP_LIBRARIES)
endif

# And this is used internally - it is the final directory where we put
# the library - it includes target arch, os dir but not the
# library_combo - this variable is PRIVATE to gnustep-make
FINAL_LIBRARY_INSTALL_DIR = $(CLIBRARY_INSTALL_DIR)/$(GNUSTEP_TARGET_DIR)

INTERNAL_LIBRARIES_DEPEND_UPON =				\
  $(shell $(WHICH_LIB_SCRIPT)					\
   $(ALL_LIB_DIRS)						\
   $(LIBRARIES_DEPEND_UPON)					\
   debug=$(debug) profile=$(profile) shared=$(shared)		\
   libext=$(LIBEXT) shared_libext=$(SHARED_LIBEXT))

ifeq ($(shared), yes)

ifneq ($(BUILD_DLL),yes)

LIBRARY_FILE = $(GNUSTEP_INSTANCE)$(LIBRARY_NAME_SUFFIX)$(SHARED_LIBEXT)
LIBRARY_FILE_EXT     = $(SHARED_LIBEXT)
VERSION_LIBRARY_FILE = $(LIBRARY_FILE).$(VERSION)
SOVERSION            = $(word 1,$(subst ., ,$(VERSION)))
SONAME_LIBRARY_FILE  = $(LIBRARY_FILE).$(SOVERSION)

else # BUILD_DLL

LIBRARY_FILE     = $(GNUSTEP_INSTANCE)$(LIBRARY_NAME_SUFFIX)$(DLL_LIBEXT)
LIBRARY_FILE_EXT = $(DLL_LIBEXT)
DLL_NAME         = $(shell echo $(LIBRARY_FILE)|cut -b 4-)
DLL_EXP_LIB      = $(GNUSTEP_INSTANCE)$(LIBRARY_NAME_SUFFIX)$(SHARED_LIBEXT)
DLL_EXP_DEF      = $(GNUSTEP_INSTANCE)$(LIBRARY_NAME_SUFFIX).def

ifeq ($(DLL_INSTALLATION_DIR),)
  DLL_INSTALLATION_DIR = $(GNUSTEP_TOOLS)/$(GNUSTEP_TARGET_LDIR)
endif

endif # BUILD_DLL

else # shared

LIBRARY_FILE         = $(GNUSTEP_INSTANCE)$(LIBRARY_NAME_SUFFIX)$(LIBEXT)
LIBRARY_FILE_EXT     = $(LIBEXT)
VERSION_LIBRARY_FILE = $(LIBRARY_FILE)
SONAME_LIBRARY_FILE  = $(LIBRARY_FILE)

endif # shared

ifeq ($(strip $(HEADER_FILES_DIR)),)
override HEADER_FILES_DIR = .
endif

#
# Internal targets
#

#
# Compilation targets
#

ifeq ($(BUILD_DLL),yes)

DERIVED_SOURCES = derived_src

ifneq ($(strip $(DLL_DEF)),)
DLL_DEF_FLAG = --input-def $(DLL_DEF)
endif

# Pass -DBUILD_lib{library_name}_DLL=1 to the preprocessor.  The
# library header files can use this preprocessor define to know that
# they are included during compilation of the library itself, and can
# then use __declspec(dllexport) to export symbols
CLEAN_library_NAME = $(shell echo $(GNUSTEP_INSTANCE)|tr '-' '_')
SHARED_CFLAGS += -DBUILD_$(CLEAN_library_NAME)_DLL=1

internal-clibrary-all:: \
	before-$(GNUSTEP_INSTANCE)-all			\
	$(GNUSTEP_OBJ_DIR)			\
	$(DERIVED_SOURCES)			\
	$(DERIVED_SOURCES)/$(GNUSTEP_INSTANCE).def	\
	$(GNUSTEP_OBJ_DIR)/$(DLL_NAME)		\
	$(GNUSTEP_OBJ_DIR)/$(DLL_EXP_LIB)	\
	after-$(GNUSTEP_INSTANCE)-all

internal-clibrary-clean::
	rm -rf $(DERIVED_SOURCES)

$(DERIVED_SOURCES):
	$(MKDIRS) $@

$(DERIVED_SOURCES)/$(GNUSTEP_INSTANCE).def: $(OBJ_FILES_TO_LINK) $(DLL_DEF)
	$(DLLTOOL) $(DLL_DEF_FLAG) --output-def $@ $(OBJ_FILES_TO_LINK)

$(GNUSTEP_OBJ_DIR)/$(DLL_EXP_LIB): $(DERIVED_SOURCES)/$(GNUSTEP_INSTANCE).def
	$(DLLTOOL) --dllname $(DLL_NAME) --def $< --output-lib $@

$(GNUSTEP_OBJ_DIR)/$(DLL_NAME): $(OBJ_FILES_TO_LINK) \
                               $(DERIVED_SOURCES)/$(GNUSTEP_INSTANCE).def
	$(DLLWRAP) --driver-name $(CC) \
	  $(SHARED_LD_PREFLAGS) \
	  --def $(DERIVED_SOURCES)/$(GNUSTEP_INSTANCE).def \
	  -o $@ $(OBJ_FILES_TO_LINK) \
	  $(INTERNAL_LIBRARIES_DEPEND_UPON) $(TARGET_SYSTEM_LIBS) \
	  $(SHARED_LD_POSTFLAGS) 

else # BUILD_DLL

internal-clibrary-all:: before-$(GNUSTEP_INSTANCE)-all \
                        $(GNUSTEP_OBJ_DIR) \
                        $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE) \
                        after-$(GNUSTEP_INSTANCE)-all

$(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE): $(OBJ_FILES_TO_LINK)
	$(LIB_LINK_CMD)

endif # BUILD_DLL

before-$(GNUSTEP_INSTANCE)-all::

after-$(GNUSTEP_INSTANCE)-all::

#
# Install and uninstall targets
#
internal-clibrary-install:: internal-install-dirs \
                            internal-install-lib \
                            internal-install-headers

# Depend on creating all the dirs
internal-install-dirs:: $(FINAL_LIBRARY_INSTALL_DIR) \
                          $(GNUSTEP_HEADERS)/$(HEADER_FILES_INSTALL_DIR) \
                          $(DLL_INSTALLATION_DIR) \
                          $(ADDITIONAL_INSTALL_DIRS)

# Now the rule to create each dir.  NB: Nothing gets executed if the dir 
# already exists
$(FINAL_LIBRARY_INSTALL_DIR):
	$(MKINSTALLDIRS) $@

$(GNUSTEP_HEADERS)/$(HEADER_FILES_INSTALL_DIR):
	$(MKINSTALLDIRS) $@

$(DLL_INSTALLATION_DIR):
	$(MKINSTALLDIRS) $@

$(ADDITIONAL_INSTALL_DIRS):
	$(MKINSTALLDIRS) $@


internal-install-headers::
ifneq ($(HEADER_FILES),)
	for file in $(HEADER_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    $(INSTALL_DATA) $(HEADER_FILES_DIR)/$$file \
	         $(GNUSTEP_HEADERS)/$(HEADER_FILES_INSTALL_DIR)/$$file ; \
	  fi; \
	done;
endif

ifeq ($(BUILD_DLL),yes)

internal-install-lib::
	if [ -f $(GNUSTEP_OBJ_DIR)/$(DLL_NAME) ]; then \
	  $(INSTALL_PROGRAM) $(GNUSTEP_OBJ_DIR)/$(DLL_NAME) \
	                     $(DLL_INSTALLATION_DIR) ; \
	fi
	if [ -f $(GNUSTEP_OBJ_DIR)/$(DLL_EXP_LIB) ]; then \
	  $(INSTALL_PROGRAM) $(GNUSTEP_OBJ_DIR)/$(DLL_EXP_LIB) \
	                     $(FINAL_LIBRARY_INSTALL_DIR) ; \
	fi

else

internal-install-lib::
	if [ -f $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE) ]; then \
	  $(INSTALL_PROGRAM) $(GNUSTEP_OBJ_DIR)/$(VERSION_LIBRARY_FILE) \
	                     $(FINAL_LIBRARY_INSTALL_DIR) ; \
	  $(AFTER_INSTALL_LIBRARY_CMD) \
	fi

endif

internal-library-uninstall:: internal-uninstall-headers \
                             internal-uninstall-lib

internal-uninstall-headers::
	for file in $(HEADER_FILES) __done; do \
	  if [ $$file != __done ]; then \
	    rm -f $(GNUSTEP_HEADERS)/$(HEADER_FILES_INSTALL_DIR)/$$file ; \
	  fi; \
	done

ifeq ($(BUILD_DLL),yes)

internal-uninstall-lib::
	rm -f $(DLL_INSTALLATION_DIR)/$(DLL_NAME) \
	      $(FINAL_LIBRARY_INSTALL_DIR)/$(DLL_EXP_LIB)

else

internal-uninstall-lib::
	rm -f $(FINAL_LIBRARY_INSTALL_DIR)/$(VERSION_LIBRARY_FILE) \
	      $(FINAL_LIBRARY_INSTALL_DIR)/$(LIBRARY_FILE)\
	      $(FINAL_LIBRARY_INSTALL_DIR)/$(SONAME_LIBRARY_FILE)
endif

#
# Testing targets
#
internal-clibrary-check::

## Local variables:
## mode: makefile
## End:
