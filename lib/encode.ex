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

defmodule WpaSupplicant.Encode do

  def encode(cmd) when is_atom(cmd) do
    to_string(cmd)
  end
  def encode({:"CTRL-RSP-IDENTITY", network_id, string}) do
    "CTRL-RSP-IDENTITY-#{network_id}-#{string}"
  end
  def encode({:"CTRL-RSP-PASSWORD", network_id, string}) do
    "CTRL-RSP-PASSWORD-#{network_id}-#{string}"
  end
  def encode({:"CTRL-RSP-NEW_PASSWORD", network_id, string}) do
    "CTRL-RSP-NEW_PASSWORD-#{network_id}-#{string}"
  end
  def encode({:"CTRL-RSP-PIN", network_id, string}) do
    "CTRL-RSP-PIN-#{network_id}-#{string}"
  end
  def encode({:"CTRL-RSP-OTP", network_id, string}) do
    "CTRL-RSP-OTP-#{network_id}-#{string}"
  end
  def encode({:"CTRL-RSP-PASSPHRASE", network_id, string}) do
    "CTRL-RSP-PASSPHRASE-#{network_id}-#{string}"
  end
  def encode({cmd, arg}) when is_atom(cmd) do
    to_string(cmd) <> " " <> encode_arg(arg)
  end
  def encode({cmd, arg, arg2}) when is_atom(cmd) do
    to_string(cmd) <> " " <> encode_arg(arg) <> " " <> encode_arg(arg2)
  end
  def encode({cmd, arg, arg2, arg3}) when is_atom(cmd) do
    to_string(cmd) <> " " <> encode_arg(arg) <> " " <> encode_arg(arg2) <> " " <> encode_arg(arg3)
  end

  defp encode_arg(arg) when is_binary(arg) do
    if String.length(arg) == 17 &&
      Regex.match?(~r/[\da-fA-F][\da-fA-F]:[\da-fA-F][\da-fA-F]:[\da-fA-F][\da-fA-F]:[\da-fA-F][\da-fA-F]:[\da-fA-F][\da-fA-F]:[\da-fA-F][\da-fA-F]/, arg) do
      # This is a MAC address
      arg
    else
      # This is a string
      "\"" <> arg <> "\""
    end
  end
  defp encode_arg(arg) do
    to_string(arg)
  end

end
