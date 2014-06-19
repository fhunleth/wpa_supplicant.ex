# Variables to override
#
# CC            C compiler
# CROSSCOMPILE	crosscompiler prefix, if any
# CFLAGS	compiler flags for compiling all C files
# LDFLAGS	linker flags for linking all binaries
# MIX		path to mix

WPA_DEFINES = -DCONFIG_CTRL_IFACE -DCONFIG_CTRL_IFACE_UNIX

LDFLAGS += -lrt
CFLAGS ?= -O2 -Wall -Wextra -Wno-unused-parameter
CC ?= $(CROSSCOMPILER)gcc
MIX ?= mix

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
setuid: priv/wpa_ex
	sudo chown root:root $^
	sudo chmod +s $^

clean:
	$(MIX) clean
	rm -f priv/wpa_ex src/*.o src/wpa_ctrl/*.o

.PHONY: all compile test clean setuid
