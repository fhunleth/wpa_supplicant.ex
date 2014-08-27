# WpaSupplicant [![Build Status](https://travis-ci.org/fhunleth/wpa_supplicant.ex.svg)](https://travis-ci.org/fhunleth/wpa_supplicant.ex)

This package enables Elixir applications to interact with the local WPA
supplicant. The WPA supplicant handles various Wi-Fi operations like scanning
for wireless networks, connecting, authenticating, and collecting wireless
adapter statistics.

## Note on permissions

The `wpa_supplicant` daemon runs as root and requires processes that attach to
its control interface to be root. This project contains a C port process whose
sole purpose is to interact with the `wpa_supplicant` daemon, but it needs
sufficient permission to do so. The `Makefile` contains logic to mark the port
process setuid root so that this works, but you may want to change this
depending on your setup.

## Building

Building `wpa_supplicant.ex` is similar to other Elixir projects. The Makefile
will invoke `mix` to compile both the Elixir and C source code. The only extra
step is to ensure that the permissions are right on the `wpa_ex` binary. The
way this is accomplished is by setting `wpa_ex` setuid root. By default, when
you run `make`, you'll be asked your password to change permissions.

    $ make

If you want to disable the setuid root step in the Makefile, just set the `SUDO`
environment variable to `true` to make it a nop:

    $ SUDO=true make

If you need to use a different askpass program, you can set that as well:

    $ SUDO_ASKPASS=/usr/bin/ssh-askpass make

## Running

The `wpa_supplicant` daemon must be running already on your system and the control
interface must be exposed. If you have any doubt, try running `wpa_cli`. If that
doesn't work, the Elixir `WpaSupplicant` won't work.

If you're on a system where you can start the `wpa_supplicant` manually, here's
an example command line:

    $ /sbin/wpa_supplicant -iwlan0 -C/var/run/wpa_supplicant -B

Once you're happy that the `wpa_supplicant` is running, start `iex` by running:

    $ iex -S mix

Start a `WpaSupplicant` process:

    iex> {:ok, pid} = WpaSupplicant.start_link("/var/run/wpa_supplicant/wlan0")
    {:ok, #PID<0.82.0>}

You can sanity check that Elixir has properly attached to the `wpa_supplicant`
daemon by pinging the daemon:

    iex> WpaSupplicant.request(pid, :PING)
    :PONG

To scan for access points, call `WpaSupplicant.scan/1`. This can take a few
seconds:

    iex> WpaSupplicant.scan(pid)
    [%{age: 42, beacon_int: 100, bssid: "00:1f:90:db:45:54", capabilities: 1073,
       flags: "[WEP][ESS]", freq: 2462, id: 8,
       ie: "00053153555434010882848b0c1296182403010b07",
       level: -83, noise: 0, qual: 0, ssid: "1SUT4", tsf: 580579066269},
     %{age: 109, beacon_int: 100, bssid: "00:18:39:7a:23:e8", capabilities: 1041,
       flags: "[WEP][ESS]", freq: 2412, id: 5,
       ie: "00076c696e6b737973010882848b962430486c0301",
       level: -86, noise: 0, qual: 0, ssid: "linksys", tsf: 464957892243},
     %{age: 42, beacon_int: 100, bssid: "1c:7e:e5:32:d1:f8", capabilities: 1041,
       flags: "[WPA2-PSK-CCMP][ESS]", freq: 2412, id: 0,
       ie: "000768756e6c657468010882848b960c1218240301",
       level: -43, noise: 0, qual: 0, ssid: "dlink", tsf: 580587711245}]

To attach to an access point, you need to configure a network entry in the
`wpa_supplicant`. The `wpa_supplicant` can have multiple network entries
configured. The following removes all network entries so that only one is
configured.

    iex> WpaSupplicant.set_network(pid, ssid: "MyNetworkSsid", psk: "secret")
    :ok


If the access point is around, the `wpa_supplicant` will eventually connect to
the network.

    iex> WpaSupplicant.status(pid)
    %{address: "84:3a:4b:11:95:23", bssid: "1c:7e:e5:32:de:32",
      group_cipher: "TKIP", id: 0, key_mgmt: "WPA2-PSK", mode: "station",
      pairwise_cipher: "CCMP", ssid: "MyNetworkSsid", wpa_state: "COMPLETED"}

Polling the `wpa_supplicant` for status isn't that great, so it's possible to
register a `GenEvent` with `WpaSupplicant`. If you don't supply one in the call
to `start_link`, one is automatically created and available via `WpaSupplicant.event_manager/1`. The
following example shows how to view events at the prompt:

    iex> defmodule Forwarder do
    ...>  use GenEvent
    ...>  def handle_event(event, parent) do
    ...>    send parent, event
    ...>    {:ok, parent}
    ...>  end
    ...> end
    iex> WpaSupplicant.event_manager(pid) |> GenEvent.add_handler(Forwarder, self())
    iex> flush
    {:wpa_supplicant, #PID<0.85.0>, :"CTRL-EVENT-SCAN-STARTED"}
    {:wpa_supplicant, #PID<0.85.0>, :"CTRL-EVENT-SCAN-RESULTS"}

## Low level messaging

It is expected that the helper functions for interacting with the `wpa_supplicant`
will not cover every situation. The `WpaSupplicant.request/2` function allows
you to send arbitrary commands. Requests are atoms that are named the same as
described in the `wpa_supplicant` documentation (see Useful links). If a request
takes a parameter, pass it as a tuple where the first element is the command.
Parameters may be strings or numbers and will be properly formatted for the
control interface. The response is also parsed and turned into atoms, numbers,
strings, lists, or maps depending on the command. The string parsing is taken
care of by this library. Here are some examples:

    iex> WpaSupplicant.request(pid, :INTERFACES)
    ["wlan0"]

    iex> WpaSupplicant.request(pid, {:GET_NETWORK, 0, :key_mgmt})
    "WPA-PSK"

## Useful links

  1. [wpa_supplicant homepage](http://w1.fi/wpa_supplicant/)
  2. [wpa_supplicant control interface](http://w1.fi/wpa_supplicant/devel/ctrl_iface_page.html)
  3. [wpa_supplicant information on the archlinux wiki](https://wiki.archlinux.org/index.php/Wpa_supplicant)

## Licensing

The majority of this package is licensed under the Apache 2.0 license. The code
that directly interfaces with the `wpa_supplicant` is copied from the
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
