//
//  AddCategoryView.swift
//  Time
//
//  Created by Stéphane Bressani on 07.05.2025.
//

import SwiftUI

struct AddCategoryView: View {
    @Binding var category: Category
    var onSave: (Category) -> Void
    @State private var newCategoryName = ""
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) var dismiss
    
    struct StringMessage: Identifiable {
        var id: String { text }
        let text: String
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Nouvelle catégorie")
                .font(.headline)
            TextField("Nom de la catégorie", text: $newCategoryName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .focused($isTextFieldFocused)

            Button("Créer") {
                CategoryController.createCategory(named: newCategoryName) { decoded in
                    if let newCategory = decoded.last {
                        onSave(newCategory)
                        dismiss()
                    }
                }
            }

            Button("Annuler") {
                dismiss()
            }
        }
        .frame(width: 300)
        .padding()
        .onAppear { isTextFieldFocused = true }
    }
}
