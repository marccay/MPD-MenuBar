//
//  MPD_MenuBarApp.swift
//  MPD-MenuBar
//
//  Created by marc on 7/25/24.
//

import SwiftUI

@main
struct MPD_MenuBarApp: App {
    var body: some Scene {
        /*
        // Traditional Application Window
        WindowGroup {
            ContentView()
        }
        */
        
        // Launches Menu Bar Application
        MenuBarExtra("MPD-MenuBar", systemImage: "music.note.house") {
            AppMenu()
        }
        .menuBarExtraStyle(.window)
    }
}
