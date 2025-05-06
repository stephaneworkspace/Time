//
//  TimeApp.swift
//  Time
//
//  Created by Stéphane Bressani on 06.05.2025.
//

import SwiftUI

@main
struct TimeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // On laisse la scène vide car on contrôle tout via AppDelegate
        Settings {
            EmptyView()
        }
    }
}
