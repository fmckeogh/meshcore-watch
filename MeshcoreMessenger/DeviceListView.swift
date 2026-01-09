//
//  DeviceListView.swift
//  MeshcoreMessenger
//

import CoreBluetooth
import SwiftUI

struct DeviceListView: View {
  @ObservedObject var bleManager: BLEManager

  var body: some View {
      VStack {
          Text("Found devices:")
            .foregroundColor(.secondary)
    
          List(bleManager.discoveredPeripherals, id: \.identifier) { peripheral in
            Button(action: {
              bleManager.connect(to: peripheral)
            }) {
              HStack {
                Text(peripheral.name ?? "Unknown Device")
              }
            }
            .foregroundColor(.primary)
        }
      }
    .onDisappear(perform: bleManager.stopScan)
  }
}
