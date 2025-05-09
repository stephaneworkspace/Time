//
//  AddSessionView.swift
//  Time
//
//  Created by Stéphane Bressani on 08.05.2025.
//

import SwiftUI

struct AddSessionView: View {
    let projectId: Int
    let defaultSessionComment: String

    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()

    init(projectId: Int, defaultSessionComment: String) {
        self.projectId = projectId
        self.defaultSessionComment = defaultSessionComment
        _name = State(initialValue: defaultSessionComment)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Session manuelle")
                .font(.headline)

            TextField("Commentaire", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            DatePicker("Début", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)
            DatePicker("Fin", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)
            
            Button("Créer") {
                SessionController.createSession(
                    projectId: projectId,
                    startedAt: startDate,
                    endedAt: endDate,
                    commentaire: name
                ) { result in
                    switch result {
                    case .success():
                        print("✅ Session enregistrée avec succès")
                        dismiss()
                    case .failure(let error):
                        print("❌ Erreur lors de la création de session : \(error.localizedDescription)")
                        print("🔍 Erreur brute : \(error)")
                    }
                }
            }
            .disabled(name.isEmpty)
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.defaultAction)

            Button("Annuler") {
                dismiss()
            }
        }
        .frame(width: 300)
        .padding()
    }
}
