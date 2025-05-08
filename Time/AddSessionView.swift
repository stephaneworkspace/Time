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

            Button("Créer") {

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
