#
#   test-application.make
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
ifeq ($(TEST_APPLICATION_MAKE_LOADED),)
TEST_APPLICATION_MAKE_LOADED=yes

TEST_APP_NAME:=$(strip $(TEST_APP_NAME))

#
# Include in the common makefile rules
#
ifeq ($(RULES_MAKE_LOADED),)
include $(GNUSTEP_MAKEFILES)/rules.make
endif

# building of test applications works as in application.make
ifeq ($(INTERNAL_app_NAME),)

internal-all:: $(TEST_APP_NAME:=.all.app.variables)

internal-clean:: $(TEST_APP_NAME:=.clean.app.variables)

internal-distclean:: $(TEST_APP_NAME:=.distclean.app.variables)

internal-check:: $(TEST_APP_NAME:=.check.testapp.variables)

$(TEST_APP_NAME)::
	@$(MAKE) -f $(MAKEFILE_NAME) --no-print-directory $@.all.app.variables

# However, we don't install/uninstall test apps
internal-install::
	@ echo Skipping installation of test apps...

internal-uninstall::
	@ echo Skipping uninstallation of test apps...

else

# We use the application.make rules for building
include $(GNUSTEP_MAKEFILES)/application.make

endif

endif # test-application.make loaded

## Local variables:
## mode: makefile
## End:
