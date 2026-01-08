//
//  MeshcoreMessengerApp.swift
//  MeshcoreMessenger
//

import SwiftUI

@main
struct MeshcoreMessengerApp: App {
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
