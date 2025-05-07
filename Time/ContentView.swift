//
//  ContentView.swift
//  Time
//
//  Created by Stéphane Bressani on 07.05.2025.
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

    @State private var projects: [Project] = []
    @State private var selectedProjectId: Int?

    @FocusState private var isTextFieldFocused: Bool
    
    @State private var showingEditCategory = false
    @State private var selectedCategory = Category(id: 0, name: "")
    
    @State private var showingAddProject = false

    struct StringMessage: Identifiable {
        var id: String { text }
        let text: String
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Picker("", selection: $selectedCategoryId) {
                    ForEach(categories) { category in
                        Text(category.name).tag(category.id as Int?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedCategoryId) { _, newValue in
                    if let id = newValue {
                        ProjectController.fetchProjects(forCategoryId: id) { decodedProjects in
                            self.projects = decodedProjects
                            self.selectedProjectId = decodedProjects.first?.id
                        }
                    }
                }
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
                Button("Édit") {
                    if let id = selectedCategoryId, let category = categories.first(where: { $0.id == id }) {
                        selectedCategory = category
                        showingEditCategory = true
                    }
                }
                .disabled(selectedCategoryId == nil)
            }
            HStack {
                if !projects.isEmpty {
                    Picker("", selection: $selectedProjectId) {
                        ForEach(projects) { project in
                            Text(project.name).tag(project.id as Int?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                } else {
                    Text("Aucun projet")
                        .foregroundColor(.gray)
                }
                Button("+") {
                    showingAddProject = true
                }
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
                    if let categoryId = decoded.first?.id {
                        ProjectController.fetchProjects(forCategoryId: categoryId) { decodedProjects in
                            self.projects = decodedProjects
                            self.selectedProjectId = decodedProjects.first?.id
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView(category: $selectedCategory) { newCategory in
                selectedCategory = newCategory
                categories.append(newCategory)
            }
        }
        .sheet(isPresented: $showingEditCategory) {
            EditCategoryView(category: $selectedCategory) { updatedCategory in
                if let index = categories.firstIndex(where: { $0.id == updatedCategory.id }) {
                    categories[index] = updatedCategory
                }
            }
        }
        .sheet(isPresented: $showingAddProject) {
            // let selectedCategoryName = categories.first(where: { $0.id == selectedCategoryId })?.name ?? ""
            AddProjectView(
                categoryId: selectedCategoryId ?? 0,
                defaultProjectName: ""
            ) { newProject in
                projects.append(newProject)
                selectedProjectId = newProject.id
            }
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
