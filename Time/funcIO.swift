//
//  funcIO.swift
//  Time
//
//  Created by Stéphane Bressani on 06.05.2025.
//

import Foundation

func readToken() -> String? {
    guard let fileURL = Bundle.main.url(forResource: "token", withExtension: "txt") else {
        print("❌ Fichier token.txt introuvable dans le bundle")
        return nil
    }

    do {
        let token = try String(contentsOf: fileURL, encoding: .utf8)
        return token.trimmingCharacters(in: .whitespacesAndNewlines)
    } catch {
        print("❌ Erreur lors de la lecture du token : \(error)")
        return nil
    }
}
