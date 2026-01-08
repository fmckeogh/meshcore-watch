//
//  Models.swift
//  MeshcoreMessenger
//

import Foundation

// MARK: - Data Models

enum MessageStatus: String, Hashable, Codable {
  case sending, sent, delivered, failed
}


struct Channel: Identifiable, Hashable, Codable {
  let id: UInt8
  var name: String
}

struct Message: Identifiable, Hashable, Codable {
  let id: UUID
  var content: String
  let isFromCurrentUser: Bool
  var status: MessageStatus
  var isRead: Bool

  init(content: String, isFromCurrentUser: Bool, status: MessageStatus, isRead: Bool = true)
  {
    self.id = UUID()
    self.content = content
    self.isFromCurrentUser = isFromCurrentUser
    self.status = status
    self.isRead = isRead
  }
}

struct Contact: Identifiable, Hashable, Codable {
  let id: UUID
  let publicKey: Data
  let name: String

  init(id: UUID = UUID(), publicKey: Data, name: String) {
    self.id = id
    self.publicKey = publicKey
    self.name = name
  }
}

struct NodeSettings: Equatable {
  var name: String = "Loading..."
  var radioFreq: UInt32 = 0
  var radioBw: UInt32 = 0
  var radioSf: UInt8 = 0
  var radioCr: UInt8 = 0
  var txPower: UInt8 = 0
}

// MARK: - Extensions

extension Data {
  func hexEncodedString() -> String {
    return map { String(format: "%02hhx", $0) }.joined()
  }

  init<T>(from value: T) {
    var value = value
    self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
  }

  func to<T>(type: T.Type) -> T {
    return self.withUnsafeBytes { $0.load(as: T.self) }
  }
}
