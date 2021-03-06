defmodule WpaEncodeTest do
  use ExUnit.Case

  test "interactive" do
    assert WpaSupplicant.Encode.encode({:'CTRL-RSP-IDENTITY', 1, "response text"}) == "CTRL-RSP-IDENTITY-1-response text"
    assert WpaSupplicant.Encode.encode({:'CTRL-RSP-PASSWORD', 1, "response text"}) == "CTRL-RSP-PASSWORD-1-response text"
    assert WpaSupplicant.Encode.encode({:'CTRL-RSP-NEW_PASSWORD', 1, "response text"}) == "CTRL-RSP-NEW_PASSWORD-1-response text"
    assert WpaSupplicant.Encode.encode({:'CTRL-RSP-PIN', 1, "response text"}) == "CTRL-RSP-PIN-1-response text"
    assert WpaSupplicant.Encode.encode({:'CTRL-RSP-OTP', 1, "response text"}) == "CTRL-RSP-OTP-1-response text"
    assert WpaSupplicant.Encode.encode({:'CTRL-RSP-PASSPHRASE', 1, "response text"}) == "CTRL-RSP-PASSPHRASE-1-response text"
  end

  test "commands" do
    assert WpaSupplicant.Encode.encode(:PING) == "PING"
    assert WpaSupplicant.Encode.encode(:MIB) == "MIB"
    assert WpaSupplicant.Encode.encode(:STATUS) == "STATUS"
    assert WpaSupplicant.Encode.encode(:'STATUS-VERBOSE') == "STATUS-VERBOSE"
    assert WpaSupplicant.Encode.encode(:PMKSA) == "PMKSA"
    assert WpaSupplicant.Encode.encode({:SET, :int_variable, 5}) == "SET int_variable 5"
    assert WpaSupplicant.Encode.encode({:SET, :string_variable, "string"}) == "SET string_variable \"string\""
    assert WpaSupplicant.Encode.encode(:LOGON) == "LOGON"
    assert WpaSupplicant.Encode.encode(:LOGOFF) == "LOGOFF"
    assert WpaSupplicant.Encode.encode(:REASSOCIATE) == "REASSOCIATE"
    assert WpaSupplicant.Encode.encode(:RECONNECT) == "RECONNECT"
    assert WpaSupplicant.Encode.encode({:PREAUTH, "00:09:5b:95:e0:4e"}) == "PREAUTH 00:09:5b:95:e0:4e"
    assert WpaSupplicant.Encode.encode(:ATTACH) == "ATTACH"
    assert WpaSupplicant.Encode.encode(:DETACH) == "DETACH"
    assert WpaSupplicant.Encode.encode({:LEVEL, 4}) == "LEVEL 4"
    assert WpaSupplicant.Encode.encode(:RECONFIGURE) == "RECONFIGURE"
    assert WpaSupplicant.Encode.encode(:TERMINATE) == "TERMINATE"
    assert WpaSupplicant.Encode.encode({:BSSID, 1, "00:09:5b:95:e0:4e"}) == "BSSID 1 00:09:5b:95:e0:4e"
    assert WpaSupplicant.Encode.encode(:LIST_NETWORKS) == "LIST_NETWORKS"
    assert WpaSupplicant.Encode.encode(:DISCONNECT) == "DISCONNECT"
    assert WpaSupplicant.Encode.encode(:SCAN) == "SCAN"
    assert WpaSupplicant.Encode.encode(:SCAN_RESULTS) == "SCAN_RESULTS"
    assert WpaSupplicant.Encode.encode({:BSS, 4}) == "BSS 4"
    assert WpaSupplicant.Encode.encode({:SELECT_NETWORK, 1}) == "SELECT_NETWORK 1"
    assert WpaSupplicant.Encode.encode({:ENABLE_NETWORK, 1}) == "ENABLE_NETWORK 1"
    assert WpaSupplicant.Encode.encode({:DISABLE_NETWORK, 1}) == "DISABLE_NETWORK 1"
    assert WpaSupplicant.Encode.encode(:ADD_NETWORK) == "ADD_NETWORK"
    assert WpaSupplicant.Encode.encode({:SET_NETWORK, 1, :ssid, "SSID"}) == "SET_NETWORK 1 ssid \"SSID\""
    assert WpaSupplicant.Encode.encode({:SET_NETWORK, 1, :psk, "SSID"}) == "SET_NETWORK 1 psk \"SSID\""
    assert WpaSupplicant.Encode.encode({:SET_NETWORK, 1, :key_mgmt, "SSID"}) == "SET_NETWORK 1 key_mgmt \"SSID\""
    assert WpaSupplicant.Encode.encode({:SET_NETWORK, 1, :identity, "SSID"}) == "SET_NETWORK 1 identity \"SSID\""
    assert WpaSupplicant.Encode.encode({:SET_NETWORK, 1, :password, "SSID"}) == "SET_NETWORK 1 password \"SSID\""
    assert WpaSupplicant.Encode.encode({:GET_NETWORK, 1, :ssid}) == "GET_NETWORK 1 ssid"
    assert WpaSupplicant.Encode.encode(:SAVE_CONFIG) == "SAVE_CONFIG"
    assert WpaSupplicant.Encode.encode(:P2P_FIND) == "P2P_FIND"
    assert WpaSupplicant.Encode.encode(:P2P_STOP_FIND) == "P2P_STOP_FIND"
    assert WpaSupplicant.Encode.encode(:P2P_CONNECT) == "P2P_CONNECT"
    assert WpaSupplicant.Encode.encode(:P2P_LISTEN) == "P2P_LISTEN"
    assert WpaSupplicant.Encode.encode(:P2P_GROUP_REMOVE) == "P2P_GROUP_REMOVE"
    assert WpaSupplicant.Encode.encode(:P2P_GROUP_ADD) == "P2P_GROUP_ADD"
    assert WpaSupplicant.Encode.encode(:P2P_PROV_DISC) == "P2P_PROV_DISC"
    assert WpaSupplicant.Encode.encode(:P2P_GET_PASSPHRASE) == "P2P_GET_PASSPHRASE"
    assert WpaSupplicant.Encode.encode(:P2P_SERV_DISC_REQ) == "P2P_SERV_DISC_REQ"
    assert WpaSupplicant.Encode.encode(:P2P_SERV_DISC_CANCEL_REQ) == "P2P_SERV_DISC_CANCEL_REQ"
    assert WpaSupplicant.Encode.encode(:P2P_SERV_DISC_RESP) == "P2P_SERV_DISC_RESP"
    assert WpaSupplicant.Encode.encode(:P2P_SERVICE_UPDATE) == "P2P_SERVICE_UPDATE"
    assert WpaSupplicant.Encode.encode(:P2P_SERV_DISC_EXTERNAL) == "P2P_SERV_DISC_EXTERNAL"
    assert WpaSupplicant.Encode.encode(:P2P_REJECT) == "P2P_REJECT"
    assert WpaSupplicant.Encode.encode(:P2P_INVITE) == "P2P_INVITE"
    assert WpaSupplicant.Encode.encode(:P2P_PEER) == "P2P_PEER"
    assert WpaSupplicant.Encode.encode(:P2P_EXT_LISTEN) == "P2P_EXT_LISTEN"
  end
end
