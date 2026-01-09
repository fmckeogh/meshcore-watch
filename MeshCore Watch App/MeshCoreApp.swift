//
//  MeshCoreApp.swift
//  MeshCore Watch App
//
//  Created by Ferdia McKeogh on 2026-01-08.
//

import SwiftUI

@main
struct MeshCore_Watch_AppApp: App {
    @StateObject private var bleManager = BLEManager.shared
    @StateObject private var messageService = MessageService()

    init() {
      let msgService = MessageService()
      _messageService = StateObject(wrappedValue: msgService)
    }

    var body: some Scene {
      WindowGroup {
        ContentView()
          .environmentObject(bleManager)
          .environmentObject(messageService)
      }
    }
}
