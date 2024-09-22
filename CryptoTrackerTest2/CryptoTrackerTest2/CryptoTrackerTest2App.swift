//
//  CryptoTrackerTest2App.swift
//  CryptoTrackerTest2
//
//  Created by Max Pintchouk on 9/19/24.
//

import SwiftUI
import SwiftData

@main
struct CryptoTrackerTest2App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: DataModel.self)
        }
    }
}
