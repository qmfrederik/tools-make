#
#   application.make
#
#   Makefile rules to build GNUstep-based applications.
#
#   Copyright (C) 1997 Free Software Foundation, Inc.
#
#   Author:  Ovidiu Predescu <ovidiu@net-community.com>
#   Based on the original version by Scott Christley.
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

#
# Include in the common makefile rules
#
include $(GNUSTEP_SYSTEM_ROOT)/Makefiles/rules.make

#
# The name of the application is in the APP_NAME variable.
#

# Determine the application directory extension
ifeq ($(profile), yes)
  APP_EXTENSION = profile
else
  ifeq ($(debug), yes)
    APP_EXTENSION=debug
  else
    APP_EXTENSION=app
  endif
endif

ifneq ($(INTERNAL_APP_NAME),)
# Don't include these definitions the first time make is invoked. This part is
# included when make is invoked the second time from the %.buildapp rule (see
# rules.make).
APP_DIR_NAME = $(INTERNAL_APP_NAME:=.$(APP_EXTENSION))

# Support building NeXT applications
ifneq ($(OBJC_COMPILER), NeXT)
APP_FILE = \
    $(APP_DIR_NAME)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO)/$(INTERNAL_APP_NAME)$(EXEEXT)
else
APP_FILE = $(APP_DIR_NAME)/$(INTERNAL_APP_NAME)$(EXEEXT)
endif

#
# Internal targets
#

$(APP_FILE): $(C_OBJ_FILES) $(OBJC_OBJ_FILES)
	$(LD) $(ALL_LDFLAGS) $(LDOUT)$@ $(C_OBJ_FILES) $(OBJC_OBJ_FILES) \
		$(ALL_LIB_DIRS) $(ALL_GUI_LIBS)
	@$(TRANSFORM_PATHS_SCRIPT) `echo $(ALL_LIB_DIRS) | sed 's/-L//g'` \
		>$(APP_DIR_NAME)/library_paths.openapp
ifeq ($(OBJC_COMPILER), NeXT)
# This is a hack for OPENSTEP systems to remove the iconheader file
# automatically generated by the makefile package.
	rm -f $(INTERNAL_APP_NAME).iconheader
endif

#
# Compilation targets
#
ifeq ($(OBJC_COMPILER), NeXT)
internal-all:: $(INTERNAL_APP_NAME).iconheader $(GNUSTEP_OBJ_DIR) \
	$(APP_DIR_NAME) $(APP_FILE)

$(INTERNAL_APP_NAME).iconheader:
	(echo "F	$(INTERNAL_APP_NAME).$(APP_EXTENSION)	$(INTERNAL_APP_NAME)	$(APP_EXTENSION)"; \
	  echo "F	$(INTERNAL_APP_NAME)	$(INTERNAL_APP_NAME)	app") >$@

$(APP_DIR_NAME):
	mkdir $@
else
internal-all:: $(GNUSTEP_OBJ_DIR) \
	$(APP_DIR_NAME)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO) $(APP_FILE)

$(APP_DIR_NAME)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO):
	@$(GNUSTEP_MAKEFILES)/mkinstalldirs \
		$(APP_DIR_NAME)/$(GNUSTEP_TARGET_DIR)/$(LIBRARY_COMBO)
endif

else
# This part gets included by the first invoked make process.
internal-all:: $(APP_NAME:=.buildapp)

#
# Cleaning targets
#
internal-clean::
	rm -rf $(GNUSTEP_OBJ_PREFIX)/$(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)/$(LIBRARY_COMBO)
ifeq ($(OBJC_COMPILER), NeXT)
	rm -f *.iconheader
	for f in *.$(APP_EXTENSION); do \
	  rm -f $$f/`basename $$f .$(APP_EXTENSION)`; \
	done
else
	rm -rf *.$(APP_EXTENSION)/$(GNUSTEP_TARGET_CPU)/$(GNUSTEP_TARGET_OS)/$(LIBRARY_COMBO)
endif


internal-distclean::
	rm -rf shared_obj static_obj shared_debug_obj shared_profile_obj \
	  static_debug_obj static_profile_obj shared_profile_debug_obj \
	  static_profile_debug_obj *.app *.debug *.profile *.iconheader

$(APP_NAME):
	@$(MAKE) --no-print-directory $@.buildapp
endif
