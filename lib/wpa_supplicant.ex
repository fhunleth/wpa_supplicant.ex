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
  This is a helper function that will initiate a scan, wait for the
  scan to complete and return a list of all of the available access
  points.
  """

  def scan(pid) do
    stream = pid |> event_manager |> GenEvent.stream(timeout: 30000)
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
