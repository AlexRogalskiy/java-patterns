ifndef __CHECKS_MAKEFILE__

__CHECKS_MAKEFILE__ := included

################################################################################
# Default checks                                                            #
################################################################################
# The .FEATURES variable is likely to be unique for GNU Make.
ifeq ($(.FEATURES), )
  $(info Error: '$(MAKE)' does not seem to be GNU Make, which is a requirement.)
  $(info Check your path, or upgrade to GNU Make 3.81 or newer.)
  $(error Cannot continue)
endif

# Assume we have GNU Make, but check version.
ifeq ($(strip $(foreach v, 3.81% 3.82% 4.%, $(filter $v, $(MAKE_VERSION)))), )
  $(info Error: This version of GNU Make is too low ($(MAKE_VERSION)).)
  $(info Check your path, or upgrade to GNU Make 3.81 or newer.)
  $(error Cannot continue)
endif

# In Cygwin, the MAKE variable gets prepended with the current directory if the
# make executable is called using a Windows mixed path (c:/cygwin/bin/make.exe).
ifneq ($(findstring :, $(MAKE)), )
  MAKE := $(patsubst $(CURDIR)%, %, $(patsubst $(CURDIR)/%, %, $(MAKE)))
endif

# Locate this Makefile
ifeq ($(filter /%, $(lastword $(MAKEFILE_LIST))),)
  makefile_path := $(CURDIR)/$(strip $(lastword $(MAKEFILE_LIST)))
else
  makefile_path := $(lastword $(MAKEFILE_LIST))
endif
topdir := $(strip $(patsubst %/, %, $(dir $(makefile_path))))

endif
