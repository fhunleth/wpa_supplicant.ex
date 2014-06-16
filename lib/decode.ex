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

defmodule WpaSupplicant.Decode do
  @doc """
  Decode notifications from the wpa_supplicant
  """
  def notif(<< "CTRL-REQ-", rest::binary >>) do
    [field, net_id, text] = String.split(rest, "-", parts: 3, trim: true)
    {String.to_atom("CTRL-REQ-" <> field), String.to_integer(net_id), text}
  end
  def notif(<< "CTRL-EVENT-BSS-ADDED", rest::binary >>) do
    [entry_id, bssid] = String.split(rest, " ", trim: true)
    {:"CTRL-EVENT-BSS-ADDED", String.to_integer(entry_id), bssid}
  end
  def notif(<< "CTRL-EVENT-BSS-REMOVED", rest::binary >>) do
    [entry_id, bssid] = String.split(rest, " ", trim: true)
    {:"CTRL-EVENT-BSS-REMOVED", String.to_integer(entry_id), bssid}
  end
  def notif(<< "CTRL-EVENT-", _type::binary>> = event) do
    event |> String.rstrip |> String.to_atom
  end
  def notif(<< "WPS-", _type::binary>> = event) do
    event |> String.rstrip |> String.to_atom
  end
  def notif(<< "AP-STA-CONNECTED ", mac::binary>>) do
    {:"AP-STA-CONNECTED", String.rstrip(mac)}
  end
  def notif(<< "AP-STA-DISCONNECTED ", mac::binary>>) do
    {:"AP-STA-DISCONNECTED", String.rstrip(mac)}
  end

  @doc """
  Decode responses from the wpa_supplicant

  The decoding of a response depends on the request, so pass the request as
  the first argument and the response as the second one.
  """
  def resp(req, resp) do
    # Strip the response of whitespace before trying to parse it.
    tresp(req, String.strip(resp))
  end

  defp tresp(:PING, "PONG"), do: :PONG
  defp tresp(:MIB, resp), do: kv_resp(resp)
  defp tresp(:STATUS, resp), do: kv_resp(resp)
  defp tresp(:"STATUS-VERBOSE", resp), do: kv_resp(resp)
  defp tresp(:BSS, resp), do: kv_resp(resp)
  defp tresp(_, resp), do: resp

  defp kv_resp(resp) do
    pairs = String.split(resp, "\n", trim: true)
    for pair <- pairs do
      [key, value] = String.split(pair, "=")
      { String.to_atom(key), kv_value(String.rstrip(value)) }
    end
  end

  defp kv_value("TRUE"), do: true
  defp kv_value("FALSE"), do: false
  defp kv_value(""), do: nil
  defp kv_value(<< "0x", hex::binary >>), do: kv_value(hex, 16)
  defp kv_value(str), do: kv_value(str, 10)

  defp kv_value(value, base) do
    try do
      String.to_integer(value, base)
    rescue
      ArgumentError -> value
    end
  end

end
