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
            requests: []

  def start_link(control_socket_path) do
    GenServer.start_link(__MODULE__, control_socket_path)
  end

  def request(pid, message) when is_binary(message) do
    GenServer.call(pid, {:request, message})
  end

  def init(control_socket_path) do
    executable = :code.priv_dir(:wpa_supplicant) ++ '/wpa_ex'
    port = Port.open({:spawn_executable, executable},
                     [{:args, [control_socket_path]},
                      {:packet, 2},
                      :binary,
                      :exit_status])
    { :ok, %WpaSupplicant{port: port} }
  end

  def handle_call({:request, command}, from, state) do
    send state.port, {self, {:command, command}}
    state = %{state | :requests => state.requests ++ [{from, command}]}
    {:noreply, state}
  end

  def handle_info({_, {:data, message}}, state) do
    handle_wpa(message, state)
  end

  defp handle_wpa(<< "<", _priority::utf8, ">", notification::binary>>, state) do
    IO.puts "Notif: #{notification}"
    n = wpa_notification(notification)
    IO.inspect n
    {:noreply, state}
  end
  defp handle_wpa(response, state) do
    IO.puts "Response: #{response}"
    [{client, _command} | next_ones] = state.requests
    state = %{state | :requests => next_ones}
    GenServer.reply client, response
    {:noreply, state}
  end

  def wpa_notification(<< "CTRL-EVENT-", _type::binary>> = event) do
    event |> String.rstrip |> String.to_atom
  end

end
