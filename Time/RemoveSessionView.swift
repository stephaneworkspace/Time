//
//  RemoveSessionView.swift
//  Time
//
//  Created by Stéphane Bressani on 09.05.2025.
//

import SwiftUI

struct RemoveSessionView: View {
    let categoryId: Int
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
                        Text("\(session.id); \(session.startedAt.formatted())")
                            .tag(Int(session.id))
                    }
                }
                Button("-") {
                    if selectedSessionId != 0 {
                        SessionController.deleteSession(id: selectedSessionId, completion: { _ in
                            SessionController.fetchSession(categoryId: categoryId, completion: { fetchedSessions in
                                self.sessions = fetchedSessions
                                self.selectedSessionId = fetchedSessions.first?.id ?? 0
                            })
                        }, onError: { errorMessage in
                            self.deleteErrorMessage = StringMessage(text: errorMessage)
                        })
                    }
                }
            }
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Text("Retour")
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
            .frame(width: 300)
        }
        .onAppear {
            SessionController.fetchSession(categoryId: categoryId, completion: { fetchedSessions in
                self.sessions = fetchedSessions
                self.selectedSessionId = fetchedSessions.first?.id ?? 0
            })
        }
        .padding()
        .frame(width: 300)
    }
}
