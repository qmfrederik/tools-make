#
#   test-tool.make
#
#   Copyright (C) 1997, 2001 Free Software Foundation, Inc.
#
#   Author:  Scott Christley <scottc@net-community.com>
#   Author:  Nicola Pero <nicola@brainstorm.co.uk>
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

# prevent multiple inclusions
ifeq ($(TEST_TOOL_MAKE_LOADED),)
TEST_TOOL_MAKE_LOADED=yes

TEST_TOOL_NAME:=$(strip $(TEST_TOOL_NAME))

#
# Include in the common makefile rules
#
ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

# building of test tools works as in tool.make
ifeq ($(INTERNAL_tool_NAME),)

internal-all:: $(TEST_TOOL_NAME:=.all.tool.variables)

internal-clean:: $(TEST_TOOL_NAME:=.clean.tool.variables)

internal-distclean:: $(TEST_TOOL_NAME:=.distclean.tool.variables)

internal-check:: $(TEST_TOOL_NAME:=.check.tool.variables)

$(TEST_TOOL_NAME)::
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory $@.all.tool.variables

# However, we don't install/uninstall test-tools
internal-install::
	@ echo Skipping installation of test tools...

internal-uninstall::
	@ echo Skipping uninstallation of test tools...

else

# We use the tool.make rules for building
include $(GNUSTEP_MAKEFILES)/tool.make

endif

endif # test-tool.make loaded

## Local variables:
## mode: makefile
## End:
