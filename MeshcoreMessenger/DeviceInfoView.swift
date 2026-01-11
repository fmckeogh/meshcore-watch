//
//  DeviceInfoView.swift
//  MeshcoreMessenger
//
//  Created by Ferdia McKeogh on 2026-01-09.
//

import SwiftUI

struct DeviceInfoView: View {
    @EnvironmentObject var messageService: MessageService
    @EnvironmentObject var bleManager: BLEManager

    var body: some View {
        NavigationView {
            List {
                Button(
                    "Disconnect",
                    role: .destructive,
                    action: bleManager.disconnect
                ).buttonStyle(.bordered)
                HStack {
                    Text("Name")
                    Spacer()
                    Text(messageService.settings.name)
                }
                IntInfoRowView(
                    name: "Battery",
                    value: messageService.batteryMilliVolts,
                    unit: "mV"
                )
                IntInfoRowView(
                    name: "Used storage",
                    value: messageService.usedStorage,
                    unit: "KB"
                )
                IntInfoRowView(
                    name: "Total storage",
                    value: messageService.totalStorage,
                    unit: "KB"
                )
                HStack {
                    Text("Public key")
                    Spacer()
                    if let pubkey = messageService.getSelfPublicKey() {
                        Text(pubkey.hexEncodedString().prefix(8))
                            .foregroundStyle(.secondary)
                    }
                }
            }.navigationTitle("Device")
        }
        .onAppear(perform: messageService.getBatteryAndStorage)
    }
}

struct IntInfoRowView: View {
    var name: String
    var value: Int?
    var unit: String

    var body: some View {
        HStack {
            Text(name)
            Spacer()
            if let value = value {
                Text(String(value) + " " + unit).foregroundStyle(.secondary)
            }
        }
    }
}
