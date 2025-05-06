//
//  CategoryController.swift
//  Time
//
//  Created by Stéphane Bressani on 06.05.2025.
//

import Foundation

struct Category: Identifiable, Decodable {
    let id: Int
    let name: String
}

class CategoryController {
    static func fetchCategories(token: String, completion: @escaping ([Category]) -> Void) {
        guard let url = URL(string: "https://time.bressani.dev:3443/api/categories") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Erreur de réseau : \(error?.localizedDescription ?? "inconnue")")
                return
            }

            if let decoded = try? JSONDecoder().decode([Category].self, from: data) {
                DispatchQueue.main.async {
                    completion(decoded)
                }
            } else {
                print("❌ Échec de décodage JSON")
                print(String(data: data, encoding: .utf8) ?? "Données illisibles")
            }
        }

        task.resume()
    }
}
