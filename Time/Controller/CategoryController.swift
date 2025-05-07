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
    
    static func createCategory(named name: String, completion: @escaping ([Category]) -> Void) {
        guard let token = readToken(),
              let url = URL(string: "https://time.bressani.dev:3443/api/categories") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["name": name]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpRes = response as? HTTPURLResponse {
                print("📦 POST status: \(httpRes.statusCode)")
            }
            if let _ = data {
                DispatchQueue.main.async {
                    fetchCategories(token: token, completion: completion)
                }
            }
        }.resume()
    }

    static func deleteCategory(id: Int, completion: @escaping ([Category]) -> Void, onError: @escaping (String) -> Void) {
        guard let token = readToken(),
              let url = URL(string: "https://time.bressani.dev:3443/api/categories/\(id)") else { return }

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
                    fetchCategories(token: token, completion: completion)
                }
            }
        }.resume()
    }
}
