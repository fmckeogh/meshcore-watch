//
//  ChatSelectorView.swift
//  MeshcoreMessenger
//
//  Created by Ferdia McKeogh on 2026-01-08.
//

import SwiftUI

struct ChatSelectorView: View {
    @EnvironmentObject var messageService: MessageService

    var body: some View {
        NavigationView {
            // list contacts
            List(messageService.contacts) { contact in
                NavigationLink(destination: ChatView(contact: contact)) {
                    Text(contact.name)
                }
            }
        }
    }
}


