# WpaSupplicant

[![Build Status](https://travis-ci.org/fhunleth/wpa_supplicant.ex.svg)](https://travis-ci.org/fhunleth/wpa_supplicant.ex)

This package enables Elixir applications to interact with the local WPA
supplicant. The WPA supplicant handles various Wi-Fi operations like scanning
for wireless networks, connecting, authenticating, and collecting wireless
adapter statistics.

## Building

The Makefile currently sets the `wpa_ex` binary to setuid root. This means that
`sudo` is used during the build process. To enter in your password during the
build, do the following:

    $ SUDO_ASKPASS=/usr/bin/ssh-askpass
    $ make

## Permissions

The `wpa_supplicant` process runs as root and requires processes that attach to
its control interface to be root. One way of doing this is to set the `wpa_ex`
binary to be setuid root. E.g.,

    chown root:root priv/wpa_ex
    chmod +s priv/wpa_ex

## Running

    iex(1)> {:ok, pid} = WpaSupplicant.start_link("/var/run/wpa_supplicant/wlan0")
    {:ok, #PID<0.82.0}

    iex(2)> WpaSupplicant.request "PING"
    "PONG\n"

## Useful links

  1. [wpa_supplicant homepage](http://w1.fi/wpa_supplicant/)
  2. [wpa_supplicant control
     interface](http://w1.fi/wpa_supplicant/devel/ctrl_iface_page.html)
  3. [wpa_supplicant information on the archlinux
     wiki](https://wiki.archlinux.org/index.php/Wpa_supplicant)

## Licensing

The majority of this package is licensed under the Apache 2.0 license. The code
that directly interfaces with the `wpa_supplicant` is taken from the
`wpa_supplicant` package and has the following copyright and license:

```
/*
 * wpa_supplicant/hostapd control interface library
 * Copyright (c) 2004-2007, Jouni Malinen <j@w1.fi>
 *
 * This software may be distributed under the terms of the BSD license.
 * See README for more details.
 */
```
