# Variables to override
#
# CC            C compiler
# CROSSCOMPILE	crosscompiler prefix, if any
# CFLAGS	compiler flags for compiling all C files
# LDFLAGS	linker flags for linking all binaries
# MIX		path to mix
# SUDO_ASKPASS  path to ssh-askpass when modifying ownership of net_basic
# SUDO          path to SUDO. If you don't want the privileged parts to run, set to "true"

WPA_DEFINES = -DCONFIG_CTRL_IFACE -DCONFIG_CTRL_IFACE_UNIX

LDFLAGS += -lrt
CFLAGS ?= -O2 -Wall -Wextra -Wno-unused-parameter
CC ?= $(CROSSCOMPILE)gcc
MIX ?= mix

# If not cross-compiling, then run sudo by default
ifeq ($(origin CROSSCOMPILE), undefined)
SUDO_ASKPASS ?= /usr/bin/ssh-askpass
SUDO ?= sudo
else
# If cross-compiling, then permissions need to be set some build system-dependent way
SUDO ?= true
endif

all: compile

compile:
	$(MIX) compile

test:
	$(MIX) test

%.o: %.c
	$(CC) -c $(WPA_DEFINES) $(CFLAGS) -o $@ $<

priv/wpa_ex: src/wpa_ex.o src/wpa_ctrl/os_unix.o src/wpa_ctrl/wpa_ctrl.o
	@mkdir -p priv
	$(CC) $^ $(LDFLAGS) -o $@
	# setuid root wpa_ex so that it can interact with the wpa_supplicant
	SUDO_ASKPASS=$(SUDO_ASKPASS) $(SUDO) -- sh -c 'chown root:root $@; chmod +s $@'

clean:
	$(MIX) clean
	rm -f priv/wpa_ex src/*.o src/wpa_ctrl/*.o

.PHONY: all compile test clean
