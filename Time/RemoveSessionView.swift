//
//  RemoveSessionView.swift
//  Time
//
//  Created by Stéphane Bressani on 09.05.2025.
//

import SwiftUI

struct RemoveSessionView: View {
    let projectId: Int
    @State var selectedSessionId: Int = 0
    @State private var sessions: [Session] = []
    @State private var deleteErrorMessage: StringMessage? = nil
    @Environment(\.dismiss) var dismiss
    
    struct StringMessage: Identifiable {
        var id: String { text }
        let text: String
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Picker("", selection: $selectedSessionId) {
                    ForEach(sessions) { session in
                        Text(session.id.formatted()+";"+session.started_at.formatted()).tag(session.id as Int?)
                    }
                }
                Button("-") {
                    /*  if let id = selectedSessionId {
                       SessionController.deleteSession(id: id, completion: { decoded in
                            self.sessions = decoded
                            self.selectedSessionId = decoded.first?.id
                        }, onError: { errorMessage in
                            self.deleteErrorMessage = StringMessage(text: errorMessage)
                        })
                    }
                     */
                }
            }
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Text("OK")
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
            .frame(width: 300)
            .onAppear {
                // SessionController.fetchSession(projectId: projectId)
            }
        }
        .padding()
        .frame(width: 300)
    }
}
