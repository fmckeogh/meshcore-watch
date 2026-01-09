//
//  DeviceInfoView.swift
//  MeshcoreMessenger
//
//  Created by Ferdia McKeogh on 2026-01-09.
//

import SwiftUI

struct DeviceInfoView: View {
    @EnvironmentObject var messageService: MessageService

    var body: some View {
        Text(String(messageService.batteryMilliVolts ?? 0) + "mV")
    }
}
