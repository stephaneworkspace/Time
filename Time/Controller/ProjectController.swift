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
    
    static func createProject(name: String, categoryId: Int, completion: @escaping (Project?) -> Void) {
        guard let token = readToken(),
              let url = URL(string: "https://time.bressani.dev:3443/api/projects") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "project": [
                "name": name,
                "category_id": categoryId
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("❌ Erreur création projet : \(error?.localizedDescription ?? "inconnue")")
                completion(nil)
                return
            }

            if let decoded = try? JSONDecoder().decode(Project.self, from: data) {
                DispatchQueue.main.async {
                    completion(decoded)
                }
            } else {
                print("❌ Échec décodage projet créé")
                print(String(data: data, encoding: .utf8) ?? "Données illisibles")
                completion(nil)
            }
        }.resume()
    }
    
    static func deleteProject(categoyId: Int, id: Int, completion: @escaping ([Project]) -> Void, onError: @escaping (String) -> Void) {
        guard let token = readToken(),
              let url = URL(string: "https://time.bressani.dev:3443/api/projects/\(id)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpRes = response as? HTTPURLResponse {
                print("🗑 DELETE status: \(httpRes.statusCode)")

                if httpRes.statusCode == 422, let data = data,
                   let responseDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = responseDict["error"] as? String {
                    DispatchQueue.main.async {
                        onError(message)
                    }
                    return
                }
                if httpRes.statusCode == 404, let data = data,
                   let responseDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = responseDict["error"] as? String {
                    DispatchQueue.main.async {
                        onError(message)
                    }
                    return
                }
            }

            if error == nil {
                DispatchQueue.main.async {
                    fetchProjects(forCategoryId: categoyId, completion: completion)
                }
            }
        }.resume()
    }
}
