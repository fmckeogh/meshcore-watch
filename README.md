# Meshcore watchOS

> Standalone Apple Watch app for MeshCore devices

Forked from Ronan Gaillard's [MeshCore Messenger](https://github.com/ronangaillard/meshcore-messenger-ios).

## Features

* [x] **Messaging**: Send/receive direct messages to/from other MeshCore devices.
* [x] **Notifications**: Get notified of new messages even when the app is in the background.    
* [x] **Node Information**: View information about the connected device.
* [x] **Persistent Chat History**: All conversations are saved locally on your device.  
* [ ] **Channels**: Send and receive texts in channels (just need to adapt DM views to support channels).
* [ ] **Node Configuration**: Make changes to the node configuration, can't really see a usecase for this.
* [ ] General UI tidy up

## Errata

Due to (I believe) watchOS not advertising keyboard support for BLE pairing (even though one could absolutely enter a 6-digit passkey), Passkey pairing must be disabled (and the Just Works BLE scheme used instead) in the MeshCore firmware of the devie one wishes to use with this app. [This offers the same security as the default MeshCore "123456" PIN](https://security.stackexchange.com/questions/286602/comparison-between-just-works-and-a-static-123456-passkey-in-ble-simple-secure/286604#286604). Might be worth upstreaming if enough people care.

Diff:

```
   Bluefruit.setTxPower(BLE_TX_POWER);
   Bluefruit.setName(device_name);
 
-  Bluefruit.Security.setMITM(true);
-  Bluefruit.Security.setPIN(charpin);
-  Bluefruit.Security.setIOCaps(true, false, false);
-  Bluefruit.Security.setPairPasskeyCallback(onPairingPasskey);
   Bluefruit.Security.setPairCompleteCallback(onPairingComplete);
 
   Bluefruit.Periph.setConnectCallback(onConnect);
   Bluefruit.setEventCallback(onBLEEvent);
 
-  bleuart.setPermission(SECMODE_ENC_WITH_MITM, SECMODE_ENC_WITH_MITM);
+  bleuart.setPermission(SECMODE_ENC_NO_MITM, SECMODE_ENC_NO_MITM);
   bleuart.begin();
   bleuart.setRxCallback(onBleUartRX);
```

## Building

1. Clone the repository.  
2. Open `MeshcoreMessenger.xcodeproj` in Xcode.  
3. Select your Apple Watch as the build target (Bluetooth is not available on the simulator).  
4. Ensure you have a developer account set up in Xcode for code signing.  
5. Build and run the application.

For ease of development it also builds as a macOS app, this might be useful.
