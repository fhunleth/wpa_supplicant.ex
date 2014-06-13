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
    args = [String.to_char_list(control_socket_path)]
    port = Port.open({:spawn_executable, executable},
                     [{:args, [control_socket_path]},
                      {:packet, 2},
                      :binary,
                      :exit_status])
    { :ok, %WpaSupplicant{port: port} }
  end

  def handle_call({:request, message}, from, state) do
    send state.port, {self, {:command, message}}
    state = %{state | :requests => state.requests ++ [from]}
    {:noreply, state}
  end

  def handle_info({_, {:data, message}}, state) do
    handle_wpa(message, state)
  end

  def handle_wpa(<< "<", priority::utf8, ">", notification::binary>>, state) do
    IO.puts "Notif: #{notification}"
    {:noreply, state}
  end
  def handle_wpa(response, state) do
    IO.puts "Response: #{response}"
    [client | next_ones] = state.requests
    state = %{state | :requests => next_ones}
    GenServer.reply client, response
    {:noreply, state}
  end

end
