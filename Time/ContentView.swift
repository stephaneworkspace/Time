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
    
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    @State private var deleteErrorMessage: StringMessage? = nil

    struct StringMessage: Identifiable {
        var id: String { text }
        let text: String
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Picker("Catégorie", selection: $selectedCategoryId) {
                    ForEach(categories) { category in
                        Text(category.name).tag(category.id as Int?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                Button("+") {
                    showingAddCategory = true
                }
                Button("-") {
                    if let id = selectedCategoryId {
                        if readToken() != nil {
                            CategoryController.deleteCategory(id: id, completion: { decoded in
                                self.categories = decoded
                                self.selectedCategoryId = decoded.first?.id
                            }, onError: { errorMessage in
                                self.deleteErrorMessage = StringMessage(text: errorMessage)
                            })
                        }
                    }
                }
                .disabled(selectedCategoryId == nil)
            }
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
        .onAppear {
            if let token = readToken() {
                CategoryController.fetchCategories(token: token) { decoded in
                    self.categories = decoded
                    self.selectedCategoryId = decoded.first?.id
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            VStack(spacing: 20) {
                Text("Nouvelle catégorie")
                    .font(.headline)
                TextField("Nom de la catégorie", text: $newCategoryName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Créer") {
                    CategoryController.createCategory(named: newCategoryName) { decoded in
                        self.categories = decoded
                        self.selectedCategoryId = decoded.last?.id
                    }
                    newCategoryName = ""
                    showingAddCategory = false
                }

                Button("Annuler") {
                    showingAddCategory = false
                }
            }
            .frame(width: 300)
            .padding()
        }
        .alert(item: $deleteErrorMessage) { message in
            Alert(title: Text("Erreur"), message: Text(message.text), dismissButton: .default(Text("OK")))
        }
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
}
