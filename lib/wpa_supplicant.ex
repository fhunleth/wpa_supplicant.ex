# Copyright 2014 LKC Technologies, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

defmodule WpaSupplicant do
  use GenServer
  require Logger

  defstruct port: nil,
            manager: nil,
            requests: []

  @doc """
  Start and link a WpaSupplicant process that uses the specified
  control socket. A GenEvent will be spawned for managing wpa_supplicant
  events. Call event_manager/1 to get the GenEvent pid.
  """
  def start_link(control_socket_path) do
    { :ok, manager } = GenEvent.start_link
    start_link(control_socket_path, manager)
  end

  @doc """
  Start and link a WpaSupplicant that uses the specified control
  socket and GenEvent event manager.
  """
  def start_link(control_socket_path, event_manager) do
    GenServer.start_link(__MODULE__, {control_socket_path, event_manager})
  end

  @doc """
  Send a request to the wpa_supplicant.

  ## Examples

      iex> WpaSupplicant.request(pid, :PING)
      :PONG
  """
  def request(pid, command) do
    GenServer.call(pid, {:request, command})
  end

  @doc """
  Get a reference to the GenEvent event manager in use by this
  supplicant.
  """
  def event_manager(pid) do
    GenServer.call(pid, :event_manager)
  end

  @doc """
  Return the current status of the wpa_supplicant. It wraps the
  STATUS command.
  """
  def status(pid) do
    request(pid, :STATUS)
  end

  @doc """
  Tell the wpa_supplicant to connect to the specified network. Invoke
  like this:

      iex> WpaSupplicant.set_network(pid, ssid: "MyNetworkSsid", key_mgmt: :WPA_PSK, psk: "secret")

  or like this:

      iex> WpaSupplicant.set_network(pid, %{ssid: "MyNetworkSsid", key_mgmt: :WPA_PSK, psk: "secret"})

  Many options are supported, but it is likely that `ssid` and `psk` are
  the most useful. The full list can be found in the wpa_supplicant
  documentation. Here's a list of some common ones:

  Option                | Description
  ----------------------|------------
  :ssid                 | Network name. This is mandatory.
  :key_mgmt             | The security in use. This is mandatory. Set to :NONE, :WPA_PSK
  :psk                  | WPA preshared key - 64 hex-digits or an ASCII passphrase
  :bssid                | Optional BSSID. If set, only associate with the AP with a matching BSSID
  :mode                 | Mode: 0 = infrastructure (default), 1 = ad-hoc, 2 = AP
  :frequency            | Channel frequency. e.g., 2412 for 802.11b/g channel 1
  :wep_key0..3          | Static WEP key
  :wep_tx_keyidx        | Default WEP key index (0 to 3)

  Note that this is a helper function that wraps several low level calls and
  is limited to specifying only one network at a time. If you'd
  like to register multiple networks with the supplicant, send the
  ADD_NETWORK, SET_NETWORK, SELECT_NETWORK messages manually.
  """
  def set_network(pid, options) do
    # Don't worry if the following fails. We just need to
    # make sure that no other networks registered with the
    # wpa_supplicant take priority over ours
    request(pid, {:REMOVE_NETWORK, "all"})

    netid = request(pid, :ADD_NETWORK)
    Enum.each(options, fn({key, value}) ->
        :ok = request(pid, {:SET_NETWORK, netid, key, value})
      end)

    :ok = request(pid, {:SELECT_NETWORK, netid})
  end

  @doc """
  This is a helper function that will initiate a scan, wait for the
  scan to complete and return a list of all of the available access
  points. This can take a while if the wpa_supplicant hasn't scanned
  for access points recently.
  """
  def scan(pid) do
    stream = pid |> event_manager |> GenEvent.stream(timeout: 60000)
    case request(pid, :SCAN) do
      :ok -> :ok

      # If the wpa_supplicant is already scanning, FAIL-BUSY is
      # returned.
      "FAIL-BUSY" -> :ok
    end

    # Wait for the scan results
    Enum.take_while(stream, fn(x) -> x == {:wpa_supplicant, pid, :"CTRL-EVENT-SCAN-RESULTS"} end)

    # Collect all BSSs
    all_bss(pid, 0, [])
  end

  defp all_bss(pid, count, acc) do
    result = request(pid, {:BSS, count})
    if result do
      all_bss(pid, count + 1, [result | acc])
    else
      acc
    end
  end

  def init({control_socket_path, event_manager}) do
    executable = :code.priv_dir(:wpa_supplicant) ++ '/wpa_ex'
    port = Port.open({:spawn_executable, executable},
                     [{:args, [control_socket_path]},
                      {:packet, 2},
                      :binary,
                      :exit_status])
    { :ok, %WpaSupplicant{port: port, manager: event_manager} }
  end

  def handle_call({:request, command}, from, state) do
    payload = WpaSupplicant.Encode.encode(command)
    Logger.info("WpaSupplicant: sending '#{payload}'")
    send state.port, {self, {:command, payload}}
    state = %{state | :requests => state.requests ++ [{from, command}]}
    {:noreply, state}
  end
  def handle_call(:event_manager, _from, state) do
    {:reply, state.manager, state}
  end

  def handle_info({_, {:data, message}}, state) do
    handle_wpa(message, state)
  end
  def handle_info({_, {:exit_status, _}}, state) do
    {:stop, :unexpected_exit, state}
  end

  defp handle_wpa(<< "<", _priority::utf8, ">", notification::binary>>, state) do
    decoded_notif = WpaSupplicant.Decode.notif(notification)
    GenEvent.notify(state.manager, {:wpa_supplicant, self, decoded_notif})
    {:noreply, state}
  end
  defp handle_wpa(response, state) do
    [{client, command} | next_ones] = state.requests
    state = %{state | :requests => next_ones}

    decoded_response = WpaSupplicant.Decode.resp(command, response)
    GenServer.reply client, decoded_response
    {:noreply, state}
  end
end
