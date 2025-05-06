//
//  AppDelegate.swift
//  Time
//
//  Created by Stéphane Bressani on 06.05.2025.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Crée l'icône dans la barre de menu
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "App")
            button.action = #selector(togglePopover(_:))
        }

        // Contenu de la popover
        let contentView = ContentView()

        popover = NSPopover()
        popover?.contentSize = NSSize(width: 300, height: 200)
        popover?.contentViewController = NSHostingController(rootView: contentView)
        popover?.behavior = .transient
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(sender)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover?.contentViewController?.view.window?.becomeKey()
            }
        }
    }
}
