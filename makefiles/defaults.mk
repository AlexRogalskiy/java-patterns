ifndef __DEFAULTS_MAKEFILE__

__DEFAULTS_MAKEFILE__ := included

################################################################################
# Default variables                                                            #
################################################################################

# SHELLFLAGS stores the shell flags.
.SHELLFLAGS 	+= -o errexit
.SHELLFLAGS 	+= -o nounset
.SHELLFLAGS 	+= -o pipefail

# Somehow, the new auto-completion for make in the recent distributions
# trigger a behavior where our Makefile calls itself recursively, in a
# never-ending loop (except on lack of ressources, swap, PIDs...)
# Avoid this situation by cutting the recursion short at the first
# level.
# This has the side effect of only showing the real targets, and hiding our
# internal ones. :-)
ifneq ($(MAKELEVEL),0)
  $(error Recursion detected, bailing out...)
endif

# Do not print directories as we descend into them
ifeq ($(filter --no-builtin-rules,$(MAKEFLAGS)),)
  CT_MAKEFLAGS += --no-builtin-rules
endif

# Do not print directories as we descend into them
ifeq ($(filter --no-print-directory,$(MAKEFLAGS)),)
  CT_MAKEFLAGS += --no-print-directory
endif

# Do not print verbose output
ifeq ($(filter --silent,$(MAKEFLAGS)),)
  CT_MAKEFLAGS += --silent
endif

# Use neither builtin rules, nor builtin variables
# Note: dual test, because if -R and -r are given on the command line
# (who knows?), MAKEFLAGS contains 'Rr' instead of '-Rr', while adding
# '-Rr' to MAKEFLAGS adds it literaly ( and does not add 'Rr' )
# Further: quad test because the flags 'rR' and '-rR' can be reordered.
ifeq ($(filter Rr,$(MAKEFLAGS)),)
  ifeq ($(filter -Rr,$(MAKEFLAGS)),)
    ifeq ($(filter rR,$(MAKEFLAGS)),)
      ifeq ($(filter -rR,$(MAKEFLAGS)),)
        CT_MAKEFLAGS += -Rr
      endif # No -rR
    endif # No rR
  endif # No -Rr
endif # No Rr

# MAKEFLAGS stores the make flags.
# MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += $(CT_MAKEFLAGS)

endif
