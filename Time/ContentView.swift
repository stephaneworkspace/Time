//
//  ContentView.swift
//  Time
//
//  Created by Stéphane Bressani on 06.05.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var startTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var timerRunning = false
    @State private var timer: Timer?
    @State private var categories: [Category] = []
    @State private var selectedCategoryId: Int?

    var body: some View {
        VStack(spacing: 20) {
            Picker("Catégorie", selection: $selectedCategoryId) {
                ForEach(categories) { category in
                    Text(category.name).tag(category.id as Int?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()

            Text(formattedTime(from: elapsedTime))
                .font(.system(size: 48, weight: .bold, design: .monospaced))
            
            HStack {
                Button(action: startTimer) {
                    Text("Start")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(timerRunning)

                Button(action: stopTimer) {
                    Text("Stop")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!timerRunning)
            }

            Button("Quitter") {
                NSApplication.shared.terminate(nil)
            }
        }
        .frame(width: 300, height: 250)
        .padding()
        .onAppear { loadCategories() }
    }

    func startTimer() {
        startTime = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Europe/Zurich")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        print("⏱️ Start at \(formatter.string(from: startTime!))")
        timerRunning = true

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let start = startTime {
                elapsedTime = Date().timeIntervalSince(start)
            }
        }
    }

    func stopTimer() {
        if let start = startTime {
            let stopTime = Date()
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(identifier: "Europe/Zurich")
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            print("🛑 Stop at \(formatter.string(from: stopTime))")
            let duration = stopTime.timeIntervalSince(start)
            print("⏳ Duration: \(formattedTime(from: duration))")
        }

        timer?.invalidate()
        timer = nil
        timerRunning = false
        elapsedTime = 0
    }

    func formattedTime(from interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        let centiseconds = Int((interval - Double(totalSeconds)) * 100)

        return String(format: "%02d:%02d.%02d", minutes, seconds, centiseconds)
    }

    private func loadCategories() {
        if let token = readToken() {
            print("🔐 Token lu : \(token)")

            if let url = URL(string: "https://time.bressani.dev:3443/api/categories") {
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
                            self.categories = decoded
                            self.selectedCategoryId = decoded.first?.id
                        }
                    } else {
                        print("❌ Échec de décodage JSON")
                        print(String(data: data, encoding: .utf8) ?? "Données illisibles")
                    }
                }
                task.resume()
            }
        }
    }
}
