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

    var body: some View {
        VStack(spacing: 20) {
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
    }

    func startTimer() {
        startTime = Date()
        print("⏱️ Start at \(startTime!)")
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
            let duration = stopTime.timeIntervalSince(start)
            print("🛑 Stop at \(stopTime)")
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
