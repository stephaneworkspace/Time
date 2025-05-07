//
//  EditProjectView.swift
//  Time
//
//  Created by Stéphane Bressani on 07.05.2025.
//

import SwiftUI

struct EditProjectView: View {
    @Binding var project: Project
    var onSave: (Project) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Nom du projet")
                .font(.headline)
            TextField("Nom", text: $project.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 250)

            HStack {
                Button("Annuler") {
                    dismiss()
                }
                Button(action: {
                    ProjectController.editProject(id: project.id, name: project.name, categoryId: project.categoryId) { _ in
                        onSave(project)
                        dismiss()
                    }
                }) {
                    Text("OK")
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 300)
    }
}
