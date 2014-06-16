defmodule WpaDecodeTest do
  use ExUnit.Case

  test "responses" do
    assert WpaSupplicant.Decode.resp(:PING, "PONG  ") == :PONG
    assert WpaSupplicant.Decode.resp(:MIB, """
      dot11RSNAOptionImplemented=TRUE
      dot11RSNAPreauthenticationImplemented=TRUE
      dot11RSNAEnabled=FALSE
      dot11RSNAPreauthenticationEnabled=FALSE
      dot11RSNAConfigVersion=1
      dot11RSNAConfigPairwiseKeysSupported=5
      dot11RSNAConfigGroupCipherSize=128
      dot11RSNAConfigPMKLifetime=43200
      dot11RSNAConfigPMKReauthThreshold=70
      dot11RSNAConfigNumberOfPTKSAReplayCounters=1
      dot11RSNAConfigSATimeout=60
      dot11RSNAAuthenticationSuiteSelected=00-50-f2-2
      dot11RSNAPairwiseCipherSelected=00-50-f2-4
      dot11RSNAGroupCipherSelected=00-50-f2-4
      dot11RSNAPMKIDUsed=
      dot11RSNAAuthenticationSuiteRequested=00-50-f2-2
      dot11RSNAPairwiseCipherRequested=00-50-f2-4
      dot11RSNAGroupCipherRequested=00-50-f2-4
      dot11RSNAConfigNumberOfGTKSAReplayCounters=0
      dot11RSNA4WayHandshakeFailures=0
      dot1xSuppPaeState=5
      dot1xSuppHeldPeriod=60
      dot1xSuppAuthPeriod=30
      dot1xSuppStartPeriod=30
      dot1xSuppMaxStart=3
      dot1xSuppSuppControlledPortStatus=Authorized
      dot1xSuppBackendPaeState=2
      dot1xSuppEapolFramesRx=0
      dot1xSuppEapolFramesTx=440
      dot1xSuppEapolStartFramesTx=2
      dot1xSuppEapolLogoffFramesTx=0
      dot1xSuppEapolRespFramesTx=0
      dot1xSuppEapolReqIdFramesRx=0
      dot1xSuppEapolReqFramesRx=0
      dot1xSuppInvalidEapolFramesRx=0
      dot1xSuppEapLengthErrorFramesRx=0
      dot1xSuppLastEapolFrameVersion=0
      dot1xSuppLastEapolFrameSource=00:00:00:00:00:00
      """) == [
      dot11RSNAOptionImplemented: true,
      dot11RSNAPreauthenticationImplemented: true,
      dot11RSNAEnabled: false,
      dot11RSNAPreauthenticationEnabled: false,
      dot11RSNAConfigVersion: 1,
      dot11RSNAConfigPairwiseKeysSupported: 5,
      dot11RSNAConfigGroupCipherSize: 128,
      dot11RSNAConfigPMKLifetime: 43200,
      dot11RSNAConfigPMKReauthThreshold: 70,
      dot11RSNAConfigNumberOfPTKSAReplayCounters: 1,
      dot11RSNAConfigSATimeout: 60,
      dot11RSNAAuthenticationSuiteSelected: "00-50-f2-2",
      dot11RSNAPairwiseCipherSelected: "00-50-f2-4",
      dot11RSNAGroupCipherSelected: "00-50-f2-4",
      dot11RSNAPMKIDUsed: nil,
      dot11RSNAAuthenticationSuiteRequested: "00-50-f2-2",
      dot11RSNAPairwiseCipherRequested: "00-50-f2-4",
      dot11RSNAGroupCipherRequested: "00-50-f2-4",
      dot11RSNAConfigNumberOfGTKSAReplayCounters: 0,
      dot11RSNA4WayHandshakeFailures: 0,
      dot1xSuppPaeState: 5,
      dot1xSuppHeldPeriod: 60,
      dot1xSuppAuthPeriod: 30,
      dot1xSuppStartPeriod: 30,
      dot1xSuppMaxStart: 3,
      dot1xSuppSuppControlledPortStatus: "Authorized",
      dot1xSuppBackendPaeState: 2,
      dot1xSuppEapolFramesRx: 0,
      dot1xSuppEapolFramesTx: 440,
      dot1xSuppEapolStartFramesTx: 2,
      dot1xSuppEapolLogoffFramesTx: 0,
      dot1xSuppEapolRespFramesTx: 0,
      dot1xSuppEapolReqIdFramesRx: 0,
      dot1xSuppEapolReqFramesRx: 0,
      dot1xSuppInvalidEapolFramesRx: 0,
      dot1xSuppEapLengthErrorFramesRx: 0,
      dot1xSuppLastEapolFrameVersion: 0,
      dot1xSuppLastEapolFrameSource: "00:00:00:00:00:00"
    ]

    assert WpaSupplicant.Decode.resp(:STATUS, """
      bssid=02:00:01:02:03:04
      ssid=test network
      pairwise_cipher=CCMP
      group_cipher=CCMP
      key_mgmt=WPA-PSK
      wpa_state=COMPLETED
      ip_address=192.168.1.21
      Supplicant PAE state=AUTHENTICATED
      suppPortStatus=Authorized
      EAP state=SUCCESS
      """) == [
      bssid: "02:00:01:02:03:04",
      ssid: "test network",
      pairwise_cipher: "CCMP",
      group_cipher: "CCMP",
      key_mgmt: "WPA-PSK",
      wpa_state: "COMPLETED",
      ip_address: "192.168.1.21",
      "Supplicant PAE state": "AUTHENTICATED",
      suppPortStatus: "Authorized",
      "EAP state": "SUCCESS"
      ]

    assert WpaSupplicant.Decode.resp(:"STATUS-VERBOSE", """
      bssid=02:00:01:02:03:04
      ssid=test network
      id=0
      pairwise_cipher=CCMP
      group_cipher=CCMP
      key_mgmt=WPA-PSK
      wpa_state=COMPLETED
      ip_address=192.168.1.21
      Supplicant PAE state=AUTHENTICATED
      suppPortStatus=Authorized
      heldPeriod=60
      authPeriod=30
      startPeriod=30
      maxStart=3
      portControl=Auto
      Supplicant Backend state=IDLE
      EAP state=SUCCESS
      reqMethod=0
      methodState=NONE
      decision=COND_SUCC
      ClientTimeout=60
      """) == [
      bssid: "02:00:01:02:03:04",
      ssid: "test network",
      id: 0,
      pairwise_cipher: "CCMP",
      group_cipher: "CCMP",
      key_mgmt: "WPA-PSK",
      wpa_state: "COMPLETED",
      ip_address: "192.168.1.21",
      "Supplicant PAE state": "AUTHENTICATED",
      suppPortStatus: "Authorized",
      heldPeriod: 60,
      authPeriod: 30,
      startPeriod: 30,
      maxStart: 3,
      portControl: "Auto",
      "Supplicant Backend state": "IDLE",
      "EAP state": "SUCCESS",
      reqMethod: 0,
      methodState: "NONE",
      decision: "COND_SUCC",
      ClientTimeout: 60
      ]

    assert WpaSupplicant.Decode.resp(:PMKSA, """
      Index / AA / PMKID / expiration (in seconds) / opportunistic
      1 / 02:00:01:02:03:04 / 000102030405060708090a0b0c0d0e0f / 41362 / 0
      2 / 02:00:01:33:55:77 / 928389281928383b34afb34ba4212345 / 362 / 1
      """) == String.strip("""
      Index / AA / PMKID / expiration (in seconds) / opportunistic
      1 / 02:00:01:02:03:04 / 000102030405060708090a0b0c0d0e0f / 41362 / 0
      2 / 02:00:01:33:55:77 / 928389281928383b34afb34ba4212345 / 362 / 1
      """)

    assert WpaSupplicant.Decode.resp(:BSS, """
      bssid=00:09:5b:95:e0:4e
      freq=2412
      beacon_int=0
      capabilities=0x0011
      qual=51
      noise=161
      level=212
      tsf=0000000000000000
      ie=000b6a6b6d2070726976617465010180dd180050f20101000050f20401000050f20401000050f2020000
      ssid=jkm private
      """) ==  [
      bssid: "00:09:5b:95:e0:4e",
      freq: 2412,
      beacon_int: 0,
      capabilities: 0x0011,
      qual: 51,
      noise: 161,
      level: 212,
      tsf: 0000000000000000,
      ie: "000b6a6b6d2070726976617465010180dd180050f20101000050f20401000050f20401000050f2020000",
      ssid: "jkm private"
      ]
  end

  test "interactive" do
    assert WpaSupplicant.Decode.notif("CTRL-REQ-IDENTITY-1-Human readable text") == {:'CTRL-REQ-IDENTITY', 1, "Human readable text"}
    assert WpaSupplicant.Decode.notif("CTRL-REQ-PASSWORD-1-Human readable text") == {:'CTRL-REQ-PASSWORD', 1, "Human readable text"}
    assert WpaSupplicant.Decode.notif("CTRL-REQ-NEW_PASSWORD-1-Human readable text") == {:'CTRL-REQ-NEW_PASSWORD', 1, "Human readable text"}
    assert WpaSupplicant.Decode.notif("CTRL-REQ-PIN-1-Human readable text") == {:'CTRL-REQ-PIN', 1, "Human readable text"}
    assert WpaSupplicant.Decode.notif("CTRL-REQ-OTP-1-Human readable text") == {:'CTRL-REQ-OTP', 1, "Human readable text"}
    assert WpaSupplicant.Decode.notif("CTRL-REQ-PASSPHRASE-1-Human readable text") == {:'CTRL-REQ-PASSPHRASE', 1, "Human readable text"}
  end

  test "ctrl-event" do
    assert WpaSupplicant.Decode.notif("CTRL-EVENT-CONNECTED  ") == :'CTRL-EVENT-CONNECTED'
    assert WpaSupplicant.Decode.notif("CTRL-EVENT-DISCONNECTED\n") == :'CTRL-EVENT-DISCONNECTED'
    assert WpaSupplicant.Decode.notif("CTRL-EVENT-TERMINATING") == :'CTRL-EVENT-TERMINATING'
    assert WpaSupplicant.Decode.notif("CTRL-EVENT-PASSWORD-CHANGED") == :'CTRL-EVENT-PASSWORD-CHANGED'
    assert WpaSupplicant.Decode.notif("CTRL-EVENT-EAP-NOTIFICATION") == :'CTRL-EVENT-EAP-NOTIFICATION'
    assert WpaSupplicant.Decode.notif("CTRL-EVENT-EAP-STARTED") == :'CTRL-EVENT-EAP-STARTED'
    assert WpaSupplicant.Decode.notif("CTRL-EVENT-EAP-METHOD") == :'CTRL-EVENT-EAP-METHOD'
    assert WpaSupplicant.Decode.notif("CTRL-EVENT-EAP-SUCCESS") == :'CTRL-EVENT-EAP-SUCCESS'
    assert WpaSupplicant.Decode.notif("CTRL-EVENT-EAP-FAILURE") == :'CTRL-EVENT-EAP-FAILURE'
    assert WpaSupplicant.Decode.notif("CTRL-EVENT-SCAN-RESULTS") == :'CTRL-EVENT-SCAN-RESULTS'
    assert WpaSupplicant.Decode.notif("CTRL-EVENT-BSS-ADDED 34 00:11:22:33:44:55") == {:'CTRL-EVENT-BSS-ADDED', 34, "00:11:22:33:44:55"}
    assert WpaSupplicant.Decode.notif("CTRL-EVENT-BSS-REMOVED 34 00:11:22:33:44:55") == {:'CTRL-EVENT-BSS-REMOVED', 34, "00:11:22:33:44:55"}
    assert WpaSupplicant.Decode.notif("WPS-OVERLAP-DETECTED") == :'WPS-OVERLAP-DETECTED'
    assert WpaSupplicant.Decode.notif("WPS-AP-AVAILABLE-PBC") == :'WPS-AP-AVAILABLE-PBC'
    assert WpaSupplicant.Decode.notif("WPS-AP-AVAILABLE-PIN") == :'WPS-AP-AVAILABLE-PIN'
    assert WpaSupplicant.Decode.notif("WPS-AP-AVAILABLE") == :'WPS-AP-AVAILABLE'
    assert WpaSupplicant.Decode.notif("WPS-CRED-RECEIVED") == :'WPS-CRED-RECEIVED'
    assert WpaSupplicant.Decode.notif("WPS-M2D") == :'WPS-M2D'
    assert WpaSupplicant.Decode.notif("WPS-FAIL") == :'WPS-FAIL'
    assert WpaSupplicant.Decode.notif("WPS-SUCCESS") == :'WPS-SUCCESS'
    assert WpaSupplicant.Decode.notif("WPS-TIMEOUT") == :'WPS-TIMEOUT'

    #assert WpaSupplicant.Decode.notif("WPS-ENROLLEE-SEEN 02:00:00:00:01:00\n572cf82f-c957-5653-9b16-b5cfb298abf1 1-0050F204-1 0x80 4 1\n[Wireless Client]") ==
    #                                      {:'WPS-ENROLLEE-SEEN', "02:00:00:00:01:00", "572cf82f-c957-5653-9b16-b5cfb298abf1", "1-0050F204-1", 0x80, 4, 1, "[Wireless Client]"}

    #assert WpaSupplicant.Decode.notif("WPS-ER-AP-ADD 87654321-9abc-def0-1234-56789abc0002 02:11:22:33:44:55\npri_dev_type=6-0050F204-1 wps_state=1 |Very friendly name|Company|\nLong description of the model|WAP|http://w1.fi/|http://w1.fi/hostapd/") ==
    #                                     {:'WPS-ER-AP-ADD', "87654321-9abc-def0-1234-56789abc0002", "02:11:22:33:44:55", "pri_dev_type=6-0050F204-1 wps_state=1", "Very friendly name", "Company", "Long description of the model", "WAP",  "http://w1.fi/", "http://w1.fi/hostapd/"}

    #assert WpaSupplicant.Decode.notif("WPS-ER-AP-REMOVE 87654321-9abc-def0-1234-56789abc0002") ==
    #                                      {:'WPS-ER-AP-ADD', "87654321-9abc-def0-1234-56789abc0002"}

    # WPS-ER-ENROLLEE-ADD 2b7093f1-d6fb-5108-adbb-bea66bb87333
    # 02:66:a0:ee:17:27 M1=1 config_methods=0x14d dev_passwd_id=0
    # pri_dev_type=1-0050F204-1
    # |Wireless Client|Company|cmodel|123|12345|

    # WPS-ER-ENROLLEE-REMOVE 2b7093f1-d6fb-5108-adbb-bea66bb87333
    # 02:66:a0:ee:17:27

    # WPS-PIN-NEEDED 5a02a5fa-9199-5e7c-bc46-e183d3cb32f7 02:2a:c4:18:5b:f3
    # [Wireless Client|Company|cmodel|123|12345|1-0050F204-1]

    assert WpaSupplicant.Decode.notif("WPS-NEW-AP-SETTINGS") == :'WPS-NEW-AP-SETTINGS'
    assert WpaSupplicant.Decode.notif("WPS-REG-SUCCESS") == :'WPS-REG-SUCCESS'
    assert WpaSupplicant.Decode.notif("WPS-AP-SETUP-LOCKED") == :'WPS-AP-SETUP-LOCKED'
    assert WpaSupplicant.Decode.notif("AP-STA-CONNECTED 02:2a:c4:18:5b:f3") == {:'AP-STA-CONNECTED', "02:2a:c4:18:5b:f3"}
    assert WpaSupplicant.Decode.notif("AP-STA-DISCONNECTED 02:2a:c4:18:5b:f3") == {:'AP-STA-DISCONNECTED', "02:2a:c4:18:5b:f3"}

    # P2P-DEVICE-FOUND 02:b5:64:63:30:63 p2p_dev_addr=02:b5:64:63:30:63
    # pri_dev_type=1-0050f204-1 name='Wireless Client' config_methods=0x84
    # dev_capab=0x21 group_capab=0x0

    # P2P-GO-NEG-REQUEST 02:40:61:c2:f3:b7 dev_passwd_id=4
    # P2P-GO-NEG-SUCCESS
    # P2P-GO-NEG-FAILURE
    # P2P-GROUP-FORMATION-SUCCESS
    # P2P-GROUP-FORMATION-FAILURE
    # P2P-GROUP-STARTED
    # P2P-GROUP-STARTED wlan0-p2p-0 GO ssid="DIRECT-3F Testing"
    # passphrase="12345678" go_dev_addr=02:40:61:c2:f3:b7 [PERSISTENT]
    # P2P-GROUP-REMOVED wlan0-p2p-0 GO
    # P2P-PROV-DISC-SHOW-PIN 02:40:61:c2:f3:b7 12345670
    # p2p_dev_addr=02:40:61:c2:f3:b7 pri_dev_type=1-0050F204-1 name='Test'
    # config_methods=0x188 dev_capab=0x21 group_capab=0x0
    # P2P-PROV-DISC-ENTER-PIN 02:40:61:c2:f3:b7 p2p_dev_addr=02:40:61:c2:f3:b7
    # pri_dev_type=1-0050F204-1 name='Test' config_methods=0x188
    # dev_capab=0x21 group_capab=0x0
    # P2P-PROV-DISC-PBC-REQ 02:40:61:c2:f3:b7 p2p_dev_addr=02:40:61:c2:f3:b7
    # pri_dev_type=1-0050F204-1 name='Test' config_methods=0x188
    # dev_capab=0x21 group_capab=0x0
    # P2P-PROV-DISC-PBC-RESP 02:40:61:c2:f3:b7
    # P2P-SERV-DISC-REQ 2412 02:40:61:c2:f3:b7 0 0 02000001
    # P2P-SERV-DISC-RESP 02:40:61:c2:f3:b7 0 0300000101
    # P2P-INVITATION-RECEIVED sa=02:40:61:c2:f3:b7 persistent=0
    # P2P-INVITATION-RESULT status=1
  end
end
