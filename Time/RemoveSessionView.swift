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
    @State var commentaire: String = ""
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
                .onChange(of: selectedSessionId) { _, newId in
                    if let selected = sessions.first(where: { $0.id == newId }) {
                        self.commentaire = selected.commentaire ?? ""
                    }
                }
                Button("-") {
                    if selectedSessionId != 0 {
                        SessionController.deleteSession(id: selectedSessionId, completion: { _ in
                            SessionController.fetchSession(categoryId: categoryId, completion: { fetchedSessions in
                                self.sessions = fetchedSessions
                                self.selectedSessionId = fetchedSessions.first?.id ?? 0
                                self.commentaire = fetchedSessions.first?.commentaire ?? ""
                            })
                        }, onError: { errorMessage in
                            self.deleteErrorMessage = StringMessage(text: errorMessage)
                        })
                    }
                }
            }
            HStack {
                if selectedSessionId != 0 {
                    Text(self.commentaire).disabled(true)
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
                self.commentaire = fetchedSessions.first?.commentaire ?? ""
            })
        }
        .padding()
        .frame(width: 300)
    }
}
