//
//  SessionController.swift
//  Time
//
//  Created by Stéphane Bressani on 08.05.2025.
//

import Foundation

struct Session: Identifiable, Decodable {
    let id: Int
    let product_id: Int
    let started_at: Date
    let ended_at: Date
}

class SessionController {
    static func createSession(
        projectId: Int,
        startedAt: Date,
        endedAt: Date,
        commentaire: String? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let token = readToken(),
              let url = URL(string: "https://time.bressani.dev:3443/api/sessions") else {
            completion(.failure(NSError(domain: "SessionController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token ou URL invalide."])))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [
            "project_id": projectId,
            "started_at": ISO8601DateFormatter().string(from: startedAt),
            "ended_at": ISO8601DateFormatter().string(from: endedAt)
        ]
        if let commentaire = commentaire {
            body["commentaire"] = commentaire
        }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                let statusError = NSError(domain: "Invalid server response", code: 0, userInfo: nil)
                completion(.failure(statusError))
                return
            }
            
            print("📝 POST status: \(httpResponse.statusCode)")

            guard (200...299).contains(httpResponse.statusCode) else {
                let statusError = NSError(domain: "Invalid server response", code: 0, userInfo: nil)
                completion(.failure(statusError))
                return
            }

            completion(.success(()))
        }

        task.resume()
    }
}
