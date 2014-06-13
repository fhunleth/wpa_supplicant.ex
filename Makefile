# Variables to override
#
# CC            C compiler
# CROSSCOMPILE	crosscompiler prefix, if any
# CFLAGS	compiler flags for compiling all C files
# LDFLAGS	linker flags for linking all binaries
# MIX		path to mix

WPA_DEFINES = -DCONFIG_CTRL_IFACE -DCONFIG_CTRL_IFACE_UNIX

LDFLAGS +=
CFLAGS ?= -O2 -Wall -Wextra -Wno-unused-parameter
CC ?= $(CROSSCOMPILER)gcc
MIX ?= mix

.PHONY: all elixir-code clean

all: elixir-code

elixir-code:
	$(MIX) compile

%.o: %.c
	$(CC) -c $(WPA_DEFINES) $(CFLAGS) -o $@ $<

priv/wpa_ex: src/wpa_ex.o src/wpa_ctrl/os_unix.o src/wpa_ctrl/wpa_ctrl.o
	@mkdir -p priv
	$(CC) $^ $(LDFLAGS) -o $@

	# setuid root wpa_ex so that it can interact with wpa_supplicant
	sudo chown root:root $@
	sudo chmod +s $@

clean:
	$(MIX) clean
	rm -f priv/wpa_ex src/*.o src/wpa_ctrl/*.o
