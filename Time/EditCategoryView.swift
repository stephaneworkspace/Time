//
//  EditCategoryView.swift
//  Time
//
//  Created by Stéphane Bressani on 06.05.2025.
//

import SwiftUI

struct EditCategoryView: View {
    @Binding var category: Category
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Nom de la catégorie")
                .font(.headline)
            TextField("Nom", text: $category.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 250)

            HStack {
                Button("Annuler") {
                    dismiss()
                }
                Button("OK") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 300)
    }
}
