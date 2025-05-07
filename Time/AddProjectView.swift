//
//  AddProjectView.swift
//  Time
//
//  Created by Stéphane Bressani on 07.05.2025.
//


import SwiftUI

struct AddProjectView: View {
    let categoryId: Int
    let defaultProjectName: String
    var onAdd: (Project) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String

    init(categoryId: Int, defaultProjectName: String, onAdd: @escaping (Project) -> Void) {
        self.categoryId = categoryId
        self.defaultProjectName = defaultProjectName
        self.onAdd = onAdd
        _name = State(initialValue: defaultProjectName)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Nom du projet")
                .font(.headline)

            TextField("Nom", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Créer") {
                ProjectController.createProject(name: name, categoryId: categoryId) { project in
                    if let project = project {
                        onAdd(project)
                        dismiss()
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
