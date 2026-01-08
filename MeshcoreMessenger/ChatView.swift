//
//  ChatView.swift
//  MeshcoreMessenger
//

import SwiftUI

struct ChatView: View {
  let contact: Contact
  @EnvironmentObject var messageService: MessageService

  @State private var messageText: String = ""
  @State private var showImagePicker = false
  @State private var selectedImageData: Data?
  @State private var showConversationSettings = false

  private let characterLimit = 140

  private var messages: [Message] {
    messageService.conversations[contact.publicKey] ?? []
  }

  @State private var showingImageDisclaimer = false

  var body: some View {
    VStack {
      ScrollViewReader { scrollViewProxy in
        ScrollView {
          ForEach(messages) { message in
            MessageView(message: message)
          }
        }
        .onAppear {
          if let lastMessage = messages.last {
            scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
          }
        }
        .onChange(of: messages) { _ in
          if let lastMessage = messages.last {
            withAnimation {
              scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
          }

          messageService.markConversationAsRead(for: contact.publicKey)
        }
      }

      Spacer()

      HStack {
        Button(action: { showingImageDisclaimer = true }) {
          Image(systemName: "plus.circle.fill")
            .font(.title2)
        }
        .padding(.leading)

        VStack(alignment: .trailing) {
          TextField("Enter your message...", text: $messageText)
            .textFieldStyle(RoundedBorderTextFieldStyle())

          // AJOUT : Le compteur de caractères
          Text("\(messageText.count) / \(characterLimit)")
            .font(.caption)
            .foregroundColor(messageText.count > characterLimit ? .red : .gray)
            .padding(.trailing, 5)
        }

        Button(action: sendMessage) {
          Image(systemName: "arrow.up.circle.fill")
            .font(.largeTitle)
        }
        .padding(.trailing)
        .disabled(messageText.isEmpty || messageText.count > characterLimit)
      }
      .alert("Sending Large Files", isPresented: $showingImageDisclaimer) {
        Button("I Understand", role: .none) {
          self.showImagePicker = true
          self.showingImageDisclaimer = false
        }
        Button("Cancel", role: .cancel) {
          self.showingImageDisclaimer = false
        }
      } message: {
        Text(
          "Warning: Sending images consumes significant network bandwidth. Please use this feature with caution, especially in areas with limited node availability."
        )
      }
      .padding(.bottom)
    }
    .navigationTitle(contact.name)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: {
          showConversationSettings = true
        }) {
          Image(systemName: "gearshape.fill")
        }
      }
    }.sheet(isPresented: $showConversationSettings) {
      ConversationSettingsView(contact: contact)
        .environmentObject(messageService)
    }
    .onAppear {
      messageService.markConversationAsRead(for: contact.publicKey)
    }
  }

  func sendMessage() {
    guard !messageText.isEmpty else { return }
    messageService.sendMessage(to: contact, message: messageText)
    messageText = ""
  }
}

struct MessageView: View {
  let message: Message

  var body: some View {
    VStack(alignment: message.isFromCurrentUser ? .trailing : .leading) {
      messageContent()
        .padding(.horizontal, 10)
      statusText()
        .font(.caption)
        .foregroundColor(.gray)
        .padding(.horizontal, 15)
    }
    .padding(.vertical, 2)
  }

  @ViewBuilder
  private func messageContent() -> some View {
    HStack {
      if message.isFromCurrentUser { Spacer() }
    
        Text(message.content)
          .padding(10)
          .foregroundColor(message.isFromCurrentUser ? .white : .primary)
          .background(message.isFromCurrentUser ? .blue : Color(UIColor.systemGray5))
          .cornerRadius(10)
      
      if !message.isFromCurrentUser { Spacer() }
    }
  }

  @ViewBuilder
  private func statusText() -> some View {
    if message.isFromCurrentUser {
      switch message.status {
      case .sending:
        Text("Sending...")
      case .sent:
        Text("Sent")
      case .delivered:
        Text("Delivered ✓")
      case .failed:
        Text("Failed to send")
      }
    }
  }
}
