//
//  ProjectController.swift
//  Time
//
//  Created by Stéphane Bressani on 07.05.2025.
//

import Foundation


struct Project: Identifiable, Decodable {
    let id: Int
    let name: String
}


class ProjectController {
    static func fetchProjects(forCategoryId categoryId: Int, completion: @escaping ([Project]) -> Void) {
        guard let token = readToken(),
              let url = URL(string: "https://time.bressani.dev:3443/api/projects/\(categoryId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Erreur réseau projets : \(error?.localizedDescription ?? "inconnue")")
                return
            }

            if let decoded = try? JSONDecoder().decode([Project].self, from: data) {
                DispatchQueue.main.async {
                    completion(decoded)
                }
            } else {
                print("❌ Échec décodage projets")
                print(String(data: data, encoding: .utf8) ?? "Données illisibles")
            }
        }.resume()
    }
}
